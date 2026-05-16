local mod = SMODS.current_mod
local cfg = mod.config
Distro.config = cfg

Distro.get_language = function()
    if cfg.language == "auto" then
        return G.SETTINGS.language or "en-us"
    end
    return cfg.language
end

local function save_config()
    SMODS.save_mod_config(mod)
end

local function toggle_row(label, ref)
    return {
        n = G.UIT.R,
        config = { padding = 0.01, align = "cr" },
        nodes = { create_toggle({label = label, ref_table = cfg, ref_value = ref, callback = save_config}) }
    }
end

mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = {
            { n = G.UIT.R, config = { align = "cm", padding = 0.01 }, nodes = {
                create_option_cycle({label = Distro.t("cfg_language"), ref_table = cfg, ref_value = "language",
                    options = {"auto", "en-us", "ru"}, opt_callback = "distro_language_changed"})
            }},
            { n = G.UIT.R, config = { padding = 0.2 }, nodes = {
                { n = G.UIT.C, config = { align = "cm" }, nodes = {
                    toggle_row(Distro.t("cfg_show_ante"), "show_ante"),
                    toggle_row(Distro.t("cfg_show_round"), "show_round"),
                    toggle_row(Distro.t("cfg_show_blind"), "show_blind"),
                    toggle_row(Distro.t("cfg_show_hands"), "show_hands"),
                    toggle_row(Distro.t("cfg_show_discards"), "show_discards"),
                    toggle_row(Distro.t("cfg_show_money"), "show_money"),
                }},
                { n = G.UIT.C, config = { align = "cm" }, nodes = {
                    toggle_row(Distro.t("cfg_show_deck"), "show_deck"),
                    toggle_row(Distro.t("cfg_show_stake"), "show_stake"),
                    toggle_row(Distro.t("cfg_show_challenge"), "show_challenge"),
                    toggle_row(Distro.t("cfg_show_blind_progress"), "show_blind_progress"),
                    toggle_row(Distro.t("cfg_carousel"), "carousel"),
                }}
            }}
        }
    }
end

function G.FUNCS.distro_language_changed()
    SMODS.save_mod_config(mod)
end
