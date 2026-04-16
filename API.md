# Auris — Submodule API

Auris is a silent platform. It loads the transcription module, polls results, and fires a hook. Your addon listens to that hook and does whatever it wants with the result.

---

## Receiving Transcriptions

Register a callback with `Auris.Subscribe`. Auris calls it once per transcription result.

```lua
Auris.Subscribe("MyAddon_Feature", function(ply, steamid64, text)
    -- your logic here
end)
```

| Parameter | Type | Notes |
|---|---|---|
| `ply` | `GPlayer` or `nil` | `nil` if the player disconnected before the result arrived |
| `steamid64` | `string` | Always present — use this as your reliable identifier |
| `text` | `string` | The transcribed speech. May be whitespace-only (whisper hallucination) |

> **Note:** Internally Auris fires `hook.Run("Auris_Transcription", ...)`. Do not use `hook.Add` on this hook directly — `Auris.Subscribe` adds duplicate-detection and namespacing that raw `hook.Add` skips.

---

## API Functions

```lua
-- Register a listener. name must be globally unique across all installed submodules.
-- Convention: prefix with your addon folder name, e.g. "MyAddon_Feature"
Auris.Subscribe(name, callback)

-- Remove a listener.
Auris.Unsubscribe(name)

-- Returns a shallow copy of the active config table. Do not mutate it.
-- Keys: model, port, threads, language, debug, print_progress, print_timestamps,
--       single_segment, no_context
Auris.GetConfig()

-- Returns true once auris has initialised successfully and the poll loop is live.
Auris.IsReady()

-- Semver string. Guard against breaking changes with a version check.
Auris.VERSION  -- e.g. "2.0.0"
```

---

## Load Order

GMod does not guarantee autorun execution order across addons. Always wrap your init in `timer.Simple(0, ...)` to defer until after all autorun files have run.

```lua
timer.Simple(0, function()
    if not Auris then
        ErrorNoHalt("[myaddon] Auris core not found\n")
        return
    end
    -- safe to subscribe here
end)
```

---

## Minimal Example — Console Logger

Prints every transcription to the server console with the speaker's name and SteamID.


### `sv_logger_init.lua`

```lua
-- Deferred so Auris core is guaranteed to have loaded regardless of
-- which autorun folder GMod processed first.
timer.Simple(0, function()
    if not Auris then
        ErrorNoHalt("[auris-logger] Auris core not found — is it installed?\n")
        return
    end

    Auris.Subscribe("Logger_Console", function(ply, steamid64, text)
        -- ply is nil when the player disconnected before transcription finished;
        -- fall back to the SteamID so the log line is still useful.
        local name = IsValid(ply) and ply:Nick() or "Disconnected"
        Msg("[Auris] " .. name .. " (" .. steamid64 .. "): " .. text .. "\n")
    end)
end)
```

That's the entire addon. No other files needed.

---

## Subscriber Name Convention

The name passed to `Auris.Subscribe` must be unique across every installed submodule. If two addons use the same name, the second one silently overwrites the first.

Use your addon folder name as a prefix:

```
auris-logger    →  "Logger_Console"
auris-badwords  →  "BadWords_Detector"
auris-commands  →  "Commands_Handler"
```

---

## Handling Disconnected Players

Always check `ply` before acting on a live player:

```lua
Auris.Subscribe("MyAddon_Feature", function(ply, steamid64, text)
    if not IsValid(ply) then
        -- player left before transcription finished; log by SteamID only
        return
    end
    -- safe to call ply:Nick(), ply:Kick(), etc.
end)
```

---

## Version Guard

If your addon uses API features that may not exist in older Auris versions, guard on load:

```lua
timer.Simple(0, function()
    if not Auris then ErrorNoHalt("[myaddon] Auris not found\n") return end

    local major = tonumber(string.match(Auris.VERSION, "^(%d+)"))
    if major < 2 then
        ErrorNoHalt("[myaddon] Requires Auris 2.0.0+, found " .. Auris.VERSION .. "\n")
        return
    end

    Auris.Subscribe("MyAddon_Feature", function(ply, sid, text)
        -- ...
    end)
end)
```

---

## Publishing Your Submodule

### Step 1 — README

Your repo **must** have a README that follows the official template. Open [SUBMODULE_README_TEMPLATE.md](SUBMODULE_README_TEMPLATE.md) in your editor, copy everything below the scissors line, paste it as your `README.md`, and fill in every placeholder. Do not skip the **Auris Submodule Info** table — that is what we display in the community list.

### Step 2 — Open an issue

Go to [github.com/ds-kimi/Auris/issues/new/choose](https://github.com/ds-kimi/Auris/issues/new/choose) and select **Submit Submodule**. Fill out every field and check all boxes in the compliance checklist. Incomplete submissions will not be reviewed.

### Compliance checklist

All of the following must be true before submitting:

- Init wrapped in `timer.Simple(0, ...)`
- Guards missing Auris with `if not Auris then ErrorNoHalt(...) return end`
- Subscriber key prefixed with your addon folder name
- No ConVar uses the `auris_` prefix
- Repo README follows the submodule template
- Addon never calls `auris.*` directly — only uses the `Auris` API

Submissions that fail any of these will not be listed.
