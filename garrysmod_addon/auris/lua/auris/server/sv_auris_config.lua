-- Loads lua/auris/config.lua and merges with ConVar overrides.
-- Must run before sv_auris_boot.lua so Boot() has a valid Auris._config.

local DEFAULTS = {
    model            = "data/whisper/ggml-tiny.en.bin",
    port             = 4000,
    threads          = 4,
    language         = "en",
    debug            = false,
    print_progress   = false,
    print_timestamps = false,
    single_segment   = true,
    no_context       = true,
}

---@return table
local function loadFileConfig()
    local ok, result = pcall(include, "auris/config.lua")
    -- If the file is missing or malformed, fall back to defaults silently.
    -- Boot will still succeed; the operator sees normal behaviour.
    if not ok or type(result) ~= "table" then return {} end
    return result
end

---@param cfg table
local function registerConVars(cfg)
    CreateConVar("auris_threads",  tostring(cfg.threads),  FCVAR_ARCHIVE, "Whisper CPU thread count")
    CreateConVar("auris_language", tostring(cfg.language), FCVAR_ARCHIVE, "Transcription language code")
    CreateConVar("auris_debug",    cfg.debug and "1" or "0", FCVAR_ARCHIVE, "Enable Auris debug output")
end

-- ConVar wins over file value so server.cfg takes precedence.
---@param cfg table
local function applyConVarOverrides(cfg)
    cfg.threads  = tonumber(GetConVar("auris_threads"):GetInt())  or cfg.threads
    cfg.language = GetConVar("auris_language"):GetString()        or cfg.language
    cfg.debug    = GetConVar("auris_debug"):GetBool()
end

function Auris.LoadConfig()
    local file = loadFileConfig()
    local cfg  = table.Merge(table.Copy(DEFAULTS), file)
    registerConVars(cfg)
    applyConVarOverrides(cfg)
    Auris._config = cfg
end
