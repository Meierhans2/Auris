AddCSLuaFile("auris_subtitles/rndx.lua")
AddCSLuaFile("auris_subtitles/cl_subtitles.lua")

-- Defers until all autorun files have loaded so Auris is guaranteed to exist.
timer.Simple(0, function()
    local mod = include("auris_subtitles/sv_subtitles.lua")
    mod.Init()
end)
