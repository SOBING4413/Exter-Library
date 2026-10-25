local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- ANTI-DUPLICATE: Destroy previous Exter instance if exists
----------------------------------------------------------------
pcall(function()
    if CoreGui:FindFirstChild("Exter") then
        CoreGui:FindFirstChild("Exter"):Destroy()
    end
end)

----------------------------------------------------------------
-- SAVED DEFAULTS
----------------------------------------------------------------
local Defaults = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FOV = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70,
    Atmosphere = nil,
}

local function SaveCurrentDefaults()
    Defaults.FogEnd = Lighting.FogEnd
    Defaults.FogStart = Lighting.FogStart
    Defaults.Brightness = Lighting.Brightness
    Defaults.OutdoorAmbient = Lighting.OutdoorAmbient
    Defaults.Ambient = Lighting.Ambient
    Defaults.ClockTime = Lighting.ClockTime
    Defaults.GlobalShadows = Lighting.GlobalShadows
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        Defaults.Atmosphere = {
            Density = atm.Density,
            Offset = atm.Offset,
            Color = atm.Color,
            Decay = atm.Decay,
            Glare = atm.Glare,
            Haze = atm.Haze
        }
    end
end

local existingAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if existingAtmosphere then
    Defaults.Atmosphere = {
        Density = existingAtmosphere.Density,
        Offset = existingAtmosphere.Offset,
        Color = existingAtmosphere.Color,
        Decay = existingAtmosphere.Decay,
        Glare = existingAtmosphere.Glare,
        Haze = existingAtmosphere.Haze
    }
end

----------------------------------------------------------------
-- CONFIGURATION
----------------------------------------------------------------
local Config = {
    ESP = {
        Enabled = true,
        Players = {
            ["Killer"] = {Color = Color3.fromRGB(220, 30, 30)},
            ["Survivor"] = {Color = Color3.fromRGB(80, 180, 255)}
        },
        Objects = {
            {Name = "Generator", Color = Color3.fromRGB(50, 220, 100), Tag = "⬡ Gen", Enabled = true},
            {Name = "Gate", Color = Color3.fromRGB(240, 200, 50), Tag = "🚪 Gate", Enabled = true},
            {Name = "Palletwrong", Color = Color3.fromRGB(100, 220, 140), Tag = "🪵 Pallet", Enabled = true},
            {Name = "Window", Color = Color3.fromRGB(100, 220, 140), Tag = "🪟 Window", Enabled = true},
            {Name = "Hook", Color = Color3.fromRGB(200, 80, 80), Tag = "🪝 Hook", Enabled = true},
            {Name = "Chest", Color = Color3.fromRGB(230, 170, 50), Tag = "📦 Chest", Enabled = true},
            {Name = "Totem", Color = Color3.fromRGB(200, 80, 180), Tag = "🏺 Totem", Enabled = true},
            {Name = "Hatch", Color = Color3.fromRGB(220, 220, 220), Tag = "⬜ Hatch", Enabled = true}
        },
        ShowDistance = true,
        ShowNames = true,
        RainbowMode = false
    },
    Survivor = {
        AutoSkillCheck = true,
        GreatOnly = false,
        AutoUnhook = false,
        AutoHeal = false,
        AutoRepair = false,
        FastVault = false,
        AutoVault = false,
        FastPallet = false,
        AutoWiggle = false,
        AutoStruggle = false,
        AutoSabotage = false,
        AntiGrab = false,
        NotifyGen = false,
        InfiniteStamina = false,
        AntiSlow = false
    },
    Killer = {
        OneHit = false,
        FastAttack = false,
        AutoAttack = false,
        ExtendedRange = false,
        ExtendedRangeValue = 15,
        FastBreakPallet = false,
        FastVaultKiller = false,
        AutoHook = false,
        ReduceCooldown = false,
        AntiPalletStun = false,
        AntiBlind = false
    },
    Movement = {
        NoClip = false,
        Walkspeed = 16,
        DefaultWalkspeed = 16,
        WalkspeedEnabled = false,
        JumpPower = 50,
        JumpPowerEnabled = false
    },
    Visuals = {
        FullBright = false,
        RemoveFog = false,
        CustomFOV = 70,
        NoShadows = false,
        ThirdPerson = false,
        ThirdPersonDistance = 10,
        NoCharacterEffects = false,
        AntiBlindVisual = true
    }
}

-- Connection storage for cleanup
local _connections = {}

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------
local function GetRole(p)
    if p.Team then
        local teamName = p.Team.Name:lower()
        if teamName:find("killer") or teamName:find("murderer") or teamName:find("hunter") or teamName:find("slasher") then
            return "Killer"
        end
    end
    return "Survivor"
end

local function GetMyRole()
    return GetRole(localPlayer)
end

----------------------------------------------------------------
-- APPLY VISUAL SETTINGS
----------------------------------------------------------------
local function ApplyActiveVisuals()
    if Config.Visuals.FullBright then
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 12
    end

    if Config.Visuals.RemoveFog then
        Lighting.FogEnd = 999999
        Lighting.FogStart = 999999
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            atm.Density = 0
            atm.Offset = 0
            atm.Haze = 0
            atm.Glare = 0
        end
    end

    if Config.Visuals.NoShadows then
        Lighting.GlobalShadows = false
    end

    if Config.Visuals.CustomFOV ~= 70 then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = Config.Visuals.CustomFOV end
    end
end

----------------------------------------------------------------
-- LOAD EXTER LIBRARY
----------------------------------------------------------------
local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()

----------------------------------------------------------------
-- CREATE WINDOW
----------------------------------------------------------------
local Window = Exter:CreateWindow({
    Name = "⬡ VIOLENCE DISTRICT v1.6.3",
    Subtitle = "by Exter Interactive"
})

----------------------------------------------------------------
-- TAB 1: ESP
----------------------------------------------------------------
local ESPTab = Window:CreateTab({ Name = "ESP", Icon = "visibility" })

ESPTab:CreateSection("Player ESP")

local ESPEnabledToggle = ESPTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = Config.ESP.Enabled,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        for _, obj in ipairs(workspace:GetDescendants()) do
            local h = obj:FindFirstChild("VDEsp")
            if h then h.Enabled = Value end
            local tag = obj:FindFirstChild("VDTag")
            if tag then tag.Enabled = Value end
        end
    end,
}, "ESPEnabled")

local ShowNamesToggle = ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = Config.ESP.ShowNames,
    Callback = function(Value)
        Config.ESP.ShowNames = Value
    end,
}, "ShowNames")

local ShowDistanceToggle = ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = Config.ESP.ShowDistance,
    Callback = function(Value)
        Config.ESP.ShowDistance = Value
    end,
}, "ShowDistance")

local RainbowToggle = ESPTab:CreateToggle({
    Name = "Rainbow Mode 🌈",
    CurrentValue = Config.ESP.RainbowMode,
    Callback = function(Value)
        Config.ESP.RainbowMode = Value
    end,
}, "RainbowMode")

-- Section: Object ESP
ESPTab:CreateSection("Object ESP")

local GeneratorsToggle = ESPTab:CreateToggle({
    Name = "Generators",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[1].Enabled = Value
    end,
}, "ESPGenerators")

local GatesToggle = ESPTab:CreateToggle({
    Name = "Gates",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[2].Enabled = Value
    end,
}, "ESPGates")

local PalletsWindowsToggle = ESPTab:CreateToggle({
    Name = "Pallets & Windows",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[3].Enabled = Value
        Config.ESP.Objects[4].Enabled = Value
    end,
}, "ESPPalletsWindows")

local HooksToggle = ESPTab:CreateToggle({
    Name = "Hooks",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[5].Enabled = Value
    end,
}, "ESPHooks")

local ChestsToggle = ESPTab:CreateToggle({
    Name = "Chests",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[6].Enabled = Value
    end,
}, "ESPChests")

