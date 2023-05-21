local wezterm = require("wezterm")
-- This table will hold the configuration.
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end
-- append to config

config.window_background_opacity = 0.95

-- config.exit_behavior = "CloseOnCleanExit"

config.adjust_window_size_when_changing_font_size = false

-- config.default_prog = { "cached-nix-shell", "--run", "zsh", wezterm.home_dir .. "/shell.nix" }
config.default_prog = { "cached-nix-shell", "--run", "tmux", wezterm.home_dir .. "/shell.nix" }
-- config.default_prog = { "tmux" }

config.adjust_window_size_when_changing_font_size = false
config.color_scheme = "neon-night (Gogh)"
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
