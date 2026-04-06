#!/bin/bash

# 1. Freeze screen and wait for your selection
geom=$(slurp)

# 2. If you hit Escape (empty selection), die instantly
[[ -z "$geom" ]] && exit 0

# 3. The Zero-Latency Pipeline
# grim captures the area and pipes it directly (-) into swappy's memory (-)
# The '&' sends this entire process to the background so the script exits in ~1ms.
grim -g "$geom" - | swappy -f - &

# 4. Asynchronous UI feedback (Runs parallel, does not slow down the capture)
notify-send -h string:x-canonical-private-synchronous:shot-notify -u low -i ~/.config/swaync/icons/picture.png "Opened in Swappy" &
~/.config/hypr/scripts/Sounds.sh --screenshot &
