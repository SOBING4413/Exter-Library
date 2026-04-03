<p align="center">
  <img src="https://img.shields.io/badge/Exter_Library-v1-7C5CFF?style=for-the-badge&logo=lua&logoColor=white" alt="Exter Library v1"/>
  <img src="https://img.shields.io/badge/Platform-Roblox-00A2FF?style=for-the-badge&logo=roblox&logoColor=white" alt="Roblox"/>
  <img src="https://img.shields.io/badge/Language-Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
</p>

<h1 align="center">⚡ Exter Library</h1>

<p align="center">
  <strong>A modern, feature-rich UI library for Roblox script executors.</strong><br/>
  Smooth animations · Multiple themes · Full configuration saving · Clean API
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-features">Features</a> •
  <a href="#-themes">Themes</a> •
  <a href="#-api-reference">API Reference</a> •
  <a href="#-elements">Elements</a> •
  <a href="#-configuration">Configuration</a> •
  <a href="#-examples">Examples</a>
</p>

---

## 🚀 Quick Start

Load the library in your script executor with a single line:

```lua
local Exter = loadstring(game:HttpGet('https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ExterLibrary'))()
```

> **Note:** Replace the URL with the raw GitHub URL where you host `ExterLibrary`.

### Minimal Example

```lua
local Exter = loadstring(game:HttpGet('YOUR_RAW_URL_HERE'))()

local Window = Exter:CreateWindow({
    Name = "My Script Hub",
    Theme = "Dark",
    LoadingTitle = "My Script Hub",
    LoadingSubtitle = "Initializing...",
})

local Tab = Window:CreateTab({ Name = "Main", Icon = "🏠" })

Tab:CreateButton({
    Name = "Print Hello",
    Callback = function()
        print("Hello from Exter Library!")
    end,
})
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎨 **5 Built-in Themes** | Dark, Light, Neon, Ocean, Sunset — switch on the fly |
| 💾 **Config Saving** | Automatically save and load user settings per-game |
| 🖱️ **Draggable Window** | Smooth drag with inertia-based tweening |
| ⌨️ **Toggle Key** | Show/hide the UI with a configurable keybind (default: `RightControl`) |
| 🔔 **Notification System** | Toast notifications with types, progress bars, and action buttons |
| 🌊 **Smooth Animations** | Quint easing, spring tweens, and ripple effects on interactions |
| 📱 **Touch Support** | Works on both desktop and mobile (touch input) |
| 🛡️ **Executor Compatibility** | Supports `gethui()`, `syn.protect_gui`, and standard `CoreGui` parenting |
| 🔄 **Auto Cleanup** | Destroys old instances when re-executing to prevent duplicates |
| ⚡ **Lightweight** | Single-file library, no external dependencies |

---

## 🎨 Themes

Exter Library ships with **5 professionally designed themes**. Set the theme when creating a window, or cycle through them at runtime using the 🎨 button in the topbar.

### Dark (Default)
> Deep dark background with Discord-inspired purple accent. Perfect for low-light environments.

### Light
> Clean white interface with blue accent. High contrast and easy readability.

### Neon
> Cyberpunk-inspired with black background and vibrant green (#00FFAA) accent. High visual impact.

### Ocean
> Deep sea blue tones with sky-blue accent. Calm and professional appearance.

### Sunset
> Warm dark tones with pink/rose accent. Elegant and distinctive look.

```lua
-- Set theme on creation
local Window = Exter:CreateWindow({
    Name = "Hub",
    Theme = "Neon",  -- "Dark" | "Light" | "Neon" | "Ocean" | "Sunset"
})
```

### Theme Color Properties

Each theme defines the following color tokens:

| Category | Properties |
|----------|-----------|
| **Background** | `Background`, `BackgroundSecondary`, `Topbar`, `TopbarBorder`, `Shadow` |
| **Text** | `TextPrimary`, `TextSecondary`, `TextMuted` |
| **Accent** | `Accent`, `AccentHover`, `AccentDark` |
| **Elements** | `ElementBackground`, `ElementBackgroundHover`, `ElementBorder`, `ElementBorderHover` |
| **Tabs** | `TabBackground`, `TabBackgroundSelected`, `TabBorder`, `TabText`, `TabTextSelected` |
| **Toggle** | `ToggleEnabled`, `ToggleDisabled`, `ToggleKnob` |
| **Slider** | `SliderBackground`, `SliderFill`, `SliderKnob` |
| **Input** | `InputBackground`, `InputBorder`, `InputBorderFocus`, `PlaceholderText` |
| **Dropdown** | `DropdownBackground`, `DropdownItemHover` |
| **Notification** | `NotificationBackground`, `NotificationBorder` |
| **Status** | `Success`, `Warning`, `Error`, `Info` |
| **Misc** | `ScrollbarColor`, `DividerColor` |

---

## 📖 API Reference

### Library

#### `Exter:CreateWindow(settings) → Window`

Creates the main UI window.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Exter Library"` | Window title displayed in the topbar |
| `Theme` | `string` | `"Dark"` | Initial theme name |
| `LoadingTitle` | `string` | `"Exter Library"` | Title shown during loading animation |
| `LoadingSubtitle` | `string` | `"Loading..."` | Subtitle shown during loading animation |
| `ToggleKey` | `Enum.KeyCode` | `RightControl` | Key to toggle UI visibility |
| `GameplayFriendly` | `boolean` | `true` | Uses compact sizing + higher UI transparency so gameplay stays visible |
| `EnableBackgroundEffects` | `boolean` | `false` | Enables cinematic backdrop/orb effects (recommended only when not playing actively) |
| `UsageInfo` | `table` | `nil` | Mandatory usage info table shown in sidebar (character/script/executor/build + extra rows) |
| `ConfigurationSaving` | `table` | `nil` | Configuration saving options (see below) |

