local wezterm = require("wezterm")
-- This table will hold the configuration.
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end
-- append to config

config.adjust_window_size_when_changing_font_size = false

-- config.default_prog = { "bash", "-c", "nix-shell --run zsh" }
-- config.default_prog = { "zsh", "-c", "nix-shell --run zsh" }
config.default_prog = { "nix-shell", "--run", "zsh" }

config.adjust_window_size_when_changing_font_size = false
config.color_scheme = "neon-night (Gogh)"
-- set font size to 14
config.font_size = 14
-- set default font to Fira Code
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
