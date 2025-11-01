#!/bin/bash
# wofi-calculator.sh

QUERY=$(wofi --dmenu --prompt "Calc:")

if [ -n "$QUERY" ]; then
    RESULT=$(echo "$QUERY" | bc -l)
    notify-send "Result: $RESULT"
fi
