# OBS-Lua-Scripts

A collection of Lua scripts for [OBS Studio][obs_studio] that automate scene switching, audio muting, and webcam fallback behaviour.

MIT licensed. Issues and PRs welcome.

---

## Table of Contents

- [OBS-Lua-Scripts](#obs-lua-scripts)
  - [Table of Contents](#table-of-contents)
  - [Scripts](#scripts)
    - [`focus_standby.lua`](#focus_standbylua)
    - [`splash_mic_mute.lua`](#splash_mic_mutelua)
    - [`webcam_fallback.lua`](#webcam_fallbacklua)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Contributing](#contributing)
  - [Security](#security)
  - [License](#license)

---

## Scripts

### `focus_standby.lua`

Shows a **standby** source whenever a specified game executable is *not* the active foreground window.

Useful for streamers who want their overlay to switch automatically when they alt-tab to Discord, a browser, or another app, and back again when they return to the game.

**How it works**

- Uses the Win32 API (`GetForegroundWindow`, `QueryFullProcessImageNameA`) to detect the executable name of the current foreground window.
- Toggles the visibility of a configured source inside a configured scene.
- Polls every 250 ms.

**Windows only.** Linux and macOS are not supported - the script loads cleanly but does nothing on other platforms.

**Settings** (configured in **Tools → Scripts**)

| Field               | Description                                             |
| ------------------- | ------------------------------------------------------- |
| Scene name          | The scene containing your standby overlay source.       |
| Standby source name | The source to show/hide.                                |
| Target executable   | The process that counts as "in game" (e.g. `game.exe`). |

---

### `splash_mic_mute.lua`

Mutes one or more audio sources whenever a splash screen is visible.

Detects any of the configured splash sources inside the configured scene, and mutes while at least one is on screen. Unmutes when they're all hidden.

**How it works**

- Iterates through the configured splash source list, checking visibility on a 250 ms timer.
- Only calls `obs_source_set_muted()` when the mute state actually changes, to avoid spamming OBS.
- Leave the microphone or desktop field empty to disable muting for that channel.

**Settings** (configured in **Tools → Scripts**)

| Field                | Description                                                 |
| -------------------- | ----------------------------------------------------------- |
| Scene name           | The scene to monitor.                                       |
| Microphone source    | Microphone source to mute. Leave blank to disable.          |
| Desktop audio source | Desktop audio source to mute. Leave blank to disable.       |
| Splash sources       | Editable list of source names that count as splash screens. |

---

### `webcam_fallback.lua`

Keeps a webcam source and a fallback image from ever being visible at the same time.

**Behaviour**

- If the webcam turns on, the fallback is hidden.
- If the fallback turns on, the webcam is hidden.
- If both are off, the fallback is shown automatically.

This lets you toggle your webcam on and off in OBS without juggling overlays - the fallback image appears whenever the camera isn't active.

**Settings** (configured in **Tools → Scripts**)

| Field                | Description                             |
| -------------------- | --------------------------------------- |
| Scene name           | The scene containing both sources.      |
| Webcam source name   | Your camera source.                     |
| Fallback source name | The image shown when the webcam is off. |

---

## Installation

1. Download or clone this repository.
2. In OBS Studio, open **Tools → Scripts**.
3. Click the **+** button and select one of the `.lua` files from the `SCRIPTS/` folder.
4. Select the script in the list on the left, then fill in the settings that appear on the right.

Settings are saved with your scene collection, so you only configure each script once per OBS profile.

> **Note:** `focus_standby.lua` relies on the Win32 API and only works on Windows.

---

## Configuration

All three scripts are configured through OBS's **Tools → Scripts** panel. There are no hardcoded values to edit - you can install the scripts, point them at your own scenes and sources, and be done.

Source and scene names are **case-sensitive**, and must match exactly what appears in your OBS scene collection.

If a required field is left blank, the script does nothing. This is intentional - it prevents stray errors on first install.

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on pull requests, coding style, and how to propose a new script.

**Found a bug?** [Open a bug report][bug_report_template] - the template will be prefilled, and it asks for the details that make bugs easy to reproduce: OBS version, OS, steps, and script log output.

For anything involving exposed credentials, personal data, or security-sensitive behaviour, please read [SECURITY.md](SECURITY.md) before opening an issue.

---

## Security

Do not open a public issue for security problems. See [SECURITY.md](SECURITY.md) for the private reporting process.

---

## License

[MIT](LICENSE) © Jericho Crosby (Chalwk)

---

[obs_studio]: https://obsproject.com/
[bug_report_template]: https://github.com/Chalwk/OBS-Lua-Scripts/issues/new?template=bug-report.yaml