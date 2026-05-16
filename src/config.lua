local mod = SMODS.current_mod
local cfg = mod.config
Distro.config = cfg

Distro.get_language = function()
    if cfg.language == "auto" then
        return G.SETTINGS.language or "en-us"
    end
    return cfg.language
end

local function toggle_row(label, ref)
    return {
        n = G.UIT.R,
        config = { align = 'cm' },
        nodes = { create_toggle({label = label, ref_table = cfg, ref_value = ref}) }
    }
end

mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = 'cm', padding = 0.1, colour = G.C.CLEAR },
        nodes = {
            { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                { n = G.UIT.T, config = { text = "Distro", scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
            }},
            { n = G.UIT.R, config = { align = 'cm', minh = 0.1 }},
            { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                create_option_cycle({label = Distro.t("cfg_language"), ref_table = cfg, ref_value = "language",
                    options = {"auto", "en-us", "ru"}, opt_callback = "distro_language_changed"})
            }},
            toggle_row(Distro.t("cfg_show_ante"), "show_ante"),
            toggle_row(Distro.t("cfg_show_round"), "show_round"),
            toggle_row(Distro.t("cfg_show_blind"), "show_blind"),
            toggle_row(Distro.t("cfg_show_hands"), "show_hands"),
            toggle_row(Distro.t("cfg_show_discards"), "show_discards"),
            toggle_row(Distro.t("cfg_show_money"), "show_money"),
            toggle_row(Distro.t("cfg_show_deck"), "show_deck"),
            toggle_row(Distro.t("cfg_show_stake"), "show_stake"),
            toggle_row(Distro.t("cfg_show_challenge"), "show_challenge"),
            toggle_row(Distro.t("cfg_show_blind_progress"), "show_blind_progress"),
            toggle_row(Distro.t("cfg_carousel"), "carousel"),
        }
    }
end

function G.FUNCS.distro_language_changed()
    SMODS.save_mod_config(mod)
end
