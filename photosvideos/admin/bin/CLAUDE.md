# Photo Gallery Generator

## Overview

Two files in `/photosvideos/admin/bin/`:

- `generate_photo_gallery.sh` — bash script that reads a properties file and generates paginated static HTML photo galleries
- `photo_gallery.properties` — INI-style config; one `[SectionName]` block per gallery

## Properties file format

```properties
[SectionName]
HTML_DIR=/absolute/path/to/output/    # required: where HTML files are written
GALLERY_DIR=/absolute/path/to/photos  # required: root folder of photo album subdirs
GALLERY_NAME=MyGallery                # optional: base name for HTML files (default: GALLERY_DIR basename)
ALBUMS_PER_PAGE=10                    # optional: album sections per page (default: 10)
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
   - Paginates albums into pages of `ALBUMS_PER_PAGE` sections
   - Writes `{GALLERY_NAME}.html`, `{GALLERY_NAME}_2.html`, … into `HTML_DIR`
   - Removes stale pages from previous runs if page count shrank
   - Each page includes top/bottom pagination nav with a link to `index_videos.html`

## Key globals used by helpers

`photo_file`, `emit_image`, `emit_image_section`, `write_pagination`, and `generate_photos` all read these globals set by `process_section` (bash dynamic scoping via `local`):

| Variable | Purpose |
|---|---|
| `HTML_DIR` | Absolute path where HTML files land |
| `GALLERY_DIR` | Absolute path to photo source |
| `GALLERY_REL` | Relative path from `HTML_DIR` → `GALLERY_DIR` |
| `GALLERY_NAME` | Base filename for generated pages |
| `ALBUMS_PER_PAGE` | Albums per page |
| `OUTPUT` | Set inside `generate_photos` loop; current page file path |

## Adding a new gallery

Append a new block to `photo_gallery.properties`:

```properties
[Europe]
HTML_DIR=/photosvideos/Europe_HTML/
GALLERY_DIR=/photosvideos/Europe
GALLERY_NAME=Europe
ALBUMS_PER_PAGE=5
```

Then run:

```bash
bash /photosvideos/admin/bin/generate_photo_gallery.sh
```
