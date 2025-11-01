#!/bin/bash
# Clipboard menu using cliphist and rofi

# Get clipboard history
CLIP_ITEMS=$(cliphist)  # or cliphist -l to list

# Show Rofi menu
SELECTED=$(echo "$CLIP_ITEMS" | rofi -dmenu -i -p "Clipboard:")

# Copy selection back to clipboard
if [ -n "$SELECTED" ]; then
    echo "$SELECTED" | wl-copy  # Wayland
    # echo "$SELECTED" | xclip -selection clipboard  # X11 alternative
fi
