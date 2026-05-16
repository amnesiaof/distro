Distro.translations = {
    ["en-us"] = {
        idle = "Idling",
        start_run = "New Run Started",
        blind_select = "Selecting Blind",
        playing = function(data)
            local parts = {}
            if data.hands then table.insert(parts, data.hands.." Hands") end
            if data.discards then table.insert(parts, data.discards.." Discards") end
            return table.concat(parts, ", ").." left"
        end,
        shop = "In Shop",
        ante = "Ante",
        round = "Round",
        money = "$",
    },
    ["ru"] = {
        idle = "В меню",
        start_run = "Новый забег",
        blind_select = "Выбор блайнда",
        playing = function(data)
            local parts = {}
            if data.hands then table.insert(parts, data.hands.." рук") end
            if data.discards then table.insert(parts, data.discards.." сбросов") end
            return "Осталось: "..table.concat(parts, ", ")
        end,
        shop = "В магазине",
        ante = "Анте",
        round = "Раунд",
        money = "$",
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
