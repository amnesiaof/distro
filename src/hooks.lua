local last_update = 0

local function format_num(n)
    local s = tostring(math.floor(n))
    local k = 3
    while #s > k do
        s = s:sub(1, #s - k)..","..s:sub(#s - k + 1)
        k = k + 4
    end
    return s
end

local function should_update()
    local now = love.timer.getTime()
    if now - last_update >= Distro.config.update_interval then
        last_update = now
        return true
    end
    return false
end

local function format_details()
    local parts = {}
    if Distro.config.show_ante then
        table.insert(parts, Distro.t("ante").." "..G.GAME.round_resets.ante)
    end
    if Distro.config.show_round then
        table.insert(parts, Distro.t("round").." "..G.GAME.round)
    end
    if Distro.config.show_money then
        table.insert(parts, Distro.t("money")..G.GAME.dollars)
    end
    return table.concat(parts, " | ")
end

local function update_activity(details, state)
    if not should_update() then
        return
    end

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

    DiscordIPC.send_activity()
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
        DiscordIPC.activity.timestamps = {
            start = os.time() * 1000
        }
    end

    update_activity("Balatro", Distro.t("idle"))
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    start_run_ref(self, args)
    update_activity(format_details(), Distro.t("start_run"))
end

local update_blind_select_ref = Game.update_blind_select
function Game:update_blind_select(dt)
    if not G.STATE_COMPLETE then
        update_activity(format_details(), Distro.t("blind_select"))
    end
    update_blind_select_ref(self, dt)
end

local update_selecting_hand_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
    if not G.STATE_COMPLETE then
        local blind_name = Distro.config.show_blind and Distro.get_blind_name() or nil
        local details = blind_name and (format_details().." | "..blind_name) or format_details()

        local state_data = {}
        if Distro.config.show_hands then state_data.hands = G.GAME.current_round.hands_left end
        if Distro.config.show_discards then state_data.discards = G.GAME.current_round.discards_left end
        if Distro.config.show_blind_progress and G.GAME.chips and G.GAME.blind and G.GAME.blind.chips then
            state_data.progress = format_num(G.GAME.chips).." / "..format_num(G.GAME.blind.chips)
        end

        update_activity(details, Distro.t("playing", state_data))
    end
    update_selecting_hand_ref(self, dt)
end

local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
    if not G.STATE_COMPLETE then
        update_activity(format_details(), Distro.t("shop"))
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
