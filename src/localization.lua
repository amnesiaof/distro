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
            if data.score and data.score > 0 then table.insert(parts, "Score: "..data.score) end
            if data.hand_type then table.insert(parts, data.hand_type) end
            if data.elapsed then table.insert(parts, data.elapsed) end
            return table.concat(parts, " | ")
        end,
        shop = "In Shop",
        game_over = "Run Over",
        win = "Victory!",
        ante = "Ante",
        round = "Round",
        money = "$",
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
        cfg_show_hand_type = "Show Hand Type",
        cfg_show_score = "Show Score",
        cfg_show_elapsed = "Show Elapsed Time",
        cfg_show_button = "Show Steam Button",
        cfg_carousel = "Enable Carousel",
        cfg_reset_defaults = "Reset to defaults",
        elapsed_min = "m",
        elapsed_hr = "h",
        elapsed_day = "d",
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
            if data.score and data.score > 0 then table.insert(parts, "Счёт: "..data.score) end
            if data.hand_type then table.insert(parts, data.hand_type) end
            if data.elapsed then table.insert(parts, data.elapsed) end
            return table.concat(parts, " | ")
        end,
        shop = "В магазине",
        game_over = "Забег проигран",
        win = "Победа!",
        ante = "Анте",
        round = "Раунд",
        money = "$",
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
        cfg_show_hand_type = "Тип комбинации",
        cfg_show_score = "Счёт",
        cfg_show_elapsed = "Время в забеге",
        cfg_show_button = "Кнопка Steam",
        cfg_carousel = "Режим карусели",
        cfg_reset_defaults = "Сбросить настройки",
        elapsed_min = "м",
        elapsed_hr = "ч",
        elapsed_day = "д",
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
