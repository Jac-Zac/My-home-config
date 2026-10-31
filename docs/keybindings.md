# Keybindings

Everything here is handled by [rift](https://github.com/acsandmann/rift)
([`.config/rift/config.toml`](../.config/rift/config.toml)) unless noted.
<kbd>command</kbd> is the main modifier; <kbd>hyper</kbd> = <kbd>ctrl + alt + command</kbd>.

- [Two kinds of workspace](#two-kinds-of-workspace)
- [Apps](#apps)
- [Windows and workspaces](#windows-and-workspaces)
- [The scrolling strip](#the-scrolling-strip)
- [Layouts](#layouts)
- [macOS desktops, mouse, session](#macos-desktops-mouse-session)
- [tmux and shell](#tmux-and-shell)

## Two kinds of workspace

Each macOS desktop has its own nine rift **workspaces** (`01`–`09` in the bar).
The layout decides what some keys and swipes do:

| Where                                    | Layout                     | <kbd>command + j/k</kbd> and swipes act on |
| ---------------------------------------- | -------------------------- | ------------------------------------------ |
| **Main display** (the one with the menu bar) | bsp tiling, <kbd>command + shift + s</kbd> for the strip | workspaces |
| **Second display** (the laptop, when connected to a monitor) — "the strip" | scrolling, set automatically | columns of the strip, then workspaces |

You can tell where you are from the bar: the pill after the app name shows the
layout (`bsp`, `scroll`, `master`, …). The bar always shows all nine
workspaces.

## Apps

| Keybind                            | Action                  |
| ---------------------------------- | ----------------------- |
| <kbd>command + shift + enter</kbd> | Terminal (Ghostty)      |
| <kbd>command + 0</kbd>             | Browser (Helium)        |
| <kbd>command + m</kbd>             | WhatsApp                |
| <kbd>command + g</kbd>             | ChatGPT                 |
| <kbd>command + space</kbd>         | Raycast *(Raycast)*     |
| <kbd>command + w</kbd> / <kbd>command + q</kbd> | Close window / quit app *(macOS)* |

Some apps always open on their own workspace: T3 Code `02`, Ghostty `03`,
Slack `05`. Settings-like apps (System Settings, Finder, Mail,
Calculator, Activity Monitor…) always float.

## Windows and workspaces

| Keybind                            | bsp                                     | In the strip                        |
| ---------------------------------- | --------------------------------------- | ----------------------------------- |
| <kbd>command + h / l</kbd>         | Focus window left / right               | Focus column left / right           |
| <kbd>command + shift + h / l</kbd> | Swap window with its left / right neighbour | Move column one place left / right |
| <kbd>command + 1-9</kbd>           | Go to workspace 1-9                     | same                                |
| <kbd>command + j / k</kbd>         | Previous / next workspace (wraps 09 → 01) | **Previous / next column**, then the previous / next workspace |
| <kbd>command + shift + 1-9</kbd>   | Send window to workspace 1-9 and follow | same — the window leaves the strip  |
| <kbd>command + shift + j / k</kbd> | Send window to previous / next workspace and follow | Move column left / right, then to the previous / next workspace |
| <kbd>command + shift + t</kbd>     | Float / unfloat the window, centred     | same                                |
| <kbd>command + shift + m</kbd>     | Maximize the window within the gaps (toggle) | same                           |
| <kbd>command + shift + o</kbd>     | Cycle all windows in the current workspace, including floating windows | same     |
| <kbd>command + shift + ↑ / ↓</kbd> | Move window to the display above (external) / below (laptop) | same             |
| three-finger swipe                 | Previous / next workspace               | Scroll the columns, then on to the previous / next workspace |

## The scrolling strip

The strip is a row of **columns**, one window each, that is wider than the
screen and scrolls sideways — like a long piece of paper you slide left and
right (the [niri](https://github.com/YaLTeR/niri) model).

- **One window** fills the screen. **Two** sit half and half.
- **A new window** opens as a new column right of the focused one; the strip
  scrolls so it is in view. With three or more columns some are off-screen.
- **Moving focus** (<kbd>command + h/l</kbd>, <kbd>j/k</kbd>, a three-finger
  swipe) scrolls the strip just enough to show the focused column. Fingers
  right-to-left = next column. Past the last column, <kbd>j/k</kbd> and the
  swipe carry on to the next workspace (swipe a little further past the edge).
- **Width**: columns start at half the screen. <kbd>command + shift + r</kbd>
  cycles the focused column ½ → ⅔ → full width → ½. <kbd>command + shift + m</kbd>
  is a quick full-screen toggle for one window.
- **Order**: <kbd>command + shift + h/l</kbd> moves the focused column one
  place left / right.
- **Workspaces still exist** in the strip — <kbd>command + 1-9</kbd>, the bar
  (click a number), or past the strip's edge. On the second display each of
  them is a strip too.

How it works: [`sketchybar/helpers/rift.lua`](../.config/sketchybar/helpers/rift.lua)
switches the second display's workspaces to the scrolling layout;
[`rift/strip_key.sh`](../.config/rift/strip_key.sh) and
[`strip_move.sh`](../.config/rift/strip_move.sh) make <kbd>j/k</kbd> walk the
columns in any scrolling workspace; the swipes are rift's own gestures in
[`config.toml`](../.config/rift/config.toml). (If sketchybar isn't running, the
second display isn't switched to scrolling automatically — use
<kbd>command + shift + s</kbd>.)

## Layouts

These change the **current workspace** only.

| Keybind                            | Layout / action                                          |
| ---------------------------------- | -------------------------------------------------------- |
| <kbd>command + shift + b</kbd>     | **bsp** — every new window halves the focused one, 50/50 |
| <kbd>command + shift + e</kbd>     | **master-stack** — master on the left half, the rest stacked evenly on the right |
| <kbd>command + shift + p</kbd>     | Master-stack: make the focused window the master         |
| <kbd>command + shift + s</kbd>     | **scrolling** strip (automatic on the second display)    |
| <kbd>command + shift + f</kbd>     | **floating** — rift stops tiling this workspace          |

bsp never rebalances on its own: with three windows you get ½ / ¼ / ¼, and a
manual resize stays until windows close. Master-stack is the balanced option.

## macOS desktops, mouse, session

| Keybind                          | Action                                         |
| -------------------------------- | ---------------------------------------------- |
| <kbd>ctrl + ← / →</kbd>          | Previous / next macOS desktop *(macOS)*        |
| four-finger swipe                | Same, on the trackpad *(macOS)*                |
| <kbd>alt</kbd> + drag            | Move a window; drop it on another to swap them |
| <kbd>hyper + q</kbd>             | Restart rift, borders and sketchybar           |
| <kbd>hyper + shift + q</kbd>     | Log out                                        |

## tmux and shell

tmux prefix is <kbd>ctrl + a</kbd>.

| Keybind                     | Action                    |
| --------------------------- | ------------------------- |
| <kbd>prefix + s</kbd>       | Sesh session picker (tv)  |
| <kbd>prefix + t</kbd>       | Window picker (tv)        |
| <kbd>prefix + S</kbd>       | SSH host picker (tv)      |
| <kbd>prefix + L</kbd>       | Last sesh session         |
| <kbd>prefix + g</kbd>       | lazygit popup             |
| <kbd>prefix + j / k</kbd>   | Next / previous window    |
| <kbd>ctrl + t</kbd>         | Shell autocomplete (tv)   |
| <kbd>ctrl + r</kbd>         | Shell history (tv)        |
