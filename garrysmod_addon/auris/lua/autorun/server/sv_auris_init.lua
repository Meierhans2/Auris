AddCSLuaFile("auris/shared/sh_auris_version.lua")
AddCSLuaFile("auris/shared/sh_auris_api.lua")
AddCSLuaFile("autorun/client/cl_auris_init.lua")
AddCSLuaFile("auris/client/cl_auris_voice.lua")

-- file.Find with wildcard covers platform suffixes (win64, linux64, etc.)
-- avoids the engine-level "File not found" print that pcall cannot suppress.
local function moduleExists(name)
    local files = file.Find("bin/gmsv_" .. name .. "_*.dll", "LUA")
    return #files > 0
end

local gpuOk = moduleExists("auris-gpu") and pcall(require, "auris-gpu")
if gpuOk and auris then
    MsgC(Color(100, 220, 100), "[Auris] GPU backend loaded\n")
elseif moduleExists("auris") and pcall(require, "auris") then
    MsgC(Color(200, 200, 200), "[Auris] CPU-only backend loaded\n")
else
    for _ = 1, 5 do
        MsgC(Color(255, 80, 80), "[Auris] ERROR: Module not found. Did you install gmsv_auris_* / gmsv_auris-gpu_*.dll into garrysmod/lua/bin/?\n")
    end
    return
end

-- Shared files first so Auris global exists before any server file references it.
include("auris/shared/sh_auris_version.lua")
include("auris/shared/sh_auris_api.lua")

include("auris/server/sv_auris_config.lua")
Auris.LoadConfig()

include("auris/server/sv_auris_boot.lua")
Auris.Boot()

-- Player and feed must load before the poll loop in case a result arrives
-- before the player lookup function exists.
include("auris/server/sv_auris_player.lua")
include("auris/server/sv_auris_feed.lua")

include("auris/server/sv_auris_poll.lua")
Auris.StartPollLoop()
