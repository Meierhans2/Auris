-- Defers until all autorun files have loaded so Auris is guaranteed to exist.
timer.Simple(0, function()
    local logger = include("auris_logger/sv_logger.lua")
    logger.Init()
end)
