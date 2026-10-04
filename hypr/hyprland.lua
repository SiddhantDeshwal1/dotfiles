-------------------------------------------------------------------------------
-- Hyprland Lua Configuration
-- Author: Man37 (Migrated from hyprland.conf for Hyprland v0.56+)
-- Performance-tuned for Ryzen 5 3450u / Vega 8 iGPU (CachyOS) — no tearing
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- VARIABLES
-------------------------------------------------------------------------------

local home        = os.getenv("HOME") or "/home/banana"
local mainMod     = "SUPER"
local term        = "kitty"
local files       = "pcmanfm"
local scriptsDir  = home .. "/.config/hypr/scripts"
local UserScripts = home .. "/.config/hypr/UserScripts"
local configs     = home .. "/.config/hypr/configs"
local UserConfigs = home .. "/.config/hypr/UserConfigs"
local rofiDir     = home .. "/.config/rofi"
local wallDIR     = home .. "/Pictures/wallpapers"

-------------------------------------------------------------------------------
-- ENVIRONMENT VARIABLES
-------------------------------------------------------------------------------

hl.env("EDITOR", "nvim")

-- Display backends
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt configuration
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "25")

-- Scaling
hl.env("GDK_SCALE", "0.85")

-- AMD/Vega 8 (RADV) tuning
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")

-------------------------------------------------------------------------------
-- MONITORS
-------------------------------------------------------------------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1366x768@60",
    position = "1920x0",
    scale    = 1,
})

-------------------------------------------------------------------------------
-- AUTOSTART (exec-once)
-------------------------------------------------------------------------------

hl.on("hyprland.start", function()
    -- Environment import for systemd / dbus
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprland-session.target")

    -- Core system
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &")
    hl.exec_cmd(scriptsDir .. "/Polkit.sh")

    -- Wallpaper daemon
    hl.exec_cmd("awww-daemon")

    -- Status bar & notifications (AGS v3 Shell)
    hl.exec_cmd("ags run &")
    hl.exec_cmd("playerctld daemon")

    -- Utilities
    hl.exec_cmd("hypridle &")

    -- Clipboard manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-------------------------------------------------------------------------------
-- GENERAL SETTINGS
-------------------------------------------------------------------------------

hl.config({
    general = {
        border_size      = 0,
        gaps_in          = 5,
        gaps_out         = 10,
        resize_on_border = true,
        layout           = "dwindle",
        allow_tearing    = false, -- explicitly off
    },
})

-------------------------------------------------------------------------------
-- DECORATIONS
-------------------------------------------------------------------------------

hl.config({
    decoration = {
        active_opacity     = 1.0,
        inactive_opacity   = 0.8,
        fullscreen_opacity = 1.0,
        dim_inactive       = true,
        dim_strength       = 0.1,
        dim_special        = 0.8,

        blur = {
            enabled           = true,
            size              = 10,
            passes            = 4,
            brightness        = 1.0,
            contrast          = 1.05,
            vibrancy          = 0.2,
            vibrancy_darkness = 0.2,
            popups            = true,
            ignore_opacity    = true,
            new_optimizations = true,
            special           = true,
            xray              = false,
        },
    },
})

-------------------------------------------------------------------------------
-- ANIMATIONS & BEZIER CURVES
-------------------------------------------------------------------------------

hl.config({
    animations = {
        enabled = true,
    },
})

-- Bezier curves (all control points strictly within Hyprland limits [0..1] for X and [-2..2] for Y)
hl.curve("myBezier",   { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}  } })
hl.curve("been",       { type = "bezier", points = { {0.24, 0.9},  {0.25, 0.91} } })
hl.curve("been2",      { type = "bezier", points = { {0.0, 0.94},  {0.5, 0.99}  } })
hl.curve("menu_decel", { type = "bezier", points = { {0.1, 1.0},   {0.0, 1.0}   } })
hl.curve("linear",     { type = "bezier", points = { {0.0, 0.0},   {1.0, 1.0}   } })
hl.curve("wind",       { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}  } })
hl.curve("winIn",      { type = "bezier", points = { {0.1, 1.1},   {0.1, 1.1}   } })
hl.curve("winOut",     { type = "bezier", points = { {0.3, -0.3},  {0.0, 1.0}   } })
hl.curve("slow",       { type = "bezier", points = { {0.0, 0.85},  {0.3, 1.0}   } })
hl.curve("overshot",   { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1}   } })
hl.curve("macos",      { type = "bezier", points = { {0.25, 0.1},  {0.25, 1.0}  } })

-- Window & workspace animations
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,  bezier = "myBezier", style = "popin 1%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 10, bezier = "myBezier", style = "popin 1%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "wind",     style = "slide" })
hl.animation({ leaf = "windows",     enabled = true, speed = 6,  bezier = "myBezier", style = "popin" })
hl.animation({ leaf = "border",      enabled = true, speed = 1,  bezier = "linear" })
hl.animation({ leaf = "fade",        enabled = true, speed = 6,  bezier = "myBezier" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4,  bezier = "overshot", style = "slide" })

