#!/usr/bin/env bash
# waybar-timer.sh — Waybar custom module: countdown timer + stopwatch
#
# Usage (waybar config):
#   "exec": "waybar-timer.sh output"     — called on interval to render the bar text
#   "on-click": "waybar-timer.sh toggle" — left-click: start / pause
#   "on-right-click": "waybar-timer.sh menu" — right-click: open tofi menu
#
# State is stored as plain text files under $XDG_CACHE_HOME/waybar-timer/:
#   mode        — "timer" or "stopwatch"
#   run         — "1" running, "0" paused
#   start       — epoch seconds (timer) or epoch milliseconds (stopwatch) of last start
#   duration    — timer duration in seconds at time of last start
#   remaining   — timer seconds left when paused
#   elapsed     — stopwatch milliseconds accumulated when paused
#   reset_flag  — "1" means we are in a clean reset state (show 00:00:00, no alarm)
#
# When a timer reaches zero the display switches to "TU: MM:SS" (time up / overtime),
# showing how many minutes and seconds have elapsed past the deadline.
# A one-shot desktop notification fires at the moment the timer first hits zero.

# ---------------------------------------------------------------------------
# State directory
# ---------------------------------------------------------------------------
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-timer"
mkdir -p "$STATE_DIR"

# ---------------------------------------------------------------------------
# Low-level I/O — no external processes
# ---------------------------------------------------------------------------

# Read a file that must contain a non-negative integer; return 0 on any error.
read_int() {
    local file="$STATE_DIR/$1"
    local val
    [[ -f "$file" ]] || { echo 0; return; }
    read -r val < "$file"
    [[ "$val" =~ ^[0-9]+$ ]] && echo "$val" || echo 0
}

# Read the mode file; return "timer" as default if missing or empty.
read_mode() {
    local file="$STATE_DIR/mode"
    local val
    if [[ -f "$file" ]]; then
        read -r val < "$file"
        [[ -n "$val" ]] && echo "$val" && return
    fi
    echo "timer"
}

write_state() {
    # write_state KEY VALUE  — atomically write VALUE to STATE_DIR/KEY
    printf '%s\n' "$2" > "$STATE_DIR/$1"
}

# ---------------------------------------------------------------------------
# Time helpers
# ---------------------------------------------------------------------------

# Milliseconds — one fork; only used when millisecond precision is needed.
now_ms() { date +%s%3N; }

fmt_hms() {
    local t=$1
    (( t < 0 )) && t=0
    printf "%02d:%02d:%02d" $(( t / 3600 )) $(( (t % 3600) / 60 )) $(( t % 60 ))
}

fmt_ms() {
    local ms=$1
    (( ms < 0 )) && ms=0
    local sec=$(( ms / 1000 ))
    local frac=$(( ms % 1000 ))
    printf "%02d:%02d:%02d.%03d" \
        $(( sec / 3600 )) $(( (sec % 3600) / 60 )) $(( sec % 60 )) "$frac"
}

# Format overtime as MM:SS (no hours — overtime should be short).
fmt_overtime() {
    local t=$1
    (( t < 0 )) && t=0
    printf "%02d:%02d" $(( t / 60 )) $(( t % 60 ))
}

# ---------------------------------------------------------------------------
# Current display value
# ---------------------------------------------------------------------------

