#!/bin/sh
set -e
# Keep the bundled (stock) translation files in the data directory in sync with the image.
# On the first start and whenever the image ships different translations, the stock files are
# overwritten; any of them that differ from the new version are backed up first to
# <data>/translations/backup/<timestamp>/. Files with other names (your own languages) are never touched.
SRC=/opt/docs-hub/translations
DST="$DOCS_HUB_DATA_DIR/translations"
STAMP="$DST/.bundled-hash"
mkdir -p "$DST"
NEW=$(cat "$SRC"/*.yaml | sha256sum | cut -d' ' -f1)
if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "$NEW" ]; then
  BACKUP="$DST/backup/$(date +%Y%m%d-%H%M%S)"
  for f in "$SRC"/*.yaml; do
    name=$(basename "$f")
    if [ -f "$DST/$name" ] && ! cmp -s "$f" "$DST/$name"; then
      mkdir -p "$BACKUP"
      cp "$DST/$name" "$BACKUP/$name"
    fi
    cp -f "$f" "$DST/$name"
  done
  echo "$NEW" > "$STAMP"
fi
exec docs-hub "$@"
