# 🚀 SketchyBar Lua Configuration

A modern, feature-rich configuration for [SketchyBar](https://felixkratz.github.io/SketchyBar) using the Lua plugin system. This configuration provides a clean, informative, and customizable menu bar experience for macOS.

## ✨ Features

- 🎨 **Modern Design**
  - Clean and minimal aesthetic with blur effects
  - Fully customizable colors and transparency
  - Rounded corners with dynamic borders
  - Consistent spacing and padding system

- 📊 **System Monitoring**
  - Real-time CPU usage tracking
  - Memory utilization metrics
  - Network traffic monitoring (up/down)
  - Battery status with charging indicators
  - Disk usage tracking

- 🎵 **Media Controls**
  - Current track information
  - Dynamic album artwork display
  - Media player controls
  - Support for multiple players:
    - Spotify
    - Music
    - Brave Browser

- 🔔 **Smart Notifications**
  - Homebrew updates counter
  - Mail notifications
  - Message indicators
  - System alerts
  - Volume and audio device controls

- 🖥️ **Workspace Management**
  - Dynamic space indicators
  - Active application tracking
  - Custom application icons
  - Window management integration
  - Space labels and navigation

## 🛠️ Prerequisites

- macOS
- [Homebrew](https://brew.sh)
- [Lua](https://www.lua.org)
- [SketchyBar](https://felixkratz.github.io/SketchyBar)
- [SbarLua](https://github.com/FelixKratz/SbarLua)

## 📦 Key Components

### Core Files
- `sketchybarrc` - Main entry point (Lua)
- `init.lua` - Initial configuration and module loading
- `bar.lua` - Bar appearance and behavior settings
- `colors.lua` - Color scheme definitions
- `settings.lua` - General configuration settings
- `icons.lua` - Icon definitions (SF Symbols/NerdFont)

### Modules
- **System Widgets** - CPU, Memory, Battery, Network monitoring
- **Media Controls** - Music player integration and controls
- **Space Management** - Workspace organization and navigation
- **Application Tracking** - Active window and application monitoring
- **Notification Center** - System and application notifications

## 🎨 Customization

The configuration is highly modular and customizable through:
- Color schemes
- Font selections
- Icon sets (SF Symbols or NerdFont)
- Layout adjustments
- Widget behavior
- Event triggers

## 🔧 Event System

Built-in C-based event providers for:
- CPU monitoring
- Memory usage
- Network traffic
- Disk usage
- Weather information

## 📚 Additional Resources

- [SketchyBar Documentation](https://felixkratz.github.io/SketchyBar/config/getting-started)
- [Lua Documentation](https://www.lua.org/docs.html)
- [SbarLua Wiki](https://github.com/FelixKratz/SbarLua/wiki)

## 🙏 Credits

- [SketchyBar](https://felixkratz.github.io/SketchyBar) by Felix Kratz
- [SbarLua](https://github.com/FelixKratz/SbarLua) by Felix Kratz

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.