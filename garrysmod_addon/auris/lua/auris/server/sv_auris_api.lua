-- Public API surface for Auris. All submodules interact only through this table.
-- Internal slots (_ready, _config) are NOT part of the public contract.

Auris = Auris or {}

Auris._ready  = false
Auris._config = {}
Auris._filter = nil

-- Pass nil to clear the filter and transcribe everyone.
---@param fn fun(ply: GPlayer): boolean|nil
function Auris.SetFilter(fn)
    Auris._filter = fn
end

---@param ply GPlayer
---@return boolean
function Auris.PassesFilter(ply)
    if not Auris._filter then return true end
    return Auris._filter(ply) == true
end

---@param name string Unique subscriber name, e.g. "MyAddon_Feature"
---@param callback fun(ply: GPlayer|nil, steamid64: string, text: string, audio: string|nil)
---@param filter fun(ply: GPlayer|nil, steamid64: string, text: string, audio: string|nil): boolean|nil
function Auris.Subscribe(name, callback, filter)
    local key = "Auris_Sub_" .. name
    -- Warn when overwriting an existing subscription so addon conflicts surface
    -- immediately rather than silently dropping one subscriber's callbacks.
    if Auris._config.debug
        and hook.GetTable()["Auris_Transcription"]
        and hook.GetTable()["Auris_Transcription"][key] then
        MsgC(Color(255, 165, 0), "[Auris] WARNING: overwriting subscriber '" .. name .. "'\n")
    end
    if Auris._filter then
        MsgC(Color(255, 165, 0), "[Auris] WARNING: subscriber '" .. name .. "' registered while a global SetFilter is active — some players will never be transcribed.\n")
    end
    if filter then
        hook.Add("Auris_Transcription", key, function(ply, sid, text, audio)
            if filter(ply, sid, text, audio) then
                callback(ply, sid, text, audio)
            end
        end)
    else
        hook.Add("Auris_Transcription", key, callback)
    end
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

-- LuaJIT (GMod) has no string.pack — write little-endian integers manually.
local function le16(n)
    return string.char(n % 256, math.floor(n / 256) % 256)
end

local function le32(n)
    return string.char(n % 256, math.floor(n / 256) % 256,
        math.floor(n / 65536) % 256, math.floor(n / 16777216) % 256)
end

-- Wraps raw float32 PCM (16kHz mono) in a WAV container.
-- The binary string returned can be written directly to disk or sent over HTTP.
---@param pcm string binary string of float32 samples from Auris_Transcription audio arg
---@return string wav complete WAV file bytes
function Auris.PCMToWAV(pcm)
    local sampleRate    = 16000
    local numChannels   = 1
    local bitsPerSample = 32
    local byteRate      = sampleRate * numChannels * (bitsPerSample / 8)
    local blockAlign    = numChannels * (bitsPerSample / 8)
    local dataSize      = #pcm
    local chunkSize     = 36 + dataSize

    -- audioFormat 3 = IEEE 754 float; 1 (PCM int) would produce garbled output
    local fmt = "fmt " .. le32(16) .. le16(3) .. le16(numChannels)
        .. le32(sampleRate) .. le32(byteRate) .. le16(blockAlign) .. le16(bitsPerSample)

    return "RIFF" .. le32(chunkSize) .. "WAVE" .. fmt
        .. "data" .. le32(dataSize) .. pcm
end