**ConfigurationSaving options:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Enabled` | `boolean` | `false` | Enable/disable config saving |
| `FileName` | `string` | `game.PlaceId` | Config file name (without extension) |

**UsageInfo options:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Informasi Wajib"` | Header for the mandatory info table |
| `Subtitle` | `string` | `"Karakter / Script yang menggunakan UI"` | Subtitle label shown above rows |
| `Character` | `string` | `LocalPlayer.Name` | Character/user name currently using the UI |
| `Script` | `string` | `Window Name` | Script name using the GUI |
| `Executor` | `string` | `identifyexecutor()` | Executor/client identifier |
| `Build` | `string` | `Release` | Build/version tag |
| `Required` | `table<string>` | `{"Character","Script","Executor","Build"}` | Required key list displayed in subtitle |
| `Extra` | `table` | `{}` | Additional rows in `{ Key = \"...\", Value = \"...\" }` format |

```lua
local Window = Exter:CreateWindow({
    Name = "My Hub",
    Theme = "Ocean",
    LoadingTitle = "My Hub",
    LoadingSubtitle = "Loading scripts...",
    ToggleKey = Enum.KeyCode.RightShift,
    GameplayFriendly = true,
    EnableBackgroundEffects = false,
    UsageInfo = {
        Character = game.Players.LocalPlayer.Name,
        Script = "My Hub Script",
        Executor = "Auto",
        Build = "v2.0",
        Extra = {
            { Key = "Mode", Value = "Raid" },
            { Key = "Server", Value = tostring(game.JobId) },
        }
    },
    ConfigurationSaving = {
        Enabled = true,
        FileName = "MyHubConfig",
    },
})
```

---

#### `Exter:Notify(settings)`

Displays a toast notification.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Notification"` | Notification title |
| `Content` | `string` | `""` | Notification body text |
| `Type` | `string` | `"Info"` | Type: `"Info"`, `"Success"`, `"Warning"`, `"Error"` |
| `Duration` | `number` | `5` | Duration in seconds before auto-dismiss |
| `Actions` | `table` | `nil` | Array of action buttons (see below) |

**Action button format:**

```lua
{ Name = "Button Text", Callback = function() end }
```

```lua
Exter:Notify({
    Title = "Script Loaded",
    Content = "All modules initialized successfully.",
    Type = "Success",
    Duration = 5,
    Actions = {
        { Name = "OK", Callback = function() print("Acknowledged") end },
        { Name = "Details", Callback = function() print("Show details") end },
    },
})
```

---

#### `Exter:Destroy()`

Completely removes the UI from the game. Destroys the ScreenGui and cleans up references.

```lua
Exter:Destroy()
```

---

### Window

#### `Window:CreateTab(settings) → Tab`

