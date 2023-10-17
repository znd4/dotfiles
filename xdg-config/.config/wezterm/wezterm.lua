local wezterm = require("wezterm")

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    local gui_window = window:gui_window()
    gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
end)

-- This table will hold the configuration.
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end
-- append to config

config.window_background_opacity = 0.95
config.window_background_opacity = 1

config.exit_behavior = "CloseOnCleanExit"

config.adjust_window_size_when_changing_font_size = false
-- config.native_macos_fullscreen_mode = true

config.keys = {
    -- {
    --   key = "'",
    --   mods = "SUPER",
    --   action = wezterm.action.HideApplication,
    -- },
}

-- config.default_prog = { "cached-nix-shell", "--run", "SHELL=`which zsh` zsh -c tmux", wezterm.home_dir .. "/shell.nix" }
-- check if windows
wezterm.log_error("target_triple: " .. wezterm.target_triple)
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    local tmux_prog = { "wsl.exe", "-d", "debian", "--shell-type", "login", "--", "tmux", "new", "-Asdotfiles" }
else
    local tmux_prog = {
        os.getenv("SHELL"),
        "-c",
        "tmux new -Asdotfiles",
    }
end

local zellij_prog = {
    os.getenv("SHELL"),
    "--login",
    "-c",
    "zellij attach --create dotfiles",
}
config.default_prog = zellij_prog

config.launch_menu = {
    {
        label = "tmux",
        args = { "tmux", "new", "-Asdotfiles" },
    },
    {
        label = "zellij",
        args = zellij_prog,
    },
    {
        args = { "zsh", "--login" },
    },
}

config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
    left = 0,
    right = 0,
    top = "0.4cell",
    bottom = 0,
}

config.adjust_window_size_when_changing_font_size = false
config.color_scheme_dirs = { wezterm.home_dir .. "/.local/share/nvim/lazy/tokyonight.nvim/extras/wezterm/" }
config.color_scheme = "tokyonight_night"
-- set font size to 14
config.font_size = 14
-- set default font to Fira Code
-- config.font = wezterm.font_with_fallback({ "Fira Code", "Symbols Nerd Font" })
config.font = wezterm.font({ family = "Fira Code" })

-- Set italic fonts to Victor Mono
config.font_rules = {
    {
        intensity = "Bold",
        italic = true,
        font = wezterm.font({
            family = "Victor Mono",
            weight = "Bold",
            style = "Italic",
        }),
    },
    {
        italic = true,
        intensity = "Half",
        font = wezterm.font({
            family = "Victor Mono",
            weight = "DemiBold",
            style = "Italic",
        }),
    },
    {
        italic = true,
        intensity = "Normal",
        font = wezterm.font({
            family = "Victor Mono",
            style = "Italic",
        }),
    },
}

return config
