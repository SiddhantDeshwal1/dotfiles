#!/bin/bash
# wofi-emoji.sh

# Path to your emoji list file (each line: "emoji description")
EMOJI_LIST="${HOME}/.local/share/emoji.txt"

# If you don't have one, you can generate a simple version:
# emojis=("😀 grinning face" "😂 joy" "🥰 smiling face with hearts" "🔥 fire")
# printf "%s\n" "${emojis[@]}" > "$EMOJI_LIST"

SELECTED=$(cat "$EMOJI_LIST" | wofi --dmenu --prompt "Emoji:")

if [ -n "$SELECTED" ]; then
    EMOJI=$(echo "$SELECTED" | awk '{print $1}')  # extract the emoji itself
    echo -n "$EMOJI" | wl-copy
    notify-send "Copied emoji" "$EMOJI"
fi
