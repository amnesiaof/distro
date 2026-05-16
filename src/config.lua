Distro.config = {
    language = "auto",
    show_ante = true,
    show_round = true,
    show_blind = true,
    show_hands = true,
    show_discards = true,
    show_money = false,
    show_deck = false,
    show_stake = false,
    show_challenge = true,
    update_interval = 1.0,
}

Distro.get_language = function()
    if Distro.config.language == "auto" then
        return G.SETTINGS.language or "en-us"
    end
    return Distro.config.language
end
