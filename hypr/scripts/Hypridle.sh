#!/bin/bash
###############################################################################
# Hypridle Status & Toggle Script
# Shows current state and allows toggling Hypridle (idle inhibitor)
# Designed for integration with Waybar
# Author: Man37
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
PROCESS="hypridle"


# ─────────────────────────────────────────────────────────────────────────────
# FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

# Show status in JSON format for Waybar
show_status() {
    sleep 1  # Small delay for accurate detection

    if pgrep -x "$PROCESS" >/dev/null; then
        echo '{
            "text": "RUNNING",
            "class": "active",
            "tooltip": "idle_inhibitor NOT ACTIVE\nLeft Click: Activate\nRight Click: Lock Screen"
        }'
    else
        echo '{
            "text": "NOT RUNNING",
            "class": "notactive",
            "tooltip": "idle_inhibitor is ACTIVE\nLeft Click: Deactivate\nRight Click: Lock Screen"
        }'
    fi
}

# Toggle Hypridle ON/OFF
toggle_process() {
    if pgrep -x "$PROCESS" >/dev/null; then
        pkill "$PROCESS"
    else
        "$PROCESS" &
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# MAIN SCRIPT LOGIC
# ─────────────────────────────────────────────────────────────────────────────
case "$1" in
    status)
        show_status
        ;;
    toggle)
        toggle_process
        ;;
    *)
        echo "Usage: $0 {status|toggle}"
        exit 1
        ;;
esac
