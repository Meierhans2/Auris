-- OpenAI speech-to-text backend.
-- Activated when config.openai_api_key is non-empty. Bypasses whisper.cpp
-- entirely: pulls raw PCM from the C++ audio buffer via auris.FlushRaw,
-- wraps it in a WAV, POSTs multipart/form-data to the OpenAI API, then
-- fires Auris_Transcription with the returned text.

local ENDPOINT = "https://api.openai.com/v1/audio/transcriptions"

-- Fixed boundary: float32 PCM inside a RIFF/WAVE container cannot legally
-- contain this ASCII sequence, so a per-request random boundary is overkill.
local BOUNDARY = "----AurisBoundary7MA4YWxkTrZu0gW"
local CRLF     = "\r\n"

---@param model string
---@param wav string complete WAV bytes
---@return string body, string contentType
local function buildMultipart(model, wav)
    local dash = "--" .. BOUNDARY
    local body = dash .. CRLF
        .. 'Content-Disposition: form-data; name="model"' .. CRLF .. CRLF
        .. model .. CRLF
        .. dash .. CRLF
        .. 'Content-Disposition: form-data; name="file"; filename="audio.wav"' .. CRLF
        .. "Content-Type: audio/wav" .. CRLF .. CRLF
        .. wav .. CRLF
        .. dash .. "--" .. CRLF
    return body, "multipart/form-data; boundary=" .. BOUNDARY
end

-- util.JSONToTable returns nil on malformed JSON; callers must branch-check.
---@param body string
---@return string|nil text
local function parseResponse(body)
    if not body or body == "" then return nil end
    local decoded = util.JSONToTable(body)
    if not decoded or type(decoded.text) ~= "string" then return nil end
    return decoded.text
end

-- Mirrors sv_auris_poll.dispatchResult: ply may be nil if the player
-- disconnected between the HTTP POST and the response. Subscribers already
-- guard on nil.
---@param sid string
---@param text string
---@param audio string raw PCM binary
local function dispatch(sid, text, audio)
    local ply = Auris.GetPlayerBySID64(sid)
    hook.Run("Auris_Transcription", ply, sid, text, audio)
end

---@param ply GPlayer
function Auris.SubmitRemote(ply)
    local pcm = auris.FlushRaw(ply:AccountID())
    if not pcm then return end

    local cfg    = Auris._config
    local sid    = ply:SteamID64()
    local wav    = Auris.PCMToWAV(pcm)
    local body, contentType = buildMultipart(cfg.openai_model, wav)

    HTTP({
        method  = "POST",
        url     = ENDPOINT,
        body    = body,
        type    = contentType,
        headers = { Authorization = "Bearer " .. cfg.openai_api_key },
        success = function(code, respBody)
            if code < 200 or code >= 300 then
                ErrorNoHalt("[Auris] OpenAI HTTP " .. code .. ": " .. tostring(respBody) .. "\n")
                return
            end
            local text = parseResponse(respBody)
            if not text then
                ErrorNoHalt("[Auris] OpenAI response missing 'text' field\n")
                return
            end
            dispatch(sid, text, pcm)
        end,
        failed = function(reason)
            ErrorNoHalt("[Auris] OpenAI request failed: " .. tostring(reason) .. "\n")
        end,
    })
end
