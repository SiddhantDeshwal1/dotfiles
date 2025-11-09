#!/bin/bash
# Clipboard menu with multiline preview

# List history (strip ID, keep readable formatting)
CLIP_ITEMS=$(cliphist list | awk '{$1=""; print substr($0,2)}' \
    | sed 's/\\n/  ⏎  /g' | fold -s -w 80)

# Show Rofi menu
SELECTED=$(echo "$CLIP_ITEMS" | rofi -dmenu -i -p "Clipboard:" \
    -theme ~/.config/rofi/themes/rofi-cliphist.rasi)

# Copy full original entry if selected
if [ -n "$SELECTED" ]; then
    ID=$(cliphist list | grep -F "$SELECTED" | head -n 1 | awk '{print $1}')
    cliphist decode "$ID" | wl-copy
fi
