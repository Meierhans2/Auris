<h1 align="center">Auris Subtitles</h1>

<p align="center">
  <strong>Worldspace subtitles above players' heads when they speak</strong><br>
  <sub>An <a href="https://github.com/ds-kimi/Auris">Auris</a> submodule</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Garry%27s%20Mod-2581d8?style=for-the-badge" alt="Garry's Mod">
</p>

<br>

## Demo Video

[![Auris Subtitles demo video](https://img.youtube.com/vi/bgYbzSJN1uk/hqdefault.jpg)](https://youtu.be/bgYbzSJN1uk)

Watch Auris Subtitles display worldspace transcriptions in real time.

---

Displays each player's transcribed speech as a floating subtitle above their head. Text drifts upward, fades out after 3 seconds, and stacks if multiple results arrive quickly. Only players within 1000 units receive the net message.

---

## Requirements

- [Auris](https://github.com/ds-kimi/Auris) 2.0.0+

---

## Installation

1. Install [Auris](https://github.com/ds-kimi/Auris) and confirm it loads without errors.
2. Drop the `auris-subtitles` folder into `garrysmod/addons/`.
3. Restart the server.

---

## Auris Submodule Info

| Field | Value |
|---|---|
| Subscriber key | `Subtitles_World` |
| Realm | Server + Client |
| Side effects | Net message to nearby players on each transcription |
| Dependencies | None |

---

## License

MIT — see [LICENSE](../../LICENSE).