Creates a new tab in the sidebar.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | *required* | Tab display name |
| `Icon` | `string` | `nil` | Emoji icon displayed before the tab name |

```lua
local MainTab = Window:CreateTab({ Name = "Main", Icon = "🏠" })
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "⚔️" })
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "👁️" })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "⚙️" })
```

> The first tab created is automatically selected.

---

#### `Window:LoadConfiguration()`

Manually loads saved configuration. This is called automatically 2.5 seconds after window creation, but can be called manually if needed.

```lua
Window:LoadConfiguration()
```

---

## 🧩 Elements

All elements are created through a `Tab` object returned by `Window:CreateTab()`.

---

### Section

Visual separator with an uppercase label and divider line.

```lua
Tab:CreateSection("Section Name")
```

**Returns:** `{ Set = function(newName) }`

```lua
local section = Tab:CreateSection("Combat")
section:Set("New Section Name")  -- Update section title
```

---

### Label

Simple text display element with a subtle background.

```lua
Tab:CreateLabel("Label text here")
```

**Returns:** `{ Set = function(newText) }`

```lua
local label = Tab:CreateLabel("Status: Ready")
label:Set("Status: Running")  -- Update label text
```

---

### Paragraph

Multi-line text block with title and content.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Title"` | Paragraph heading |
| `Content` | `string` | `"Content"` | Paragraph body (supports wrapping) |

```lua
local para = Tab:CreateParagraph({
    Title = "Welcome",
    Content = "This script provides various features for enhanced gameplay. Use the tabs on the left to navigate between different categories.",
})

para:Set({
    Title = "Updated Title",
    Content = "Updated content text.",
})
```

---

### Button

Clickable button with ripple effect and success/error feedback.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Button"` | Button display text |
| `Callback` | `function` | *required* | Function called on click |

```lua
local btn = Tab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end,
})

btn:Set("New Button Name")  -- Update button text
```

> On callback error, the button flashes red and shows "Error!" for 0.5s.

---

### Toggle

On/off switch with smooth animation.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Toggle"` | Toggle display text |
| `CurrentValue` | `boolean` | `false` | Initial state |
| `Flag` | `string` | `nil` | Unique flag name for config saving |
| `Callback` | `function` | *required* | Called with `(boolean)` on state change |

```lua
local toggle = Tab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "toggle_godmode",
    Callback = function(value)
        if value then
            -- Enable god mode
        else
            -- Disable god mode
        end
    end,
})

toggle:Set(true)   -- Programmatically enable
toggle:Set(false)  -- Programmatically disable
```

---

### Slider

Draggable value slider with real-time updates.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Slider"` | Slider display text |
| `Range` | `{min, max}` | `{0, 100}` | Value range |
| `Increment` | `number` | `1` | Step increment |
| `CurrentValue` | `number` | `min` | Initial value |
| `Suffix` | `string` | `nil` | Unit suffix (e.g., `"studs/s"`) |
| `Flag` | `string` | `nil` | Unique flag name for config saving |
| `Callback` | `function` | *required* | Called with `(number)` on value change |

```lua
local slider = Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Suffix = "studs/s",
    Flag = "slider_walkspeed",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})

slider:Set(100)  -- Programmatically set value
```

---

### Input

Text input field with focus animations.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Input"` | Input label text |
| `PlaceholderText` | `string` | `"Type here..."` | Placeholder when empty |
| `RemoveTextAfterFocusLost` | `boolean` | `false` | Clear input after submission |
| `Flag` | `string` | `nil` | Unique flag name for config saving |
| `Callback` | `function` | *required* | Called with `(string)` on focus lost |

```lua
local input = Tab:CreateInput({
    Name = "Target Player",
    PlaceholderText = "Enter username...",
    RemoveTextAfterFocusLost = false,
    Flag = "input_target",
    Callback = function(text)
        print("Target set to:", text)
    end,
})

input:Set("PlayerName")  -- Programmatically set text
```

---

### Dropdown

Selection menu with single or multi-select support.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Dropdown"` | Dropdown label text |
| `Options` | `{string}` | `{}` | Array of option strings |
| `CurrentOption` | `{string}` | `{}` | Initially selected option(s) |
| `MultipleOptions` | `boolean` | `false` | Allow multiple selections |
| `Flag` | `string` | `nil` | Unique flag name for config saving |
| `Callback` | `function` | *required* | Called with `({string})` on selection change |

