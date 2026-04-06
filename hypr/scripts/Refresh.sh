#!/bin/bash

# Kill existing instances
killall -q waybar mako

# Wait until fully stopped
while pgrep -x waybar >/dev/null; do sleep 0.1; done
while pgrep -x mako >/dev/null; do sleep 0.1; done

# Launch services
waybar >/dev/null 2>&1 &
mako >/dev/null 2>&1 &

exit 0
