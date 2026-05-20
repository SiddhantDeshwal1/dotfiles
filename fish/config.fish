# ==============================================
# Environment & Core Settings
# ==============================================
set -x LANG en_IN.UTF-8
set -x LC_ALL en_IN.UTF-8
set -Ux EDITOR nvim
set -g fish_greeting

# Paths & Custom Drives
fish_add_path /usr/lib/jvm/java-24-openjdk/bin
set -Ua CDPATH /run/media/banana
export PATH="$HOME/.local/bin:$PATH"

# History
set -U HISTFILE ~/.fish_history
set -U HISTSIZE 10000
set -U SAVEHIST 10000
set -U appendhistory 1

# ==============================================
# Theming & Visuals
# ==============================================
set -U BAT_THEME tokyonight_night
set -U tide_character_vi_icon_default ❯

# ==============================================
# File Management & Aliases
# ==============================================
function ls; eza -a --icons $argv; end
function ll; eza -al --icons $argv; end
function lt; eza -a --tree --level=1 --icons $argv; end

# ==============================================
# FZF (Fuzzy Finder) Configuration
# ==============================================
set -Ux FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
set -Ux FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -Ux FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

function fzf-preview
    if test -d $argv
        eza --tree --color=always $argv | head -200
    else
        bat -n --color=always --line-range :500 $argv
    end
end

set -Ux FZF_CTRL_T_OPTS "--preview 'fzf-preview {}'"
set -Ux FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# Initialize FZF key bindings
fzf --fish | source

# ==============================================
# Navigation (Yazi & CD override)
# ==============================================
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function cd
    # 1. Run the normal cd command
    builtin cd $argv
    set -l cd_status $status

    # 2. Safely check for and run the alias setup
    if type -q setup_dir_aliases
        setup_dir_aliases
    end

    # 3. Return the exit status of the original cd command
    return $cd_status
end

# Auto-load directory aliases if function exists
type -q setup_dir_aliases && setup_dir_aliases

# ==============================================
# Event Handlers
# ==============================================
function on_keypress --on-event fish_key_reader
    # Beep on empty command line enter
    if test -z (commandline)
        echo -e '\a'
    end
end
