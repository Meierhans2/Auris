-- Signals the server when the local player stops speaking so it can flush
-- the audio buffer and trigger transcription.

-- Other players' end-voice events are ignored because auris.FlushAll()
-- on the server flushes all buffers at once — only one signal needed.
hook.Add("PlayerEndVoice", "Auris_EndVoice", function(ply)
    if not IsValid(ply) or ply ~= LocalPlayer() then return end
    net.Start("auris_end_voice")
    net.SendToServer()
end)
