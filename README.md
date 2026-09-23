# Exter Library

<div align="center">

**A modern, feature-rich UI Library for Roblox**

*Created by [Sobing4413](https://github.com/SOBING4413) · Exter Interactive*

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-red.svg)](https://www.roblox.com)
[![Language](https://img.shields.io/badge/Language-Lua-purple.svg)](ExterLibrary.lua)
[![Status](https://img.shields.io/badge/Status-Beta-yellow.svg)]()
[![Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?logo=discord&logoColor=white)](https://discord.gg/77WnqnJcPu)

[Documentation](http://exter-library.gt.tc/) · [Examples](examples/) · [Discord](https://discord.gg/77WnqnJcPu)

</div>

---

## Overview

Exter Library is a comprehensive UI Library for Roblox scripts, designed to help developers quickly build clean, interactive GUIs with minimal effort. It provides a full set of ready-to-use UI elements, icon support (Lucide & Material Icons), theme customization, notifications, and more.

## Features

- **Rich UI Elements** — Buttons, toggles, sliders, dropdowns, text inputs, color pickers, and more
- **Navigation System** — Tab-based navigation with smooth transitions
- **Notification System** — Built-in toast-style notifications
- **Icon Support** — Hundreds of Lucide and Material Icons built-in
- **Theme Customization** — Gradient-based theming with full color control
- **Draggable Windows** — Moveable and resizable UI panels
- **Config Saving** — Persist user settings across sessions
- **Studio Compatible** — Works in both Roblox Studio and live games
- **Lightweight** — Single-file library, easy to load

## Installation

Load the library directly in your Roblox LocalScript using `loadstring`:

```lua
local ExterLibrary = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"
))()
```

> **Note:** Make sure `HttpService` is enabled in your game settings if you're testing in Studio.

## Quick Start

```lua
-- Load the library
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"
))()

-- Create a Window
local Window = Library:CreateWindow({
    Name = "My Script",
})

-- Create a Tab
local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "settings",
})

-- Add a Button
Tab:CreateButton({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end,
})

-- Add a Toggle
Tab:CreateToggle({
    Name = "Enable Feature",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end,
})
```

`Window` accepts an optional `LogoID` (a numeric Roblox asset id) if you want a custom logo instead of the default one — `Icon` names are only used on tabs and other elements, not on the window itself.

## UI Elements

| Element | Description |
|---|---|
| `CreateButton` | Clickable button with callback |
| `CreateToggle` | On/off toggle switch |
| `CreateSlider` | Numeric value slider |
| `CreateDropdown` | Selection dropdown menu, with single or multiple selection |
| `CreateInput` | Text input field |
| `CreateColorPicker` | RGB/HSV color picker |
| `CreateBind` / `CreateKeybind` | Keybind capture input |
| `CreateLabel` | Static text label |
| `CreateParagraph` | Multi-line text block |
| `CreateSection` | Visual separator/section header |

Every element also exposes a `:Set(...)` method afterwards to update its settings or value at runtime.

## Notifications

```lua
Library:Notification({
    Title = "Hello!",
    Content = "This is a notification.",
    Duration = 5,
})
```

## Icons

Exter Library includes two built-in icon sets:

- **Material Icons** — Google's Material Design icon set
- **Lucide Icons** — Clean, consistent open-source icons

Use icon names as strings when creating tabs or other elements:

```lua
local Tab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",  -- Material Icon name (default ImageSource)
})
```

To use a Lucide icon instead, set `ImageSource = "Lucide"` alongside the icon name. Browse the full icon list inside `ExterLibrary.lua`, or refer to the [documentation](http://exter-library.gt.tc/).

## Theme

The library uses a customizable gradient theme. The default gradient transitions from blue to teal to pink:

```lua
-- Default theme gradient
ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(117, 164, 206)),  -- Blue
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(123, 201, 201)),  -- Teal
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(224, 138, 175)),  -- Pink
}
```

## Examples

See the [`examples/`](examples/) folder for full script examples demonstrating different features.

## Credits

| Role | Name |
|---|---|
| Created By | Sobing4413 |
| Organization | Exter Interactive |
| Icons | [Latte Softworks](https://github.com/latte-soft) (Lucide), qweery (Material) |

## Community

Join the Discord server for support, updates, and to share your scripts:

[![Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/77WnqnJcPu)

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
