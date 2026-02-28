#!/usr/bin/env bash

set -euo pipefail

# Cancel on ESC / right click -> slurp exits nonzero -> whole script exits
region="$(slurp)" || exit 0

img="$(mktemp --suffix=.png)"
trap 'rm -f "$img"' EXIT

grim -g "$region" "$img"

content="$(
  tesseract "$img" stdout \
    --oem 1 \
    --psm 6 \
    -c load_system_dawg=1 \
    -c load_freq_dawg=1 \
    -c tessedit_char_blacklist="¦" \
    2>/dev/null
)"

# trim (optional): drop trailing whitespace/newlines
content="$(printf "%s" "$content" | sed -e 's/[[:space:]]\+$//')"

test -z "$content" && exit 0

printf "%s" "$content" | wl-copy
