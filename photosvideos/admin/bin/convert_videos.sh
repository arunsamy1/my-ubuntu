#!/usr/bin/env bash
# convert_videos.sh - Re-encode MPEG-4 Part 2 videos to H.264 for browser playback.
# Converts every *.mp4 in gallery_videos/ (recursively) that is not already H.264.
# Output files are saved alongside the originals with a _web.mp4 suffix.
# Safe to re-run: already-converted files are skipped.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VIDEOS_DIR="$ROOT_DIR/gallery_videos"

if [[ ! -d "$VIDEOS_DIR" ]]; then
  echo "Error: gallery_videos directory not found at $VIDEOS_DIR" >&2
  exit 1
fi

converted=0
skipped=0
already_done=0

while IFS= read -r -d '' src; do
  # Skip files that already have _web in the filename
  [[ "$(basename "$src")" == *_web* ]] && continue

  dst="${src%.mp4}_web.mp4"

  if [[ -f "$dst" ]]; then
    echo "SKIP (exists): $(basename "$dst")"
    (( already_done++ )) || true
    continue
  fi

  codec=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name -of csv=p=0 "$src" 2>/dev/null || echo "unknown")

  if [[ "$codec" == "h264" ]]; then
    echo "SKIP (already H.264): $(basename "$src")"
    (( skipped++ )) || true
    continue
  fi

  echo "Converting [$codec -> h264]: $(basename "$src")"
  ffmpeg -y -i "$src" \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    "$dst" \
    && echo "  -> $(basename "$dst")" \
    || { echo "  ERROR converting $(basename "$src")" >&2; rm -f "$dst"; }

  (( converted++ )) || true

done < <(find "$VIDEOS_DIR" -type f -iname "*.mp4" -print0 | sort -z)

echo ""
echo "Done. Converted: $converted  |  Skipped (H.264): $skipped  |  Already converted: $already_done"
