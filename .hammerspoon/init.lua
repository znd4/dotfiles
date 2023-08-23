hs.hotkey.bind({ "ctrl" }, "`", function()
    local wez = hs.application.find("Wezterm")
    if wez then
        if wez:isFrontmost() then
            print("hiding")
            local hidden = wez:hide()
            print("hidden: " .. tostring(hidden))
        else
            print("activating")
            wez:activate()
        end
    end
end)