local TotemsToggle = ESPTab:CreateToggle({
    Name = "Totems",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[7].Enabled = Value
    end,
}, "ESPTotems")

local HatchToggle = ESPTab:CreateToggle({
    Name = "Hatch",
    CurrentValue = true,
    Callback = function(Value)
        Config.ESP.Objects[8].Enabled = Value
    end,
}, "ESPHatch")

----------------------------------------------------------------
-- TAB 2: SURVIVOR
----------------------------------------------------------------
local SurvivorTab = Window:CreateTab({ Name = "Survivor", Icon = "favorite" })

-- Section: Skill Checks
SurvivorTab:CreateSection("⚡ Skill Checks")

local AutoSkillCheckToggle = SurvivorTab:CreateToggle({
    Name = "Auto Skill Check",
    CurrentValue = Config.Survivor.AutoSkillCheck,
    Callback = function(Value)
        Config.Survivor.AutoSkillCheck = Value
    end,
}, "AutoSkillCheck")

local GreatOnlyToggle = SurvivorTab:CreateToggle({
    Name = "Great Skill Check Only",
    CurrentValue = Config.Survivor.GreatOnly,
    Callback = function(Value)
        Config.Survivor.GreatOnly = Value
    end,
}, "GreatOnly")

-- Section: Vault & Pallet
SurvivorTab:CreateSection("🪟 Vault & Pallet")

local FastVaultToggle = SurvivorTab:CreateToggle({
    Name = "Fast Vault",
    CurrentValue = Config.Survivor.FastVault,
    Callback = function(Value)
        Config.Survivor.FastVault = Value
        if not Value then
            pcall(function()
                local char = localPlayer.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                            if anim.Name:lower():find("vault") or anim.Name:lower():find("climb") or anim.Name:lower():find("window") then
                                anim:AdjustSpeed(1)
                            end
                        end
                    end
                end
            end)
        end
    end,
}, "FastVault")

local FastPalletToggle = SurvivorTab:CreateToggle({
    Name = "Fast Pallet Drop",
    CurrentValue = Config.Survivor.FastPallet,
    Callback = function(Value)
        Config.Survivor.FastPallet = Value
    end,
}, "FastPallet")

local AutoVaultToggle = SurvivorTab:CreateToggle({
    Name = "Auto Vault (Near Window)",
    CurrentValue = Config.Survivor.AutoVault,
    Callback = function(Value)
        Config.Survivor.AutoVault = Value
    end,
}, "AutoVault")

-- Section: Automation
SurvivorTab:CreateSection("🔧 Automation")

local AutoRepairToggle = SurvivorTab:CreateToggle({
    Name = "Auto Repair Generator",
    CurrentValue = Config.Survivor.AutoRepair,
    Callback = function(Value)
        Config.Survivor.AutoRepair = Value
    end,
}, "AutoRepair")

local AutoHealToggle = SurvivorTab:CreateToggle({
    Name = "Auto Heal (Near Teammate)",
    CurrentValue = Config.Survivor.AutoHeal,
    Callback = function(Value)
        Config.Survivor.AutoHeal = Value
    end,
}, "AutoHeal")

local AutoUnhookToggle = SurvivorTab:CreateToggle({
    Name = "Auto Unhook",
    CurrentValue = Config.Survivor.AutoUnhook,
    Callback = function(Value)
        Config.Survivor.AutoUnhook = Value
    end,
}, "AutoUnhook")

local AutoSabotageToggle = SurvivorTab:CreateToggle({
    Name = "Auto Sabotage Hook",
    CurrentValue = Config.Survivor.AutoSabotage,
    Callback = function(Value)
        Config.Survivor.AutoSabotage = Value
    end,
}, "AutoSabotage")

-- Section: When Caught
SurvivorTab:CreateSection("🆘 When Caught")

local AutoWiggleToggle = SurvivorTab:CreateToggle({
    Name = "Auto Wiggle (When Carried)",
    CurrentValue = Config.Survivor.AutoWiggle,
    Callback = function(Value)
        Config.Survivor.AutoWiggle = Value
    end,
}, "AutoWiggle")

local AutoStruggleToggle = SurvivorTab:CreateToggle({
    Name = "Auto Struggle (On Hook)",
    CurrentValue = Config.Survivor.AutoStruggle,
    Callback = function(Value)
        Config.Survivor.AutoStruggle = Value
    end,
}, "AutoStruggle")

-- Section: Defense
SurvivorTab:CreateSection("🛡️ Defense & Awareness")

local AntiGrabToggle = SurvivorTab:CreateToggle({
    Name = "Anti Grab (Notif Killer Dekat)",
    CurrentValue = Config.Survivor.AntiGrab,
    Callback = function(Value)
        Config.Survivor.AntiGrab = Value
    end,
}, "AntiGrab")

local AntiSlowToggle = SurvivorTab:CreateToggle({
    Name = "Anti Slow (Remove Slow Effects)",
    CurrentValue = Config.Survivor.AntiSlow,
    Callback = function(Value)
        Config.Survivor.AntiSlow = Value
    end,
}, "AntiSlow")

local InfiniteStaminaToggle = SurvivorTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = Config.Survivor.InfiniteStamina,
    Callback = function(Value)
        Config.Survivor.InfiniteStamina = Value
    end,
}, "InfiniteStamina")

local NotifyGenToggle = SurvivorTab:CreateToggle({
    Name = "Notify Gen Complete",
    CurrentValue = Config.Survivor.NotifyGen,
    Callback = function(Value)
        Config.Survivor.NotifyGen = Value
    end,
}, "NotifyGen")

local ForceUnhookButton = SurvivorTab:CreateButton({
    Name = "🔄 Force Unhook (Dekat Hooked Survivor)",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("Hook") then
                local hookPart = obj:FindFirstChild("HookPart") or obj:FindFirstChildWhichIsA("BasePart")
                if hookPart and (hookPart.Position - root.Position).Magnitude < 15 then
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(child, 1) end)
                        end
                    end
                    break
                end
            end
        end
    end,
})

----------------------------------------------------------------
-- TAB 3: KILLER
----------------------------------------------------------------
local KillerTab = Window:CreateTab({ Name = "Killer", Icon = "dangerous" })

-- Section: Attack
KillerTab:CreateSection("⚔️ Attack")

local OneHitToggle = KillerTab:CreateToggle({
    Name = "One Hit Down",
    CurrentValue = Config.Killer.OneHit,
    Callback = function(Value)
        Config.Killer.OneHit = Value
    end,
}, "OneHit")

local FastAttackToggle = KillerTab:CreateToggle({
    Name = "Fast Attack (Speed Up Animation)",
    CurrentValue = Config.Killer.FastAttack,
    Callback = function(Value)
        Config.Killer.FastAttack = Value
    end,
}, "FastAttack")

local AutoAttackToggle = KillerTab:CreateToggle({
    Name = "Auto Attack (Near Survivor)",
    CurrentValue = Config.Killer.AutoAttack,
    Callback = function(Value)
        Config.Killer.AutoAttack = Value
    end,
}, "AutoAttack")

local ExtendedRangeToggle = KillerTab:CreateToggle({
    Name = "Extended Attack Range",
    CurrentValue = Config.Killer.ExtendedRange,
    Callback = function(Value)
        Config.Killer.ExtendedRange = Value
    end,
}, "ExtendedRange")

local ExtendedRangeSlider = KillerTab:CreateSlider({
    Name = "Attack Range Value",
    Range = {10, 30},
    Increment = 1,
    CurrentValue = Config.Killer.ExtendedRangeValue,
    Callback = function(Value)
        Config.Killer.ExtendedRangeValue = Value
    end,
}, "ExtendedRangeVal")

-- Section: Killer Vault & Pallet
KillerTab:CreateSection("🪟 Vault & Pallet")

