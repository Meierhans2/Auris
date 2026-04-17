<p align="center">
  <img src="assets/auris.png" alt="Auris logo" width="120" height="120">
</p>

<h1 align="center">Auris</h1>

<p align="center">
  <strong>Real-time voice transcription for Garry’s Mod servers</strong><br>
  <sub>Opus · whisper.cpp · extensible submodule API</sub>
</p>

<p align="center">
  <a href="https://github.com/ds-kimi/Auris/releases"><img src="https://img.shields.io/github/v/release/ds-kimi/Auris?sort=semver&amp;style=for-the-badge&amp;logo=github&amp;label=release" alt="GitHub release"></a>
  <a href="https://github.com/ds-kimi/Auris"><img src="https://img.shields.io/github/stars/ds-kimi/Auris?style=for-the-badge&amp;logo=github" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&amp;logo=windows&amp;logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Garry%27s%20Mod-2581d8?style=for-the-badge" alt="Garry's Mod">
</p>

<br>

Captures player voice chat via an in-process `SV_BroadcastVoiceData` detour, decodes Opus audio, and transcribes it in real time using whisper.cpp. Auris is a silent platform — it does nothing by default except make transcriptions available. What happens with them is up to submodule addons.

---

## Demo Video

[![Auris demo video](https://img.youtube.com/vi/se-04PY7Yls/hqdefault.jpg)](https://youtu.be/se-04PY7Yls)

Watch Auris transcribe Garry's Mod voice chat in real time.

---

## Requirements

- [Git](https://git-scm.com/)
- [Vulkan SDK](https://vulkan.lunarg.com/) 1.4.341.1 or newer *(GPU builds only)*
- [Visual Studio](https://visualstudio.microsoft.com/) with C++ build tools
- whisper.cpp model file (see "Models" below)

---

## Models

Download a `ggml-*.bin` Whisper model from:

- https://huggingface.co/ggerganov/whisper.cpp/tree/main

Place the model on your server in the Garry's Mod data folder:

- `garrysmod/data/auris/ggml-tiny.en.bin`

> **Upgrading from a previous release?** Move your model file from `data/whisper/` to `data/auris/`.

If you want to use a different model name or path, update it in:

- `garrysmod_addon/auris/lua/auris/config.lua`

---

## Building the module

See **[BUILD.md](BUILD.md)** for the full build guide — all platforms, architectures, CPU vs GPU variants, and flag reference.

**Quick start (Windows, CPU-only):**

```
RUN_ONCE.bat
premake5.exe --os=windows --gmcommon=./garrysmod_common vs2022
```

Open `projects/windows/vs2022/` and build in Release.

---

## Tested on

- Windows 11
- Vulkan SDK 1.4.341.1
- Visual Studio 18.5.11626.173

---

## Configuration

Edit `garrysmod_addon/auris/lua/auris/config.lua` to change the model path, language, thread count, and other options. Every key can also be overridden at runtime via ConVar (`auris_threads`, `auris_language`, `auris_debug`) in `server.cfg` — ConVar values take precedence over the file.

---

## Backends

Auris has two transcription backends. Both fire the same `Auris_Transcription` hook with identical arguments, so submodules work unchanged on either.

| Backend | When it runs | Trade-off |
|---|---|---|
| **Local (whisper.cpp)** | `openai_api_key = ""` (default) | Private, offline, no per-clip cost; uses server CPU/GPU and requires a downloaded model file |
| **Remote (OpenAI)** | `openai_api_key` set in `config.lua` | Zero local compute, hosted accuracy; requires network I/O and incurs OpenAI per-minute billing |

To switch to the remote backend, fill the two keys in `config.lua`:

```lua
openai_api_key = "sk-...",
openai_model   = "whisper-1", -- or gpt-4o-mini-transcribe / gpt-4o-transcribe
```

Whisper.cpp is not loaded and the worker thread is not spawned in remote mode — the Steam voice detour still runs, captured Opus is still decoded to float32 PCM, but transcription happens entirely at `https://api.openai.com/v1/audio/transcriptions`. See [OpenAI's speech-to-text docs](https://developers.openai.com/api/docs/guides/speech-to-text?lang=curl) for pricing and model options.

---

## Submodule API

Auris exposes a hook that any addon can listen to:

```lua
hook.Run("Auris_Transcription", ply, steamid64, text, audio)
```

| Parameter | Type | Notes |
|---|---|---|
| `ply` | `GPlayer` or `nil` | `nil` if the player disconnected before the result arrived |
| `steamid64` | `string` | Always present |
| `text` | `string` | Transcribed speech |
| `audio` | `string` or `nil` | Raw 16 kHz mono float32 PCM binary. Convert to a playable WAV with `Auris.PCMToWAV(audio)` |

### Quick start

Create a new GMod addon with one server-side file:

```lua
-- lua/autorun/server/sv_myaddon_init.lua

-- timer.Simple(0) defers until all autorun files have loaded,
-- avoiding load-order issues with Auris.
timer.Simple(0, function()
    if not Auris then
        ErrorNoHalt("[myAddon] Auris core not found\n")
        return
    end

    Auris.Subscribe("MyAddon_Feature", function(ply, steamid64, text, audio)
        local name = IsValid(ply) and ply:Nick() or "Disconnected"
        Msg("[myAddon] " .. name .. ": " .. text .. "\n")

        -- optional: save the voice clip to disk
        if audio then
            file.Write("myaddon/" .. steamid64 .. ".wav", Auris.PCMToWAV(audio))
        end
    end)
end)
```

### Full API reference

See [API.md](API.md) for the complete API, subscriber name conventions, version guards, and the publishing checklist to get your submodule listed here.

### Community submodules

| Addon | Description | Author |
|---|---|---|
| [auris-logger](garrysmod_addon/auris-logger/) | Prints every transcription to the server console with player name and SteamID64 | [ds-kimi](https://github.com/ds-kimi) |
| [auris-discord](garrysmod_addon/auris-discord/) | Forwards every transcription to a Discord webhook (requires [gmsv_reqwest](https://github.com/williamvenner/gmsv_reqwest)) | [ds-kimi](https://github.com/ds-kimi) |
| [auris-subtitles](garrysmod_addon/auris-subtitles/) | Displays transcriptions as animated worldspace subtitles above the speaker's head, visible to nearby players | [ds-kimi](https://github.com/ds-kimi) |

To add yours: follow the [publishing guide in API.md](API.md#publishing-your-submodule), then open a [Submit Submodule](https://github.com/ds-kimi/Auris/issues/new?template=submodule.yml) issue.

---

## Star history

<a href="https://www.star-history.com/#ds-kimi/Auris&amp;Date"><img src="https://api.star-history.com/svg?repos=ds-kimi/Auris&amp;type=Date" alt="Star history chart"></a>

See the interactive chart on **[Star History](https://www.star-history.com/)** (repo: `ds-kimi/Auris`).
