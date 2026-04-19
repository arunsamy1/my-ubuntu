#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROPERTIES_FILE="$SCRIPT_DIR/webscrapbook.properties"
OUTPUT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PARENT_INDEX="$OUTPUT_DIR/index.html"

# --- Validate properties file ---
if [ ! -f "$PROPERTIES_FILE" ]; then
    echo "ERROR: Properties file not found: $PROPERTIES_FILE" >&2
    exit 1
fi

# --- HTML-escape a string: & < > " ---
escape_html() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    echo "$s"
}

# --- Extract title from an HTML file, handling multi-line tags.
#     Falls back to <h1>, then <h2>. ---
extract_title() {
    local file="$1"
    local title=""
    local oneline
    oneline=$(tr '\n' ' ' < "$file")

    for tag in title h1 h2; do
        title=$(echo "$oneline" | grep -oi "<${tag}[^>]*>[^<]*</${tag}>" \
            | sed -e "s/<${tag}[^>]*>//i" -e "s/<\/${tag}>//i" \
            | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
            | head -1)
        [ -n "$title" ] && break
    done

    echo "$title"
}

# --- Parse properties file: return all values for a given key ---
get_property_values() {
    local key="$1"
    grep -E "^[[:space:]]*${key}[[:space:]]*=" "$PROPERTIES_FILE" \
        | sed -e "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//" \
              -e 's/[[:space:]]*$//' \
              -e '/^#/d' \
              -e '/^$/d'
}

# --- Resolve a path: absolute as-is, relative resolved against SCRIPT_DIR ---
resolve_path() {
    local p="$1"
    if [[ "$p" = /* ]]; then
        echo "$p"
    else
        echo "$SCRIPT_DIR/$p"
    fi
}

echo "Properties : $PROPERTIES_FILE"
echo "Output dir : $OUTPUT_DIR"
echo ""

# Accumulate entries in a temp file so count is known before writing the header
TEMP_ENTRIES=$(mktemp)
trap 'rm -f "$TEMP_ENTRIES"' EXIT

count=0

while IFS= read -r raw_dir; do
    source_dir=$(resolve_path "$raw_dir")

    if [ ! -d "$source_dir" ]; then
        echo "WARNING: source_dir does not exist, skipping: $source_dir" >&2
        continue
    fi

    while IFS= read -r -d '' dir; do
        # Compute path relative to the output directory for HTML linking
        rel_path=$(realpath --relative-to="$OUTPUT_DIR" "$dir")
        index_file="$dir/index.html"

        if [ -f "$index_file" ]; then
            title=$(extract_title "$index_file")
            title=$(echo "$title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

            if [ -z "$title" ]; then
                safe_title=$(escape_html "$(basename "$dir")")
                title_class=" no-title"
            else
                safe_title=$(escape_html "$title")
                title_class=""
            fi

            safe_rel_path=$(escape_html "$rel_path")

            cat >> "$TEMP_ENTRIES" << ENTRY
        <li class="folder-item">
            <a href="${safe_rel_path}/index.html" class="folder-link${title_class}">${safe_title}</a>
            <div class="folder-path">Folder: ${safe_rel_path}</div>
        </li>
ENTRY

            echo "Processed: $rel_path - Title: '$title'"
            ((++count))
        else
            echo "Skipping $(basename "$dir"): No index.html found"
        fi
    done < <(find "$source_dir" -maxdepth 1 -type d -name "[0-9]*" -print0 | sort -z)

done < <(get_property_values "source_dir")

GENERATED_ON=$(date)

cat > "$PARENT_INDEX" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Folders Index</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }
        .folder-list {
            list-style-type: none;
            padding: 0;
        }
        .folder-item {
            margin-bottom: 15px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .folder-item:hover {
            background-color: #f0f0f0;
            border-color: #999;
        }
        .folder-link {
            text-decoration: none;
            color: #0066cc;
            font-weight: bold;
            font-size: 1.1em;
        }
        .folder-link:hover {
            color: #004499;
            text-decoration: underline;
        }
        .folder-path {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        }
        .no-title {
            color: #999;
            font-style: italic;
        }
        .count {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 20px;
        }
        .footer {
            margin-top: 30px;
            color: #999;
            font-size: 0.8em;
            text-align: center;
            border-top: 1px solid #eee;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <h1>All Folders Index</h1>
    <div class="count">Total folders found: $count</div>
    <ul class="folder-list">
EOF

cat "$TEMP_ENTRIES" >> "$PARENT_INDEX"

cat >> "$PARENT_INDEX" << EOF
    </ul>
    <div class="footer">Generated on $GENERATED_ON</div>
</body>
</html>
EOF

echo ""
echo "========================================="
echo "index.html created successfully!"
echo "Total folders processed: $count"
echo "File created: $PARENT_INDEX"
echo "========================================="