```lua
-- Single select
local dropdown = Tab:CreateDropdown({
    Name = "ESP Type",
    Options = {"Box", "Corner", "Highlight", "Chams"},
    CurrentOption = {"Box"},
    MultipleOptions = false,
    Flag = "dropdown_esp",
    Callback = function(options)
        print("Selected:", options[1])
    end,
})

-- Multi select
local multiDrop = Tab:CreateDropdown({
    Name = "Features",
    Options = {"Aimbot", "ESP", "Speed", "Fly", "Noclip"},
    CurrentOption = {"ESP", "Speed"},
    MultipleOptions = true,
    Flag = "dropdown_features",
    Callback = function(options)
        print("Active features:", table.concat(options, ", "))
    end,
})

dropdown:Set({"Highlight"})           -- Single select
multiDrop:Set({"Aimbot", "ESP"})      -- Multi select
```

> Single-select dropdowns auto-close after selection. Multi-select stays open.

---

### Keybind

Configurable key binding with listen mode.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Keybind"` | Keybind label text |
| `CurrentKeybind` | `string` | `"E"` | Initial key name (e.g., `"F"`, `"G"`, `"LeftShift"`) |
| `Flag` | `string` | `nil` | Unique flag name for config saving |
| `Callback` | `function` | *required* | Called when the bound key is pressed |

```lua
local keybind = Tab:CreateKeybind({
    Name = "Toggle Fly",
    CurrentKeybind = "F",
    Flag = "keybind_fly",
    Callback = function()
        -- Toggle fly on/off
        print("Fly toggled!")
    end,
})

keybind:Set("G")  -- Change keybind programmatically
```

> Click the key box to enter listen mode (`...`), then press any key to rebind.

---

### Color Picker

HSV color picker with hex input support.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | `"Color Picker"` | Color picker label text |
| `Color` | `Color3` | `Color3.fromRGB(255,255,255)` | Initial color |
| `Flag` | `string` | `nil` | Unique flag name for config saving |
| `Callback` | `function` | *required* | Called with `(Color3)` on color change |

```lua
local colorPicker = Tab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "color_esp",
    Callback = function(color)
        print("New color:", color)
    end,
})

colorPicker:Set(Color3.fromRGB(0, 255, 128))  -- Set color programmatically
```

> Click the color preview to expand the picker. Supports SV plane, hue slider, and hex input.

---

## 💾 Configuration

Exter Library supports automatic configuration saving and loading using the executor's file system (`writefile`, `readfile`, `isfolder`, `makefolder`, `isfile`).

### File Structure

```
ExterLib/
└── Configs/
    └── MyConfig.exter      ← JSON-encoded settings
```

### How It Works

1. **Enable** config saving in `CreateWindow`:
   ```lua
   ConfigurationSaving = {
       Enabled = true,
       FileName = "MyConfig",
   }
   ```

2. **Flag** each element you want to save:
   ```lua
   Tab:CreateToggle({
       Name = "Feature",
       Flag = "unique_flag_name",  -- ← This enables saving for this element
       Callback = function(v) end,
   })
   ```

3. **Auto-save**: Settings are saved automatically whenever a flagged element changes.

4. **Auto-load**: Settings are restored 2.5 seconds after window creation.

### Supported Save Types

| Element | Saved Value |
|---------|-------------|
| Toggle | `boolean` |
| Slider | `number` |
| Dropdown | `{string}` (selected options) |
| Input | `string` |
| Keybind | `string` (key name) |
| Color Picker | `{R, G, B}` (0-255) |

---

## 🎯 Window Controls

| Control | Action |
|---------|--------|
| **Drag Topbar** | Move the window |
| **🎨 Button** | Cycle through themes |
| **─ Button** | Minimize (collapse to topbar only) |
| **× Button** | Hide the window |
| **Toggle Key** | Show/hide window (default: `RightControl`) |

---

## 📋 Full Example

