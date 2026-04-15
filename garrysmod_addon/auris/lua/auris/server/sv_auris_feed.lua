-- Net boundary for end-of-voice signals from the client.
-- Only responsibility: validate sender and trigger whisper flush.

util.AddNetworkString("auris_end_voice")

-- IsValid + IsPlayer guard: during map transitions the engine can fire
-- net handlers with a NULL entity before the player is fully spawned.
---@param ply GPlayer
---@return boolean
local function isValidSender(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    return Auris.CheckRateLimit(ply)
end

net.Receive("auris_end_voice", function(_, ply)
    if not isValidSender(ply) then return end
    whisper.FlushAll()
end)