local FastVaultKillerToggle = KillerTab:CreateToggle({
    Name = "Fast Vault (Killer)",
    CurrentValue = Config.Killer.FastVaultKiller,
    Callback = function(Value)
        Config.Killer.FastVaultKiller = Value
    end,
}, "FastVaultKiller")

local FastBreakPalletToggle = KillerTab:CreateToggle({
    Name = "Fast Break Pallet",
    CurrentValue = Config.Killer.FastBreakPallet,
    Callback = function(Value)
        Config.Killer.FastBreakPallet = Value
    end,
}, "FastBreakPallet")

-- Section: Killer Defense
KillerTab:CreateSection("🛡️ Killer Defense")

local ReduceCooldownToggle = KillerTab:CreateToggle({
    Name = "Reduce Attack Cooldown",
    CurrentValue = Config.Killer.ReduceCooldown,
    Callback = function(Value)
        Config.Killer.ReduceCooldown = Value
    end,
}, "ReduceCooldown")

local AntiPalletStunToggle = KillerTab:CreateToggle({
    Name = "Anti Pallet Stun",
    CurrentValue = Config.Killer.AntiPalletStun,
    Callback = function(Value)
        Config.Killer.AntiPalletStun = Value
    end,
}, "AntiPalletStun")

local AntiBlindKillerToggle = KillerTab:CreateToggle({
    Name = "Anti Blind (Flashlight)",
    CurrentValue = Config.Killer.AntiBlind,
    Callback = function(Value)
        Config.Killer.AntiBlind = Value
    end,
}, "AntiBlindKiller")

-- Section: Killer Automation
KillerTab:CreateSection("🤖 Automation")

local AutoHookToggle = KillerTab:CreateToggle({
    Name = "Auto Hook (Carry to Nearest Hook)",
    CurrentValue = Config.Killer.AutoHook,
    Callback = function(Value)
        Config.Killer.AutoHook = Value
    end,
}, "AutoHook")

KillerTab:CreateParagraph({
    Title = "⚠️ Peringatan",
    Text = "Fitur Killer hanya aktif saat kamu bermain sebagai Killer.\nGunakan dengan bijak untuk menghindari report."
})

----------------------------------------------------------------
-- TAB 4: MOVEMENT
----------------------------------------------------------------
local MoveTab = Window:CreateTab({ Name = "Movement", Icon = "directions_run" })

MoveTab:CreateSection("🏃 Speed")

local WalkSpeedEnabledToggle = MoveTab:CreateToggle({
    Name = "Enable Custom WalkSpeed",
    CurrentValue = Config.Movement.WalkspeedEnabled,
    Callback = function(Value)
        Config.Movement.WalkspeedEnabled = Value
        if not Value then
            local char = localPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = Config.Movement.DefaultWalkspeed
                end
            end
        end
    end,
}, "WalkSpeedEnabled")

local WalkSpeedSlider = MoveTab:CreateSlider({
    Name = "Walk Speed Value",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = Config.Movement.Walkspeed,
    Callback = function(Value)
        Config.Movement.Walkspeed = Value
    end,
}, "WalkSpeed")

MoveTab:CreateSection("🦘 Jump")

local JumpPowerEnabledToggle = MoveTab:CreateToggle({
    Name = "Enable Custom Jump Power",
    CurrentValue = Config.Movement.JumpPowerEnabled,
    Callback = function(Value)
        Config.Movement.JumpPowerEnabled = Value
        if not Value then
            local char = localPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = 50
                    humanoid.UseJumpPower = true
                end
            end
        end
    end,
}, "JumpPowerEnabled")

local JumpPowerSlider = MoveTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 150},
    Increment = 5,
    CurrentValue = Config.Movement.JumpPower,
    Callback = function(Value)
        Config.Movement.JumpPower = Value
    end,
}, "JumpPower")

MoveTab:CreateSection("👻 Clip")

local NoClipToggle = MoveTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = Config.Movement.NoClip,
    Callback = function(Value)
        Config.Movement.NoClip = Value
        if not Value then
            local char = localPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
}, "NoClip")

----------------------------------------------------------------
-- TAB 5: VISUALS
----------------------------------------------------------------
local VisualTab = Window:CreateTab({ Name = "Visuals", Icon = "wb_sunny" })

VisualTab:CreateSection("🌍 World")

local FullBrightToggle = VisualTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = Config.Visuals.FullBright,
    Callback = function(Value)
        Config.Visuals.FullBright = Value
        if Value then
            Lighting.Brightness = 3
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ClockTime = 12
        else
            Lighting.Brightness = Defaults.Brightness
            Lighting.OutdoorAmbient = Defaults.OutdoorAmbient
            Lighting.Ambient = Defaults.Ambient
            Lighting.ClockTime = Defaults.ClockTime
        end
    end,
}, "FullBright")

local RemoveFogToggle = VisualTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = Config.Visuals.RemoveFog,
    Callback = function(Value)
        Config.Visuals.RemoveFog = Value
        if Value then
            Lighting.FogEnd = 999999
            Lighting.FogStart = 999999
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then
                atm.Density = 0
                atm.Offset = 0
                atm.Haze = 0
                atm.Glare = 0
            end
        else
            Lighting.FogEnd = Defaults.FogEnd
            Lighting.FogStart = Defaults.FogStart
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm and Defaults.Atmosphere then
                atm.Density = Defaults.Atmosphere.Density
                atm.Offset = Defaults.Atmosphere.Offset
                atm.Haze = Defaults.Atmosphere.Haze
                atm.Glare = Defaults.Atmosphere.Glare
            end
        end
    end,
}, "RemoveFog")

local NoShadowsToggle = VisualTab:CreateToggle({
    Name = "No Shadows",
    CurrentValue = Config.Visuals.NoShadows,
    Callback = function(Value)
        Config.Visuals.NoShadows = Value
        Lighting.GlobalShadows = not Value and Defaults.GlobalShadows or false
    end,
}, "NoShadows")

local FOVSlider = VisualTab:CreateSlider({
    Name = "Field of View",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = Config.Visuals.CustomFOV,
    Callback = function(Value)
        Config.Visuals.CustomFOV = Value
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = Value end
    end,
}, "CustomFOV")

-- Camera Section
VisualTab:CreateSection("📷 Camera")

local ThirdPersonToggle = VisualTab:CreateToggle({
    Name = "Third Person Lock",
    CurrentValue = Config.Visuals.ThirdPerson,
    Callback = function(Value)
        Config.Visuals.ThirdPerson = Value
        if Value then
            localPlayer.CameraMaxZoomDistance = Config.Visuals.ThirdPersonDistance
            localPlayer.CameraMinZoomDistance = Config.Visuals.ThirdPersonDistance
        else
            localPlayer.CameraMaxZoomDistance = 128
            localPlayer.CameraMinZoomDistance = 0.5
        end
    end,
}, "ThirdPerson")

local ThirdPersonSlider = VisualTab:CreateSlider({
    Name = "Third Person Distance",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = Config.Visuals.ThirdPersonDistance,
    Callback = function(Value)
        Config.Visuals.ThirdPersonDistance = Value
        if Config.Visuals.ThirdPerson then
            localPlayer.CameraMaxZoomDistance = Value
            localPlayer.CameraMinZoomDistance = Value
        end
    end,
}, "ThirdPersonDist")

-- Anti Effects Section
VisualTab:CreateSection("🚫 Anti Effects")

local AntiBlindToggle = VisualTab:CreateToggle({
    Name = "Anti Blind",
    CurrentValue = Config.Visuals.AntiBlindVisual,
    Callback = function(Value)
        Config.Visuals.AntiBlindVisual = Value
    end,
}, "AntiBlind")

local NoCharEffectsToggle = VisualTab:CreateToggle({
    Name = "No Character Effects (Particles)",
    CurrentValue = Config.Visuals.NoCharacterEffects,
    Callback = function(Value)
        Config.Visuals.NoCharacterEffects = Value
    end,
}, "NoCharEffects")

