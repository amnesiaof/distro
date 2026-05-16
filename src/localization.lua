Distro.translations = {
    ["en-us"] = {
        idle = "Idling",
        start_run = "New Run Started",
        blind_select = "Selecting Blind",
        playing = function(data)
            local parts = {}
            if data.progress then table.insert(parts, data.progress) end
            if data.hands then table.insert(parts, data.hands.." Hands") end
            if data.discards then table.insert(parts, data.discards.." Discards") end
            return table.concat(parts, " | ")
        end,
        shop = "In Shop",
        game_over = "Run Over",
        win = "Victory!",
        ante = "Ante",
        round = "Round",
        money = "$",
        cfg_tab_display = "Display",
        cfg_tab_extra = "Extra",
        cfg_tab_carousel = "Carousel",
        cfg_language = "Language",
        cfg_show_ante = "Show Ante",
        cfg_show_round = "Show Round",
        cfg_show_blind = "Show Blind Name",
        cfg_show_hands = "Show Hands",
        cfg_show_discards = "Show Discards",
        cfg_show_money = "Show Money",
        cfg_show_deck = "Show Deck",
        cfg_show_stake = "Show Stake",
        cfg_show_challenge = "Show Challenge Mode",
        cfg_show_blind_progress = "Blind Score Progress",
        cfg_carousel = "Enable Carousel",
        cfg_reset_defaults = "Reset to defaults",
    },
    ["ru"] = {
        idle = "В меню",
        start_run = "Новый забег",
        blind_select = "Выбор блайнда",
        playing = function(data)
            local parts = {}
            if data.progress then table.insert(parts, data.progress) end
            if data.hands then table.insert(parts, data.hands.." рук") end
            if data.discards then table.insert(parts, data.discards.." сбросов") end
            return table.concat(parts, " | ")
        end,
        shop = "В магазине",
        game_over = "Забег проигран",
        win = "Победа!",
        ante = "Анте",
        round = "Раунд",
        money = "$",
        cfg_tab_display = "Основные",
        cfg_tab_extra = "Дополнительно",
        cfg_tab_carousel = "Карусель",
        cfg_language = "Язык",
        cfg_show_ante = "Показывать анте",
        cfg_show_round = "Показывать раунд",
        cfg_show_blind = "Название блайнда",
        cfg_show_hands = "Остаток рук",
        cfg_show_discards = "Остаток сбросов",
        cfg_show_money = "Деньги",
        cfg_show_deck = "Колода",
        cfg_show_stake = "Ставка",
        cfg_show_challenge = "Режим испытаний",
        cfg_show_blind_progress = "Прогресс блайнда",
        cfg_carousel = "Режим карусели",
        cfg_reset_defaults = "Сбросить настройки",
    },
}

Distro.t = function(key, data)
    local lang = Distro.get_language()
    local trans = Distro.translations[lang] or Distro.translations["en-us"]
    local val = trans[key]
    if type(val) == "function" then
        return val(data or {})
    end
    return val or key
end
