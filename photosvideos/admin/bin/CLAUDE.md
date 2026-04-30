# Photo Gallery Generator

## Overview

Two files in `/photosvideos/admin/bin/`:

- `generate_photo_gallery.sh` — bash script that reads a properties file and generates a static HTML photo gallery with one page per album
- `photo_gallery.properties` — INI-style config; one `[SectionName]` block per gallery

## Properties file format

```properties
[SectionName]
HTML_DIR=/absolute/path/to/output/    # required: where HTML files are written
GALLERY_DIR=/absolute/path/to/photos  # required: root folder of photo album subdirs
GALLERY_NAME=MyGallery                # optional: base name for index file (default: GALLERY_DIR basename)
```

- Multiple `[Section]` blocks are allowed; each generates an independent gallery
- Relative paths resolve relative to the script directory
- Lines starting with `#` and blank lines are ignored

## How the script works

1. Reads all `[Section]` headers from the properties file
2. For each section, calls `process_section` which:
   - Parses that section's key=value pairs
   - Resolves and validates `HTML_DIR` and `GALLERY_DIR`
   - Computes `GALLERY_REL` (relative path from `HTML_DIR` to `GALLERY_DIR` for use in HTML `href`/`src`)
   - Calls `generate_photos`
3. `generate_photos`:
   - Finds subdirectories of `GALLERY_DIR` that contain images (jpg, jpeg, png, gif, webp, avif)
   - Also collects unsorted images directly in `GALLERY_DIR`
   - Writes `index.html` into each album subfolder (alongside the photos)
   - Writes an index page `{GALLERY_NAME}.html` in `HTML_DIR` with cover thumbnails linking to each album page
   - Cover image for each album is the first photo alphabetically (found safely via `while`+`break` to avoid SIGPIPE under `set -o pipefail`)
   - Unsorted images (directly in `GALLERY_DIR`) appear on the index page
   - Removes stale paginated files from previous runs (`{GALLERY_NAME}_2.html`, etc.)

## Output structure

```
HTML_DIR/
  {GALLERY_NAME}.html          ← index: album grid, each card links to album page

GALLERY_DIR/
  {album_name}/
    index.html                 ← album page (lives alongside photos); back link → index
    photo1.jpg …
```

## Key globals used by helpers

`emit_image`, `emit_image_section`, and `generate_photos` all read these globals set by `process_section` (bash dynamic scoping via `local`):

| Variable | Purpose |
|---|---|
| `HTML_DIR` | Absolute path where HTML files land |
| `GALLERY_DIR` | Absolute path to photo source |
| `GALLERY_REL` | Relative path from `HTML_DIR` → `GALLERY_DIR` |
| `GALLERY_NAME` | Base filename for the index page |
| `OUTPUT` | Set per-page inside `generate_photos`; current output file path |

## Adding a new gallery

Append a new block to `photo_gallery.properties`:

```properties
[Europe]
HTML_DIR=/photosvideos/Europe_HTML/
GALLERY_DIR=/photosvideos/Europe
GALLERY_NAME=Europe
```

Then run:

```bash
bash /photosvideos/admin/bin/generate_photo_gallery.sh
```
