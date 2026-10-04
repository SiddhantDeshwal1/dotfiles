#!/bin/bash

# Kill existing instances
killall -q quickshell mako

# Wait until fully stopped
while pgrep -x quickshell >/dev/null; do sleep 0.1; done
while pgrep -x mako >/dev/null; do sleep 0.1; done

# Launch services
quickshell >/dev/null 2>&1 & disown
mako >/dev/null 2>&1 & disown

exit 0
