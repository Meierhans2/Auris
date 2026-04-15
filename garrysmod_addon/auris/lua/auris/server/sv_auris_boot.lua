-- Initialises eightbit and the auris C++ module.
-- Sets Auris._ready = true only on full success so the poll loop
-- and submodules have a reliable gate to check before acting.

-- .en.bin models hard-code English; passing a different language to them
-- causes auris to silently produce garbage output.
---@param cfg table
---@return string
local function resolveLanguage(cfg)
    if string.find(cfg.model, "%.en%.bin$") then return "en" end
    return cfg.language
end

---@param cfg table
---@return table
local function buildWhisperConfig(cfg)
    return {
        language         = resolveLanguage(cfg),
        n_threads        = cfg.threads,
        print_progress   = cfg.print_progress,
        print_timestamps = cfg.print_timestamps,
        single_segment   = cfg.single_segment,
        no_context       = cfg.no_context,
    }
end

---@param cfg table
---@return boolean
local function bootEightbit(cfg)
    eightbit.SetBroadcastIP("127.0.0.1")
    eightbit.SetBroadcastPort(cfg.port)
    eightbit.EnableBroadcast(true)
    return true
end

function Auris.Boot()
    local cfg = Auris._config
    bootEightbit(cfg)

    if not auris.Init(cfg.model) then
        ErrorNoHalt("[Auris] Failed to load model: " .. tostring(cfg.model) .. "\n")
        return
    end

    auris.SetConfig(buildWhisperConfig(cfg))
    auris.Debug(cfg.debug)
    auris.Listen(cfg.port)

    Auris._ready = true
end
