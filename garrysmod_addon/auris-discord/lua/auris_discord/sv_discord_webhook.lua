require("reqwest")

---@class AurisDiscord
local AurisDiscord = {}

local WEBHOOK_URL = "DISCORD_WEBHOOK_URL_HERE"

---@param name string
---@param text string
local function sendToDiscord(name, text)
    reqwest({
        method  = "POST",
        url     = WEBHOOK_URL,
        timeout = 30,
        body    = util.TableToJSON({ username = name, content = text }),
        type    = "application/json",
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
local function onTranscription(ply, steamid64, text)
    if not isstring(steamid64) or #steamid64 == 0 then return end
    if not isstring(text) or #text == 0 then return end
    if text == "[BLANK_AUDIO]" then return end

    local name = IsValid(ply) and ply:Nick() or "Disconnected"
    sendToDiscord(name, text)
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