```lua
-- ═══════════════════════════════════════════════
-- EXTER LIBRARY — FULL EXAMPLE SCRIPT
-- ═══════════════════════════════════════════════

local Exter = loadstring(game:HttpGet('YOUR_RAW_URL_HERE'))()

-- Create Window
local Window = Exter:CreateWindow({
    Name = "Exter Hub v1",
    Theme = "Dark",
    LoadingTitle = "Exter Hub",
    LoadingSubtitle = "Initializing modules...",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigurationSaving = {
        Enabled = true,
        FileName = "ExterHub_" .. tostring(game.PlaceId),
    },
})

-- Welcome notification
Exter:Notify({
    Title = "Welcome!",
    Content = "Exter Hub loaded successfully.",
    Type = "Success",
    Duration = 5,
})

-- ═══════════════════════════════════════════════
-- MAIN TAB
-- ═══════════════════════════════════════════════

local MainTab = Window:CreateTab({ Name = "Main", Icon = "🏠" })

MainTab:CreateSection("Player")

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Suffix = "studs/s",
    Flag = "slider_ws",
    Callback = function(value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
    end,
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Suffix = "force",
    Flag = "slider_jp",
    Callback = function(value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "toggle_infjump",
    Callback = function(value)
        _G.InfJump = value
    end,
})

MainTab:CreateSection("Teleport")

MainTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end)
        Exter:Notify({
            Title = "Teleported",
            Content = "You have been teleported to spawn.",
            Type = "Info",
            Duration = 3,
        })
    end,
})

-- ═══════════════════════════════════════════════
-- VISUALS TAB
-- ═══════════════════════════════════════════════

local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "👁️" })

VisualsTab:CreateSection("ESP")

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "toggle_esp",
    Callback = function(value)
        print("ESP:", value)
    end,
})

VisualsTab:CreateDropdown({
    Name = "ESP Type",
    Options = {"Box", "Corner", "Highlight", "Chams"},
    CurrentOption = {"Box"},
    MultipleOptions = false,
    Flag = "dropdown_esptype",
    Callback = function(options)
        print("ESP Type:", options[1])
    end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "color_esp",
    Callback = function(color)
        print("ESP Color changed:", color)
    end,
})

-- ═══════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════

local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "⚙️" })

SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    Flag = "keybind_toggle",
    Callback = function()
        -- Handled internally
    end,
})

SettingsTab:CreateParagraph({
    Title = "About Exter Library",
    Content = "Exter Library v1 — A modern UI library for Roblox executors. Features smooth animations, multiple themes, and full configuration saving.",
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Exter:Destroy()
    end,
})
```

---

## ⚙️ Compatibility

| Executor | Status |
|----------|--------|
| Synapse X | ✅ Supported (`syn.protect_gui`) |
| Fluxus | ✅ Supported (`gethui`) |
| KRNL | ✅ Supported |
| Arceus X | ✅ Supported |
| Script-Ware | ✅ Supported |
| Hydrogen | ✅ Supported |
| Delta | ✅ Supported |
| Solara | ✅ Supported |
| Others | ✅ Falls back to `CoreGui` |

> The library automatically detects the best method to parent the ScreenGui based on available executor functions.

---

## 📁 File Structure

```
ExterLibrary          ← Main library file (single file, no dependencies)
README.md                 ← This documentation
```

**Runtime folders (created automatically):**
```
ExterLib/                 ← Created in executor's workspace
└── Configs/
    └── <FileName>.exter  ← JSON config files
```

---

## 🔧 Flags System

Flags provide a global reference to any element's state via `Exter.Flags`.

```lua
-- Access any flagged element
local espToggle = Exter.Flags["toggle_esp"]
print(espToggle.CurrentValue)  -- true/false

-- Modify from anywhere
Exter.Flags["slider_ws"]:Set(200)
Exter.Flags["toggle_esp"]:Set(true)
Exter.Flags["dropdown_esptype"]:Set({"Highlight"})
Exter.Flags["color_esp"]:Set(Color3.fromRGB(0, 255, 0))
```

---

## 📝 Changelog

### v1 (Current)
- Complete rewrite with modern design language
- 5 built-in themes with full color token system
- Smooth Quint/Spring easing animations
- Ripple effect on button clicks
- Notification system with action buttons and progress bar
- Color picker with HSV plane and hex input
- Multi-select dropdown support
- Configuration saving with JSON serialization
- Auto-cleanup of duplicate instances
- Touch input support for mobile executors
- Theme cycling button in topbar

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and distribute.

---

<p align="center">
  <strong>Built with ❤️ by Sobing4413</strong><br/>
  <sub>If you find this library useful, consider giving it a ⭐ on GitHub!</sub>
</p>
