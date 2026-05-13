# Exter Library

Standalone Roblox UI library by SOBING.

## Load from GitHub

```lua
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()
```

## Basic Usage

```lua
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()

local Window = Exter:CreateWindow({
    Name = "My Script Hub",
    Subtitle = "Example",
    LoadingTitle = "Loading..."
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home"
})

MainTab:CreateButton({
    Name = "Print Hello",
    Callback = function()
        print("Hello!")
    end
})
```

## Executor Compatibility

The library now chooses GUI parent with fallback logic:

- `syn.protect_gui` + `CoreGui`
- `gethui()`
- `CoreGui`

## Notes

The current version still loads the template asset `rbxassetid://86467455075715` at runtime. Keep this asset available.
