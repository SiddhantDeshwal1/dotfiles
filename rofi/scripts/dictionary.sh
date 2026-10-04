#!/bin/bash
# Mac-style "look up" popup for Hyprland, using rofi.
#
# Flow:
#   1. Try primary selection (highlighted text)
#   2. Fall back to clipboard (Ctrl+C'd text)
#   3. Fall back to an interactive rofi search prompt (type a word/sentence)
# Then, whichever text was obtained:
#   - Single word  -> dictionary definition (sdcv), or spelling suggestions if not found
#   - Sentence     -> explain meaning via Claude API

ROFI_THEME_ARGS=(-theme-str 'window {width: 550px;} listview {lines: 10;}')

notify() {
    notify-send "Dictionary" "$1"
}

get_selection() {
    local text
    text=$(wl-paste --primary --no-newline 2>/dev/null)
    if [ -n "$text" ]; then
        echo "$text" | xargs
        return
    fi

    text=$(wl-paste --no-newline 2>/dev/null)
    if [ -n "$text" ]; then
        echo "$text" | xargs
        return
    fi

    echo ""
}

prompt_for_input() {
    rofi -dmenu -p "🔍 Look up (word, phrase, or misspelling)" -theme-str 'window {width: 550px;}'
}

show_definition() {
    local word="$1"
    local result
    result=$(sdcv -n "$word" 2>/dev/null)

    if [ -n "$result" ]; then
        echo "$result" | rofi -dmenu -p "📖 $word" "${ROFI_THEME_ARGS[@]}"
        return 0
    fi
    return 1
}

show_spelling_suggestions() {
    local word="$1"
    local aspell_line
    aspell_line=$(echo "$word" | aspell -a 2>/dev/null | sed -n '2p')

    if [[ "$aspell_line" == "*" ]]; then
        notify "'$word' is spelled correctly, but no definition was found."
        exit 0
    fi

    local suggestions
    suggestions=$(echo "$aspell_line" | sed -n 's/^&.*: //p' | tr ',' '\n' | sed 's/^[[:space:]]*//')

    if [ -z "$suggestions" ]; then
        notify "No spelling suggestions found for '$word'"
        exit 1
    fi

    local choice
    choice=$(echo "$suggestions" | rofi -dmenu -p "❓ Did you mean" "${ROFI_THEME_ARGS[@]}")

    if [ -n "$choice" ]; then
        show_definition "$choice" || notify "No definition found for '$choice'"
    fi
}

explain_sentence() {
    local text="$1"

    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo "Sentence explanation needs an Anthropic API key.
Set ANTHROPIC_API_KEY in your shell profile to enable this.

Selected text:
$text" | rofi -dmenu -p "ℹ️ Sentence" "${ROFI_THEME_ARGS[@]}"
        return
    fi

    local payload
    payload=$(jq -n --arg text "$text" '{
        model: "claude-sonnet-4-6",
        max_tokens: 300,
        messages: [{role: "user", content: ("Briefly explain the meaning of this sentence in 2-3 plain sentences. Note tone or register only if it matters:\n\n" + $text)}]
    }')

    local response
    response=$(curl -s https://api.anthropic.com/v1/messages \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "$payload")

    local explanation
    explanation=$(echo "$response" | jq -r '.content[0].text // "Could not get explanation. Check your API key and connection."')

    echo "$explanation" | rofi -dmenu -p "💬 Meaning" "${ROFI_THEME_ARGS[@]}"
}

process_text() {
    local text="$1"
    local word_count
    word_count=$(echo "$text" | wc -w)

    if [ "$word_count" -eq 1 ]; then
        local clean_word
        clean_word=$(echo "$text" | tr -d '[:punct:]')
        if ! show_definition "$clean_word"; then
            show_spelling_suggestions "$clean_word"
        fi
    else
        explain_sentence "$text"
    fi
}

main() {
    local selection
    selection=$(get_selection)

    if [ -z "$selection" ]; then
        selection=$(prompt_for_input)
    fi

    if [ -z "$selection" ]; then
        exit 0
    fi

    process_text "$selection"
}

main
