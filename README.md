# Exter Library

Exter Library is loaded directly from GitHub with `loadstring` and uses a published Roblox UI asset at runtime.

## Installation

```lua
local ExterLibrary = loadstring(game:HttpService():GetAsync(
    "https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"
))()

local Window = ExterLibrary:CreateWindow({
    Name = "My Script",

    ConfigSettings = {
        ConfigFolder = "MyScript",
        RootFolder = "MyScriptConfigs"
    }
})

local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "home"
})

Tab:CreateButton({
    Name = "Test Button",

    Callback = function()
        print("Clicked!")
    end
})
```

## Runtime Dependency

This version uses `game:GetObjects("rbxassetid://86467455075715")` to load the full ScreenGui template.

- ✅ Public users can run with only `loadstring(...)`.
- ⚠️ The UI still depends on that published Roblox asset being available.

## Executor Compatibility

GUI parent fallback order:

1. `syn.protect_gui` + `CoreGui`
2. `gethui()`
3. `CoreGui`
