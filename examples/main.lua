--[[
    Exter Universal Script
    By: SOBING4413
    Fitur: Aimbot, ESP, Speed, Jump Power, FOV Slider, dll.
--]]

local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()

-- ============================================================
-- VARIABEL GLOBAL
-- ============================================================
getgenv().ExterUniversal = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        VisibilityCheck = true,
        HitChance = 100,
        Smoothness = 0,
        SelectedPart = "Head",
        FOVRadius = 180,
        ShowFOV = true,
        TargetKey = "MouseButton2"
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        HealthBar = true,
        NameTag = true,
        Tracers = false,
        TeamColor = true,
        Distance = false
    },
    Movement = {
        Walkspeed = 16,
        JumpPower = 50,
        NoClip = false,
        AntiFall = false,
        AutoFarm = false
    },
    Character = {
        InfiniteJump = false,
        NoSlowdown = false,
        AutoClick = false,
        ClickInterval = 0.1
    },
    Visuals = {
        FullBright = false,
        FOV = 70,
        NoFog = false
    },
    Misc = {
        Rejoin = function() 
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end,
        ServerHop = false,
        AntiAFK = false
    }
}

local E = getgenv().ExterUniversal
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- ============================================================
-- FUNGSI UTILITY
-- ============================================================
local function getCharacters()
    local chars = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if E.Aimbot.TeamCheck and plr.Team == Player.Team then continue end
            table.insert(chars, plr)
        end
    end
    return chars
end

local function isVisible(part)
    if not E.Aimbot.VisibilityCheck then return true end
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (part.Position - origin).Unit * 500)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character, Camera})
    return hit and (hit:IsDescendantOf(part.Parent) or hit == part)
end

local function getClosestTarget()
    local closest, dist = nil, math.huge
    local fovRad = E.Aimbot.FOVRadius
    for _, plr in ipairs(getCharacters()) do
        local hrp = plr.Character.HumanoidRootPart
        local part = plr.Character:FindFirstChild(E.Aimbot.SelectedPart) or hrp
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        if not isVisible(part) then continue end
        
        local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        if distFromMouse < fovRad and distFromMouse < dist then
            dist = distFromMouse
            closest = plr
        end
    end
    return closest
end

-- ============================================================
-- AIMBOT ENGINE
-- ============================================================
local AimbotConnection
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

local function updateFOV()
    FOVCircle.Radius = E.Aimbot.FOVRadius * (Camera.ViewportSize.X / 1920)
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Visible = E.Aimbot.Enabled and E.Aimbot.ShowFOV
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    end
end)

