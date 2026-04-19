#!/usr/bin/env bash
# generate_video_gallery.sh - Generate paginated video gallery.
# Videos : index_videos.html, index_videos_2.html, ...
# 10 albums per page.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

VIDEOS_DIR="gallery_videos"
ALBUMS_PER_PAGE=4

# ---------------------------------------------------------------------------
# Cell helpers  (OUTPUT must be set by caller)
# ---------------------------------------------------------------------------
emit_video() {
  local rel="$1" label
  label="$(basename "$rel" | sed 's/\.[^.]*$//; s/_web$//')"
  cat >> "$OUTPUT" <<CELL
    <div class="video-cell">
      <video controls preload="metadata" src="$rel" title="$label"
        onloadedmetadata="this.currentTime=0.5"
        onplay="this.onplay=null;this.currentTime=0"></video>
      <span class="video-label">$label</span>
    </div>
CELL
}

emit_video_section() {
  local heading="$1"; shift
  local -a files=("$@")
  [[ ${#files[@]} -eq 0 ]] && return
  printf '  <h2>%s</h2>\n' "$heading" >> "$OUTPUT"
  echo '  <div class="grid video-grid">' >> "$OUTPUT"
  for f in "${files[@]}"; do emit_video "$f"; done
  echo '  </div>' >> "$OUTPUT"
}

# ---------------------------------------------------------------------------
# Filename helpers
# ---------------------------------------------------------------------------
video_file()  { [[ $1 -eq 1 ]] && echo "index_videos.html" || echo "index_videos_${1}.html"; }

# ---------------------------------------------------------------------------
# Pagination nav
# ---------------------------------------------------------------------------
# write_pagination CUR TOTAL PREV_HREF NEXT_HREF OTHER_LABEL OTHER_HREF [EXTRA_CLASS]
write_pagination() {
  local cur="$1" total="$2" prev_href="$3" next_href="$4" other_label="$5" other_href="$6"
  local extra_class="${7:-}"
  {
    echo "<nav class=\"pager${extra_class:+ $extra_class}\">"
    echo "  <a href=\"$other_href\">$other_label</a>"
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

VIDEO_STYLE='
    .grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 0.75rem;
    }
    .video-cell { display: flex; flex-direction: column; background: #1a1a1a; border-radius: 4px; overflow: hidden; }
    .video-cell video { width: 100%; aspect-ratio: 16/9; background: #000; display: block; }
    .video-label { font-size: 0.75rem; color: #888; padding: 0.4rem 0.5rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }'

# ---------------------------------------------------------------------------
# Generate video gallery pages
# ---------------------------------------------------------------------------
generate_videos() {
  if [[ ! -d "$VIDEOS_DIR" ]]; then
    echo "Warning: $VIDEOS_DIR not found, skipping video gallery." >&2
    return
  fi

  # Collect video albums (any mp4, including _web)
  local video_albums=()
  while IFS= read -r -d '' d; do
    local count
    count=$(find "$d" -maxdepth 1 -type f -iname "*.mp4" | wc -l)
    [[ $count -gt 0 ]] && video_albums+=("$d")
  done < <(find "$VIDEOS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  local total=${#video_albums[@]}
  if [[ $total -eq 0 ]]; then
    echo "Warning: no videos found in $VIDEOS_DIR" >&2
    return
  fi

  local total_pages=$(( (total + ALBUMS_PER_PAGE - 1) / ALBUMS_PER_PAGE ))

  # Remove stale pages from previous runs
  local n=2
  while true; do
    local stale="$(video_file $n)"
    [[ ! -f "$stale" ]] && break
    [[ $n -gt $total_pages ]] && { rm -f "$stale"; echo "Removed stale: $(basename "$stale")"; }
    (( n++ ))
  done

  for (( page=1; page<=total_pages; page++ )); do
    OUTPUT="$(video_file $page)"
    local prev_href="" next_href=""
    [[ $page -gt 1 ]]            && prev_href="$(video_file $((page-1)))"
    [[ $page -lt $total_pages ]] && next_href="$(video_file $((page+1)))"

    # Head
    cat > "$OUTPUT" <<HTMLHEAD
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Video Gallery — Page $page of $total_pages</title>
  <style>$SHARED_STYLE
$VIDEO_STYLE
  </style>
</head>
<body>
<h1>Video Gallery</h1>
HTMLHEAD

    write_pagination "$page" "$total_pages" "$prev_href" "$next_href" \
      "&#128247; Photo Gallery" "index.html"

    # Albums for this page
    local start=$(( (page-1) * ALBUMS_PER_PAGE ))
    local end=$(( start + ALBUMS_PER_PAGE ))
    [[ $end -gt $total ]] && end=$total

    for (( i=start; i<end; i++ )); do
      local vdir="${video_albums[$i]}"
      local vname heading videos=()
      vname="$(basename "$vdir")"
      heading="$(printf '%s' "$vname" | sed 's/_/ /g')"
      # Prefer _web.mp4 over original; if only _web files exist, use them directly
      local seen=()
      while IFS= read -r -d '' f; do
        local base; base="$(basename "$f")"
        [[ "$base" == *_web* ]] && continue  # handled via originals or below
        local web="${f%.mp4}_web.mp4"
        if [[ -f "$web" ]]; then
          videos+=("gallery_videos/${vname}/$(basename "$web")")
        else
          videos+=("gallery_videos/${vname}/$base")
        fi
        seen+=("$(basename "$web")")
      done < <(find "$vdir" -maxdepth 1 -type f -iname "*.mp4" -print0 | sort -z)
      # Add _web files that have no corresponding original
      while IFS= read -r -d '' f; do
        local base; base="$(basename "$f")"
        [[ ! "$base" == *_web* ]] && continue
        local already=0
        for s in "${seen[@]+"${seen[@]}"}"; do [[ "$s" == "$base" ]] && already=1 && break; done
        [[ $already -eq 0 ]] && videos+=("gallery_videos/${vname}/$base")
      done < <(find "$vdir" -maxdepth 1 -type f -iname "*.mp4" -print0 | sort -z)
      emit_video_section "$heading" "${videos[@]+"${videos[@]}"}"
    done

    # Foot
    write_pagination "$page" "$total_pages" "$prev_href" "$next_href" \
      "&#128247; Photo Gallery" "index.html" "pager-bottom"
    cat >> "$OUTPUT" <<'HTMLFOOT'
<footer>Generated by generate_video_gallery.sh</footer>
</body>
</html>
HTMLFOOT

    echo "Video gallery page $page/$total_pages written to $(video_file $page)"
  done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
generate_videos
