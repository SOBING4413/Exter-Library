# Exter Library

Professional Roblox UI Library focused on smooth animations, modern theming, and config-ready components.

## Features
- Complete UI elements: Button, Toggle, Slider, Dropdown, Input, ColorPicker, Bind, Label, Paragraph, Section.
- Built-in Notification system.
- Theme gradient system + presets.
- Global theme sync (accent applied across menu strokes/icons, not only theme panel).
- Config Save/Load/Autoload helpers.
- Mobile support and window hide/minimize controls.
- Default unload support with runtime toggle (`EnableUnload`) and `Window:Unload()`.
- Customizable menu keybind with default `Enum.KeyCode.K` (`Bind`/`MenuKeybind`, `Window:SetMenuKeybind()`).
- Built-in default Settings tab (`DefaultSettings = true`) with GUI keybind and unload controls.
- Optional premium visual layer (`PremiumEffects = true`) for richer title styling.
- Smoother transition engine (Quint easing + adaptive animation multiplier).
- Premium notification style (gradient card + icon pop animation).
- Mobile performance mode (`MobileOptimization`, `BlurEnabled`) for smoother Android usage.
- Executor GUI parent fallback (`syn.protect_gui`, `gethui`, `CoreGui`).

## Installation

```lua
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()
```

## Quick Start

```lua
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()

local Window = Exter:CreateWindow({
    Name = "My Hub",
    Subtitle = "Release",
    Bind = Enum.KeyCode.K, -- default menu toggle keybind
    EnableUnload = true, -- disable if your hub should never unload itself
    DefaultSettings = true, -- auto-create built-in Settings tab
    MenuAnimationSpeed = 0.32, -- lower=faster, higher=smoother
    LoadingTitle = "Exter Library",
    PremiumEffects = true,
    MobileOptimization = true,
    BlurEnabled = false, -- default for best FPS on all devices
    ConfigSettings = {
        ConfigFolder = "MyHub",
        RootFolder = "ExterConfigs"
    }
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home", ImageSource = "Material" })

Main:CreateButton({
    Name = "Print Hello",
    Description = "Simple callback example",
    Callback = function()
        print("Hello from Exter")
    end
})

Main:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(v)
        print("God Mode:", v)
    end
}, "GodModeFlag")
```

## Icons

### Supported Sources
- `Material` (default)
- `Lucide` (with runtime cache + safe fallback)
- `Custom` (`rbxassetid://` id string)

### Icon Fallback Behavior
If a Lucide icon fails to load or icon name is missing, Exter automatically falls back to a Material help icon.


## Credits

| Role | Name |
|---|---|
| Created By | Sobing4413 |
| Organization | Exter Interactive |

## Runtime Dependency

Exter currently loads its UI template from:

`rbxassetid://86467455075715`

If this asset is unavailable/private/moderated, the UI cannot render.

## API Overview

### Library
- `Exter:CreateWindow(WindowSettings)`
- `Exter:Notification(NotificationSettings)`
- `Exter:SaveConfig(name)`
- `Exter:LoadConfig(name)`
- `Exter:LoadAutoloadConfig()`
- `Exter:RefreshConfigList()`
- `Exter:Unload()` (alias to destroy UI)

### Window Methods
- `Window:SetMenuKeybind(Enum.KeyCode | string)`
- `Window:ToggleVisibility()`
- `Window:Unload()`

### Tab Methods
- `CreateButton`
- `CreateToggle`
- `CreateSlider`
- `CreateDropdown`
- `CreateInput`
- `CreateColorPicker`
- `CreateBind`
- `CreateLabel`
- `CreateParagraph`
- `CreateSection`
- `BuildConfigSection`
- `BuildThemeSection`

## Examples
- `examples/basic_example.lua`
- `examples/all_elements.lua`

## Executor Compatibility
Fallback order:
1. `syn.protect_gui` + `CoreGui`
2. `gethui()`
3. `CoreGui`

## Publishing Notes
Before publishing your script hub:
- Test in at least 2 executors.
- Confirm config save/load path.
- Confirm icon names used by your tabs/buttons.
- Verify keybind and mobile support behavior.


## Performance Tips
- Keep `BlurEnabled = false` for best FPS.
- Keep `MobileOptimization = true` even on low-end PC/laptop.
- Avoid creating excessive tabs/elements in one frame; batch creation with small `task.wait()` between groups.
