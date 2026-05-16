local ffi = require("ffi")

function Distro.get_uuid()
    math.randomseed(os.time())
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

function Distro.get_pid()
    if DiscordIPC.is_windows then
        ffi.cdef[[unsigned long GetCurrentProcessId(void);]]
        return ffi.C.GetCurrentProcessId()
    else
        ffi.cdef[[int getpid(void);]]
        return ffi.C.getpid()
    end
end

function Distro.stringify(data)
    local result = {}
    for k, v in pairs(data) do
        local formatted
        if type(v) == "table" then
            formatted = Distro.stringify(v)
        elseif type(v) == "string" then
            formatted = '"'..v..'"'
        else
            formatted = tostring(v)
        end
        table.insert(result, string.format('"%s":%s', k, formatted))
    end
    return "{"..table.concat(result, ",").."}"
end

function Distro.int_to_le_bytes(number)
    local hex = string.format("%04x", number)
    local result = { tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(1, 2), 16) }
    for _ = 1, 4 - #result do table.insert(result, 0) end
    return result
end

function Distro.le_bytes_to_int(bytes)
    local result = 0
    for i, v in ipairs(bytes) do
        result = result + v * (0x100 ^ (i - 1))
    end
    return math.floor(result)
end

function Distro.string_to_le_bytes(str)
    local result = {}
    for i = 1, #str do table.insert(result, str:byte(i)) end
    return result
end

function Distro.le_bytes_to_string(bytes)
    local result = {}
    for _, v in ipairs(bytes) do
        local byte = v < 0 and (0xff + v + 1) or v
        table.insert(result, string.char(byte))
    end
    return table.concat(result)
end

function Distro.pack(opcode, length)
    return Distro.le_bytes_to_string(Distro.int_to_le_bytes(opcode))
        .. Distro.le_bytes_to_string(Distro.int_to_le_bytes(length))
end

function Distro.unpack(data)
    return Distro.le_bytes_to_int(Distro.string_to_le_bytes(data:sub(1, 4))),
        Distro.le_bytes_to_int(Distro.string_to_le_bytes(data:sub(5, 8)))
end

function Distro.get_back_name()
    local back = G.GAME.selected_back
    if not back or not back.effect or not back.effect.center then
        return "default", "Balatro"
    end
    local center = back.effect.center
    local key = center.key
    local name = center.name or key
    if center.loc_txt and center.loc_txt.name then
        name = center.loc_txt.name
    end
    return key or "default", name or "Balatro"
end

function Distro.get_stake_name()
    local stake_idx = G.GAME.stake
    if not stake_idx then
        return nil, nil
    end
    local pool = G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake
    if not pool or not pool[stake_idx] then
        return nil, nil
    end
    local center = pool[stake_idx]
    local key = center.key
    local name = center.name or key
    if center.loc_txt and center.loc_txt.name then
        name = center.loc_txt.name
    end
    return key, name
end

function Distro.get_blind_name()
    if not G.GAME.blind or not G.GAME.blind.config or not G.GAME.blind.config.blind then
        return ""
    end
    local key = G.GAME.blind.config.blind.key
    local center = G.P_BLINDS and G.P_BLINDS[key]
    if not center then
        return ""
    end
    local name = center.name or key
    if center.loc_txt and center.loc_txt.name then
        name = center.loc_txt.name
    end
    return name
end