local function aimbotLoop()
    if not E.Aimbot.Enabled then
        FOVCircle.Visible = false
        return
    end
    
    updateFOV()
    
    local targeting = E.Aimbot.TargetKey == "MouseButton2" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                     or E.Aimbot.TargetKey == "MouseButton1" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                     or UserInputService:IsKeyDown(Enum.KeyCode[E.Aimbot.TargetKey])
    
    if not targeting then return end
    
    local target = getClosestTarget()
    if target then
        local part = target.Character:FindFirstChild(E.Aimbot.SelectedPart) or target.Character.HumanoidRootPart
        local hrp = target.Character.HumanoidRootPart
        
        -- HitChance check
        if math.random(1, 100) > E.Aimbot.HitChance then return end
        
        -- Smoothness
        if E.Aimbot.Smoothness > 0 then
            local current = CFrame.new(Camera.CFrame.Position, part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(current, 1 / E.Aimbot.Smoothness, 0.5)
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end
end

-- ============================================================
-- ESP ENGINE
-- ============================================================
local ESPObjects = {}
local ESPConnection

local function createESP(plr)
    if ESPObjects[plr] then return end
    ESPObjects[plr] = {}
    
    -- Box
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false
    ESPObjects[plr].Box = box
    
    -- HealthBar bg & fill
    local hpBg = Drawing.new("Square")
    hpBg.Filled = true
    hpBg.Color = Color3.fromRGB(0, 0, 0)
    hpBg.Transparency = 0.5
    hpBg.Visible = false
    ESPObjects[plr].HPBg = hpBg
    
    local hpFill = Drawing.new("Square")
    hpFill.Filled = true
    hpFill.Visible = false
    ESPObjects[plr].HPFill = hpFill
    
    -- Name
    local nameTag = Drawing.new("Text")
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Visible = false
    ESPObjects[plr].NameTag = nameTag
    
    -- Distance
    local distText = Drawing.new("Text")
    distText.Size = 12
    distText.Center = true
    distText.Outline = true
    distText.Visible = false
    ESPObjects[plr].DistText = distText
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false
    ESPObjects[plr].Tracer = tracer
end

local function updateESP(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    local char = plr.Character
    if not char then
        obj.Box.Visible = false
        obj.HPBg.Visible = false
        obj.HPFill.Visible = false
        obj.NameTag.Visible = false
        obj.DistText.Visible = false
        obj.Tracer.Visible = false
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        obj.Box.Visible = false
        return
    end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then
        obj.Box.Visible = false
        return
    end
    
    local pos = Vector2.new(screenPos.X, screenPos.Y)
    local scale = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y
    local boxSize = Vector2.new(scale * 0.8, scale)
    
    local teamColor = plr.TeamColor.Color
    local espColor = E.ESP.TeamColor and teamColor or Color3.fromRGB(255, 255, 255)
    local health = hum.Health / hum.MaxHealth
    
    -- Box
    if E.ESP.Boxes then
        obj.Box.Size = boxSize
        obj.Box.Position = pos - boxSize / 2
        obj.Box.Color = espColor
        obj.Box.Visible = true
    else
        obj.Box.Visible = false
    end
    
    -- HealthBar
    if E.ESP.HealthBar then
        local hpPos = pos - boxSize / 2 + Vector2.new(-6, 0)
        local hpSize = Vector2.new(4, boxSize.Y)
        obj.HPBg.Size = hpSize
        obj.HPBg.Position = hpPos
        obj.HPBg.Visible = true
        
        obj.HPFill.Size = Vector2.new(4, boxSize.Y * math.clamp(health, 0, 1))
        obj.HPFill.Position = hpPos + Vector2.new(0, boxSize.Y * (1 - math.clamp(health, 0, 1)))
        obj.HPFill.Color = Color3.fromRGB(math.floor((1 - health) * 255), math.floor(health * 255), 0)
        obj.HPFill.Visible = true
    else
        obj.HPBg.Visible = false
        obj.HPFill.Visible = false
    end
    
    -- NameTag
    if E.ESP.NameTag then
        obj.NameTag.Position = pos - boxSize / 2 + Vector2.new(0, -20)
        obj.NameTag.Text = plr.Name
        obj.NameTag.Color = espColor
        obj.NameTag.Visible = true
    else
        obj.NameTag.Visible = false
    end
    
    -- Distance
    if E.ESP.Distance and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        obj.DistText.Position = pos + boxSize / 2 + Vector2.new(0, 10)
        obj.DistText.Text = math.floor(dist) .. "m"
        obj.DistText.Color = Color3.fromRGB(200, 200, 200)
        obj.DistText.Visible = true
    else
        obj.DistText.Visible = false
    end
    
    -- Tracer
    if E.ESP.Tracers then
        obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        obj.Tracer.To = pos
        obj.Tracer.Color = espColor
        obj.Tracer.Visible = true
    else
        obj.Tracer.Visible = false
    end
end

local function espLoop()
    if not E.ESP.Enabled then
        for _, obj in pairs(ESPObjects) do
            obj.Box.Visible = false
            obj.HPBg.Visible = false
            obj.HPFill.Visible = false
            obj.NameTag.Visible = false
            obj.DistText.Visible = false
            obj.Tracer.Visible = false
        end
        return
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            createESP(plr)
            updateESP(plr)
        end
    end
end

-- ESP Player Added
Players.PlayerAdded:Connect(function(plr)
    createESP(plr)
end)

-- Cleanup ESP for disconnected players
Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            obj:Remove()
        end
        ESPObjects[plr] = nil
    end
end)

-- Init existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Player then
        createESP(plr)
    end
end

-- ============================================================
-- MOVEMENT ENGINE
-- ============================================================
local function applyMovement()
    if not Player.Character then return end
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    hum.WalkSpeed = E.Movement.Walkspeed
    hum.JumpPower = E.Movement.JumpPower
end

-- NoClip
local function noclipLoop()
    if not E.Movement.NoClip then return end
    if not Player.Character then return end
    for _, part in ipairs(Player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- AntiFall (teleport ke posisi aman)
local function antiFallLoop()
    if not E.Movement.AntiFall then return end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = Player.Character.HumanoidRootPart
    if hrp.Position.Y < -50 then
        hrp.CFrame = CFrame.new(0, 50, 0)
    end
end

-- ============================================================
-- CHARACTER FEATURES
-- ============================================================
-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if E.Character.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- No Slowdown
RunService.Stepped:Connect(function()
    if E.Character.NoSlowdown and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, state in ipairs({Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Swimming}) do
                if hum:GetState() == state then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    end
end)

-- AutoClick
local autoClickRunning = false
local function autoClickLoop()
    while autoClickRunning and E.Character.AutoClick do
        mouse1click()
        task.wait(E.Character.ClickInterval)
    end
end

E.Character.__autoClickToggle = function(state)
    autoClickRunning = state
    if state then
        task.spawn(autoClickLoop)
    end
end

-- ============================================================
-- VISUALS ENGINE
-- ============================================================
local originalBrightness = Lighting.Brightness
local originalFogEnd = Lighting.FogEnd
local originalAmbient = Lighting.Ambient

local function applyVisuals()
    -- FullBright
    if E.Visuals.FullBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.GlobalShadows = true
    end
    
    -- NoFog
    if E.Visuals.NoFog then
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 1e10
    else
        Lighting.FogEnd = originalFogEnd
    end
    
    -- FOV
    if Camera then
        Camera.FieldOfView = E.Visuals.FOV
    end
end

-- ============================================================
-- ANTI AFK
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")
local function antiAFK()
    if not E.Misc.AntiAFK then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end

Player.Idled:Connect(function()
    antiAFK()
end)

-- ============================================================
-- LOOP ENGINE
-- ============================================================
RunService.RenderStepped:Connect(function()
    aimbotLoop()
    espLoop()
    applyMovement()
    noclipLoop()
    antiFallLoop()
    applyVisuals()
end)

RunService.Stepped:Connect(function()
    applyMovement()
end)

-- ============================================================
-- UI WINDOW
-- ============================================================
local Window = Exter:CreateWindow({
    Name = "Exter Universal",
    Subtitle = "v1.0 — by SOBING4413",
    Bind = Enum.KeyCode.K,
    ConfigSettings = {
        ConfigFolder = "ExterUniversal",
        RootFolder = "ExterConfigs"
    }
})

-- ============================================================
-- TAB: AIMBOT
-- ============================================================
local AimbotTab = Window:CreateTab({ Name = "Aimbot", Icon = "gavel" })

AimbotTab:CreateSection("Main Settings")

AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = E.Aimbot.Enabled,
    Callback = function(v) E.Aimbot.Enabled = v end
}, "AimbotEnabled")

