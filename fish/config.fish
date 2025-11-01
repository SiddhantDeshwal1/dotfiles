# ==============================================
# Fish Shell Configuration
# ==============================================


set -x LANG en_IN.UTF-8
set -x LC_ALL en_IN.UTF-8

# ---------- Aliases & File Management ----------
# Use `eza` as a modern replacement for `ls`
function ls
    eza -a --icons $argv
end

function ll
    eza -al --icons $argv
end

function lt
    eza -a --tree --level=1 --icons $argv
end


set -U fish_user_paths /usr/lib/jvm/java-24-openjdk/bin $fish_user_paths

# ---------- Editor ----------
# Set default editor to Neovim
set -Ux EDITOR nvim


# ---------- Disable Default Greeting ----------
set -g fish_greeting


# ---------- FZF (Fuzzy Finder) Setup ----------
# Default search command: use `fd` for speed, include hidden files, ignore .git
set -U FZF_DEFAULT_COMMAND 'fd --hidden --strip-cwd-prefix --exclude .git'
set -U FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -U FZF_ALT_C_COMMAND  'fd --type=d --hidden --strip-cwd-prefix --exclude .git'

# Preview function for FZF
function fzf-preview
    if test -d $argv
        eza --tree --color=always $argv | head -200
    else
        bat -n --color=always --line-range :500 $argv
    end
end

# Configure FZF keybind previews
set -U FZF_CTRL_T_OPTS "--preview 'fzf-preview {}'"
set -U FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# Enable FZF key bindings for Fish
fzf --fish | source


# ---------- History Settings ----------
set -U HISTFILE ~/.fish_history
set -U HISTSIZE 10000
set -U SAVEHIST 10000
set -U appendhistory 1


# ---------- Directory-Specific Aliases ----------
function setup_dir_aliases
    if test $PWD = $HOME/competitiveProgramming/contest
        alias add="python $HOME/competitiveProgramming/contest/cf.py add"
        alias load="python $HOME/competitiveProgramming/contest/cf.py load"
        alias check="$HOME/competitiveProgramming/contest/run.sh"
        alias submit="python $HOME/competitiveProgramming/contest/cf.py submit"
        alias runcpp="g++ -o workspace workspace.cpp && ./workspace"
    else if test $PWD = $HOME/competitiveProgramming/editor
        alias add="python $HOME/competitiveProgramming/editor/cf.py add"
        alias load="python $HOME/competitiveProgramming/editor/cf.py load"
        alias check="python $HOME/competitiveProgramming/editor/cf.py check"
        alias submit="python $HOME/competitiveProgramming/editor/cf.py submit"
        alias last="python $HOME/competitiveProgramming/editor/cf.py last"
        alias contest="python $HOME/competitiveProgramming/editor/cf.py contest"
        alias runcpp="g++ -o workspace workspace.cpp && ./workspace"
        alias friends="python $HOME/competitiveProgramming/editor/cf.py friends"
    else
        # Remove aliases if not in specific directories
        functions -e add load check runcpp submit
    end
end

# Override `cd` to auto-load directory-specific aliases
function cd
    builtin cd $argv
    setup_dir_aliases
end

# Initialize directory aliases at startup
setup_dir_aliases


# ---------- TheFuck Command Fixer ----------
# `fuck` → corrects last command using thefuck
function fuck
    set -l fucked_up_command $history[1]
    env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck \
        $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
    if test "$unfucked_command" != ""
        eval $unfucked_command
        history --delete --exact --case-sensitive -- $fucked_up_command
        history --merge
    end
end

# Short alias `fk` for the same functionality
function fk
    set -l fucked_up_command $history[1]
    env TF_SHELL=fish TF_ALIAS=fk PYTHONIOENCODING=utf-8 thefuck \
        $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
    if test "$unfucked_command" != ""
        eval $unfucked_command
        history --delete --exact --case-sensitive -- $fucked_up_command
        history --merge
    end
end


# ---------- On Keypress Event ----------
# Beeps if you press a key with an empty command line
function on_keypress --on-event fish_key_reader
    if test -z (commandline)
        echo -e '\a'
    end
end


# ---------- Bat & Eza Config ----------
set -U BAT_THEME tokyonight_night


# ---------- Yazi (Terminal File Manager) ----------
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end


# ---------- (Optional) Tide Theme Git Status Colors ----------
# Uncomment to customize Tide prompt git colors
set -g tide_git_bg_color 268bd2
set -g tide_git_bg_color_unstable C4A000
set -g tide_git_bg_color_urgent CC0000
set -g tide_git_branch_color 000000
set -g tide_git_color_branch 000000
set -g tide_git_color_conflicted 000000
set -g tide_git_color_dirty 000000
set -g tide_git_color_operation 000000
set -g tide_git_color_staged 000000
set -g tide_git_color_stash 000000
set -g tide_git_color_untracked 000000
set -g tide_git_color_upstream 000000
set -g tide_git_conflicted_color 000000
set -g tide_git_dirty_color 000000
set -g tide_git_icon 
set -g tide_git_operation_color 000000
set -g tide_git_staged_color 000000
set -g tide_git_stash_color 000000
set -g tide_git_untracked_color 000000
set -g tide_git_upstream_color 000000
set -g tide_pwd_bg_color 444444
# ... other Tide color settings ...


# ---------- (Optional) Starship Prompt ----------
# sset -x STARSHIP_CONFIG ~/.config/starship.toml
# starship init fish | source

