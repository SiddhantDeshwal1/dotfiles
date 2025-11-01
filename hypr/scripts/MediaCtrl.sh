#!/bin/bash
# Playerctl Media Control Script

music_icon="$HOME/.config/swaync/icons/music.png"

# Play the next track
play_next() {
    playerctl next
    show_music_notification
}

# Play the previous track
play_previous() {
    playerctl previous
    show_music_notification
}

# Toggle play/pause
toggle_play_pause() {
    playerctl play-pause
    sleep 0.1   # allow status to update
    show_music_notification
}

# Stop playback
stop_playback() {
    playerctl stop
    notify-send -e -u low -i "$music_icon" "Playback Stopped"
}

# Display notification with song information
show_music_notification() {
    status=$(playerctl status 2>/dev/null)

    case "$status" in
        "Playing")
            song_title=$(playerctl metadata title 2>/dev/null)
            song_artist=$(playerctl metadata artist 2>/dev/null)
            notify-send -e -u low -i "$music_icon" "Now Playing:" "$song_title\nby $song_artist"
            ;;
        "Paused")
            notify-send -e -u low -i "$music_icon" "Playback Paused"
            ;;
        "Stopped"|"")
            notify-send -e -u low -i "$music_icon" "No Media Playing"
            ;;
    esac
}

# Main
case "$1" in
    --nxt)
        play_next
        ;;
    --prv)
        play_previous
        ;;
    --pause)
        toggle_play_pause
        ;;
    --stop)
        stop_playback
        ;;
    *)
        echo "Usage: $0 [--nxt|--prv|--pause|--stop]"
        exit 1
        ;;
esac
