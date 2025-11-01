#!/bin/bash
###############################################################################
# Battery Monitor Script
# Checks battery level and sends a notification if below threshold
# Author: Man37
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
battery_icon="$HOME/.config/swaync/icons/battery-status.png"   # Path to battery icon
battery_path="/sys/class/power_supply/BAT1"                    # Battery info path
check_interval=60                                              # Time between checks (seconds)
low_battery_threshold=25                                       # % battery to trigger alert
sound_file="$(dirname "$0")/bmw_chime.mp3"                     # Sound file in same dir

# ─────────────────────────────────────────────────────────────────────────────
# MAIN LOOP
# ─────────────────────────────────────────────────────────────────────────────
while true; do
    # Read battery level & status
    battery_level=$(<"$battery_path/capacity")
    charging_status=$(<"$battery_path/status")

    echo "Battery Level: $battery_level%"
    echo "Charging Status: $charging_status"

    # Trigger low battery warning if below threshold and not charging
    if [[ "$battery_level" -lt $low_battery_threshold && "$charging_status" != "Charging" ]]; then
        # Notification popup
        notify-send \
            -u normal \
            -t 10000 \
            -i "$battery_icon" \
            "Low Battery" \
            "Battery level is ${battery_level}%. Plug in the charger!"

        # Play sound
        if command -v mpv &> /dev/null; then
            mpv --no-terminal "$sound_file"
        elif command -v cvlc &> /dev/null; then
            cvlc --play-and-exit "$sound_file"
        else
            echo "No supported media player found (mpv or cvlc). Install one to play sound."
        fi
    fi

    # Wait before checking again
    sleep $check_interval
done
