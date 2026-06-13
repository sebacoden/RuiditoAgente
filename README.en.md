# 🔔 RuiditoAgentes

🌍 **Language / Idioma**: **English** · [Español](README.md)

Makes a **sound** (and shows a text notification) whenever your **AI agent** asks
for permission or needs your attention. So you don't have to keep staring at the
terminal.

- 🔊 **Multi-format audio**: wav, mp3, ogg, flac, m4a… customizable.
- 💬 **Optional text notification** (toast on Windows, `notify-send` on Linux, `osascript` on macOS).
- 🤖 **Any agent**: reusable core + adapters. Ships an automatic adapter for **Claude Code** and a **generic** one for everything else.
- 🖥️ **Cross-platform**: Windows, macOS and Linux.

---

## How it works

Most agents let you run a command on certain events (asking for permission,
finishing a task, etc.). RuiditoAgentes provides a **core** (`core/notify`) that
plays the sound and shows the notification, plus **adapters** that wire that core
into your agent's event.

```
Agent needs your attention  ──▶  adapter  ──▶  core/notify  ──▶  🔊 + 💬
```

---

## Installation

Clone the repo and run the adapter for your agent.

```bash
git clone https://github.com/TU_USUARIO/RuiditoAgentes.git
cd RuiditoAgentes
```

### Claude Code

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File adapters\claude-code\install.ps1
```

```bash
# macOS / Linux
bash adapters/claude-code/install.sh
```

Restart Claude Code when done. The installer **merges** your `settings.json`
(it keeps any other hooks) and creates a backup. More details in
[adapters/claude-code/README.md](adapters/claude-code/README.md).

### Any other agent

Use the generic adapter, which prints the exact command to paste into your agent
and can merge it into **json / toml / yaml** configs. See
[adapters/generic/README.md](adapters/generic/README.md).

```powershell
powershell -ExecutionPolicy Bypass -File adapters\generic\print-command.ps1   # Windows
```
```bash
bash adapters/generic/print-command.sh                                        # macOS / Linux
```

---

## Customization

There are three ways, from the simplest to the most complete:

### 1. Change just the sound
Replace [`sounds/notify.wav`](sounds/notify.wav) with your own file. It supports
**any format** (wav, mp3, ogg, flac, m4a…); if you use a different name/extension,
point to it in `config.json` (below).

### 2. Full config (`config.json`)
Copy [`config.example.json`](config.example.json) to `config.json` in the repo root and edit:

```json
{
  "sound": "sounds/my-sound.mp3",
  "message": "Your agent needs your attention",
  "playSound": true,
  "showText": true
}
```

### 3. Environment variables (one-off, highest priority)
`RUIDITO_SOUND`, `RUIDITO_MESSAGE`, `RUIDITO_NO_SOUND=1`, `RUIDITO_NO_TEXT=1`.

> **Precedence:** command arguments › environment variables › `config.json` › defaults.

Want the default sound back? Regenerate it:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate-default-sound.ps1
```

---

## Test the notification

To check that the sound and text notification work **without needing an agent**,
run the test script:

```powershell
powershell -ExecutionPolicy Bypass -File test-notification.ps1   # Windows
```
```bash
bash test-notification.sh                                        # macOS / Linux
```

It accepts the same options as the core, e.g. to try another sound or sound-only:

```powershell
powershell -ExecutionPolicy Bypass -File test-notification.ps1 -Sound "sounds\other.mp3"
powershell -ExecutionPolicy Bypass -File test-notification.ps1 -NoText   # sound only
```
```bash
bash test-notification.sh --sound sounds/other.mp3
bash test-notification.sh --no-text   # sound only
```

---

## Project structure

```
RuiditoAgentes/
├── core/
│   ├── notify.ps1            Windows core (multi-format audio + text)
│   └── notify.sh             macOS/Linux core
├── adapters/
│   ├── claude-code/          Automatic installer for Claude Code
│   └── generic/              Command + config merge for any agent
├── lib/
│   └── merge-config.py       Merges the command into json/toml/yaml configs
├── sounds/
│   └── notify.wav            Default sound (replaceable)
├── scripts/
│   └── generate-default-sound.ps1   Generates the default WAV
├── config.example.json       Configuration template
├── examples/settings.json    Manual hook example (Claude Code)
└── test-notification.ps1/.sh Test the notification without an agent
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| No sound at all | Restart the agent. Make sure the command path points to `core/notify`. |
| Windows blocks the script | Use `-ExecutionPolicy Bypass` (already included in the adapters). |
| mp3/ogg won't play on Linux | Install `ffmpeg` (`ffplay`) or `mpg123`/`pulseaudio-utils`. |
| Text doesn't show on Linux | Install `libnotify-bin` (`notify-send`). |
| I want to test the sound | Run `test-notification` (see "Test the notification"). |

---

## Contributing

Contributions are welcome! Most useful: **new adapters** for other agents (create
a folder under `adapters/`), more audio formats, or better text notifications.

## License

[MIT](LICENSE). The default sound is original work generated by code
(`scripts/generate-default-sound.ps1`) and free to use.
