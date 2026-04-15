<p align="center">
  <img src="assets/auris.png" alt="Auris logo" width="120" height="120">
</p>

<h1 align="center">Auris</h1>

<p align="center">
  <strong>Real-time voice transcription for Garry’s Mod servers</strong><br>
  <sub>gm_8bit · Opus · whisper.cpp · extensible submodule API</sub>
</p>

<p align="center">
  <a href="https://github.com/ds-kimi/Auris/releases"><img src="https://img.shields.io/github/v/release/ds-kimi/Auris?sort=semver&amp;style=for-the-badge&amp;logo=github&amp;label=release" alt="GitHub release"></a>
  <a href="https://github.com/ds-kimi/Auris"><img src="https://img.shields.io/github/stars/ds-kimi/Auris?style=for-the-badge&amp;logo=github" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&amp;logo=windows&amp;logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Garry%27s%20Mod-2581d8?style=for-the-badge" alt="Garry's Mod">
</p>

<br>

Captures player voice chat via [gm_8bit](https://github.com/Meachamp/gm_8bit), decodes Opus audio, and transcribes it in real time using whisper.cpp. Auris is a silent platform — it does nothing by default except make transcriptions available. What happens with them is up to submodule addons.

---

## Demo Video

[![Auris demo video](https://img.youtube.com/vi/se-04PY7Yls/hqdefault.jpg)](https://youtu.be/se-04PY7Yls)

Watch Auris transcribe Garry's Mod voice chat in real time.

---

## Requirements

- [gm_8bit](https://github.com/Meachamp/gm_8bit) binary module (thanks to Meachamp for creating it)
- Vulkan-capable GPU (NVIDIA or AMD)
- [Git](https://git-scm.com/)
- [CMake](https://cmake.org/)
- [Vulkan SDK](https://vulkan.lunarg.com/) 1.4.341.1 or newer
- [Visual Studio](https://visualstudio.microsoft.com/) with C++ build tools
- whisper.cpp model file (see "Models" below)

---

## Models

Download a `ggml-*.bin` Whisper model from:

- https://huggingface.co/ggerganov/whisper.cpp/tree/main

Place the model on your server in the Garry's Mod data folder:

- `garrysmod/data/whisper/ggml-tiny.en.bin`

If you want to use a different model name or path, update it in:

- `garrysmod_addon/auris/lua/auris/config.lua`

---

## Building the module

Run the setup script once from the repo root to compile shaders and patch vendor files:

```
RUN_ONCE.bat
```

Then generate the Visual Studio solution:

```
premake5.exe --os=windows --gmcommon=./garrysmod_common vs2022
```

Open the generated solution in `projects/windows/vs2022/` and build in Release.

---

## Tested on

- Windows 11
- Vulkan SDK 1.4.341.1
- Visual Studio 18.5.11626.173

---

## Configuration

Edit `garrysmod_addon/auris/lua/auris/config.lua` to change the model path, language, thread count, and other options. Every key can also be overridden at runtime via ConVar (`auris_threads`, `auris_language`, `auris_debug`) in `server.cfg` — ConVar values take precedence over the file.

---

## Submodule API

Auris exposes a hook that any addon can listen to:

```lua
hook.Run("Auris_Transcription", ply, steamid64, text)
```

| Parameter | Type | Notes |
|---|---|---|
| `ply` | `GPlayer` or `nil` | `nil` if the player disconnected before the result arrived |
| `steamid64` | `string` | Always present |
| `text` | `string` | Transcribed speech |

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

    Auris.Subscribe("MyAddon_Feature", function(ply, steamid64, text)
        local name = IsValid(ply) and ply:Nick() or "Disconnected"
        Msg("[myAddon] " .. name .. ": " .. text .. "\n")
    end)
end)
```

### Full API reference

See [API.md](API.md) for the complete API, subscriber name conventions, version guards, and the publishing checklist to get your submodule listed here.

### Community submodules

| Addon | Description | Author |
|---|---|---|
| *(be the first!)* | | |

To add yours: follow the [publishing guide in API.md](API.md#publishing-your-submodule), then open a [Submit Submodule](https://github.com/ds-kimi/Auris/issues/new?template=submodule.yml) issue.

---

## Star history

<a href="https://www.star-history.com/#ds-kimi/Auris&amp;Date"><img src="https://api.star-history.com/svg?repos=ds-kimi/Auris&amp;type=Date" alt="Star history chart"></a>

See the interactive chart on **[Star History](https://www.star-history.com/)** (repo: `ds-kimi/Auris`).
