Distro = {}

if SMODS.Atlas then
    SMODS.Atlas({
        key = "modicon",
        path = "icon.png",
        px = 34,
        py = 34
    })
end

SMODS.load_file("src/config.lua")()
SMODS.load_file("src/localization.lua")()
SMODS.load_file("src/hooks.lua")()
