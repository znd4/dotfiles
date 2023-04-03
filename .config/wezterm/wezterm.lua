local wezterm = require("wezterm")
return {
    adjust_window_size_when_changing_font_size = false,
    color_scheme = "neon-night (Gogh)",
    default_prog = { "bash", "-c", "nix-shell --run zsh" },
    -- set font size to 14
    font_size = 14,
    -- set default font to Fira Code
    font = wezterm.font({ family = "Fira Code" }),
    -- Set italic fonts to Victor Mono
    font_rules = {
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
    },
}
