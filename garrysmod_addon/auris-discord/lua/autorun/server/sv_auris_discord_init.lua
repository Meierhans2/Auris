hook.Add("Initialize", "AurisDiscord_Init", function()
    if not Auris or not Auris.IsReady() then
        MsgC(Color(255, 165, 0), "[Auris:Discord] Auris not ready — Discord bridge not loaded\n")
        return
    end

    local AurisDiscord = include("auris_discord/sv_discord_webhook.lua")
    AurisDiscord.Init()
end)
