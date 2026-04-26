#!/usr/bin/env bash
# generate_photo_gallery.sh - Generate paginated photo gallery.
# Photos : index.html, index_2.html, index_3.html, ...
# 10 albums per page.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Properties file
# ---------------------------------------------------------------------------
PROPS_FILE="$SCRIPT_DIR/photo_gallery.properties"
if [[ ! -f "$PROPS_FILE" ]]; then
  echo "Error: properties file not found at $PROPS_FILE" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Cell helpers  (OUTPUT must be set by caller)
# ---------------------------------------------------------------------------
emit_image() {
  local rel="$1" alt
  alt="$(basename "$rel" | sed 's/\.[^.]*$//')"
  echo "    <a href=\"$rel\"><img src=\"$rel\" alt=\"$alt\" loading=\"lazy\"></a>" >> "$OUTPUT"
}

emit_image_section() {
  local heading="$1"; shift
  local -a files=("$@")
  [[ ${#files[@]} -eq 0 ]] && return
  printf '  <h2>%s</h2>\n' "$heading" >> "$OUTPUT"
  echo '  <div class="grid">' >> "$OUTPUT"
  for f in "${files[@]}"; do emit_image "$f"; done
  echo '  </div>' >> "$OUTPUT"
}

# ---------------------------------------------------------------------------
# Filename helpers
# ---------------------------------------------------------------------------
photo_file()  { [[ $1 -eq 1 ]] && echo "${HTML_DIR}/${GALLERY_NAME}.html" || echo "${HTML_DIR}/${GALLERY_NAME}_${1}.html"; }

# ---------------------------------------------------------------------------
# Pagination nav
# ---------------------------------------------------------------------------
# write_pagination CUR TOTAL PREV_HREF NEXT_HREF [EXTRA_CLASS]
write_pagination() {
  local cur="$1" total="$2" prev_href="$3" next_href="$4"
  local extra_class="${5:-}"
  {
    echo "<nav class=\"pager${extra_class:+ $extra_class}\">"
    echo '  <span class="page-nav">'
    if [[ -n "$prev_href" ]]; then
      echo "    <a href=\"$prev_href\">&larr; Prev</a>"
    else
      echo '    <span class="off">&larr; Prev</span>'
    fi
    echo "    <span>Page $cur of $total</span>"
    if [[ -n "$next_href" ]]; then
      echo "    <a href=\"$next_href\">Next &rarr;</a>"
    else
      echo '    <span class="off">Next &rarr;</span>'
    fi
    echo '  </span>'
    echo '</nav>'
  } >> "$OUTPUT"
}

# ---------------------------------------------------------------------------
# Shared CSS
# ---------------------------------------------------------------------------
SHARED_STYLE='
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: sans-serif; background: #111; color: #eee; padding: 2rem; }
    h1 { text-align: center; margin-bottom: 1.5rem; font-size: 1.8rem; letter-spacing: 0.05em; }
    h2 { font-size: 1.1rem; margin: 2rem 0 0.75rem; color: #aaa; border-bottom: 1px solid #333; padding-bottom: 0.4rem; }
    .pager {
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 1.5rem; gap: 1rem; flex-wrap: wrap;
    }
    .pager-bottom { margin-top: 4rem; }
    .pager a { color: #88aaff; text-decoration: none; font-size: 0.9rem; }
    .pager a:hover { text-decoration: underline; }
    .page-nav { display: flex; gap: 1rem; align-items: center; font-size: 0.9rem; }
    .off { color: #555; }
    footer { text-align: center; margin-top: 3rem; font-size: 0.75rem; color: #555; }'

PHOTO_STYLE='
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 0.75rem;
    }
    .grid a { display: block; overflow: hidden; border-radius: 4px; background: #222; aspect-ratio: 4/3; }
    .grid a img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.2s ease; }
    .grid a:hover img { transform: scale(1.05); }
    .grid a:focus { outline: 2px solid #88aaff; }'

# ---------------------------------------------------------------------------
# Generate photo gallery pages
# ---------------------------------------------------------------------------
generate_photos() {
  # Collect albums that have images
  local photo_albums=()
  while IFS= read -r -d '' d; do
    local count
    count=$(find "$d" -maxdepth 1 -type f \
      \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
         -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) | wc -l)
    [[ $count -gt 0 ]] && photo_albums+=("$d")
  done < <(find "$GALLERY_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  # Unsorted images directly in gallery/
  local top_images=()
  while IFS= read -r -d '' f; do top_images+=("$GALLERY_REL/$(basename "$f")"); done \
    < <(find "$GALLERY_DIR" -maxdepth 1 -type f \
          \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
             -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) \
          -print0 | sort -z)
  [[ ${#top_images[@]} -gt 0 ]] && photo_albums+=("__unsorted__")

  local total=${#photo_albums[@]}
  if [[ $total -eq 0 ]]; then
    echo "Warning: no photos found in $GALLERY_DIR" >&2
    return
  fi

  local total_pages=$(( (total + ALBUMS_PER_PAGE - 1) / ALBUMS_PER_PAGE ))

  # Remove stale pages from previous runs
  local n=2
  while true; do
    local stale="$(photo_file $n)"
    [[ ! -f "$stale" ]] && break
    [[ $n -gt $total_pages ]] && { rm -f "$stale"; echo "Removed stale: $(basename "$stale")"; }
    (( n++ ))
  done

  for (( page=1; page<=total_pages; page++ )); do
    OUTPUT="$(photo_file $page)"
    local prev_href="" next_href=""
    [[ $page -gt 1 ]]            && prev_href="$(basename "$(photo_file $((page-1)))")"
    [[ $page -lt $total_pages ]] && next_href="$(basename "$(photo_file $((page+1)))")"

    # Head
    cat > "$OUTPUT" <<HTMLHEAD
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Photo Gallery — Page $page of $total_pages</title>
  <style>$SHARED_STYLE
$PHOTO_STYLE
  </style>
</head>
<body>
<h1>Photo Gallery</h1>
HTMLHEAD

    write_pagination "$page" "$total_pages" "$prev_href" "$next_href"

    # Albums for this page
    local start=$(( (page-1) * ALBUMS_PER_PAGE ))
    local end=$(( start + ALBUMS_PER_PAGE ))
    [[ $end -gt $total ]] && end=$total

    for (( i=start; i<end; i++ )); do
      local album_dir="${photo_albums[$i]}"
      if [[ "$album_dir" == "__unsorted__" ]]; then
        emit_image_section "Unsorted" "${top_images[@]}"
      else
        local album_name heading images=()
        album_name="$(basename "$album_dir")"
        heading="$(printf '%s' "$album_name" | sed 's/_/ /g')"
        while IFS= read -r -d '' f; do images+=("$GALLERY_REL/${album_name}/$(basename "$f")"); done \
          < <(find "$album_dir" -maxdepth 1 -type f \
                \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
                   -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) \
                -print0 | sort -z)
        emit_image_section "$heading" "${images[@]+"${images[@]}"}"
      fi
    done

    # Foot
    write_pagination "$page" "$total_pages" "$prev_href" "$next_href" "pager-bottom"
    cat >> "$OUTPUT" <<'HTMLFOOT'
<footer>Generated by generate_photo_gallery.sh</footer>
</body>
</html>
HTMLFOOT

    echo "Photo gallery page $page/$total_pages written to $(photo_file $page)"
  done
}

# ---------------------------------------------------------------------------
# Process one gallery section from the properties file
# ---------------------------------------------------------------------------
process_section() {
  local section="$1"
  local HTML_DIR="" GALLERY_DIR="" GALLERY_NAME="" ALBUMS_PER_PAGE=10
  local GALLERY_REL in_section=0 line key value

  while IFS= read -r line; do
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      [[ "${BASH_REMATCH[1]}" == "$section" ]] && in_section=1 || in_section=0
      continue
    fi
    [[ $in_section -eq 0 ]] && continue
    [[ "$line" =~ ^[[:space:]]*# || -z "${line// }" ]] && continue
    key="${line%%=*}"; key="${key// /}"
    value="${line#*=}"; value="${value// /}"
    case "$key" in
      HTML_DIR)        HTML_DIR="$value" ;;
      GALLERY_DIR)     GALLERY_DIR="$value" ;;
      GALLERY_NAME)    GALLERY_NAME="$value" ;;
      ALBUMS_PER_PAGE) ALBUMS_PER_PAGE="$value" ;;
    esac
  done < "$PROPS_FILE"

  if [[ -z "$HTML_DIR" || -z "$GALLERY_DIR" ]]; then
    echo "Error: [$section] missing HTML_DIR or GALLERY_DIR — skipping" >&2
    return 0
  fi

  [[ "$HTML_DIR"    != /* ]] && HTML_DIR="$SCRIPT_DIR/$HTML_DIR"
  [[ "$GALLERY_DIR" != /* ]] && GALLERY_DIR="$SCRIPT_DIR/$GALLERY_DIR"

  if [[ ! -d "$GALLERY_DIR" ]]; then
    echo "Warning: [$section] gallery directory not found at $GALLERY_DIR — skipping" >&2
    return 0
  fi

  mkdir -p "$HTML_DIR"
  GALLERY_REL="$(realpath --relative-to="$HTML_DIR" "$GALLERY_DIR")"
  : "${GALLERY_NAME:="$(basename "$GALLERY_DIR")"}"

  echo "--- [$section] ---"
  generate_photos
}

# ---------------------------------------------------------------------------
# Main: collect all [Section] headers and process each
# ---------------------------------------------------------------------------
sections=()
while IFS= read -r line; do
  [[ "$line" =~ ^\[(.+)\]$ ]] && sections+=("${BASH_REMATCH[1]}")
done < "$PROPS_FILE"

if [[ ${#sections[@]} -eq 0 ]]; then
  echo "Error: no [SectionName] headers found in $PROPS_FILE" >&2
  echo "Add a [GalleryName] header before each set of parameters." >&2
  exit 1
fi

for section in "${sections[@]}"; do
  process_section "$section"
done
