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
        TargetKey = "MouseButton2",
        Prediction = false,
        PredictionAmount = 0.165
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        HealthBar = true,
        NameTag = true,
        Tracers = false,
        TeamColor = true,
        Distance = false,
        MaxDistance = 1000
    },
    Movement = {
        Walkspeed = 16,
        JumpPower = 50,
        NoClip = false,
        AntiFall = false,
        Fly = false,
        FlySpeed = 50
    },
    Character = {
        InfiniteJump = false,
        NoSlowdown = false,
        AutoClick = false,
        ClickInterval = 0.1,
        GodMode = false
    },
    Visuals = {
        FullBright = false,
        FOV = 70,
        NoFog = false,
        NightMode = false
    },
    Misc = {
        Rejoin = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end,
        ServerHop = false,
        AntiAFK = true,
        ChatSpam = false,
        ChatMessage = "Exter Universal",
        ChatInterval = 3
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================================
-- FUNGSI UTILITY
-- ============================================================
local function getCharacters()
    local chars = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if E.Aimbot.TeamCheck and plr.Team and Player.Team and plr.Team == Player.Team then continue end
            table.insert(chars, plr)
        end
    end
    return chars
end

local function isVisible(part)
    if not E.Aimbot.VisibilityCheck then return true end
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {Player.Character, Camera}

    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return result.Instance:IsDescendantOf(part.Parent) or result.Instance == part
    end
    return true
end

local function getClosestTarget()
    local closest, dist = nil, math.huge
    local fovRad = E.Aimbot.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(getCharacters()) do
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local partName = E.Aimbot.SelectedPart
        if partName == "Random" then
            local parts = {"Head", "Torso", "HumanoidRootPart"}
            partName = parts[math.random(1, #parts)]
        end

        local part = char:FindFirstChild(partName) or hrp
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        if not isVisible(part) then continue end

        local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distFromCenter < fovRad and distFromCenter < dist then
            dist = distFromCenter
            closest = plr
        end
    end
    return closest
end

-- ============================================================
-- AIMBOT ENGINE (FIXED)
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.7

local function updateFOV()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = E.Aimbot.FOVRadius
    FOVCircle.Position = screenCenter
    FOVCircle.Visible = E.Aimbot.Enabled and E.Aimbot.ShowFOV
end

local function isTargeting()
    local key = E.Aimbot.TargetKey
    if key == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    else
        local success, keyCode = pcall(function()
            return Enum.KeyCode[key]
        end)
        if success and keyCode then
            return UserInputService:IsKeyDown(keyCode)
        end
    end
    return false
end

local function aimbotLoop()
    if not E.Aimbot.Enabled then
        FOVCircle.Visible = false
        return
    end

    updateFOV()

    if not isTargeting() then return end

    local target = getClosestTarget()
    if not target then return end

    local char = target.Character
    if not char then return end

    local partName = E.Aimbot.SelectedPart
    if partName == "Random" then
        local parts = {"Head", "Torso", "HumanoidRootPart"}
        partName = parts[math.random(1, #parts)]
    end

    local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
    if not part then return end

    -- HitChance check
    if math.random(1, 100) > E.Aimbot.HitChance then return end

    -- Calculate target position with prediction
    local targetPos = part.Position
    if E.Aimbot.Prediction then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
            targetPos = targetPos + (velocity * E.Aimbot.PredictionAmount)
        end
    end

    -- Apply aim with smoothness (FIXED: CFrame:Lerp only takes 2 args)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    if E.Aimbot.Smoothness > 0 then
        local alpha = math.clamp(1 / E.Aimbot.Smoothness, 0.01, 1)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
    else
        Camera.CFrame = targetCFrame
    end
end

-- ============================================================
-- ESP ENGINE (FIXED)
-- ============================================================
local ESPObjects = {}

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

local function hideESP(obj)
    if not obj then return end
    if obj.Box then obj.Box.Visible = false end
    if obj.HPBg then obj.HPBg.Visible = false end
    if obj.HPFill then obj.HPFill.Visible = false end
    if obj.NameTag then obj.NameTag.Visible = false end
    if obj.DistText then obj.DistText.Visible = false end
    if obj.Tracer then obj.Tracer.Visible = false end
end

local function updateESP(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    local char = plr.Character
    if not char then
        hideESP(obj)
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        hideESP(obj)
        return
    end

    -- Max distance check
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local distToPlayer = (hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        if distToPlayer > E.ESP.MaxDistance then
            hideESP(obj)
            return
        end
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then
        hideESP(obj)
        return
    end

    local pos = Vector2.new(screenPos.X, screenPos.Y)

    -- FIXED: Better box size calculation using head and feet positions
    local headPos = char:FindFirstChild("Head")
    local rootPos = hrp.Position

    local topPos, topOnScreen = Camera:WorldToViewportPoint(rootPos + Vector3.new(0, 3, 0))
    local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(rootPos - Vector3.new(0, 4.5, 0))

    if not topOnScreen or not bottomOnScreen then
        hideESP(obj)
        return
    end

    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
    local boxWidth = boxHeight * 0.55
    local boxSize = Vector2.new(boxWidth, boxHeight)
    local boxPos = Vector2.new(screenPos.X - boxWidth / 2, topPos.Y)

    -- Team color
    local espColor = Color3.fromRGB(255, 255, 255)
    if E.ESP.TeamColor then
        pcall(function()
            espColor = plr.TeamColor.Color
        end)
    end

    local health = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

    -- Box
    if E.ESP.Boxes then
        obj.Box.Size = boxSize
        obj.Box.Position = boxPos
        obj.Box.Color = espColor
        obj.Box.Visible = true
    else
        obj.Box.Visible = false
    end

    -- HealthBar
    if E.ESP.HealthBar then
        local hpX = boxPos.X - 6
        local hpY = boxPos.Y
        local hpHeight = boxHeight

        obj.HPBg.Size = Vector2.new(4, hpHeight)
        obj.HPBg.Position = Vector2.new(hpX, hpY)
        obj.HPBg.Visible = true

        local fillHeight = hpHeight * health
        obj.HPFill.Size = Vector2.new(4, fillHeight)
        obj.HPFill.Position = Vector2.new(hpX, hpY + (hpHeight - fillHeight))
        obj.HPFill.Color = Color3.fromRGB(math.floor((1 - health) * 255), math.floor(health * 255), 0)
        obj.HPFill.Visible = true
    else
        obj.HPBg.Visible = false
        obj.HPFill.Visible = false
    end

    -- NameTag
    if E.ESP.NameTag then
        obj.NameTag.Position = Vector2.new(screenPos.X, boxPos.Y - 18)
        obj.NameTag.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
        obj.NameTag.Color = espColor
        obj.NameTag.Visible = true
    else
        obj.NameTag.Visible = false
    end

    -- Distance
    if E.ESP.Distance and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        obj.DistText.Position = Vector2.new(screenPos.X, boxPos.Y + boxHeight + 4)
        obj.DistText.Text = math.floor(dist) .. " studs"
        obj.DistText.Color = Color3.fromRGB(200, 200, 200)
        obj.DistText.Visible = true
    else
        obj.DistText.Visible = false
    end

    -- Tracer
    if E.ESP.Tracers then
        obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        obj.Tracer.To = Vector2.new(screenPos.X, boxPos.Y + boxHeight)
        obj.Tracer.Color = espColor
        obj.Tracer.Visible = true
    else
        obj.Tracer.Visible = false
    end
end

local function espLoop()
    if not E.ESP.Enabled then
        for _, obj in pairs(ESPObjects) do
            hideESP(obj)
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

-- ESP Player Added/Removed
Players.PlayerAdded:Connect(function(plr)
    if E.ESP.Enabled then
        createESP(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            pcall(function() obj:Remove() end)
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
-- MOVEMENT ENGINE (FIXED & IMPROVED)
-- ============================================================
local function applyMovement()
    if not Player.Character then return end
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.WalkSpeed = E.Movement.Walkspeed
    hum.JumpPower = E.Movement.JumpPower
end

-- Reapply on respawn
Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    applyMovement()
end)

-- NoClip (FIXED: more reliable)
local function noclipLoop()
    if not E.Movement.NoClip then return end
    if not Player.Character then return end
    for _, part in ipairs(Player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- AntiFall (FIXED: save last safe position)
local lastSafePosition = CFrame.new(0, 50, 0)

local function antiFallLoop()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = Player.Character.HumanoidRootPart

    -- Save safe position when on ground
    if hrp.Position.Y > 0 then
        lastSafePosition = hrp.CFrame
    end

    if not E.Movement.AntiFall then return end
    if hrp.Position.Y < -50 then
        hrp.CFrame = lastSafePosition
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- ============================================================
-- FLY ENGINE (NEW)
-- ============================================================
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function startFly()
    if not Player.Character then return end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Remove existing
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end) end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.P = 9e4
    flyBodyGyro.D = 1000
    flyBodyGyro.Parent = hrp

    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
end

local function stopFly()
    if flyBodyVelocity then
        pcall(function() flyBodyVelocity:Destroy() end)
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        pcall(function() flyBodyGyro:Destroy() end)
        flyBodyGyro = nil
    end
    if Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

local function flyLoop()
    if not E.Movement.Fly then
        if flyBodyVelocity then stopFly() end
        return
    end

    if not flyBodyVelocity then startFly() end
    if not flyBodyVelocity or not flyBodyVelocity.Parent then
        startFly()
    end

    local speed = E.Movement.FlySpeed
    local direction = Vector3.new(0, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end

    if direction.Magnitude > 0 then
        direction = direction.Unit * speed
    end

    flyBodyVelocity.Velocity = direction
    flyBodyGyro.CFrame = Camera.CFrame
end

-- ============================================================
-- CHARACTER FEATURES (FIXED)
-- ============================================================
-- Infinite Jump (FIXED)
UserInputService.JumpRequest:Connect(function()
    if E.Character.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- No Slowdown (FIXED: handle all slowdown states)
local function noSlowdownLoop()
    if not E.Character.NoSlowdown then return end
    if not Player.Character then return end
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local slowStates = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.StrafingNoPhysics,
    }

    for _, state in ipairs(slowStates) do
        hum:SetStateEnabled(state, false)
    end
end

-- AutoClick (FIXED: proper coroutine management)
local autoClickThread = nil

local function startAutoClick()
    if autoClickThread then return end
    autoClickThread = task.spawn(function()
        while E.Character.AutoClick do
            pcall(function()
                mouse1click()
            end)
            task.wait(E.Character.ClickInterval)
        end
        autoClickThread = nil
    end)
end

local function stopAutoClick()
    autoClickThread = nil
end

-- GodMode (NEW)
local function godModeLoop()
    if not E.Character.GodMode then return end
    if not Player.Character then return end
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Prevent death states
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

-- ============================================================
-- VISUALS ENGINE (FIXED & IMPROVED)
-- ============================================================
local originalBrightness = Lighting.Brightness
local originalFogEnd = Lighting.FogEnd
local originalFogStart = Lighting.FogStart
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalClockTime = Lighting.ClockTime

local function applyVisuals()
    -- FullBright
    if E.Visuals.FullBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.GlobalShadows = false
        -- Remove atmosphere/blur effects
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = false
            end
        end
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoorAmbient
        Lighting.GlobalShadows = true
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = true
            end
        end
    end

    -- NoFog
    if E.Visuals.NoFog then
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 1e10
    else
        Lighting.FogEnd = originalFogEnd
        Lighting.FogStart = originalFogStart
    end

    -- Night Mode
    if E.Visuals.NightMode then
        Lighting.ClockTime = 0
    end

    -- FOV
    if Camera then
        Camera.FieldOfView = E.Visuals.FOV
    end
end

-- ============================================================
-- ANTI AFK (FIXED)
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")

Player.Idled:Connect(function()
    if E.Misc.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ============================================================
-- SERVER HOP (NEW - IMPLEMENTED)
-- ============================================================
local function serverHop()
    local success, servers = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
    end)

    if not success or not servers or not servers.data then
        Exter:Notification({
            Title = "Server Hop",
            Content = "Failed to fetch servers!",
            Icon = "error",
            ImageSource = "Material",
            Duration = 3
        })
        return
    end

    for _, server in ipairs(servers.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
            return
        end
    end

    Exter:Notification({
        Title = "Server Hop",
        Content = "No available servers found!",
        Icon = "warning",
        ImageSource = "Material",
        Duration = 3
    })
end

-- ============================================================
-- CHAT SPAM (NEW)
-- ============================================================
local chatSpamThread = nil

local function startChatSpam()
    if chatSpamThread then return end
    chatSpamThread = task.spawn(function()
        while E.Misc.ChatSpam do
            pcall(function()
                local args = {
                    E.Misc.ChatMessage,
                    "All"
                }
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
            end)
            task.wait(E.Misc.ChatInterval)
        end
        chatSpamThread = nil
    end)
end

local function stopChatSpam()
    chatSpamThread = nil
end

-- ============================================================
-- TELEPORT TO PLAYER (NEW)
-- ============================================================
local function teleportToPlayer(targetName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and (plr.Name:lower():find(targetName:lower()) or plr.DisplayName:lower():find(targetName:lower())) then
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    Exter:Notification({
                        Title = "Teleport",
                        Content = "Teleported to " .. plr.DisplayName,
                        Icon = "check_circle",
                        ImageSource = "Material",
                        Duration = 2
                    })
                    return
                end
            end
        end
    end
    Exter:Notification({
        Title = "Teleport",
        Content = "Player not found!",
        Icon = "error",
        ImageSource = "Material",
        Duration = 2
    })
end

-- ============================================================
-- LOOP ENGINE (OPTIMIZED)
-- ============================================================
RunService.RenderStepped:Connect(function()
    aimbotLoop()
    espLoop()
    flyLoop()
    noclipLoop()
    antiFallLoop()
    applyVisuals()
    godModeLoop()
    noSlowdownLoop()
end)

RunService.Stepped:Connect(function()
    applyMovement()
end)

-- ============================================================
-- UI WINDOW
-- ============================================================
local Window = Exter:CreateWindow({
    Name = "Exter Universal",
    Subtitle = "v2.0 — by SOBING4413 (Fixed & Improved)",
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
    Name = "Smoothness (0 = Instant)",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = E.Aimbot.Smoothness,
    Callback = function(v)
        E.Aimbot.Smoothness = v
        if v == 0 then
            Exter:Notification({Title = "Aimbot", Content = "Smoothness off — instant aim", Icon = "info", ImageSource = "Material", Duration = 2})
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
    Options = {"MouseButton2", "MouseButton1", "E", "Q", "F", "C", "X"},
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

AimbotTab:CreateSection("Prediction")

AimbotTab:CreateToggle({
    Name = "Enable Prediction",
    CurrentValue = E.Aimbot.Prediction,
    Callback = function(v) E.Aimbot.Prediction = v end
}, "AimbotPrediction")

AimbotTab:CreateSlider({
    Name = "Prediction Amount",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = E.Aimbot.PredictionAmount,
    Callback = function(v) E.Aimbot.PredictionAmount = v end
}, "AimbotPredictionAmount")

AimbotTab:CreateSection("FOV Settings")

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 500},
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

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 5000},
    Increment = 50,
    CurrentValue = E.ESP.MaxDistance,
    Callback = function(v) E.ESP.MaxDistance = v end
}, "ESPMaxDistance")

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

MovementTab:CreateSection("Speed & Jump")

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

MovementTab:CreateSection("Fly")

MovementTab:CreateToggle({
    Name = "Enable Fly (WASD + Space/Shift)",
    CurrentValue = E.Movement.Fly,
    Callback = function(v)
        E.Movement.Fly = v
        if not v then stopFly() end
    end
}, "Fly")

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = E.Movement.FlySpeed,
    Callback = function(v) E.Movement.FlySpeed = v end
}, "FlySpeed")

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
    Name = "God Mode (Client-Side)",
    CurrentValue = E.Character.GodMode,
    Callback = function(v) E.Character.GodMode = v end
}, "GodMode")

CharTab:CreateSection("Auto Click")

CharTab:CreateToggle({
    Name = "Auto Click",
    CurrentValue = E.Character.AutoClick,
    Callback = function(v)
        E.Character.AutoClick = v
        if v then
            startAutoClick()
        else
            stopAutoClick()
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

VisualsTab:CreateToggle({
    Name = "Night Mode",
    CurrentValue = E.Visuals.NightMode,
    Callback = function(v)
        E.Visuals.NightMode = v
        if not v then
            Lighting.ClockTime = originalClockTime
        end
    end
}, "NightMode")

-- ============================================================
-- TAB: MISC
-- ============================================================
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "alarm_add" })

MiscTab:CreateSection("Server Options")

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Description = "Kick & rejoin current server",
    Callback = E.Misc.Rejoin
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Description = "Join a different server",
    Callback = serverHop
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = E.Misc.AntiAFK,
    Callback = function(v) E.Misc.AntiAFK = v end
}, "AntiAFK")

MiscTab:CreateSection("Teleport")

MiscTab:CreateInput({
    Name = "Teleport to Player",
    PlaceholderText = "Enter player name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if text and text ~= "" then
            teleportToPlayer(text)
        end
    end
})

MiscTab:CreateSection("Chat Spam")

MiscTab:CreateToggle({
    Name = "Chat Spam",
    CurrentValue = E.Misc.ChatSpam,
    Callback = function(v)
        E.Misc.ChatSpam = v
        if v then
            startChatSpam()
        else
            stopChatSpam()
        end
    end
}, "ChatSpam")

MiscTab:CreateInput({
    Name = "Spam Message",
    PlaceholderText = "Enter message...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if text and text ~= "" then
            E.Misc.ChatMessage = text
        end
    end
})

MiscTab:CreateSlider({
    Name = "Spam Interval (sec)",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = E.Misc.ChatInterval,
    Callback = function(v) E.Misc.ChatInterval = v end
}, "ChatInterval")

MiscTab:CreateSection("Config")

MiscTab:BuildConfigSection()
MiscTab:BuildThemeSection()

MiscTab:CreateSection("Credits")

MiscTab:CreateLabel({ Text = "Exter Universal v2.0" })
MiscTab:CreateLabel({ Text = "Fixed & Improved Edition" })
MiscTab:CreateLabel({ Text = "Powered by Exter Library" })
MiscTab:CreateLabel({ Text = "by SOBING4413" })

-- ============================================================
-- NOTIFICATION STARTUP
-- ============================================================
Exter:Notification({
    Title = "Exter Universal v2.0",
    Content = "Loaded successfully! Press K to toggle menu.\nAll features fixed & working.",
    Icon = "check_circle",
    ImageSource = "Material",
    Duration = 5
})

-- Auto load config
pcall(function()
    Exter:LoadAutoloadConfig()
end)
