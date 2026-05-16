local mod = SMODS.current_mod
local cfg = mod.config
Distro.config = cfg

Distro.get_language = function()
    return G.SETTINGS.language or "en-us"
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

local function build_col(keys)
    local ns = {}
    for _, k in ipairs(keys) do
        table.insert(ns, toggle_row(Distro.t("cfg_"..k), k))
    end
    return ns
end

local DEFAULTS = {
    show_ante = true, show_round = true, show_blind = true,
    show_hands = true, show_discards = true, show_money = false,
    show_deck = false, show_stake = false, show_challenge = true,
    show_blind_progress = false, show_hand_type = true,
    show_score = false, show_elapsed = false, show_button = false,
    carousel = false,
}

G.FUNCS.distro_reset_defaults = function()
    for k, v in pairs(DEFAULTS) do
        cfg[k] = v
    end
    save_config()
    G.FUNCS.exit_overlay_menu()
end

mod.config_tab = function()
    local left_keys = {"show_ante", "show_round", "show_blind", "show_hands", "show_discards", "show_money"}
    local right_keys = {"show_deck", "show_stake", "show_challenge", "show_blind_progress", "show_hand_type", "show_score", "show_elapsed", "show_button"}

    return {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = {
            { n = G.UIT.R, config = { padding = 0.2 }, nodes = {
                { n = G.UIT.C, config = { align = "cm" }, nodes = build_col(left_keys) },
                { n = G.UIT.C, config = { align = "cm" }, nodes = build_col(right_keys) },
            }},
            { n = G.UIT.R, config = { padding = 0.1, align = "cm" }, nodes = {
                UIBox_button({
                    button = "distro_reset_defaults",
                    label = { Distro.t("cfg_reset_defaults") },
                    colour = G.C.JOKER_GREY,
                    minw = 2.8,
                    minh = 0.6,
                    scale = 0.35,
                })
            }}
        }
    }
end
