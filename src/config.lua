local cfg = SMODS.current_mod.config
Distro.config = cfg

local tab_state = { value = 1 }
local tab_keys = {"display", "extra", "carousel"}

local function current_tab()
    for i, k in ipairs(tab_keys) do
        if Distro.t("cfg_tab_"..k) == tab_state.value then
            return k
        end
    end
    tab_state.value = Distro.t("cfg_tab_display")
    return "display"
end

Distro.get_language = function()
    if cfg.language == "auto" then
        return G.SETTINGS.language or "en-us"
    end
    return cfg.language
end

local function lbl(key)
    return Distro.t("cfg_"..key)
end

local function toggle_row(label, ref)
    return {
        n = G.UIT.R,
        config = { align = 'cm' },
        nodes = { create_toggle({label = label, ref_table = cfg, ref_value = ref}) }
    }
end

SMODS.current_mod.config_tab = function()
    local tab = current_tab()
    local tab_opts = {}
    for _, k in ipairs(tab_keys) do
        table.insert(tab_opts, Distro.t("cfg_tab_"..k))
    end

    local nodes = {
        { n = G.UIT.R, config = { align = 'cm' }, nodes = {
            { n = G.UIT.T, config = { text = "Distro", scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
        }},
        { n = G.UIT.R, config = { align = 'cm', minh = 0.1 }},
        { n = G.UIT.R, config = { align = 'cm' }, nodes = {
            create_option_cycle({label = "", ref_table = tab_state, ref_value = "value", options = tab_opts})
        }},
    }

    local tab_nodes
    if tab == "display" then
        tab_nodes = {
            { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                create_option_cycle({label = lbl("language"), ref_table = cfg, ref_value = "language", options = {"auto", "en-us", "ru"}})
            }},
            toggle_row(lbl("show_ante"), "show_ante"),
            toggle_row(lbl("show_round"), "show_round"),
            toggle_row(lbl("show_blind"), "show_blind"),
            toggle_row(lbl("show_hands"), "show_hands"),
            toggle_row(lbl("show_discards"), "show_discards"),
            toggle_row(lbl("show_money"), "show_money"),
        }
    elseif tab == "extra" then
        tab_nodes = {
            toggle_row(lbl("show_deck"), "show_deck"),
            toggle_row(lbl("show_stake"), "show_stake"),
            toggle_row(lbl("show_challenge"), "show_challenge"),
            toggle_row(lbl("show_blind_progress"), "show_blind_progress"),
        }
    else
        tab_nodes = {
            toggle_row(lbl("carousel"), "carousel"),
        }
    end

    for _, node in ipairs(tab_nodes) do
        table.insert(nodes, node)
    end

    return {
        n = G.UIT.ROOT,
        config = { align = 'cm', padding = 0.1, colour = G.C.CLEAR },
        nodes = nodes,
    }
end