AimbotTab:CreateSlider({
    Name = "Hit Chance",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = E.Aimbot.HitChance,
    Callback = function(v) E.Aimbot.HitChance = v end
}, "AimbotHitChance")

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = E.Aimbot.Smoothness,
    Callback = function(v) 
        E.Aimbot.Smoothness = v 
        if v == 0 then
            Exter:Notification({Title="Aimbot", Content="Smoothness off — instant aim", Icon="info", ImageSource="Material", Duration=2})
        end
    end
}, "AimbotSmoothness")

AimbotTab:CreateSection("Targeting")

AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart", "Random"},
    CurrentOption = {E.Aimbot.SelectedPart},
    MultipleOptions = false,
    Callback = function(v) E.Aimbot.SelectedPart = v end
}, "AimbotPart")

AimbotTab:CreateDropdown({
    Name = "Trigger Key",
    Options = {"MouseButton2", "MouseButton1", "E", "Q", "F"},
    CurrentOption = {E.Aimbot.TargetKey},
    MultipleOptions = false,
    Callback = function(v) E.Aimbot.TargetKey = v end
}, "AimbotKey")

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = E.Aimbot.TeamCheck,
    Callback = function(v) E.Aimbot.TeamCheck = v end
}, "AimbotTeamCheck")

AimbotTab:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = E.Aimbot.VisibilityCheck,
    Callback = function(v) E.Aimbot.VisibilityCheck = v end
}, "AimbotVisibility")

AimbotTab:CreateSection("FOV Settings")

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 360},
    Increment = 5,
    CurrentValue = E.Aimbot.FOVRadius,
    Callback = function(v) E.Aimbot.FOVRadius = v end
}, "AimbotFOV")

AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = E.Aimbot.ShowFOV,
    Callback = function(v) E.Aimbot.ShowFOV = v end
}, "AimbotShowFOV")

-- ============================================================
-- TAB: ESP
-- ============================================================
local ESPTab = Window:CreateTab({ Name = "ESP", Icon = "list" })

ESPTab:CreateSection("Main Settings")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = E.ESP.Enabled,
    Callback = function(v) E.ESP.Enabled = v end
}, "ESPEnabled")

ESPTab:CreateSection("ESP Elements")

ESPTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = E.ESP.Boxes,
    Callback = function(v) E.ESP.Boxes = v end
}, "ESPBoxes")

ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = E.ESP.HealthBar,
    Callback = function(v) E.ESP.HealthBar = v end
}, "ESPHealth")

