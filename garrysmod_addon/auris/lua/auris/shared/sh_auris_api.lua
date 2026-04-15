-- Public API surface for Auris. All submodules interact only through this table.
-- Internal slots (_ready, _config) are NOT part of the public contract.

Auris = Auris or {}

Auris._ready  = false
Auris._config = {}

---@param name string Unique subscriber name, e.g. "MyAddon_Feature"
---@param callback fun(ply: GPlayer|nil, steamid64: string, text: string)
function Auris.Subscribe(name, callback)
    local key = "Auris_Sub_" .. name
    -- Warn when overwriting an existing subscription so addon conflicts surface
    -- immediately rather than silently dropping one subscriber's callbacks.
    if Auris._config.debug
        and hook.GetTable()["Auris_Transcription"]
        and hook.GetTable()["Auris_Transcription"][key] then
        MsgC(Color(255, 165, 0), "[Auris] WARNING: overwriting subscriber '" .. name .. "'\n")
    end
    hook.Add("Auris_Transcription", key, callback)
end

---@param name string
function Auris.Unsubscribe(name)
    hook.Remove("Auris_Transcription", "Auris_Sub_" .. name)
end

-- Returns a copy so submodules cannot corrupt the live config by mutating it.
---@return table
function Auris.GetConfig()
    return table.Copy(Auris._config)
end

---@return boolean
function Auris.IsReady()
    return Auris._ready == true
end