-- Keybinds Section
VisualTab:CreateSection("⌨️ Keybinds")

VisualTab:CreateLabel({ Text = "V = Toggle ESP On/Off" })
VisualTab:CreateLabel({ Text = "G = Toggle Fast Vault" })
VisualTab:CreateLabel({ Text = "INSERT / RightShift = Toggle GUI" })
VisualTab:CreateLabel({ Text = "F = Reset FOV to Default" })

local ResetVisualsButton = VisualTab:CreateButton({
    Name = "🔄 Reset All Visuals",
    Callback = function()
        Config.Visuals.FullBright = false
        Config.Visuals.RemoveFog = false
        Config.Visuals.NoShadows = false
        Config.Visuals.CustomFOV = Defaults.FOV
        Config.Visuals.ThirdPerson = false

        Lighting.Brightness = Defaults.Brightness
        Lighting.OutdoorAmbient = Defaults.OutdoorAmbient
        Lighting.Ambient = Defaults.Ambient
        Lighting.ClockTime = Defaults.ClockTime
        Lighting.FogEnd = Defaults.FogEnd
        Lighting.FogStart = Defaults.FogStart
        Lighting.GlobalShadows = Defaults.GlobalShadows

        localPlayer.CameraMaxZoomDistance = 128
        localPlayer.CameraMinZoomDistance = 0.5

        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm and Defaults.Atmosphere then
            atm.Density = Defaults.Atmosphere.Density
            atm.Offset = Defaults.Atmosphere.Offset
            atm.Haze = Defaults.Atmosphere.Haze
            atm.Glare = Defaults.Atmosphere.Glare
        end

        local cam = workspace.CurrentCamera
        if cam then
            cam.FieldOfView = Defaults.FOV
        end

        pcall(function()
            FullBrightToggle:Set(false)
            RemoveFogToggle:Set(false)
            NoShadowsToggle:Set(false)
            FOVSlider:Set(Defaults.FOV)
            ThirdPersonToggle:Set(false)
        end)

        Exter:Notification({
            Title = "Visuals Reset",
            Content = "Semua visual dikembalikan ke default.",
            Duration = 3,
            Icon = "refresh",
            ImageSource = "Material",
        })
    end,
})

----------------------------------------------------------------
-- TAB 6: TELEPORT
----------------------------------------------------------------
local TeleportTab = Window:CreateTab({ Name = "Teleport", Icon = "place" })

TeleportTab:CreateSection("📍 Quick Teleport")

