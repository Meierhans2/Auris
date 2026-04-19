---@class AurisSubtitles
local AurisSubtitles = {}

util.AddNetworkString("auris_subtitle")

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

hook.Add("PlayerDisconnected", "AurisSubtitles_Cleanup", function(ply)
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
    if text == "[BLANK_AUDIO]" then return end
    if not IsValid(ply) then return end
    if isRateLimited(ply) then return end

    -- Only send to players within 1000 units; avoids spamming the whole server
    -- with subtitles for voice that nobody nearby can hear.
    local pos = ply:GetPos()
    local recipients = {}
    for _, other in ipairs(player.GetAll()) do
        if IsValid(other) and other:GetPos():DistToSqr(pos) <= 1000 * 1000 then
            recipients[#recipients + 1] = other
        end
    end

    if #recipients == 0 then return end

    net.Start("auris_subtitle")
        net.WriteEntity(ply)
        net.WriteString(text)
    net.Send(recipients)
end

---@return boolean success
function AurisSubtitles.Init()
    if not Auris then
        ErrorNoHalt("[Auris:Subtitles] Auris core not found — load order issue or missing module\n")
        return false
    end

    Auris.Subscribe("Subtitles_World", onTranscription)
    MsgC(Color(120, 200, 255), "[Auris:Subtitles] Loaded\n")
    return true
end

return AurisSubtitles
