#!/usr/bin/env bash

# Paths
DIR="$HOME/.config/waybar/scripts"
TASK_FILE="$DIR/tasks.txt"

# Ensure directory and file exist
mkdir -p "$DIR"
touch "$TASK_FILE"

# Waybar signaling
WAYBAR_SIGNAL=9

# ==========================================
# Auto-Migrate old task format to new format
# Old: 10|Task
# New: A|10|Task (A=Active, D=Done)
# ==========================================
if grep -q "^[0-9]\+|" "$TASK_FILE"; then
    sed -i -E 's/^([0-9]+\|)/A|\1/' "$TASK_FILE"
fi

# Helper: Keep only max 5 completed tasks
cleanup_tasks() {
    # Save all Active tasks
    grep "^A|" "$TASK_FILE" > "${TASK_FILE}.tmp" || true
    # Keep only the last 5 Done tasks (tail -n 5 drops the oldest)
    grep "^D|" "$TASK_FILE" | tail -n 5 >> "${TASK_FILE}.tmp" || true
    mv "${TASK_FILE}.tmp" "$TASK_FILE"
}

# Helper: Determine CSS class based on task count
get_todo_class() {
    local count=$1
    if [[ "$count" -eq 0 ]]; then
        echo "todo-none"
    elif [[ "$count" -lt 3 ]]; then
        echo "todo-low"
    elif [[ "$count" -lt 5 ]]; then
        echo "todo-medium"
    else
        echo "todo-high"
    fi
}

# Helper: Safely generate JSON for Waybar
print_waybar_status() {
    local count=0
    local tooltip="No tasks! You're all caught up. 🎉"

    if [[ -s "$TASK_FILE" ]]; then
        # Count only Active tasks for the Waybar number
        count=$(grep -c "^A|" "$TASK_FILE" || true)
        
        # Format Active Tasks (Blue, Reverse Priority Sort)
        local active_tt
        active_tt=$(grep "^A|" "$TASK_FILE" | sort -t'|' -k2 -nr | awk -F'|' '{print "<span color=\"#89b4fa\">["$2"]</span> " $3}')
        
        # Format Done Tasks (Muted Gray, Strikethrough)
        local done_tt
        done_tt=$(grep "^D|" "$TASK_FILE" | awk -F'|' '{print "<span color=\"#a6adc8\"><s>["$2"] " $3 "</s></span>"}')
        
        # Combine them
        if [[ -n "$active_tt" ]] && [[ -n "$done_tt" ]]; then
            tooltip="${active_tt}\n${done_tt}"
        elif [[ -n "$active_tt" ]]; then
            tooltip="${active_tt}"
        elif [[ -n "$done_tt" ]]; then
            tooltip="${done_tt}"
        fi
    fi

    local todo_class
    todo_class=$(get_todo_class "$count")

    jq -n -c --unbuffered \
        --arg text " $count" \
        --arg tooltip "$tooltip" \
        --arg class "$todo_class" \
        '{"text": $text, "tooltip": $tooltip, "class": $class}'
}

# Helper: Add a task
add_task() {
    local input="$1"
    
    local stripped="${input// /}"
    [[ -z "$stripped" ]] && return

    local prio=10
    local task_text="$input"

    local re="^(.*[^[:space:]])[[:space:]]*\[([0-9]+)\]$"
    
    if [[ "$input" =~ $re ]]; then
        task_text="${BASH_REMATCH[1]}"
        prio="${BASH_REMATCH[2]}"
    fi

    # Append as Active (A|)
    echo "A|${prio}|${task_text}" >> "$TASK_FILE"
}

# Core Interactive Menu
show_menu() {
    local active_formatted=""
    local done_formatted=""

    if [[ -s "$TASK_FILE" ]]; then
        # Active: Normal text
        active_formatted=$(grep "^A|" "$TASK_FILE" | sort -t'|' -k2 -nr | awk -F'|' '{print "["$2"] "$3}')
        
        # Done: Apply Unicode Strikethrough (\xCC\xB6) to the entire string
        done_formatted=$(grep "^D|" "$TASK_FILE" | awk -F'|' '{print "["$2"] "$3}' | sed 's/./&\xCC\xB6/g')
    fi

    # Prepare menu options
    local options="+ Add Task\n- Clear All Tasks"
    
    if [[ -n "$active_formatted" ]] || [[ -n "$done_formatted" ]]; then
        options+="\n " # Visual gap
    fi
    [[ -n "$active_formatted" ]] && options+="\n$active_formatted"
    [[ -n "$done_formatted" ]] && options+="\n$done_formatted"

    # Launch Tofi
    local selection
    selection=$(echo -e "$options" | tofi \
        --prompt-text " Todo: " \
        --width 800 \
        --height 500 \
        --border-width 2 \
        --outline-width 0 \
        --result-spacing 15 \
        --require-match false)

    # Clean the unicode strikethrough characters from the selection so we can match it via Regex
    local clean_selection
    clean_selection=$(echo "$selection" | sed 's/\xCC\xB6//g')

    case "$clean_selection" in
        "" | " ") 
            return 0 
            ;;
        "+ Add Task")
            local new_task
            new_task=$(echo "" | tofi \
                --prompt-text "New Task: " \
                --width 1000 \
                --height 100 \
                --border-width 2 \
                --outline-width 0 \
                --require-match false)
            add_task "$new_task"
            ;;
        "- Clear All Tasks")
            > "$TASK_FILE"
            ;;
        "["*"] "*)
            local sel_re="^\[([0-9]+)\][[:space:]]+(.*)$"
            if [[ "$clean_selection" =~ $sel_re ]]; then
                local p="${BASH_REMATCH[1]}"
                local t="${BASH_REMATCH[2]}"
                
                # If Active -> Move to Done
                if grep -q -F -x "A|${p}|${t}" "$TASK_FILE"; then
                    grep -v -F -x "A|${p}|${t}" "$TASK_FILE" > "${TASK_FILE}.tmp"
                    echo "D|${p}|${t}" >> "${TASK_FILE}.tmp"
                    mv "${TASK_FILE}.tmp" "$TASK_FILE"
                
                # If Done -> Delete Permanently
                elif grep -q -F -x "D|${p}|${t}" "$TASK_FILE"; then
                    grep -v -F -x "D|${p}|${t}" "$TASK_FILE" > "${TASK_FILE}.tmp"
                    mv "${TASK_FILE}.tmp" "$TASK_FILE"
                fi
            fi
            ;;
        *)
            add_task "$selection"
            ;;
    esac

    # Enforce the 5-item limit on Completed tasks
    cleanup_tasks

    # Signal Waybar to refresh
    pkill -RTMIN+$WAYBAR_SIGNAL waybar
}

# Main routing
if [[ "$1" == "--menu" ]]; then
    show_menu
else
    print_waybar_status
fi