local TPGenButton = TeleportTab:CreateButton({
    Name = "TP ke Generator Terdekat",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local closest, closestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Generator" and obj:IsA("Model") then
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (primary.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closest = primary
                        closestDist = dist
                    end
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
            Exter:Notification({Title = "Teleported", Content = "TP ke Generator (" .. math.floor(closestDist) .. "m)", Duration = 2.5, Icon = "check_circle", ImageSource = "Material"})
        else
            Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada generator.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
        end
    end,
})

local TPGateButton = TeleportTab:CreateButton({
    Name = "TP ke Gate Terdekat",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local closest, closestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Gate" and obj:IsA("Model") then
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (primary.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closest = primary
                        closestDist = dist
                    end
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
            Exter:Notification({Title = "Teleported", Content = "TP ke Gate (" .. math.floor(closestDist) .. "m)", Duration = 2.5, Icon = "check_circle", ImageSource = "Material"})
        else
            Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada gate.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
        end
    end,
})

local TPHatchButton = TeleportTab:CreateButton({
    Name = "TP ke Hatch",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Hatch" then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    Exter:Notification({Title = "Teleported", Content = "TP ke Hatch.", Duration = 2.5, Icon = "check_circle", ImageSource = "Material"})
                    return
                end
            end
        end
        Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada hatch.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
    end,
})

local TPChestButton = TeleportTab:CreateButton({
    Name = "TP ke Chest Terdekat",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local closest, closestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Chest" then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (part.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closest = part
                        closestDist = dist
                    end
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
            Exter:Notification({Title = "Teleported", Content = "TP ke Chest (" .. math.floor(closestDist) .. "m)", Duration = 2.5, Icon = "check_circle", ImageSource = "Material"})
        else
            Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada chest.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
        end
    end,
})

local TPTotemButton = TeleportTab:CreateButton({
    Name = "TP ke Totem Terdekat",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local closest, closestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Totem" then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (part.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closest = part
                        closestDist = dist
                    end
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
            Exter:Notification({Title = "Teleported", Content = "TP ke Totem (" .. math.floor(closestDist) .. "m)", Duration = 2.5, Icon = "check_circle", ImageSource = "Material"})
        else
            Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada totem.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
        end
    end,
})

-- Player Teleport
TeleportTab:CreateSection("👤 Player Teleport")

local TPSurvivorButton = TeleportTab:CreateButton({
    Name = "TP ke Random Survivor",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local survivors = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character then
                local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if pRoot and GetRole(p) == "Survivor" then
                    table.insert(survivors, {root = pRoot, name = p.Name})
                end
            end
        end
        if #survivors > 0 then
            local target = survivors[math.random(1, #survivors)]
            root.CFrame = target.root.CFrame + Vector3.new(3, 0, 0)
            Exter:Notification({Title = "Teleported", Content = "TP ke: " .. target.name, Duration = 2.5, Icon = "check_circle", ImageSource = "Material"})
        else
            Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada survivor.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
        end
    end,
})

local TPKillerButton = TeleportTab:CreateButton({
    Name = "⚠️ TP ke Killer (Beresiko!)",
    Callback = function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and GetRole(p) == "Killer" then
                local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if pRoot then
                    root.CFrame = pRoot.CFrame + Vector3.new(5, 0, 5)
                    Exter:Notification({Title = "⚠️ TP ke Killer", Content = "Dekat " .. p.Name .. " - Hati-hati!", Duration = 3, Icon = "warning", ImageSource = "Material"})
                    return
                end
            end
        end
        Exter:Notification({Title = "Tidak Ditemukan", Content = "Tidak ada killer.", Duration = 2.5, Icon = "error", ImageSource = "Material"})
    end,
})

----------------------------------------------------------------
-- TAB 7: INFO
----------------------------------------------------------------
local InfoTab = Window:CreateTab({ Name = "Info", Icon = "info" })

InfoTab:CreateSection("Session")

InfoTab:CreateLabel({ Text = "Script: Violence District v1.6.3" })
InfoTab:CreateLabel({ Text = "Creator: Exter Interactive" })
InfoTab:CreateLabel({ Text = "Status: ✓ One Hit + Separated Tabs" })
InfoTab:CreateLabel({ Text = "Role: " .. GetMyRole() })
InfoTab:CreateLabel({ Text = "Platform: " .. tostring(pcall(function() return identifyexecutor() end) and identifyexecutor() or "Universal") })

InfoTab:CreateSection("Changelog v1.6.3")

InfoTab:CreateParagraph({
    Title = "What's New in v1.6.3",
    Text = "✓ Tab Survivor & Killer DIPISAH (rapih!)\n✓ One Hit Down (Killer)\n✓ Fast Attack (Killer)\n✓ Auto Attack Near Survivor (Killer)\n✓ Extended Attack Range (Killer)\n✓ Fast Break Pallet (Killer)\n✓ Anti Pallet Stun (Killer)\n✓ Reduce Attack Cooldown (Killer)\n✓ Auto Hook (Killer)\n✓ Fast Vault (Survivor + Killer)\n✓ Fast Pallet Drop (Survivor)\n✓ Auto Vault (Survivor)\n✓ Auto Wiggle & Struggle\n✓ Anti Slow\n✓ Auto Sabotage Hook\n✓ Third Person Camera\n✓ Custom Jump Power\n✓ Notify Gen Complete\n✓ Movement Tab terpisah\n✓ Keybind G = Fast Vault"
})

InfoTab:CreateParagraph({
    Title = "Tab Structure",
    Text = "ESP → Semua ESP & highlight\nSurvivor → Fitur khusus survivor\nKiller → Fitur khusus killer\nMovement → Speed, Jump, NoClip\nVisuals → Lighting, FOV, Camera\nTeleport → TP ke objek & player\nInfo → Changelog & session info"
})

----------------------------------------------------------------
-- KEYBINDS
----------------------------------------------------------------
local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.V then
            Config.ESP.Enabled = not Config.ESP.Enabled
            for _, obj in ipairs(workspace:GetDescendants()) do
                local h = obj:FindFirstChild("VDEsp")
                if h then h.Enabled = Config.ESP.Enabled end
                local tag = obj:FindFirstChild("VDTag")
                if tag then tag.Enabled = Config.ESP.Enabled end
            end
            pcall(function() ESPEnabledToggle:Set(Config.ESP.Enabled) end)
        elseif input.KeyCode == Enum.KeyCode.F then
            Config.Visuals.CustomFOV = Defaults.FOV
            local cam = workspace.CurrentCamera
            if cam then cam.FieldOfView = Defaults.FOV end
            pcall(function() FOVSlider:Set(Defaults.FOV) end)
        elseif input.KeyCode == Enum.KeyCode.G then
            -- Toggle Fast Vault based on role
            if GetMyRole() == "Killer" then
                Config.Killer.FastVaultKiller = not Config.Killer.FastVaultKiller
                pcall(function() FastVaultKillerToggle:Set(Config.Killer.FastVaultKiller) end)
                Exter:Notification({
                    Title = "Fast Vault (Killer)",
                    Content = Config.Killer.FastVaultKiller and "✓ ENABLED" or "✗ DISABLED",
                    Duration = 2,
                    Icon = "flash_on",
                    ImageSource = "Material",
                })
            else
                Config.Survivor.FastVault = not Config.Survivor.FastVault
                pcall(function() FastVaultToggle:Set(Config.Survivor.FastVault) end)
                Exter:Notification({
                    Title = "Fast Vault (Survivor)",
                    Content = Config.Survivor.FastVault and "✓ ENABLED" or "✗ DISABLED",
                    Duration = 2,
                    Icon = "flash_on",
                    ImageSource = "Material",
                })
            end
        end
    end)
end

----------------------------------------------------------------
-- ESP SYSTEM
----------------------------------------------------------------
local espCache = {}

local function ApplyHighlight(obj, color, nameTag, isKiller)
    if not obj or obj == localPlayer.Character then return end
    if espCache[obj] then return end

    local h = Instance.new("Highlight")
    h.Name = "VDEsp"
    h.Adornee = obj
    h.FillColor = color
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Enabled = Config.ESP.Enabled

    if isKiller then
        h.FillTransparency = 0.55
        h.OutlineTransparency = 0.1
        h.OutlineColor = Color3.fromRGB(255, 80, 80)
    elseif isKiller == false then
        h.FillTransparency = 0.8
        h.OutlineTransparency = 0.3
        h.OutlineColor = Color3.fromRGB(150, 210, 255)
    else
        h.FillTransparency = 0.75
        h.OutlineTransparency = 0.25
        h.OutlineColor = Color3.new(1, 1, 1)
    end

    h.Parent = obj

    if nameTag then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VDTag"
        billboard.Adornee = obj
        billboard.Size = UDim2.new(0, 160, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = Config.ESP.Enabled

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = nameTag
        textLabel.TextStrokeTransparency = 0.2
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 11

        if isKiller then
            textLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            textLabel.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
        elseif isKiller == false then
            textLabel.TextColor3 = Color3.fromRGB(160, 220, 255)
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 30, 60)
        else
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        end

        textLabel.Parent = billboard
        billboard.Parent = obj
    end

    espCache[obj] = true
end

local function RemoveHighlight(obj)
    if not espCache[obj] then return end
    local h = obj:FindFirstChild("VDEsp")
    if h then h:Destroy() end
    local tag = obj:FindFirstChild("VDTag")
    if tag then tag:Destroy() end
    espCache[obj] = nil
end

local function RefreshPlayerESP(p)
    if p == localPlayer then return end
    if not p.Character then return end
    RemoveHighlight(p.Character)
    local role = GetRole(p)
    local isKiller = (role == "Killer")
    ApplyHighlight(
        p.Character,
        Config.ESP.Players[role].Color,
        "[" .. role .. "] " .. p.Name,
        isKiller
    )
end

local function SetupPlayerESP(p)
    if p == localPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(1.5)
        espCache[char] = nil
        local role = GetRole(p)
        local isKiller = (role == "Killer")
        ApplyHighlight(
            char,
            Config.ESP.Players[role].Color,
            "[" .. role .. "] " .. p.Name,
            isKiller
        )
    end)
    if p.Character then
        local role = GetRole(p)
        local isKiller = (role == "Killer")
        ApplyHighlight(
            p.Character,
            Config.ESP.Players[role].Color,
            "[" .. role .. "] " .. p.Name,
            isKiller
        )
    end
end

local objectNameLookup = {}
for _, data in ipairs(Config.ESP.Objects) do
    objectNameLookup[data.Name] = data
end

local function SetupObjectESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local data = objectNameLookup[obj.Name]
        if data and data.Enabled and (obj:IsA("Model") or obj:IsA("BasePart")) then
            ApplyHighlight(obj, data.Color, data.Tag, nil)
        end
    end

    workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            local data = objectNameLookup[obj.Name]
            if data and data.Enabled and (obj:IsA("Model") or obj:IsA("BasePart")) then
                ApplyHighlight(obj, data.Color, data.Tag, nil)
            end
        end)
    end)

    workspace.DescendantRemoving:Connect(function(obj)
        if espCache[obj] then
            espCache[obj] = nil
        end
    end)
end

----------------------------------------------------------------
-- CORE LOOP: Movement + Fast Vault + Killer Features
----------------------------------------------------------------
local function StartCoreLoop()
    local steppedConn = RunService.Stepped:Connect(function(_, dt)
        local char = localPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local myRole = GetMyRole()

        -- WALKSPEED
        if Config.Movement.WalkspeedEnabled then
            humanoid.WalkSpeed = Config.Movement.Walkspeed
            if root and humanoid.MoveDirection.Magnitude > 0 then
                local boost = (Config.Movement.Walkspeed - Config.Movement.DefaultWalkspeed) * dt
                if boost > 0 then
                    root.CFrame = root.CFrame + (humanoid.MoveDirection * boost * 0.5)
                end
            end
        end

        -- JUMP POWER
        if Config.Movement.JumpPowerEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Config.Movement.JumpPower
        end

        -- NOCLIP
        if Config.Movement.NoClip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        -- ============ SURVIVOR FEATURES ============
        if myRole == "Survivor" then
            -- Fast Vault (Survivor)
            if Config.Survivor.FastVault then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("vault") or animName:find("climb") or animName:find("window") or animName:find("hurdle") then
                        if anim.Speed < 2.5 then
                            anim:AdjustSpeed(3)
                        end
                    end
                end
            end

            -- Fast Pallet (Survivor)
            if Config.Survivor.FastPallet then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("pallet") or animName:find("drop") or animName:find("throw") then
                        if anim.Speed < 2.5 then
                            anim:AdjustSpeed(3)
                        end
                    end
                end
            end

            -- Anti Slow (Survivor)
            if Config.Survivor.AntiSlow then
                pcall(function()
                    for _, child in ipairs(char:GetDescendants()) do
                        if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                            local n = child.Name:lower()
                            if n:find("slow") or n:find("hinder") or n:find("exhaust") then
                                child.Value = 0
                            end
                        end
                    end
                    for _, attrName in ipairs({"Slowed", "Hindered", "Exhausted", "SlowMultiplier"}) do
                        if char:GetAttribute(attrName) ~= nil then
                            pcall(function() char:SetAttribute(attrName, nil) end)
                        end
                    end
                end)
            end
        end

        -- ============ KILLER FEATURES ============
        if myRole == "Killer" then
            -- Fast Vault (Killer)
            if Config.Killer.FastVaultKiller then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("vault") or animName:find("climb") or animName:find("window") then
                        if anim.Speed < 2.5 then
                            anim:AdjustSpeed(2.8)
                        end
                    end
                end
            end

            -- Fast Break Pallet (Killer)
            if Config.Killer.FastBreakPallet then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("break") or animName:find("pallet") or animName:find("destroy") then
                        if anim.Speed < 2.5 then
                            anim:AdjustSpeed(3)
                        end
                    end
                end
            end

            -- Fast Attack (Killer) - speed up attack animation
            if Config.Killer.FastAttack then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("attack") or animName:find("slash") or animName:find("swing") or animName:find("hit") or animName:find("lunge") then
                        if anim.Speed < 2 then
                            anim:AdjustSpeed(2.5)
                        end
                    end
                end
            end

            -- Reduce Attack Cooldown (Killer) - speed up cooldown/wipe animations
            if Config.Killer.ReduceCooldown then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("cooldown") or animName:find("wipe") or animName:find("clean") or animName:find("recover") then
                        if anim.Speed < 2.5 then
                            anim:AdjustSpeed(4)
                        end
                    end
                end
            end

            -- Anti Pallet Stun (Killer) - speed up stun animation
            if Config.Killer.AntiPalletStun then
                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = anim.Name:lower()
                    if animName:find("stun") or animName:find("stunned") or animName:find("daze") then
                        if anim.Speed < 3 then
                            anim:AdjustSpeed(5)
                        end
                    end
                end
            end
        end
    end)
    table.insert(_connections, steppedConn)