-------------------------------------------------------------------------------
-- LAYOUTS
-------------------------------------------------------------------------------

hl.config({
    dwindle = {
        preserve_split       = true,
        special_scale_factor = 0.8,
    },
    master = {
        new_status = "master",
        new_on_top = true,
        mfact      = 0.5,
    },
})

-------------------------------------------------------------------------------
-- INPUT
-------------------------------------------------------------------------------

hl.config({
    input = {
        kb_layout                   = "us",
        repeat_rate                 = 40,
        repeat_delay                = 250,
        numlock_by_default          = true,
        follow_mouse                = 1,
        float_switch_override_focus = 0,

        -- Sensitivity settings
        sensitivity    = 0.6,
        accel_profile  = "adaptive",
        force_no_accel = false,

        touchpad = {
            disable_while_typing    = true,
            natural_scroll          = true,
            middle_button_emulation = true,
            tap_to_click            = true,
        },
    },
})

-------------------------------------------------------------------------------
-- GESTURES
-------------------------------------------------------------------------------

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.gesture({
    fingers   = 3,
    direction = "swipe",
    mods      = "ALT",
    action    = "resize",
})

-------------------------------------------------------------------------------
-- GROUPS
-------------------------------------------------------------------------------

hl.config({
    group = {
        groupbar = {},
    },
})

-------------------------------------------------------------------------------
-- MISCELLANEOUS, RENDER, DEBUG
-------------------------------------------------------------------------------

hl.config({
    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        vrr                        = 0,
        mouse_move_enables_dpms    = true,
        enable_swallow             = true,
        swallow_regex              = "^(kitty)$",
        focus_on_activate          = false,
        initial_workspace_tracking = 0,
        middle_click_paste         = false,
    },
    render = {
        direct_scanout = false,
    },
    debug = {
        disable_logs = true,
    },
})

-------------------------------------------------------------------------------
-- BINDS CONFIG
-------------------------------------------------------------------------------

hl.config({
    binds = {
        workspace_back_and_forth    = true,
        allow_workspace_cycles      = true,
        pass_mouse_when_bound       = false,
        movefocus_cycles_fullscreen = true,
    },
})

-------------------------------------------------------------------------------
-- XWAYLAND & CURSOR
-------------------------------------------------------------------------------

hl.config({
    xwayland = {
        enabled            = true,
        force_zero_scaling = true,
    },
    cursor = {
        no_hardware_cursors      = 0,
        enable_hyprcursor        = true,
        warp_on_change_workspace = 1,
        no_warps                 = true,
    },
})

-------------------------------------------------------------------------------
-- LAYER RULES
-------------------------------------------------------------------------------

hl.layer_rule({
    match     = { namespace = "^rofi$" },
    animation = "slide",
})

hl.layer_rule({
    match        = { namespace = "^(ags-.*)$" },
    blur         = true,
    ignore_alpha = 0.05,
    blur_popups  = true,
})

hl.layer_rule({
    match        = { namespace = "^(quickshell.*)$" },
    blur         = true,
    ignore_alpha = 0.05,
})

hl.layer_rule({
    match        = { namespace = "^(waybar)$" },
    blur         = true,
    ignore_alpha = 0.05,
})

hl.layer_rule({
    match = { namespace = "^(gtk-layer-shell)$" },
    blur  = true,
})

-------------------------------------------------------------------------------
-- WINDOW RULES
-------------------------------------------------------------------------------

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name   = "clipmenu-window",
    match  = { class = "clipmenu" },
    float  = true,
    center = true,
    size   = { 1500, 600 },
})

hl.window_rule({
    name   = "todo-input-window",
    match  = { class = "todo-input" },
    float  = true,
    center = true,
    size   = { 820, 540 },
})

hl.window_rule({
    name   = "timer-input-window",
    match  = { class = "timer-input" },
    float  = true,
    center = true,
    size   = { 700, 480 },
})

hl.window_rule({
    name   = "satty-window",
    match  = { class = [=[^(com\.gabm\.satty)$]=] },
    float  = true,
    center = true,
    size   = { 800, 600 },
})

hl.window_rule({
    name      = "screenshare-meet-general",
    match     = { title = [=[^(meet\.google\.com is sharing.*)$]=] },
    workspace = "special:screenshare silent",
})

hl.window_rule({
    name      = "screenshare-meet-window",
    match     = { title = [=[^(meet\.google\.com is sharing a window\.)]=] },
    workspace = "special:screenshare silent",
})

-------------------------------------------------------------------------------
-- KEYBINDINGS
-------------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
-- System Control
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("hyprctl dispatch exit 0"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"))
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("hyprlock"), { locked = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- Application Launchers
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(files))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("kitty nvim"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd('sh -c "tofi-drun | sh"'))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty --class floatkitty"))

-- AGS Shell Controls
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd('ags request "toggle controlcenter"'))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd('ags request "toggle notifications"'))

