#!/bin/bash
# Playerctl Media Control Script (Browser-Aware)

music_icon="$HOME/.config/swaync/icons/music.png"

# Select the currently active player (Playing > Paused)
select_player() {
    # First, try to find a player that is actively Playing
    for p in $(playerctl -l 2>/dev/null); do
        status=$(playerctl -p "$p" status 2>/dev/null)
        if [ "$status" = "Playing" ]; then
            echo "$p"
            return
        fi
    done

    # If none are Playing, pick one that is Paused
    for p in $(playerctl -l 2>/dev/null); do
        status=$(playerctl -p "$p" status 2>/dev/null)
        if [ "$status" = "Paused" ]; then
            echo "$p"
            return
        fi
    done

    # Fallback: first available player
    playerctl -l 2>/dev/null | head -n1
}

player=$(select_player)

if [ -z "$player" ]; then
    notify-send -e -u low -i "$music_icon" "No Media Players Found"
    exit 1
fi

play_next() {
    playerctl -p "$player" next
    show_music_notification
}

play_previous() {
    playerctl -p "$player" previous
    show_music_notification
}

toggle_play_pause() {
    playerctl -p "$player" play-pause
    sleep 0.15
    show_music_notification
}

stop_playback() {
    playerctl -p "$player" stop
    notify-send -e -u low -i "$music_icon" "Playback Stopped"
}

show_music_notification() {
    status=$(playerctl -p "$player" status 2>/dev/null)

    case "$status" in
        "Playing")
            song_title=$(playerctl -p "$player" metadata title 2>/dev/null)
            song_artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
            [ -z "$song_artist" ] && song_artist="Unknown Artist"
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
