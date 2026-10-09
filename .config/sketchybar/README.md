# sketchybar

A Lua ([SbarLua](https://github.com/FelixKratz/SbarLua)) configuration for
[SketchyBar](https://felixkratz.github.io/SketchyBar) on macOS: full-width top
bar, SF Symbols throughout, dark popups. Every popup opens and closes by
clicking its bar cell; opening one closes the rest (`helpers/popups.lua`,
exclusive like the reference setup — SketchyBar has no click-outside event).

## Layout

Left to right: Apple · spaces · front app · app menus.
Right to left: calendar/date · battery · wifi · volume · control center ·
passwords · keyboard layout · **agent usage**.

## Widgets of note

**Agent usage** (`items/widgets/agents.lua`, `helpers/agents_usage.py`) — Claude
Code + Codex quota, shown as **remaining** (like the ChatGPT app). One cell per
engine, auto-hiding when its source is absent:

- data is read from local files only (`~/.claude.json`,
  `~/.codex/sessions`), no network;
- the helper scans only the 12 newest session files and picks the record with
  the latest event timestamp (~0.09 s cold), then the bar caches on file mtime;
- bar cell: `◎ 49%`, amber ≤ 20 %, red ≤ 5 %;
- popup: per-engine 5h/week rows with 50-cell gauges and precise reset
  countdown (`5d 23h 38m reset`), reset right-aligned with the gauge end.

**Volume** (`items/widgets/volume.lua`) — bar glyph plus dark `VOLUME` popup:
slider, mute toggle, `OUTPUT` device list (click to switch, `✓` marks the
current); mute and device changes are pushed by the resident `audio watch`
daemon (`volume_refresh` event) with a 30 s safety-net poll. Devices, real transport kinds and
switching come from the CoreAudio helper (`helpers/audio.swift`, built with
`swiftc -O helpers/audio.swift -o helpers/audio`).

**Battery** (`items/widgets/battery.lua`) — bar glyph + `%`, dark `BATTERY`
popup: status (`99% · Charging`), 40-cell gauge, time remaining/to-full, and
health / cycle count / temperature from `ioreg`.

**Calendar** (`items/calendar.lua`) — date + time cell with a dark month-grid
popup on click: today as `[dd]`, `‹ prev` / `next ›` rows, `●` jumps back to
this month, plus upcoming events from Apple Calendar via his `events` helper
(local EventKit, no network).

**Keyboard** (`items/widgets/keyboard.lua`) — bar shows the current layout,
click opens a dark `KEYBOARD` popup listing enabled layouts (`✓` marks the
current) to switch between them. Switching uses the local `kbswitch` helper
(TextInput API, built with `swiftc -O helpers/kbswitch.swift -o
helpers/kbswitch`).

**Wi-Fi** (`items/widgets/wifi.lua`) — bar glyph,
dark `WI-FI` popup on click: current ssid / ip / router plus the preferred
(saved) networks with the current one marked `✓`; clicking another joins it
via `networksetup` (keychain password for known networks). Network calls are
alarm-guarded and the wake refresh is staggered so a cold network stack after
lid-open can't stall the bar — nothing here ever touches the network itself.

## Files

- `sketchybarrc` — entry point (Lua 5.4), enables hot reload
- `init.lua` — loads `bar`, `default`, `items`
- `bar.lua` / `default.lua` / `settings.lua` / `colors.lua` / `icons.lua` —
  bar geometry, defaults, fonts, theme, icon set
- `items/` — left/right widgets (`items/widgets/agents.lua`,
  `items/widgets/volume.lua`, `keyboard.lua`, …)
- `helpers/` — `agents_usage.py` extractor, `audio.swift` CoreAudio helper,
  `events.swift` calendar helper and `kbswitch.swift` keyboard helper (+ built
  binaries), `wake.lua` post-wake blackout, `underline.lua` active-popup
   binaries), `wake.lua` post-wake blackout, `underline.lua` active-popup
   underline, `popups.lua` exclusive-popup registry, `menus` binary. All
   helpers build via `helpers/makefile`, rebuilt only when their sources are
   newer than the binaries

## Requirements

- macOS, Homebrew, [SketchyBar](https://felixkratz.github.io/SketchyBar),
  Lua 5.4 with [SbarLua](https://github.com/FelixKratz/SbarLua)
- Xcode Command Line Tools (only to build `helpers/audio` once)
- Optional: Claude Code and/or Codex — the agent cell appears only for the
  engines actually installed

## Credits

- [SketchyBar](https://felixkratz.github.io/SketchyBar) and
  [SbarLua](https://github.com/FelixKratz/SbarLua) by Felix Kratz — the bar
  itself; this repo is only configuration
- [garamnohhh/sketchybar-island](https://github.com/garamnohhh/sketchybar-island) —
  the agent-cell concept (local usage parsing, remaining %, gauge popup), the
  volume/calendar popup structures, and the CoreAudio `audio` helper source;
  adapted here to Lua with SF/Menlo fonts
- Fonts: Apple SF Pro / SF Mono / Menlo (macOS),
  [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font) for
  app icons, [Nerd Fonts](https://www.nerdfonts.com) (Material Design device
  glyphs only)

## License

MIT — see [LICENSE](LICENSE).
