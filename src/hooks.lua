local last_update = 0

local function should_update()
    local now = love.timer.getTime()
    if now - last_update >= Distro.config.update_interval then
        last_update = now
        return true
    end
    return false
end

local function format_num(n)
    if not n then return "0" end
    local s = tostring(math.floor(n))
    local k = 3
    while #s > k do
        s = s:sub(1, #s - k)..","..s:sub(#s - k + 1)
        k = k + 4
    end
    return s
end

local function get_hand_type_name()
    local h = G.hand_text_area
    if h and type(h.handname) == "string" then
        return h.handname
    end
    return nil
end

local function get_score_text()
    local chips = G.GAME.chips
    local mult = G.GAME.mult
    if chips and mult and chips > 0 and mult > 0 then
        return format_num(chips * mult)
    end
    if chips and chips > 0 then
        return format_num(chips)
    end
    return nil
end

local function get_elapsed_text()
    if not Distro.run_start then return nil end
    local elapsed = os.time() - Distro.run_start
    if elapsed < 60 then return nil end
    local minutes = math.floor(elapsed / 60)
    if minutes < 60 then
        return minutes..Distro.t("elapsed_min")
    end
    local hours = math.floor(minutes / 60)
    local rem_min = minutes % 60
    if hours < 24 then
        return hours..Distro.t("elapsed_hr").." "..rem_min..Distro.t("elapsed_min")
    end
    local days = math.floor(hours / 24)
    local rem_hrs = hours % 24
    return days..Distro.t("elapsed_day").." "..rem_hrs..Distro.t("elapsed_hr")
end

local function format_fields(keys)
    local parts = {}
    for _, k in ipairs(keys) do
        if k == "ante" and Distro.config.show_ante then
            table.insert(parts, Distro.t("ante").." "..G.GAME.round_resets.ante)
        elseif k == "round" and Distro.config.show_round then
            table.insert(parts, Distro.t("round").." "..G.GAME.round)
        elseif k == "money" and Distro.config.show_money then
            table.insert(parts, Distro.t("money")..G.GAME.dollars)
        end
    end
    return table.concat(parts, " | ")
end

local function format_details()
    local base = format_fields({"ante", "round", "money"})
    local extras = {}
    if Distro.config.show_blind then
        local name = Distro.get_blind_name()
        if name and name ~= "" then table.insert(extras, name) end
    end
    if Distro.config.show_hand_type then
        local hand = get_hand_type_name()
        if hand then table.insert(extras, hand) end
    end
    if #extras > 0 then
        if base == "" then
            base = table.concat(extras, " | ")
        else
            base = base.." | "..table.concat(extras, " | ")
        end
    end
    return base
end

local function playing_state_text()
    local data = {}
    if Distro.config.show_hands then data.hands = G.GAME.current_round.hands_left end
    if Distro.config.show_discards then data.discards = G.GAME.current_round.discards_left end
    if Distro.config.show_blind_progress and G.GAME.chips and G.GAME.blind and G.GAME.blind.chips then
        data.progress = format_num(G.GAME.chips).." / "..format_num(G.GAME.blind.chips)
    end
    if Distro.config.show_score then
        local score = get_score_text()
        if score then data.score = score end
    end
    if Distro.config.show_hand_type then
        local hand = get_hand_type_name()
        if hand then data.hand_type = hand end
    end
    if Distro.config.show_elapsed then
        local elapsed = get_elapsed_text()
        if elapsed then data.elapsed = elapsed end
    end
    return Distro.t("playing", data)
end

local function update_activity(details, state)
    if not should_update() then return end

    local back_key, back_name = Distro.get_back_name()
    local stake_key, stake_name = Distro.get_stake_name()

    DiscordIPC.activity.details = details
    DiscordIPC.activity.state = state
    DiscordIPC.activity.assets = {}

    if Distro.config.show_deck then
        DiscordIPC.activity.assets.large_image = back_key
        DiscordIPC.activity.assets.large_text = back_name
    else
        DiscordIPC.activity.assets.large_image = "default"
        DiscordIPC.activity.assets.large_text = nil
    end

    if Distro.config.show_stake then
        DiscordIPC.activity.assets.small_image = stake_key
        DiscordIPC.activity.assets.small_text = stake_name
    end

    if G.GAME.challenge and Distro.config.show_challenge then
        for _, v in ipairs(G.CHALLENGES) do
            if v.id == G.GAME.challenge then
                DiscordIPC.activity.assets.small_text = "Challenge ("..v.name..")"
                break
            end
        end
        if not Distro.config.show_stake then
            DiscordIPC.activity.assets.small_image = nil
        end
    end

    DiscordIPC.activity.buttons = nil

    DiscordIPC.send_activity()
end

-- Carousel pages
local carousel = { idx = 1, last = 0 }

local pages = {}

pages.progress = {
    details = function() return format_fields({"ante", "round"}) end,
    state = function()
        if G.STATE == G.STATES.SELECTING_HAND then return playing_state_text()
        elseif G.STATE == G.STATES.SHOP then return Distro.t("shop")
        elseif G.STATE == G.STATES.BLIND_SELECT then return Distro.t("blind_select") end
        return ""
    end,
    available = function() return true end,
}

pages.blind = {
    details = function() return Distro.get_blind_name() end,
    state = function()
        if G.GAME.chips and G.GAME.blind and G.GAME.blind.chips then
            return format_num(G.GAME.chips).." / "..format_num(G.GAME.blind.chips)
        end
        return ""
    end,
    available = function()
        return Distro.config.show_blind and G.GAME.blind and G.GAME.blind.chips
            and G.STATE == G.STATES.SELECTING_HAND
    end,
}

pages.money = {
    details = function() return Distro.t("money")..G.GAME.dollars end,
    state = function()
        if G.GAME.challenge and Distro.config.show_challenge then
            for _, v in ipairs(G.CHALLENGES) do
                if v.id == G.GAME.challenge then
                    return "Challenge ("..v.name..")"
                end
            end
        end
        return ""
    end,
    available = function() return Distro.config.show_money end,
}

pages.hand = {
    details = function()
        local h = G.hand_text_area
        if h and type(h.handname) == "string" and h.hand_level then
            return h.handname.." lv."..h.hand_level
        end
        return format_fields({"ante", "round"})
    end,
    state = function()
        local h = G.hand_text_area
        local parts = {}
        if h and h.chips then table.insert(parts, "+"..format_num(h.chips).." chips") end
        if h and h.mult then table.insert(parts, "x"..format_num(h.mult).." mult") end
        return table.concat(parts, " | ")
    end,
    available = function()
        return G.STATE == G.STATES.SELECTING_HAND
            and G.hand_text_area and type(G.hand_text_area.handname) == "string"
    end,
}

local function get_active_pages()
    local active = {}
    for _, key in ipairs(Distro.config.carousel_pages) do
        local p = pages[key]
        if p and p.available() then
            table.insert(active, p)
        end
    end
    return active
end

local function carousel_tick()
    local active = get_active_pages()
    if #active == 0 then
        carousel.idx = 1
        return format_fields({"ante"}), Distro.t("idle")
    end

    local now = love.timer.getTime()
    if now - carousel.last >= Distro.config.carousel_interval then
        carousel.last = now
        carousel.idx = carousel.idx % #active + 1
    end

    if carousel.idx > #active then carousel.idx = 1 end
    local p = active[carousel.idx]
    local d = p.details()
    local s = p.state()
    if not d or d == "" then d = format_fields({"ante", "round"}) end
    if not s then s = "" end
    return d, s
end

local main_menu_ref = Game.main_menu
function Game:main_menu(change_context)
    main_menu_ref(self, change_context)

    if not Distro.initialized then
        SMODS.load_file("src/util.lua", "Distro")()
        SMODS.load_file("src/discord-rpc.lua", "Distro")()
        Distro.initialized = true
    end

    if not DiscordIPC.connected and not DiscordIPC.connect() then
        print("Distro :: Failed to connect to Discord IPC")
        DiscordIPC.reconnect()
    end

    if not DiscordIPC.activity.timestamps then
        DiscordIPC.activity.timestamps = { start = os.time() * 1000 }
    end

    DiscordIPC.activity.details = "Balatro"
    DiscordIPC.activity.state = Distro.t("idle")
    DiscordIPC.activity.assets = {
        large_image = "default",
        large_text = nil,
    }
    DiscordIPC.activity.buttons = nil
    DiscordIPC.send_activity()
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    start_run_ref(self, args)
    carousel.last = love.timer.getTime()
    Distro.run_start = os.time()
    update_activity(format_details(), Distro.t("start_run"))
end

local update_blind_select_ref = Game.update_blind_select
function Game:update_blind_select(dt)
    if not G.STATE_COMPLETE then
        if Distro.config.carousel then
            update_activity(carousel_tick())
        else
            update_activity(format_details(), Distro.t("blind_select"))
        end
    end
    update_blind_select_ref(self, dt)
end

local update_selecting_hand_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
    if not G.STATE_COMPLETE then
        if Distro.config.carousel then
            update_activity(carousel_tick())
        else
            local details = format_details()
            update_activity(details, playing_state_text())
        end
    end
    update_selecting_hand_ref(self, dt)
end

local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
    if not G.STATE_COMPLETE then
        if Distro.config.carousel then
            update_activity(carousel_tick())
        else
            update_activity(format_details(), Distro.t("shop"))
        end
    end
    update_shop_ref(self, dt)
end

local game_over_state = G.STATES and G.STATES.GAME_OVER
local win_state = G.STATES and G.STATES.WIN
local end_shown = false

local function set_end_state(state)
    DiscordIPC.activity.details = "Balatro"
    DiscordIPC.activity.state = state
    DiscordIPC.activity.assets = {
        large_image = "default",
        large_text = "Balatro"
    }
    DiscordIPC.activity.buttons = nil
    DiscordIPC.send_activity()
end

local game_update_ref = Game.update
function Game:update(dt)
    game_update_ref(self, dt)
    if G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante and G.GAME.round_resets.ante > 0 then
        if game_over_state and G.STATE == game_over_state then
            if not end_shown then
                end_shown = true
                set_end_state(Distro.t("game_over"))
            end
        elseif win_state and G.STATE == win_state then
            if not end_shown then
                end_shown = true
                set_end_state(Distro.t("win"))
            end
        else
            end_shown = false
        end
    else
        end_shown = false
    end
end

local quit_ref = G.FUNCS.quit
function G.FUNCS.quit(e)
    DiscordIPC.close()
    quit_ref(e)
end
