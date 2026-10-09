# sketchybar

A Lua ([SbarLua](https://github.com/FelixKratz/SbarLua)) config for [SketchyBar](https://felixkratz.github.io/SketchyBar): a full-width top bar with dark, click-to-open popups.

## Full install

On a fresh Mac (Apple silicon, macOS 14+):

1. **Homebrew** — https://brew.sh
2. **Xcode Command Line Tools** (the helpers are small Swift/C programs):
   ```sh
   xcode-select --install
   ```
3. **Clone to `~/.config/sketchybar`** (paths are fixed) — move any existing
   config out of the way first:
   ```sh
   git clone <this repo> ~/.config/sketchybar
   ```
4. **Run the installer** — installs SketchyBar, Lua 5.4, SbarLua, the fonts
   (SF Pro, SF Mono, SF Symbols, Hack Nerd Font, sketchybar-app-font), builds
   the helpers and starts the bar:
   ```sh
   bash ~/.config/sketchybar/helpers/install.sh
   ```
   It ends with `helpers/doctor.sh`, a checklist of anything still missing
   with the exact command to fix it.
5. **Hide the macOS menu bar** — System Settings → Control Center →
   *Automatically hide and show the menu bar* → **Always**.
6. **One-time permissions** (macOS asks the first time you use each):
   - **Calendars** — open the calendar popup and allow `sketchybar`.
   - **Wi-Fi name** — macOS hides it from scripts; to mark the current
     network run `sudo ipconfig setverbose 1` (or create a Shortcut named
     *SketchyBar Wi-Fi* that returns the network name).
   - **Bluetooth / System Events** — the Control Center toggles.

Re-run `bash ~/.config/sketchybar/helpers/doctor.sh` any time something
looks off.

### Optional

- **Live Claude usage** — Claude Code passes its current rate limits to a
  statusline script on every update. Add to `~/.claude/settings.json`:
  ```json
  "statusLine": { "type": "command", "command": "~/.config/sketchybar/helpers/claude_statusline.py" }
  ```
  (it also shows `ctx · 5h · wk` in Claude Code). Without it the bar uses what
  Claude Code / the desktop app last saved, and the popup shows its age.
- **Calendar** — events come from every account in System Settings →
  Internet Accounts (Google, iCloud, Exchange…), i.e. whatever Calendar.app
  or Notion Calendar shows. *Calendar ↗* opens Notion Calendar, or
  Calendar.app if it isn't installed.
- [yabai](https://github.com/koekeishiya/yabai) — click a space to switch to it.
- Claude Code, Codex, Tailscale — their parts hide when not installed.

## What's in the bar

**Left:** Apple (system stats, power actions) · spaces · front app · app menus

**Right:** next meeting (shows up 30 min before) · Claude / Codex usage ·
keyboard layout · Control Center (Wi-Fi, Bluetooth, dark mode, brightness,
keyboard light, sound) · volume + outputs · Wi-Fi + saved networks + Tailscale ·
battery · date/time + calendar

Click a cell to open its popup; click it again or anywhere else to close.

## Configure

`settings.lua`:

| Setting | Meaning |
|---|---|
| `calendars` | limit the calendar to these calendar names (as in Calendar.app); empty = all |
| `calendar_app` | app opened by *Calendar ↗* (default Notion Calendar) |
| `next_event_minutes` | how early the next meeting appears (0 = only while it runs) |

Keep personal choices out of the repo in `settings.local.lua` (git-ignored);
it returns only the keys you change:

```lua
return { calendars = { "Work", "Holidays in Italy" }, calendar_app = "Calendar" }
```

Fonts are in `helpers/default_font.lua`, colors in `colors.lua`. Reload with
`sketchybar --reload`.

## How it fits together

- `items/` — one file per widget; `helpers/popup.lua` builds every popup
  (one grid, batched updates, rows created after the bar's first paint).
- `helpers/` — small native helpers (calendar, audio, keyboard, Control
  Center, click-away, calendar grid) rebuilt automatically when changed, and
  the Claude/Codex usage reader.
- Updates are event-driven where macOS offers events; the few timers are
  cheap (clock 30s, Wi-Fi and Claude/Codex usage 60s, battery/volume 2 min);
  popups read their data
  only when opened.

Logs: `/opt/homebrew/var/log/sketchybar/sketchybar.out.log`.

## Credits

[SketchyBar](https://felixkratz.github.io/SketchyBar) and
[SbarLua](https://github.com/FelixKratz/SbarLua) by Felix Kratz;
[sketchybar-island](https://github.com/garamnohhh/sketchybar-island) for the
popup design, agent-usage idea and the `audio`/`events` helpers;
[sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font);
[Nerd Fonts](https://www.nerdfonts.com).

## License

MIT — see [LICENSE](LICENSE).
