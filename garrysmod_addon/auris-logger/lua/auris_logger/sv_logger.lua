---@class AurisLogger
local AurisLogger = {}

-- One entry per SteamID64; cleaned on PlayerDisconnected.
---@type table<string, number>
local nextAllowed = {}

local COOLDOWN = 0.5

---@param ply Player
---@return boolean
local function isRateLimited(ply)
    local id = ply:SteamID64()
    if (nextAllowed[id] or 0) > CurTime() then return true end
    nextAllowed[id] = CurTime() + COOLDOWN
    return false
end

hook.Add("PlayerDisconnected", "AurisLogger_Cleanup", function(ply)
    if IsValid(ply) then
        nextAllowed[ply:SteamID64()] = nil
    end
end)

---@param ply Player|nil
---@param steamid64 string
---@param text string
local function onTranscription(ply, steamid64, text)
    if not isstring(steamid64) or #steamid64 == 0 then return end
    if not isstring(text) or #text == 0 then return end
    if IsValid(ply) and isRateLimited(ply) then return end

    local name = IsValid(ply) and ply:Nick() or "Disconnected"
    MsgC(Color(120, 200, 255), "[Auris:Logger] ", Color(255, 255, 255), name .. " (" .. steamid64 .. "): " .. text .. "\n")
end

---@return boolean success
function AurisLogger.Init()
    if not Auris then
        ErrorNoHalt("[Auris:Logger] Auris core not found — load order issue or missing module\n")
        return false
    end

    Auris.Subscribe("Logger_Console", onTranscription)
    MsgC(Color(120, 200, 255), "[Auris:Logger] Loaded\n")
    return true
end

return AurisLogger
