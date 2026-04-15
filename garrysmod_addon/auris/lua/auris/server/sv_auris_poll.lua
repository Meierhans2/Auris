-- Single timer that drains the auris result queue and dispatches to subscribers.
-- All transcription delivery happens here; submodules never call auris.Poll().

-- ply is intentionally nil when the player disconnected before the result arrived.
-- Submodules that need a live player guard with `if not ply then return end`.
---@param sid string
---@param text string
local function dispatchResult(sid, text)
    local ply = Auris.GetPlayerBySID64(sid)
    hook.Run("Auris_Transcription", ply, sid, text)
end

-- Drain the entire queue in one tick so bursts from multiple simultaneous
-- speakers are not artificially spread across timer intervals.
local function drainQueue()
    if not Auris.IsReady() then return end
    local sid, text = auris.Poll()
    while sid do
        dispatchResult(sid, text)
        sid, text = auris.Poll()
    end
end

function Auris.StartPollLoop()
    timer.Create("Auris_Poll", 0.1, 0, drainQueue)
end