# Returns the current timer countdown (seconds) or stopwatch value (ms),
# depending on mode and running state.
current_value() {
    local mode running
    mode=$(read_mode)
    running=$(read_int "run")

    if [[ "$mode" == "timer" ]]; then
        if (( running == 1 )); then
            local start dur
            start=$(read_int "start")
            dur=$(read_int "duration")
            echo $(( dur - (EPOCHSECONDS - start) ))
        else
            read_int "remaining"
        fi
    else
        # stopwatch
        if (( running == 1 )); then
            local start
            start=$(read_int "start")
            echo $(( $(now_ms) - start ))
        else
            read_int "elapsed"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_output() {
    local mode val reset
    mode=$(read_mode)
    val=$(current_value)
    reset=$(read_int "reset_flag")

    if [[ "$mode" == "timer" ]]; then
        if (( val <= 0 && reset != 1 )); then
            # Timer has expired — show overtime ("TU: MM:SS").
            local overtime=$(( -val ))

            # Fire a desktop notification exactly once when overtime first begins
            # (i.e. when overtime < 2 seconds, so we catch the first poll interval).
            local notif_flag="$STATE_DIR/notif_sent"
            if (( overtime < 2 )) && [[ ! -f "$notif_flag" ]]; then
                touch "$notif_flag"
                command -v notify-send &>/dev/null && \
                    notify-send -u critical "⏰ Timer up!" "Waybar timer has expired." &
            fi

            printf "⏰ TU: %s\n" "$(fmt_overtime "$overtime")"
        else
            # Normal countdown display.
            # Clean up any leftover notification flag if timer was reset or paused above zero.
            rm -f "$STATE_DIR/notif_sent"
            printf "󰥔 %s\n" "$(fmt_hms "$val")"
        fi
    else
        # Stopwatch.
        printf "󰥔 %s\n" "$(fmt_ms "$val")"
    fi
}

cmd_toggle() {
    local mode running
    mode=$(read_mode)
    running=$(read_int "run")

    if (( running == 1 )); then
        # ---- PAUSE ----
        if [[ "$mode" == "timer" ]]; then
            local start dur rem
            start=$(read_int "start")
            dur=$(read_int "duration")
            rem=$(( dur - (EPOCHSECONDS - start) ))
            (( rem < 0 )) && rem=0
            write_state "remaining" "$rem"
        else
            local start_ms elapsed
            start_ms=$(read_int "start")
            elapsed=$(( $(now_ms) - start_ms ))
            (( elapsed < 0 )) && elapsed=0
            write_state "elapsed" "$elapsed"
        fi
        write_state "run"   "0"
        write_state "start" "0"

    else
        # ---- START / RESUME ----
        rm -f "$STATE_DIR/reset_flag"

        if [[ "$mode" == "timer" ]]; then
            local rem
            rem=$(read_int "remaining")
            # If remaining is 0 (or timer was never set), do nothing useful.
            (( rem <= 0 )) && return
            write_state "duration" "$rem"
            write_state "start"    "$EPOCHSECONDS"
            rm -f "$STATE_DIR/remaining"
        else
            local elapsed ms
            elapsed=$(read_int "elapsed")
            ms=$(now_ms)
            if (( elapsed == 0 )); then
                write_state "start" "$ms"
            else
                # Back-calculate virtual start so elapsed accumulates correctly.
                write_state "start" "$(( ms - elapsed ))"
            fi
            rm -f "$STATE_DIR/elapsed"
        fi
        write_state "run" "1"
    fi
}

cmd_menu() {
    local choice
    choice=$(printf "Set Timer\nStopwatch Mode\nReset\n" | tofi --prompt-text "~") || return

    case "$choice" in

        "Set Timer")
            local d
            d=$(printf "1 min\n5 min\n10 min\n25 min\n45 min\nCustom\n" \
                | tofi --prompt-text "~: ") || return

            local sec
            case "$d" in
                "1 min")  sec=60   ;;
                "5 min")  sec=300  ;;
                "10 min") sec=600  ;;
                "25 min") sec=1500 ;;
                "45 min") sec=2700 ;;
                "Custom")
                    local custom
                    custom=$(printf "" | tofi --prompt-text "Minutes: ") || return
                    if [[ "$custom" =~ ^[1-9][0-9]*$ ]]; then
                        sec=$(( custom * 60 ))
                    else
                        return  # invalid or empty input — abort cleanly
                    fi
                    ;;
                *) return ;;
            esac

            rm -f "$STATE_DIR/notif_sent"
            write_state "mode"       "timer"
            write_state "run"        "0"
            write_state "start"      "0"
            write_state "duration"   "$sec"
            write_state "remaining"  "$sec"
            write_state "elapsed"    "0"
            write_state "reset_flag" "0"
            ;;

        "Stopwatch Mode")
            write_state "mode"       "stopwatch"
            write_state "run"        "0"
            write_state "start"      "0"
            write_state "duration"   "0"
            write_state "remaining"  "0"
            write_state "elapsed"    "0"
            write_state "reset_flag" "0"
            ;;

        "Reset")
            rm -f "$STATE_DIR/notif_sent"
            write_state "mode"       "timer"
            write_state "run"        "0"
            write_state "start"      "0"
            write_state "duration"   "0"
            write_state "remaining"  "0"
            write_state "elapsed"    "0"
            write_state "reset_flag" "1"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

case "$1" in
    output) cmd_output ;;
    toggle) cmd_toggle ;;
    menu)   cmd_menu   ;;
    *)
        printf 'Usage: %s {output|toggle|menu}\n' "$(basename "$0")" >&2
        exit 1
        ;;
esac
