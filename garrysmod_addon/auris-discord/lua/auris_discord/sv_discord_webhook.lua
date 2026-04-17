local Config = include("auris_discord/sv_discord_config.lua")

---@class AurisDiscord
local AurisDiscord = {}

local BOUNDARY  = "AurisDiscordBoundary"
local STEAM_API = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/"

---@param steamid64 string
---@param callback fun(avatarUrl: string|nil)
local function fetchAvatar(steamid64, callback)
    if Config.STEAM_API_KEY == "" then callback(nil) return end

    HTTP({
        method  = "GET",
        url     = STEAM_API .. "?key=" .. Config.STEAM_API_KEY .. "&steamids=" .. steamid64,
        timeout = 10,
        success = function(_, body)
            local data = util.JSONToTable(body)
            local p = data and data.response and data.response.players and data.response.players[1]
            callback(p and p.avatarfull or nil)
        end,
        failed = function() callback(nil) end,
    })
end

---@param name string
---@param text string
---@param avatarUrl string|nil
---@param wav string WAV binary
---@return string body
---@return string contentType
local function buildMultipart(name, text, avatarUrl, wav)
    local payload = util.TableToJSON({ username = name, content = text, avatar_url = avatarUrl })
    local body = "--" .. BOUNDARY .. "\r\n"
        .. 'Content-Disposition: form-data; name="payload_json"\r\n'
        .. "Content-Type: application/json\r\n\r\n"
        .. payload .. "\r\n"
        .. "--" .. BOUNDARY .. "\r\n"
        .. 'Content-Disposition: form-data; name="files[0]"; filename="voice.wav"\r\n'
        .. "Content-Type: audio/wav\r\n\r\n"
        .. wav .. "\r\n"
        .. "--" .. BOUNDARY .. "--\r\n"
    return body, "multipart/form-data; boundary=" .. BOUNDARY
end

---@param name string
---@param text string
---@param avatarUrl string|nil
---@param wav string|nil
local function sendToDiscord(name, text, avatarUrl, wav)
    if Config.WEBHOOK_URL == "DISCORD_WEBHOOK_URL_HERE" or #Config.WEBHOOK_URL == 0 then
        MsgC(Color(255, 165, 0), "[Auris:Discord] WEBHOOK_URL not configured\n")
        return
    end

    local body, contentType
    if wav then
        body, contentType = buildMultipart(name, text, avatarUrl, wav)
    else
        body        = util.TableToJSON({ username = name, content = text, avatar_url = avatarUrl })
        contentType = "application/json"
    end

    reqwest({
        method  = "POST",
        url     = Config.WEBHOOK_URL,
        timeout = 30,
        body    = body,
        type    = contentType,
        headers = { ["User-Agent"] = "AurisDiscord/1.0" },
        success = function(status)
            if status ~= 200 and status ~= 204 then
                MsgC(Color(255, 80, 80), "[Auris:Discord] webhook HTTP " .. status .. "\n")
            end
        end,
        failed = function(err, errExt)
            MsgC(Color(255, 80, 80), "[Auris:Discord] " .. err .. " (" .. errExt .. ")\n")
        end,
    })
end

---@param ply GPlayer|nil
---@param steamid64 string
---@param text string
---@param audio string|nil
local function onTranscription(ply, steamid64, text, audio)
    if not isstring(steamid64) or #steamid64 == 0 then return end
    if not isstring(text) or #text == 0 then return end
    if text == "[BLANK_AUDIO]" then return end

    local name = IsValid(ply) and ply:Nick() or "Disconnected"
    local wav  = audio and Auris.PCMToWAV(audio) or nil

    fetchAvatar(steamid64, function(avatarUrl)
        sendToDiscord(name, text, avatarUrl, wav)
    end)
end

---@return boolean success
function AurisDiscord.Init()
    if not Auris then
        ErrorNoHalt("[Auris:Discord] Auris core not found — load order issue or missing module\n")
        return false
    end

    Auris.Subscribe("Discord_Webhook", onTranscription)
    MsgC(Color(120, 200, 255), "[Auris:Discord] Loaded\n")
    return true
end

return AurisDiscord