end

----------------------------------------------------------------
-- BACKGROUND LOOPS
----------------------------------------------------------------
local function StartBackgroundLoops()
    -- Rainbow ESP
    local rainbowConn = RunService.RenderStepped:Connect(function()
        if not Config.ESP.RainbowMode or not Config.ESP.Enabled then return end
        local hue = tick() % 5 / 5
        local rainbow = Color3.fromHSV(hue, 1, 1)
        for obj, _ in pairs(espCache) do
            if obj and obj.Parent then
                local h = obj:FindFirstChild("VDEsp")
                if h and h:IsA("Highlight") then
                    h.FillColor = rainbow
                end
            end
        end
    end)
    table.insert(_connections, rainbowConn)

    -- VISUAL ENFORCER
    task.spawn(function()
        while task.wait(2) do
            ApplyActiveVisuals()
        end
    end)

    -- ESP ROLE REFRESH
    task.spawn(function()
        while task.wait(5) do
            if not Config.ESP.Enabled then continue end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character then
                    local role = GetRole(p)
                    local expectedColor = Config.ESP.Players[role].Color
                    local h = p.Character:FindFirstChild("VDEsp")
                    if h and h:IsA("Highlight") then
                        if h.FillColor ~= expectedColor and not Config.ESP.RainbowMode then
                            RefreshPlayerESP(p)
                        end
                    else
                        espCache[p.Character] = nil
                        RefreshPlayerESP(p)
                    end
                end
            end
        end
    end)

    ----------------------------------------------------------------
    -- KILLER: One Hit Down
    ----------------------------------------------------------------
    task.spawn(function()
        while task.wait(0.3) do
            if not Config.Killer.OneHit then continue end
            if GetMyRole() ~= "Killer" then continue end

            pcall(function()
                local char = localPlayer.Character
                if not char then return end

                -- Method 1: Modify damage values in character
                for _, child in ipairs(char:GetDescendants()) do
                    if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                        local n = child.Name:lower()
                        if n:find("damage") or n:find("dmg") or n:find("attack") or n:find("power") then
                            if child.Value < 999 then
                                child.Value = 999
                            end
                        end
                    end
                end

                -- Method 2: Set attributes
                for _, attrName in ipairs({"Damage", "AttackDamage", "HitDamage", "BaseDamage", "KillerDamage"}) do
                    if char:GetAttribute(attrName) ~= nil then
                        char:SetAttribute(attrName, 999)
                    end
                end

                -- Method 3: Check tools for damage values
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, child in ipairs(tool:GetDescendants()) do
                            if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                                local n = child.Name:lower()
                                if n:find("damage") or n:find("dmg") then
                                    if child.Value < 999 then
                                        child.Value = 999
                                    end
                                end
                            end
                        end
                        -- Tool attributes
                        for _, attrName in ipairs({"Damage", "AttackDamage", "HitDamage"}) do
                            if tool:GetAttribute(attrName) ~= nil then
                                tool:SetAttribute(attrName, 999)
                            end
                        end
                    end
                end
            end)
        end
    end)

    ----------------------------------------------------------------
    -- KILLER: Auto Attack (Near Survivor)
    ----------------------------------------------------------------
    task.spawn(function()
        while task.wait(0.8) do
            if not Config.Killer.AutoAttack then continue end
            if GetMyRole() ~= "Killer" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local attackRange = Config.Killer.ExtendedRange and Config.Killer.ExtendedRangeValue or 10

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character and GetRole(p) == "Survivor" then
                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot and (pRoot.Position - root.Position).Magnitude < attackRange then
                        -- Try to trigger attack via click
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait(0.05)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end)
                        break
                    end
                end
            end
        end
    end)

    ----------------------------------------------------------------
    -- KILLER: Extended Range
    ----------------------------------------------------------------
    task.spawn(function()
        while task.wait(0.5) do
            if not Config.Killer.ExtendedRange then continue end
            if GetMyRole() ~= "Killer" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            pcall(function()
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, child in ipairs(tool:GetDescendants()) do
                            if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                                local n = child.Name:lower()
                                if n:find("range") or n:find("reach") or n:find("distance") then
                                    child.Value = Config.Killer.ExtendedRangeValue
                                end
                            end
                        end
                        if tool:GetAttribute("Range") ~= nil then
                            tool:SetAttribute("Range", Config.Killer.ExtendedRangeValue)
                        end
                        if tool:GetAttribute("AttackRange") ~= nil then
                            tool:SetAttribute("AttackRange", Config.Killer.ExtendedRangeValue)
                        end
                    end
                end
            end)
        end
    end)

    ----------------------------------------------------------------
    -- KILLER: Anti Blind (Flashlight)
    ----------------------------------------------------------------
    task.spawn(function()
        while task.wait(2) do
            if not Config.Killer.AntiBlind then continue end
            if GetMyRole() ~= "Killer" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            if head then
                local blind = head:FindFirstChild("BlindEffect")
                if blind then blind:Destroy() end
            end
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui.Name:lower():find("blind") or gui.Name:lower():find("flash") then
                    pcall(function() gui:Destroy() end)
                end
            end
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("ColorCorrectionEffect") then
                    local n = effect.Name:lower()
                    if n:find("blind") or n:find("flash") then
                        pcall(function() effect:Destroy() end)
                    end
                end
            end
            pcall(function()
                if char:GetAttribute("Blinded") ~= nil then
                    char:SetAttribute("Blinded", false)
                end
                if char:GetAttribute("Blind") ~= nil then
                    char:SetAttribute("Blind", 0)
                end
            end)
        end
    end)

    ----------------------------------------------------------------
    -- KILLER: Auto Hook
    ----------------------------------------------------------------
    task.spawn(function()
        while task.wait(1) do
            if not Config.Killer.AutoHook then continue end
            if GetMyRole() ~= "Killer" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end

            -- Check if carrying someone
            local isCarrying = false
            pcall(function()
                if char:GetAttribute("Carrying") or char:GetAttribute("IsCarrying") then
                    isCarrying = true
                end
                for _, child in ipairs(char:GetDescendants()) do
                    if (child:IsA("Weld") or child:IsA("WeldConstraint")) and child.Part1 then
                        if child.Part1.Parent and child.Part1.Parent ~= char then
                            local otherPlayer = Players:GetPlayerFromCharacter(child.Part1.Parent)
                            if otherPlayer and GetRole(otherPlayer) == "Survivor" then
                                isCarrying = true
                            end
                        end
                    end
                end
            end)

            if isCarrying then
                local closestHook, closestDist = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:find("Hook") then
                        local hookPart = obj:FindFirstChild("HookPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if hookPart then
                            local dist = (hookPart.Position - root.Position).Magnitude
                            if dist < closestDist then
                                closestHook = hookPart
                                closestDist = dist
                            end
                        end
                    end
                end

                if closestHook then
                    if closestDist < 8 then
                        for _, child in ipairs(closestHook.Parent:GetDescendants()) do
                            if child:IsA("ProximityPrompt") and child.Enabled then
                                pcall(function() fireproximityprompt(child, 1) end)
                                break
                            end
                        end
                    else
                        humanoid:MoveTo(closestHook.Position)
                    end
                end
            end
        end
    end)

    ----------------------------------------------------------------
    -- SURVIVOR: Anti Grab Warning
    ----------------------------------------------------------------
    task.spawn(function()
        local lastWarning = 0
        while task.wait(1.5) do
            if not Config.Survivor.AntiGrab then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and GetRole(p) == "Killer" and p.Character then
                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local dist = (pRoot.Position - root.Position).Magnitude
                        if dist < 25 and (tick() - lastWarning) > 5 then
                            lastWarning = tick()
                            Exter:Notification({
                                Title = "⚠️ KILLER DEKAT!",
                                Content = p.Name .. " (" .. math.floor(dist) .. "m) - LARI!",
                                Duration = 3,
                                Icon = "warning",
                                ImageSource = "Material",
                            })
                        end
                    end
                end
            end
        end
    end)

    -- SURVIVOR: Auto Heal
    task.spawn(function()
        while task.wait(2) do
            if not Config.Survivor.AutoHeal then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character and GetRole(p) == "Survivor" then
                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot and (pRoot.Position - root.Position).Magnitude < 10 then
                        local pHumanoid = p.Character:FindFirstChildOfClass("Humanoid")
                        if pHumanoid and pHumanoid.Health < pHumanoid.MaxHealth then
                            for _, part in ipairs(p.Character:GetDescendants()) do
                                if part:IsA("ProximityPrompt") and part.Enabled then
                                    pcall(function() fireproximityprompt(part, 1) end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- SURVIVOR: Infinite Stamina
    task.spawn(function()
        while task.wait(0.8) do
            if not Config.Survivor.InfiniteStamina then continue end
            local char = localPlayer.Character
            if not char then continue end

            pcall(function()
                for _, child in ipairs(char:GetDescendants()) do
                    if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                        local n = child.Name:lower()
                        if n:find("stamina") or n:find("energy") or n:find("sprint") then
                            child.Value = 100
                        elseif n:find("fatigue") or n:find("exhaust") then
                            child.Value = 0
                        end
                    end
                end
            end)

            pcall(function()
                for _, attrName in ipairs({"Stamina", "Energy", "Sprint", "RunStamina", "SprintStamina"}) do
                    if char:GetAttribute(attrName) ~= nil then
                        char:SetAttribute(attrName, 100)
                    end
                end
                for _, attrName in ipairs({"Fatigue", "Exhaustion", "Tired"}) do
                    if char:GetAttribute(attrName) ~= nil then
                        char:SetAttribute(attrName, 0)
                    end
                end
            end)

            pcall(function()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, attrName in ipairs({"Stamina", "Energy", "Sprint", "RunStamina"}) do
                        if humanoid:GetAttribute(attrName) ~= nil then
                            humanoid:SetAttribute(attrName, 100)
                        end
                    end
                end
            end)
        end
    end)

    -- SURVIVOR: Auto Repair Generator
    task.spawn(function()
        while task.wait(1.5) do
            if not Config.Survivor.AutoRepair then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Generator" and obj:IsA("Model") then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary and (primary.Position - root.Position).Magnitude < 12 then
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("ProximityPrompt") and child.Enabled then
                                pcall(function() fireproximityprompt(child, 1) end)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- SURVIVOR: Auto Unhook
    task.spawn(function()
        while task.wait(1.5) do
            if not Config.Survivor.AutoUnhook then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find("Hook") then
                    local hookPart = obj:FindFirstChild("HookPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if hookPart and (hookPart.Position - root.Position).Magnitude < 12 then
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("ProximityPrompt") and child.Enabled then
                                pcall(function() fireproximityprompt(child, 1) end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end)

    -- SURVIVOR: Auto Vault
    task.spawn(function()
        while task.wait(0.5) do
            if not Config.Survivor.AutoVault then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.MoveDirection.Magnitude == 0 then continue end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj.Name == "Window" or obj.Name:lower():find("vault")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                    if part and (part.Position - root.Position).Magnitude < 8 then
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("ProximityPrompt") and child.Enabled then
                                pcall(function() fireproximityprompt(child, 1) end)
                                break
                            end
                        end
                        break
                    end
                end
            end
        end
    end)

    -- SURVIVOR: Auto Wiggle
    task.spawn(function()
        while task.wait(0.15) do
            if not Config.Survivor.AutoWiggle then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end

            local isCarried = false
            pcall(function()
                local state = humanoid:GetState()
                if state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.Physics then
                    isCarried = true
                end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, child in ipairs(root:GetChildren()) do
                        if child:IsA("Weld") or child:IsA("WeldConstraint") then
                            if child.Part1 and child.Part1.Parent ~= char then
                                isCarried = true
                            end
                        end
                    end
                end
                if char:GetAttribute("Carried") or char:GetAttribute("IsCarried") or char:GetAttribute("Grabbed") then
                    isCarried = true
                end
            end)

            if isCarried then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                end)
            end
        end
    end)

    -- SURVIVOR: Auto Struggle
    task.spawn(function()
        while task.wait(0.3) do
            if not Config.Survivor.AutoStruggle then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end

            local isOnHook = false
            pcall(function()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local state = humanoid:GetState()
                    if state == Enum.HumanoidStateType.PlatformStanding then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("Model") and obj.Name:find("Hook") then
                                    local hookPart = obj:FindFirstChild("HookPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                    if hookPart and (hookPart.Position - root.Position).Magnitude < 5 then
                                        isOnHook = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                if char:GetAttribute("Hooked") or char:GetAttribute("OnHook") then
                    isOnHook = true
                end
            end)

            if isOnHook then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end
        end
    end)

    -- SURVIVOR: Auto Sabotage Hook
    task.spawn(function()
        while task.wait(1.5) do
            if not Config.Survivor.AutoSabotage then continue end
            if GetMyRole() ~= "Survivor" then continue end

            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find("Hook") then
                    local hookPart = obj:FindFirstChild("HookPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if hookPart and (hookPart.Position - root.Position).Magnitude < 8 then
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("ProximityPrompt") and child.Enabled then
                                local promptName = child.Name:lower()
                                if promptName:find("sabotage") or promptName:find("sabo") or promptName:find("break") then
                                    pcall(function() fireproximityprompt(child, 1) end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- SURVIVOR: Notify Gen Complete
    task.spawn(function()
        local genStates = {}
        while task.wait(3) do
            if not Config.Survivor.NotifyGen then continue end
            local genCount = 0
            local completedCount = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Generator" and obj:IsA("Model") then
                    genCount = genCount + 1
                    local isComplete = true
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            isComplete = false
                            break
                        end
                    end
                    if isComplete then
                        completedCount = completedCount + 1
                        if not genStates[obj] then
                            genStates[obj] = true
                            Exter:Notification({
                                Title = "⬡ Generator Complete!",
                                Content = completedCount .. "/" .. genCount .. " generators done!",
                                Duration = 3,
                                Icon = "check_circle",
                                ImageSource = "Material",
                            })
                        end
                    else
                        genStates[obj] = nil
                    end
                end
            end
        end
    end)

    -- Anti Blind (Visual)
    task.spawn(function()
        while task.wait(2.5) do
            if not Config.Visuals.AntiBlindVisual then continue end
            local char = localPlayer.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            if head then
                local blind = head:FindFirstChild("BlindEffect")
                if blind then blind:Destroy() end
            end
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui.Name:lower():find("blind") then
                    pcall(function() gui:Destroy() end)
                end
            end
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("ColorCorrectionEffect") and effect.Name:lower():find("blind") then
                    pcall(function() effect:Destroy() end)
                end
            end
        end
    end)

    -- No Character Effects
    task.spawn(function()
        while task.wait(3) do
            if not Config.Visuals.NoCharacterEffects then continue end
            local char = localPlayer.Character
            if not char then continue end
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Fire") or child:IsA("Smoke") or child:IsA("Sparkles") then
                    pcall(function() child.Enabled = false end)
                end
            end
        end
    end)

    -- Distance Updater
    task.spawn(function()
        while task.wait(4) do
            if not Config.ESP.Enabled or not Config.ESP.ShowDistance then continue end
            local char = localPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character then
                    local tag = p.Character:FindFirstChild("VDTag")
                    if tag then
                        local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            local dist = math.floor((pRoot.Position - root.Position).Magnitude)
                            local role = GetRole(p)
                            local textLabel = tag:FindFirstChildWhichIsA("TextLabel")
                            if textLabel then
                                textLabel.Text = "[" .. role .. "] " .. p.Name .. " [" .. dist .. "m]"
                            end
                        end
                    end
                end
            end
        end
    end)

    -- FOV enforcer
    task.spawn(function()
        while task.wait(3) do
            if Config.Visuals.CustomFOV ~= 70 then
                local cam = workspace.CurrentCamera
                if cam and cam.FieldOfView ~= Config.Visuals.CustomFOV then
                    cam.FieldOfView = Config.Visuals.CustomFOV
                end
            end
        end
    end)

    -- Third Person enforcer
    task.spawn(function()
        while task.wait(2) do
            if Config.Visuals.ThirdPerson then
                localPlayer.CameraMaxZoomDistance = Config.Visuals.ThirdPersonDistance
                localPlayer.CameraMinZoomDistance = Config.Visuals.ThirdPersonDistance
            end
        end
    end)
end

----------------------------------------------------------------
-- AUTO SKILL CHECK
----------------------------------------------------------------
local function StartSkillCheckLogic()
    local function ConnectUI()
        local CheckGui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not CheckGui then
            CheckGui = PlayerGui:WaitForChild("SkillCheckPromptGui", 30)
        end
        if not CheckGui then return end

        local Check = CheckGui:FindFirstChild("Check")
        if not Check then
            Check = CheckGui:WaitForChild("Check", 10)
        end
        if not Check then return end

        local Line = Check:FindFirstChild("Line")
        local Goal = Check:FindFirstChild("Goal")
        if not Line or not Goal then return end

        local heartbeatConn = nil
        local debounce = false

        Check:GetPropertyChangedSignal("Visible"):Connect(function()
            if heartbeatConn then
                heartbeatConn:Disconnect()
                heartbeatConn = nil
            end
            debounce = false

            if Check.Visible and Config.Survivor.AutoSkillCheck then
                task.wait(0.02)

                heartbeatConn = RunService.Heartbeat:Connect(function()
                    if not Check.Visible or not Config.Survivor.AutoSkillCheck or debounce then
                        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
                        return
                    end

                    local lineRot = Line.Rotation % 360
                    local goalRot = Goal.Rotation % 360

                    local zoneStart, zoneEnd

                    if Config.Survivor.GreatOnly then
                        zoneStart = (goalRot + 114) % 360
                        zoneEnd = (goalRot + 117) % 360
                    else
                        zoneStart = (goalRot + 110) % 360
                        zoneEnd = (goalRot + 122) % 360
                    end

                    local isInZone
                    if zoneStart > zoneEnd then
                        isInZone = (lineRot >= zoneStart or lineRot <= zoneEnd)
                    else
                        isInZone = (lineRot >= zoneStart and lineRot <= zoneEnd)
                    end

                    if isInZone then
                        debounce = true
                        task.defer(function()
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                task.wait(0.015)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            end)
                        end)
                        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
                    end
                end)
            end
        end)
    end

    localPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        ConnectUI()
    end)
    ConnectUI()

    task.spawn(function()
        while task.wait(10) do
            if not PlayerGui:FindFirstChild("SkillCheckPromptGui") then continue end
            local gui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
            local check = gui and gui:FindFirstChild("Check")
            if check and not check:FindFirstChild("_VDConnected") then
                local marker = Instance.new("BoolValue")
                marker.Name = "_VDConnected"
                marker.Parent = check
                ConnectUI()
            end
        end
    end)
end

----------------------------------------------------------------
-- CHARACTER RESPAWN HANDLER
----------------------------------------------------------------
local function OnCharacterSpawn(char)
    task.wait(2)
    ApplyActiveVisuals()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            RefreshPlayerESP(p)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        local data = objectNameLookup[obj.Name]
        if data and data.Enabled and (obj:IsA("Model") or obj:IsA("BasePart")) then
            if not espCache[obj] then
                ApplyHighlight(obj, data.Color, data.Tag, nil)
            end
        end
    end
end

----------------------------------------------------------------
-- MAIN INITIALIZATION
----------------------------------------------------------------

SetupKeybinds()
StartCoreLoop()
StartBackgroundLoops()
SetupObjectESP()
task.spawn(StartSkillCheckLogic)

for _, p in ipairs(Players:GetPlayers()) do
    SetupPlayerESP(p)
end
Players.PlayerAdded:Connect(SetupPlayerESP)

localPlayer.CharacterAdded:Connect(OnCharacterSpawn)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer then
        pcall(function()
            p:GetPropertyChangedSignal("Team"):Connect(function()
                task.wait(1)
                RefreshPlayerESP(p)
            end)
        end)
    end
end
Players.PlayerAdded:Connect(function(p)
    SetupPlayerESP(p)
    pcall(function()
        p:GetPropertyChangedSignal("Team"):Connect(function()
            task.wait(1)
            RefreshPlayerESP(p)
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if p.Character then
        espCache[p.Character] = nil
    end
end)

localPlayer.OnTeleport:Connect(function()
    pcall(function()
        for _, conn in ipairs(_connections) do
            pcall(function() conn:Disconnect() end)
        end
    end)
end)

-- Notification
Exter:Notification({
    Title = "⬡ Violence District v1.6.3",
    Content = "Tab Survivor & Killer dipisah! One Hit + Fast Vault aktif.",
    Duration = 5,
    Icon = "check_circle",
    ImageSource = "Material",
})

-- Init complete
warn("══════════════════════════════════════════════════")
warn("  ⬡ VIOLENCE DISTRICT v1.6.3 - EXTER LIBRARY")
warn("  by Exter Interactive")
warn("  ──────────────────────────────────────────────")
warn("  TAB STRUCTURE:")
warn("  [ESP] → Player & Object ESP")
warn("  [Survivor] → Skill Check, Vault, Repair, Heal")
warn("  [Killer] → One Hit, Fast Attack, Auto Hook")
warn("  [Movement] → Speed, Jump, NoClip")
warn("  [Visuals] → Lighting, FOV, Camera")
warn("  [Teleport] → TP ke objek & player")
warn("  [Info] → Changelog & session")
warn("  ──────────────────────────────────────────────")
warn("  GUI: Exter Library (SOBING4413)")
warn("  ──────────────────────────────────────────────")
warn("  KEYBINDS: V=ESP | G=FastVault | F=ResetFOV")
warn("══════════════════════════════════════════════════")
