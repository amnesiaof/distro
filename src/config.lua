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

mod.config_tab = function()
    local left_keys = {"show_ante", "show_round", "show_blind", "show_hands", "show_discards", "show_money"}
    local right_keys = {"show_deck", "show_stake", "show_challenge", "show_blind_progress", "carousel"}

    return {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = {
            { n = G.UIT.R, config = { padding = 0.2 }, nodes = {
                { n = G.UIT.C, config = { align = "cm" }, nodes = build_col(left_keys) },
                { n = G.UIT.C, config = { align = "cm" }, nodes = build_col(right_keys) },
            }}
        }
    }
end