-- ─────────────────────────────────────────────────────────────────────────────
-- Window Management
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + P", hl.dsp.window.pin({ action = "toggle" }))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- ─────────────────────────────────────────────────────────────────────────────
-- Window Grouping
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + Tab", hl.dsp.group.next())

-- ─────────────────────────────────────────────────────────────────────────────
-- Features & Utilities
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"))
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd([=[foot --app-id clipmenu -e fish -c 'cliphist list | fzf --layout=reverse --border --preview "if echo {} | grep -q \"binary data\"; cliphist decode {1} | chafa -f sixel -s \"$FZF_PREVIEW_COLUMNS\"x\"$FZF_PREVIEW_LINES\" -; else; cliphist decode {1}; end" --preview-window=right:55% --bind "enter:execute(cliphist decode {1} | wl-copy)+abort"']=]))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/timer.sh menu"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(home .. "/.config/quickshell/scripts/screenshot.sh --area"))
hl.bind("Print", hl.dsp.exec_cmd(home .. "/.config/quickshell/scripts/screenshot.sh --full"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(home .. "/.config/quickshell/scripts/screenshot.sh --win"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort"))
hl.bind("F9", hl.dsp.exec_cmd("wtype -M alt -k t -m alt"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(home .. "/.config/rofi/scripts/dictionary.sh"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Media Controls
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && " .. scriptsDir .. "/Sounds.sh --volume"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " .. scriptsDir .. "/Sounds.sh --volume"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " .. scriptsDir .. "/Sounds.sh --volume"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Layout: Dwindle
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- ─────────────────────────────────────────────────────────────────────────────
-- Layout: Master
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + CTRL + D", hl.dsp.layout("removemaster"))
hl.bind(mainMod .. " + I", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd('pgrep -f "target/debug/app" && pkill -USR1 -f "target/debug/app" || /run/media/banana/Alpha/editor/test/src-tauri/target/debug/app'))
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.layout("swapwithmaster"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Layout: General
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Window Resizing (binde / repeating)
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { repeating = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- Window Moving
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "down" }))

-- ─────────────────────────────────────────────────────────────────────────────
-- Focus Management
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- ─────────────────────────────────────────────────────────────────────────────
-- Workspace Management (Workspaces 1-10 via Keycodes code:10 .. code:19)
-- ─────────────────────────────────────────────────────────────────────────────

local keycodes = {
    { code = "code:10", ws = 1 },
    { code = "code:11", ws = 2 },
    { code = "code:12", ws = 3 },
    { code = "code:13", ws = 4 },
    { code = "code:14", ws = 5 },
    { code = "code:15", ws = 6 },
    { code = "code:16", ws = 7 },
    { code = "code:17", ws = 8 },
    { code = "code:18", ws = 9 },
    { code = "code:19", ws = 10 },
}

for _, item in ipairs(keycodes) do
    -- Switch to workspace 1-10
    hl.bind(mainMod .. " + " .. item.code, hl.dsp.focus({ workspace = item.ws }))
    -- Move window to workspace 1-10
    hl.bind(mainMod .. " + SHIFT + " .. item.code, hl.dsp.window.move({ workspace = item.ws }))
    -- Move window silently to workspace 1-10
    hl.bind(mainMod .. " + CTRL + " .. item.code, hl.dsp.window.move({ workspace = item.ws, follow = false }))
end

-- Bracket moves
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + CTRL + bracketleft",   hl.dsp.window.move({ workspace = "-1", follow = false }))
hl.bind(mainMod .. " + CTRL + bracketright",  hl.dsp.window.move({ workspace = "+1", follow = false }))

-- ─────────────────────────────────────────────────────────────────────────────
-- Workspaces 11-19 (SUPER + ALT + 1-9)
-- ─────────────────────────────────────────────────────────────────────────────

for i = 1, 9 do
    local ws = 10 + i
    -- Switch to workspace 11-19
    hl.bind("SUPER + ALT + " .. i, hl.dsp.focus({ workspace = ws }))
    -- Move active window to workspace 11-19 (SUPER + ALT + SHIFT + 1-9)
    hl.bind("SUPER + ALT + SHIFT + " .. i, hl.dsp.window.move({ workspace = ws }))
end

-- Workspace 20 (SUPER + ALT + 0)
hl.bind("SUPER + ALT + 0", hl.dsp.focus({ workspace = 20 }))
hl.bind("SUPER + ALT + SHIFT + 0", hl.dsp.window.move({ workspace = 20 }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + period",     hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma",      hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + U",         hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + grave",     hl.dsp.focus({ workspace = "emptyn" }))

-- ─────────────────────────────────────────────────────────────────────────────
-- Mouse Bindings (bindm)
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- Spotlight / App Switcher
-- ─────────────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("quickshell ipc call spotlight toggle"))
