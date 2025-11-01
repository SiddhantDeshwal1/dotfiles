#!/bin/bash

# Colors
black='\033[0;30m'
blue='\033[0;34m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
magenta='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
reset='\033[0m'

get_wm() {
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        echo "$XDG_CURRENT_DESKTOP"
        return
    fi
    if [ -n "$DESKTOP_SESSION" ]; then
        echo "$DESKTOP_SESSION"
        return
    fi

    # Check running processes
    for wm in qtile i3 dwm awesome bspwm Hyprland; do
        if pgrep -x "$wm" > /dev/null; then echo "${wm^}"
            return
        fi
    done
    echo "Unknown"
}

# System info
user=$(whoami)
os="Arch Linux"
wm=$(get_wm)
kernel=$(uname -r)
shell=$(basename "$SHELL")
uptime=$(uptime -p | cut -d' ' -f2-)

color_dots="${black}● ${red}● ${green}● ${yellow}● ${blue}● ${magenta}● ${cyan}● ${white}●${reset}"

# Disable default Neofetch output
clear

# Output
echo
echo -e "${blue}      /\\          ${green} user${reset}    $user"
echo -e "${blue}     /  \\         ${yellow}󰣇 os${reset}      $os"
echo -e "${blue}    /\   \\        ${blue}󰍹 wm${reset}      $wm"
echo -e "${blue}   /      \\       ${magenta} kernel${reset}  $kernel"
echo -e "${blue}  /   ,,   \\      ${cyan} shell${reset}   $shell"
echo -e "${blue} /   |  |  -\\     ${red} uptime${reset}  $uptime"
echo -e "${blue}/_-''    ''-_\\    ${reset}${color_dots}"
echo