ESPTab:CreateToggle({
    Name = "Name Tags",
    CurrentValue = E.ESP.NameTag,
    Callback = function(v) E.ESP.NameTag = v end
}, "ESPNames")

ESPTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = E.ESP.Tracers,
    Callback = function(v) E.ESP.Tracers = v end
}, "ESPTracers")

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = E.ESP.Distance,
    Callback = function(v) E.ESP.Distance = v end
}, "ESPDistance")

ESPTab:CreateToggle({
    Name = "Team Color",
    CurrentValue = E.ESP.TeamColor,
    Callback = function(v) E.ESP.TeamColor = v end
}, "ESPTeamColor")

-- ============================================================
-- TAB: MOVEMENT
-- ============================================================
local MovementTab = Window:CreateTab({ Name = "Movement", Icon = "sticky_note_2" })

MovementTab:CreateSection("Movement Settings")

MovementTab:CreateSlider({
    Name = "Walkspeed",
    Range = {1, 250},
    Increment = 1,
    CurrentValue = E.Movement.Walkspeed,
    Callback = function(v) E.Movement.Walkspeed = v end
}, "Walkspeed")

MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = E.Movement.JumpPower,
    Callback = function(v) E.Movement.JumpPower = v end
}, "JumpPower")

MovementTab:CreateSection("Utilities")

MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = E.Movement.NoClip,
    Callback = function(v) E.Movement.NoClip = v end
}, "NoClip")

MovementTab:CreateToggle({
    Name = "Anti Fall",
    CurrentValue = E.Movement.AntiFall,
    Callback = function(v) E.Movement.AntiFall = v end
}, "AntiFall")

-- ============================================================
-- TAB: CHARACTER
-- ============================================================
local CharTab = Window:CreateTab({ Name = "Character", Icon = "table_view" })

CharTab:CreateSection("Character Options")

CharTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = E.Character.InfiniteJump,
    Callback = function(v) E.Character.InfiniteJump = v end
}, "InfiniteJump")

CharTab:CreateToggle({
    Name = "No Slowdown",
    CurrentValue = E.Character.NoSlowdown,
    Callback = function(v) E.Character.NoSlowdown = v end
}, "NoSlowdown")

CharTab:CreateToggle({
    Name = "Auto Click",
    CurrentValue = E.Character.AutoClick,
    Callback = function(v) 
        E.Character.AutoClick = v
        if E.Character.__autoClickToggle then
            E.Character.__autoClickToggle(v)
        end
    end
}, "AutoClick")

CharTab:CreateSlider({
    Name = "Click Interval (ms)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = E.Character.ClickInterval * 1000,
    Callback = function(v) E.Character.ClickInterval = v / 1000 end
}, "ClickInterval")

-- ============================================================
-- TAB: VISUALS
-- ============================================================
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "perm_media" })

VisualsTab:CreateSection("Visual Settings")

VisualsTab:CreateSlider({
    Name = "Field of View",
    Range = {30, 120},
    Increment = 1,
    CurrentValue = E.Visuals.FOV,
    Callback = function(v) E.Visuals.FOV = v end
}, "FOV")

VisualsTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = E.Visuals.FullBright,
    Callback = function(v) E.Visuals.FullBright = v end
}, "FullBright")

VisualsTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = E.Visuals.NoFog,
    Callback = function(v) E.Visuals.NoFog = v end
}, "NoFog")

-- ============================================================
-- TAB: MISC
-- ============================================================
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "alarm_add" })

MiscTab:CreateSection("Server Options")

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Description = "Kick & rejoin server",
    Callback = E.Misc.Rejoin
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = E.Misc.AntiAFK,
    Callback = function(v) E.Misc.AntiAFK = v end
}, "AntiAFK")

MiscTab:CreateSection("Config")

MiscTab:BuildConfigSection()
MiscTab:BuildThemeSection()

MiscTab:CreateSection("Credits")

MiscTab:CreateLabel({ Text = "Exter Universal v1.0" })
MiscTab:CreateLabel({ Text = "Powered by Exter Library" })
MiscTab:CreateLabel({ Text = "by SOBING4413" })

-- ============================================================
-- NOTIFICATION STARTUP
-- ============================================================
Exter:Notification({
    Title = "Exter Universal",
    Content = "Loaded successfully! Press K to toggle menu.",
    Icon = "check_circle",
    ImageSource = "Material",
    Duration = 5
})

-- Auto load config
Exter:LoadAutoloadConfig()