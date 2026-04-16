<h1 align="center">Auris Discord</h1>

<p align="center">
  <strong>Forwards every Auris transcription to a Discord webhook</strong><br>
  <sub>An <a href="https://github.com/ds-kimi/Auris">Auris</a> submodule</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Garry%27s%20Mod-2581d8?style=for-the-badge" alt="Garry's Mod">
</p>

<br>

Posts each player's transcribed speech to a Discord channel via webhook. The Discord message username is the player's in-game name. `[BLANK_AUDIO]` results are silently dropped.

---

## Requirements

- [Auris](https://github.com/ds-kimi/Auris)
- [gmsv_reqwest](https://github.com/williamvenner/gmsv_reqwest) — place the binary module in `garrysmod/lua/bin/`

---

## Installation

1. Install [Auris](https://github.com/ds-kimi/Auris) and confirm it loads without errors.
2. Install [gmsv_reqwest](https://github.com/williamvenner/gmsv_reqwest) binary module.
3. Drop the `auris_discord` folder into `garrysmod/addons/`.
4. Set your webhook URL in `lua/auris_discord/sv_discord_webhook.lua`.
5. Restart the server.

---

## Auris Submodule Info

| Field | Value |
|---|---|
| Subscriber key | `Discord_Webhook` |
| Realm | Server |
| Side effects | HTTP POST to Discord webhook on each transcription |
| Dependencies | gmsv_reqwest |

---

## License

MIT — see [LICENSE](../../LICENSE).
