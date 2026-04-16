<!--
  AURIS SUBMODULE README TEMPLATE
  ================================
  Open this file in your editor, copy everything below the scissors line,
  paste it as your addon's README.md, then fill in every placeholder.
  Delete this comment block before publishing.

  Placeholders to replace:
    YOUR_ADDON_SLUG     → your GitHub repo / folder name, e.g. auris-logger
    YOUR_ADDON_NAME     → display name, e.g. Auris Logger
    YOUR_DESCRIPTION    → one line describing what the addon does
    YOUR_USERNAME       → your GitHub username
    YOUR_SUBSCRIBER_KEY → the exact string passed to Auris.Subscribe(...)
    YOUR_MIN_VERSION    → minimum Auris version required, e.g. 2.0.0
    YOUR_REALM          → Server / Client / Shared
    WORKSHOP_ID         → Steam Workshop file ID (or remove that badge)
-->

<!-- ✂ copy from here -------------------------------------------------------->

<p align="center">
  <img src="assets/icon.png" alt="YOUR_ADDON_NAME logo" width="120" height="120">
</p>

<h1 align="center">YOUR_ADDON_NAME</h1>

<p align="center">
  <strong>YOUR_DESCRIPTION</strong><br>
  <sub>An <a href="https://github.com/ds-kimi/Auris">Auris</a> submodule</sub>
</p>

<p align="center">
  <a href="https://github.com/YOUR_USERNAME/YOUR_ADDON_SLUG/releases"><img src="https://img.shields.io/github/v/release/YOUR_USERNAME/YOUR_ADDON_SLUG?sort=semver&style=for-the-badge&logo=github&label=release" alt="GitHub release"></a>
  <a href="https://github.com/YOUR_USERNAME/YOUR_ADDON_SLUG"><img src="https://img.shields.io/github/stars/YOUR_USERNAME/YOUR_ADDON_SLUG?style=for-the-badge&logo=github" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/Auris-YOUR_MIN_VERSION%2B-brightgreen?style=for-the-badge" alt="Requires Auris">
  <img src="https://img.shields.io/badge/Garry%27s%20Mod-2581d8?style=for-the-badge" alt="Garry's Mod">
</p>

<br>

<!-- One paragraph. What does this addon do with transcriptions? Be specific. -->
YOUR_DESCRIPTION

---

## Requirements

- [Auris](https://github.com/ds-kimi/Auris) YOUR_MIN_VERSION or newer
- <!-- add any other requirements here, or remove this line -->

---

## Installation

1. Install [Auris](https://github.com/ds-kimi/Auris) and confirm it loads without errors.
2. Drop the `YOUR_ADDON_SLUG` folder into `garrysmod/addons/`.
3. Restart the server.

---

## Configuration

<!-- Describe every ConVar your addon adds. Example: -->

| ConVar | Default | Description |
|---|---|---|
| `YOUR_ADDON_SLUG_enabled` | `1` | Enable or disable the addon |

Edit `lua/YOUR_ADDON_SLUG/config.lua` for file-based configuration.

---

## Auris Submodule Info

| Field | Value |
|---|---|
| Subscriber key | `YOUR_SUBSCRIBER_KEY` |
| Minimum Auris version | `YOUR_MIN_VERSION` |
| Realm | YOUR_REALM |
| Side effects | <!-- e.g. "Prints to server console" --> |
| ConVars added | <!-- list them --> |
| Net strings added | <!-- or "none" --> |
| Dependencies | <!-- or "none" --> |

---

## License

MIT — see [LICENSE](LICENSE).

---

<!--
  EXAMPLES
  ========
  These are real submodules included in the Auris repo. Use them as reference.
-->

## Examples

### auris-logger — minimal, no dependencies

[garrysmod_addon/auris-logger/](garrysmod_addon/auris-logger/)

Prints every transcription to the server console with player name and SteamID64. No extra binaries required — good starting point for a simple submodule.

### auris-discord — external HTTP dependency (gmsv_reqwest)

[garrysmod_addon/auris-discord/](garrysmod_addon/auris-discord/)

Forwards each transcription to a Discord webhook. Requires [gmsv_reqwest](https://github.com/williamvenner/gmsv_reqwest). Shows how to handle an extra binary dependency and filter unwanted results (`[BLANK_AUDIO]`).
