#!/bin/bash

# Define directories
CONFIG_DIR="$HOME/.config"
CURRENT_DIR="$(pwd)"

# Safety Check: Prevent running this directly inside ~/.config/
if [ "$CURRENT_DIR" == "$CONFIG_DIR" ]; then
    echo "Error: You are currently in $CONFIG_DIR. Please run this from your dotfiles repo."
    exit 1
fi

echo "Syncing dotfiles from $CONFIG_DIR into $CURRENT_DIR..."

# Loop through all directories in the current folder
for dir in */; do
    # Remove the trailing slash from the directory name (e.g., "hypr/" becomes "hypr")
    target="${dir%/}"

    # Skip the .git folder so we don't destroy the repository history
    if [ "$target" == ".git" ]; then
        continue
    fi

    # Check if this exact directory exists in ~/.config/
    if [ -d "$CONFIG_DIR/$target" ]; then
        echo "[*] Found matching config for: $target"
        
        # 1. Delete the old folder in the current directory
        rm -rf "./$target"
        
        # 2. Copy the fresh folder from ~/.config/ to the current directory
        cp -r "$CONFIG_DIR/$target" "./$target"
        
        echo "    -> Successfully updated $target"
    else
        echo "[ ] Skipping $target: Not found in $CONFIG_DIR"
    fi
done

echo "Sync complete! You can now run 'git status' to see what changed."
