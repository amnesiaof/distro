local cfg = SMODS.current_mod.config
Distro.config = cfg

Distro.get_language = function()
    if cfg.language == "auto" then
        return G.SETTINGS.language or "en-us"
    end
    return cfg.language
end

SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {align = 'cm', padding = 0.1, colour = G.C.CLEAR},
        nodes = {
            {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                {n = G.UIT.T, config = {text = "Distro — Discord Rich Presence", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
            }},
            {n = G.UIT.R, config = {align = 'cm', minh = 0.1}},
            create_option_cycle({label = "Language", ref_table = cfg, ref_value = "language", options = {"auto", "en-us", "ru"}}),
            {n = G.UIT.R, config = {align = 'cm', minh = 0.1}},
            create_toggle({label = "Show Ante", ref_table = cfg, ref_value = "show_ante"}),
            create_toggle({label = "Show Round", ref_table = cfg, ref_value = "show_round"}),
            create_toggle({label = "Show Blind Name", ref_table = cfg, ref_value = "show_blind"}),
            create_toggle({label = "Show Hands", ref_table = cfg, ref_value = "show_hands"}),
            create_toggle({label = "Show Discards", ref_table = cfg, ref_value = "show_discards"}),
            {n = G.UIT.R, config = {align = 'cm', minh = 0.05}},
            create_toggle({label = "Show Money", ref_table = cfg, ref_value = "show_money"}),
            create_toggle({label = "Show Deck", ref_table = cfg, ref_value = "show_deck"}),
            create_toggle({label = "Show Stake", ref_table = cfg, ref_value = "show_stake"}),
            create_toggle({label = "Show Challenge Mode", ref_table = cfg, ref_value = "show_challenge"}),
            create_toggle({label = "Blind Score Progress", ref_table = cfg, ref_value = "show_blind_progress"}),
            {n = G.UIT.R, config = {align = 'cm', minh = 0.1}},
            {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                {n = G.UIT.T, config = {text = "Carousel Mode", scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
            }},
            create_toggle({label = "Enable Carousel", ref_table = cfg, ref_value = "carousel"}),
        }
    }
end
