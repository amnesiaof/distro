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

local function build_col(keys)
    local ns = {}
    for _, k in ipairs(keys) do
        table.insert(ns, toggle_row(Distro.t("cfg_"..k), k))
    end
    return ns
end

local function lang_index()
    for i, v in ipairs({"auto", "en-us", "ru"}) do
        if v == cfg.language then return i end
    end
    return 1
end

mod.config_tab = function()
    local lang_opts = {"auto", "en-us", "ru"}
    local left_keys = {"show_ante", "show_round", "show_blind", "show_hands", "show_discards", "show_money"}
    local right_keys = {"show_deck", "show_stake", "show_challenge", "show_blind_progress", "carousel"}

    return {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = {
            { n = G.UIT.R, config = { align = "cm", padding = 0.01 }, nodes = {
                create_option_cycle({label = Distro.t("cfg_language"),
                    options = lang_opts, current_option = lang_index(), opt_callback = "distro_language_changed"})
            }},
            { n = G.UIT.R, config = { padding = 0.2 }, nodes = {
                { n = G.UIT.C, config = { align = "cm" }, nodes = build_col(left_keys) },
                { n = G.UIT.C, config = { align = "cm" }, nodes = build_col(right_keys) },
            }}
        }
    }
end

function G.FUNCS.distro_language_changed(args)
    cfg.language = ({"auto", "en-us", "ru"})[args.to_key]
    SMODS.save_mod_config(mod)
end
