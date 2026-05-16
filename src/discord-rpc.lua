local ffi = require("ffi")
ffi.cdef[[
    typedef unsigned int size_t;
    typedef unsigned short sa_family_t;
    typedef unsigned int socklen_t;
    typedef int ssize_t;

    struct sockaddr {
        sa_family_t sa_family;
        char sa_data[14];
    };

    struct sockaddr_un {
        sa_family_t sun_family;
        char sun_path[104];
    };

    int socket(int domain, int type, int protocol);
    int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    ssize_t send(int sockfd, const void *buf, size_t len, int flags);
    ssize_t recv(int sockfd, void *buf, size_t len, int flags);
    int close(int fd);
]]

DiscordIPC = {
    id = "1244356034689237082",
    activity = {},
    is_windows = love.system.getOS() == "Windows",
    connected = false,
    socket = nil,
    OPCODES = {
        HANDSHAKE = 0,
        FRAME = 1,
        CLOSE = 2,
        PING = 3,
        PONG = 4,
    },
}

function DiscordIPC.connect()
    if DiscordIPC.connected then return true end

    if DiscordIPC.is_windows then
        for i = 0, 9 do
            local file, err = io.open("\\\\.\\pipe\\discord-ipc-"..i, "r+b")
            if file then
                print("Distro :: Connected to Discord IPC (pipe "..i..")")
                DiscordIPC.socket = file
                DiscordIPC.connected = true
                break
            end
        end
        if not DiscordIPC.connected then
            print("Distro :: Failed to connect to any Discord IPC pipe")
            return false
        end
    else
        local socket = ffi.C.socket(1, 1, 0)
        if socket < 0 then
            print("Distro :: Failed to create Discord IPC socket")
            return false
        end

        local env_path = nil
        for _, v in ipairs({ "XDG_RUNTIME_DIR", "TMPDIR", "TMP", "TEMP" }) do
            env_path = os.getenv(v)
            if env_path then
                if env_path:sub(-1) == "/" then
                    env_path = env_path:sub(1, -2)
                end
                break
            end
        end
        if not env_path then env_path = "/tmp" end

        local pipe_suffixes = { "", "app/com.discordapp.Discord/", "snap.discord-canary/", "snap.discord/" }

        local connected = false
        for i = 0, 9 do
            for _, suffix in ipairs(pipe_suffixes) do
                local address = ffi.new("struct sockaddr_un")
                address.sun_family = 1
                ffi.copy(address.sun_path, env_path.."/"..suffix.."discord-ipc-"..i)

                if ffi.C.connect(socket, ffi.cast("const struct sockaddr*", address), ffi.sizeof(address)) == 0 then
                    print("Distro :: Connected to Discord IPC (pipe "..i..")")
                    DiscordIPC.socket = socket
                    DiscordIPC.connected = true
                    connected = true
                    break
                end
            end
            if connected then break end
        end

        if not connected then
            print("Distro :: Failed to connect to any Discord IPC pipe")
            ffi.C.close(socket)
            return false
        end
    end

    local result, _ = DiscordIPC.send_handshake()
    if result ~= DiscordIPC.OPCODES.FRAME then
        print("Distro :: Discord IPC handshake failed")
        DiscordIPC.close()
        return false
    end

    return true
end

function DiscordIPC.reconnect()
    DiscordIPC.close()
    return DiscordIPC.connect()
end

function DiscordIPC.write(message)
    if not DiscordIPC.socket then return end

    if DiscordIPC.is_windows then
        DiscordIPC.socket:seek("end")
        local _, err = DiscordIPC.socket:write(message)
        DiscordIPC.socket:flush()
        if err then
            print("Distro :: Failed to write to Discord IPC - "..err)
        end
    else
        local sent = ffi.C.send(DiscordIPC.socket, message, #message, 0)
        if sent < 0 then
            print("Distro :: Failed to write to Discord IPC")
        end
    end
end

function DiscordIPC.read(buffer)
    if not DiscordIPC.socket then return end
    if DiscordIPC.is_windows then
        return DiscordIPC.socket:read(buffer)
    else
        local data_buffer = ffi.new("char[?]", buffer)
        local bytes = ffi.C.recv(DiscordIPC.socket, data_buffer, buffer, 0)
        if bytes < 0 then return nil end
        return ffi.string(data_buffer, bytes)
    end
end

function DiscordIPC.close()
    if not DiscordIPC.socket then return end

    DiscordIPC.send("{}", DiscordIPC.OPCODES.CLOSE)

    if DiscordIPC.is_windows then
        DiscordIPC.socket:close()
    else
        ffi.C.close(DiscordIPC.socket)
    end

    DiscordIPC.socket = nil
    DiscordIPC.connected = false
    print("Distro :: Disconnected from Discord IPC")
end

function DiscordIPC.send(data, opcode)
    DiscordIPC.write(Distro.pack(opcode, #data)..data)
end

function DiscordIPC.send_handshake()
    DiscordIPC.send('{"v": 1, "client_id": "'..DiscordIPC.id..'"}', DiscordIPC.OPCODES.HANDSHAKE)
    return DiscordIPC.receive()
end

function DiscordIPC.send_activity()
    if not DiscordIPC.connected then return end
    local data = {
        cmd = "SET_ACTIVITY",
        args = {
            pid = Distro.get_pid() or 9999,
            activity = DiscordIPC.activity,
        },
        nonce = Distro.get_uuid(),
    }
    DiscordIPC.send(Distro.stringify(data), DiscordIPC.OPCODES.FRAME)
end

function DiscordIPC.clear_activity()
    if not DiscordIPC.connected then return end
    local data = {
        cmd = "SET_ACTIVITY",
        args = {
            pid = Distro.get_pid() or 9999,
            activity = {},
        },
        nonce = Distro.get_uuid(),
    }
    DiscordIPC.send(Distro.stringify(data), DiscordIPC.OPCODES.FRAME)
end

function DiscordIPC.receive()
    if DiscordIPC.is_windows then
        local header = DiscordIPC.read(8)
        if not header then return nil, nil end
        local opcode, length = Distro.unpack(header)
        local data = DiscordIPC.read(length)
        return opcode, data
    else
        local header_buffer = ffi.new("char[8]")
        local header_bytes = ffi.C.recv(DiscordIPC.socket, header_buffer, 8, 0)
        if header_bytes < 0 then return nil, nil end
        local opcode, length = Distro.unpack(ffi.string(header_buffer, header_bytes))

        local data_buffer = ffi.new("char[?]", length)
        local data_bytes = ffi.C.recv(DiscordIPC.socket, data_buffer, length, 0)
        if data_bytes < 0 then return nil, nil end
        local data = ffi.string(data_buffer, data_bytes)

        return opcode, data
    end
end
