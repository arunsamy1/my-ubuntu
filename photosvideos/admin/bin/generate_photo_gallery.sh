#!/usr/bin/env bash
# generate_photo_gallery.sh - Generate a static HTML photo gallery.
# Produces one page per album plus an index page.

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
# Image helpers  (OUTPUT must be set by caller)
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
# Shared CSS
# ---------------------------------------------------------------------------
SHARED_STYLE='
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: sans-serif; background: #111; color: #eee; padding: 2rem; }
    h1 { text-align: center; margin-bottom: 1.5rem; font-size: 1.8rem; letter-spacing: 0.05em; }
    h2 { font-size: 1.1rem; margin: 2rem 0 0.75rem; color: #aaa; border-bottom: 1px solid #333; padding-bottom: 0.4rem; }
    .back-nav { margin-bottom: 1.5rem; }
    .back-nav a { color: #88aaff; text-decoration: none; font-size: 0.9rem; }
    .back-nav a:hover { text-decoration: underline; }
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

INDEX_STYLE='
    .album-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 1rem;
    }
    .album-grid a {
      display: block; text-decoration: none; color: #eee;
      background: #222; border-radius: 6px; overflow: hidden;
    }
    .album-grid a img { width: 100%; aspect-ratio: 4/3; object-fit: cover; display: block; transition: transform 0.2s ease; }
    .album-grid a:hover img { transform: scale(1.05); }
    .album-grid .caption { padding: 0.5rem 0.75rem; font-size: 0.9rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }'

# ---------------------------------------------------------------------------
# Generate gallery: one HTML page per album + an index page
# ---------------------------------------------------------------------------
generate_photos() {
  # Collect subdirectories that contain images
  local photo_albums=()
  while IFS= read -r -d '' d; do
    local count
    count=$(find "$d" -maxdepth 1 -type f \
      \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
         -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) | wc -l)
    [[ $count -gt 0 ]] && photo_albums+=("$d")
  done < <(find "$GALLERY_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  # Images sitting directly in GALLERY_DIR (unsorted)
  local top_images=()
  while IFS= read -r -d '' f; do
    top_images+=("$GALLERY_REL/$(basename "$f")")
  done < <(find "$GALLERY_DIR" -maxdepth 1 -type f \
              \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
                 -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) \
              -print0 | sort -z)

  if [[ ${#photo_albums[@]} -eq 0 && ${#top_images[@]} -eq 0 ]]; then
    echo "Warning: no photos found in $GALLERY_DIR" >&2
    return
  fi

  # Remove stale paginated files left by previous script versions
  local n=2
  while true; do
    local stale="${HTML_DIR}/${GALLERY_NAME}_${n}.html"
    [[ ! -f "$stale" ]] && break
    rm -f "$stale"
    echo "Removed stale: $(basename "$stale")"
    (( n++ ))
  done

  local index_page="${HTML_DIR}/${GALLERY_NAME}.html"

  # ---- Individual album pages (written into each album's own subfolder) ----
  for album_dir in "${photo_albums[@]}"; do
    local album_name heading images=() back_href
    album_name="$(basename "$album_dir")"
    heading="$(printf '%s' "$album_name" | sed 's/_/ /g')"
    back_href="$(realpath --relative-to="$album_dir" "$index_page")"

    while IFS= read -r -d '' f; do
      images+=("$(basename "$f")")
    done < <(find "$album_dir" -maxdepth 1 -type f \
                \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
                   -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) \
                -print0 | sort -z)

    OUTPUT="${album_dir}/index.html"
    cat > "$OUTPUT" <<HTMLHEAD
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$heading</title>
  <style>$SHARED_STYLE
$PHOTO_STYLE
  </style>
</head>
<body>
<nav class="back-nav"><a href="$back_href">&#8592; Back to Gallery</a></nav>
<h1>$heading</h1>
<div class="grid">
HTMLHEAD

    for f in "${images[@]+"${images[@]}"}"; do emit_image "$f"; done
    cat >> "$OUTPUT" <<'HTMLFOOT'
</div>
<footer>Generated by generate_photo_gallery.sh</footer>
</body>
</html>
HTMLFOOT
    echo "  Album page: ${album_name}/index.html (${#images[@]} photos)"
  done

  # ---- Index page ----
  OUTPUT="$index_page"
  cat > "$OUTPUT" <<HTMLHEAD
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Photo Gallery</title>
  <style>$SHARED_STYLE
$INDEX_STYLE
$PHOTO_STYLE
  </style>
</head>
<body>
<h1>Photo Gallery</h1>
HTMLHEAD

  if [[ ${#photo_albums[@]} -gt 0 ]]; then
    echo '<div class="album-grid">' >> "$OUTPUT"
    for album_dir in "${photo_albums[@]}"; do
      local album_name heading cover_img="" cover_rel
      album_name="$(basename "$album_dir")"
      heading="$(printf '%s' "$album_name" | sed 's/_/ /g')"
      while IFS= read -r -d '' f; do cover_img="$f"; break; done \
        < <(find "$album_dir" -maxdepth 1 -type f \
              \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
                 -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) \
              -print0 | sort -z)
      cover_rel="$GALLERY_REL/${album_name}/$(basename "$cover_img")"
      {
        echo "  <a href=\"$GALLERY_REL/${album_name}/index.html\">"
        echo "    <img src=\"$cover_rel\" alt=\"$heading\" loading=\"lazy\">"
        echo "    <div class=\"caption\">$heading</div>"
        echo "  </a>"
      } >> "$OUTPUT"
    done
    echo '</div>' >> "$OUTPUT"
  fi

  # Unsorted images appear directly on the index page
  [[ ${#top_images[@]} -gt 0 ]] && emit_image_section "Unsorted" "${top_images[@]}"

  cat >> "$OUTPUT" <<'HTMLFOOT'
<footer>Generated by generate_photo_gallery.sh</footer>
</body>
</html>
HTMLFOOT
  echo "  Index page:  $(basename "$OUTPUT")"
}

# ---------------------------------------------------------------------------
# Process one gallery section from the properties file
# ---------------------------------------------------------------------------
process_section() {
  local section="$1"
  local HTML_DIR="" GALLERY_DIR="" GALLERY_NAME=""
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
      HTML_DIR)     HTML_DIR="$value" ;;
      GALLERY_DIR)  GALLERY_DIR="$value" ;;
      GALLERY_NAME) GALLERY_NAME="$value" ;;
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
