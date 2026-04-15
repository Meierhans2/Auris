AddCSLuaFile("auris/shared/sh_auris_version.lua")
AddCSLuaFile("auris/shared/sh_auris_api.lua")
AddCSLuaFile("autorun/client/cl_auris_init.lua")
AddCSLuaFile("auris/client/cl_auris_voice.lua")

require("eightbit")
require("auris")

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
