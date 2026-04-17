local function moduleExists(name)
    return #file.Find("bin/gmsv_" .. name .. "_*.dll", "LUA") > 0
end

if not moduleExists("reqwest") or not pcall(require, "reqwest") then
    MsgC(Color(255, 80, 80), "[Auris:Discord] reqwest not found — install gmsv_reqwest_*.dll into garrysmod/lua/bin/ (https://github.com/williamvenner/gmsv_reqwest)\n")
    return
end

hook.Add("Initialize", "AurisDiscord_Init", function()
    if not Auris or not Auris.IsReady() then
        MsgC(Color(255, 165, 0), "[Auris:Discord] Auris not ready — Discord bridge not loaded\n")
        return
    end

    local AurisDiscord = include("auris_discord/sv_discord_webhook.lua")
    AurisDiscord.Init()
end)
