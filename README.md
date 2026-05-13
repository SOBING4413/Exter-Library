# Exter Library

Modern UI library untuk Roblox scripting.

## 📦 Installation

```lua
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()
```

## 🚀 Quick Start

```lua
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()

local Window = Exter:CreateWindow({
    Name = "My Hub",
    Subtitle = "v1.0",
    Bind = Enum.KeyCode.K,
    ConfigSettings = {
        ConfigFolder = "MyHub",
        RootFolder = "ExterConfigs"
    }
})

local Tab = Window:CreateTab({ Name = "Main", Icon = "home" })
Tab:CreateButton({ Name = "Print Hello", Callback = function() print("Hello World!") end })
```

## 📚 API Ringkas

### Window
- `CreateWindow(settings)`
- `Destroy()`

### Tab Elements
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

### Notification
```lua
Exter:Notification({
    Title = "Welcome",
    Content = "Script loaded successfully!",
    Icon = "check_circle",
    ImageSource = "Material",
    Duration = 5
})
```

## 🎨 Theme

```lua
Exter.ThemeGradient = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(117, 164, 206)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(123, 201, 201)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(224, 138, 175))
}
```

## 💾 Config

```lua
Exter:SaveConfig("MyConfig")
Exter:LoadConfig("MyConfig")
Exter:LoadAutoloadConfig()
local list = Exter:RefreshConfigList()
```

## Runtime Dependency

Library ini memuat template UI lewat asset published berikut:

`rbxassetid://86467455075715`

Jika asset tidak tersedia/termoderasi, UI tidak dapat dibuat.

## Examples

- `examples/basic_example.lua`
- `examples/all_elements.lua`

## Executor Compatibility

Urutan fallback parent GUI:
1. `syn.protect_gui` + `CoreGui`
2. `gethui()`
3. `CoreGui`
