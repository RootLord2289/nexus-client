-- Вставь этот код вместо своего или обнови соответствующие части
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Flying, Noclip = false, false
local S3xEnabled, Spin3313Enabled = false, false
local IsSpinning, IsS3xing = false, false
local FlySpeed, WalkSpeed, JumpPower = 50, 16, 50
local SpinSpeed = 3313 
local FlyKey, NoclipKey, MenuKey = Enum.KeyCode.J, Enum.KeyCode.N, Enum.KeyCode.Insert
local S3xKey, SpinKey = Enum.KeyCode.H, Enum.KeyCode.V
local IsBinding = false

-- --- CONFIGS ---
local ESP_Config = { Enabled = false, Boxes = false, Names = false, Health = false, Glow = false, VisCheck = false }
local Aim_Config = { Enabled = false, ShowFOV = false, LMB_Active = false, RMB_Active = false, Radius = 150, Smooth = 0.2, Instant = 1.0 }

local ESP_Objects = {}
local VISIBLE_COLOR = Color3.fromRGB(0, 255, 0)
local HIDDEN_COLOR = Color3.fromRGB(255, 0, 0)

-- FOV Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Aim_Config.Radius
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.5

local HoldingLMB, HoldingRMB = false, false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Sakurasi_V4"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- --- NOTIFY SYSTEM ---
local NotifyFrame = Instance.new("Frame", ScreenGui)
NotifyFrame.Size = UDim2.new(0, 240, 0, 45)
NotifyFrame.Position = UDim2.new(0.5, 0, 0, -100)
NotifyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
NotifyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 10)
local NotifyScale = Instance.new("UIScale", NotifyFrame)
NotifyScale.Scale = 0 
local NotifyLabel = Instance.new("TextLabel", NotifyFrame)
NotifyLabel.Size = UDim2.new(1, 0, 1, 0)
NotifyLabel.BackgroundTransparency = 1
NotifyLabel.TextColor3 = Color3.new(1, 1, 1)
NotifyLabel.Font = Enum.Font.GothamBold
NotifyLabel.TextSize = 14
NotifyLabel.RichText = true

local activeTweenPos, activeTweenScale
local notifyTimer = 0

local function ShowNotify(feature, status, isEnabled)
    local statusColor = isEnabled and "rgb(46, 204, 113)" or "rgb(231, 76, 60)"
    NotifyLabel.Text = status == "" and feature or feature .. ": <font color='" .. statusColor .. "'>" .. status .. "</font>"
    if activeTweenPos then activeTweenPos:Cancel() end
    if activeTweenScale then activeTweenScale:Cancel() end
    activeTweenPos = TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, -20)})
    activeTweenScale = TweenService:Create(NotifyScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
    activeTweenPos:Play(); activeTweenScale:Play()
    local currentTimer = tick()
    notifyTimer = currentTimer
    task.delay(1.5, function()
        if notifyTimer == currentTimer then
            activeTweenPos = TweenService:Create(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -100)})
            activeTweenScale = TweenService:Create(NotifyScale, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0})
            activeTweenPos:Play(); activeTweenScale:Play()
        end
    end)
end

-- --- AIMBOT HELPERS ---
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = Aim_Config.Radius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- --- ESP HELPERS ---
local function isVisible(targetPart)
    if not targetPart then return false end
    local char = Player.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1; box.Filled = false; box.Visible = false
    local healthText = Drawing.new("Text")
    healthText.Size = 14; healthText.Center = true; healthText.Outline = true; healthText.Visible = false
    local nameText = Drawing.new("Text")
    nameText.Size = 14; nameText.Center = true; nameText.Outline = true; nameText.Visible = false; nameText.Text = player.Name
    ESP_Objects[player] = {Box = box, Health = healthText, Name = nameText}
end

local function removeESP(p)
    if ESP_Objects[p] then
        ESP_Objects[p].Box:Remove()
        ESP_Objects[p].Health:Remove()
        ESP_Objects[p].Name:Remove()
        ESP_Objects[p] = nil
    end
    if p.Character and p.Character:FindFirstChild("SakurasiGlow") then p.Character.SakurasiGlow:Destroy() end
end

-- --- MENU UI ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainScale = Instance.new("UIScale", MainFrame)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -130, 1, -45)
ContentFrame.Position = UDim2.new(0, 125, 0, 40)
ContentFrame.BackgroundTransparency = 1

local Pages = { Movement = Instance.new("Frame", ContentFrame), Visuals = Instance.new("Frame", ContentFrame), Combat = Instance.new("Frame", ContentFrame), Keybinds = Instance.new("Frame", ContentFrame), Fun = Instance.new("Frame", ContentFrame) }
for name, frame in pairs(Pages) do
    frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.Visible = (name == "Movement")
end

local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, pos); btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); btn.BackgroundTransparency = (name == "Movement") and 0 or 1
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.Name = name
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        for pName, p in pairs(Pages) do
            p.Visible = (pName == name)
            if Sidebar:FindFirstChild(pName) then Sidebar[pName].BackgroundTransparency = (pName == name) and 0 or 1 end
        end
    end)
end

CreateTab("Movement", 15); CreateTab("Visuals", 55); CreateTab("Combat", 95); CreateTab("Keybinds", 135); CreateTab("Fun", 175)

local function CreateToggle(text, pos, default, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 210, 0, 30); btn.Position = pos
    btn.BackgroundColor3 = default and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state; btn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
        btn.Text = text .. ": " .. (state and "ON" or "OFF"); callback(state)
    end)
    return btn
end

local function CreateInput(text, pos, default, parent, callback)
    local Label = Instance.new("TextLabel", parent); Label.Text = text; Label.Size = UDim2.new(0, 100, 0, 30); Label.Position = pos; Label.TextColor3 = Color3.new(1, 1, 1); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.GothamBold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
    local Input = Instance.new("TextBox", parent); Input.Size = UDim2.new(0, 100, 0, 30); Input.Position = pos + UDim2.new(0, 110, 0, 0); Input.Text = tostring(default); Input.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Input.TextColor3 = Color3.new(1, 1, 1); Input.Font = Enum.Font.GothamBold; Input.TextSize = 14; Input.ClearTextOnFocus = false; Instance.new("UICorner", Input)
    Input.FocusLost:Connect(function() local num = tonumber(Input.Text) if num then callback(num) end end)
end

local function CreateBind(text, pos, defaultKey, parent, callback)
    local Label = Instance.new("TextLabel", parent); Label.Text = text; Label.Size = UDim2.new(0, 100, 0, 30); Label.Position = pos; Label.TextColor3 = Color3.new(1, 1, 1); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.GothamBold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
    local BindBtn = Instance.new("TextButton", parent); BindBtn.Size = UDim2.new(0, 100, 0, 30); BindBtn.Position = pos + UDim2.new(0, 110, 0, 0); BindBtn.Text = defaultKey.Name; BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); BindBtn.TextColor3 = Color3.new(1, 1, 1); BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextSize = 12; Instance.new("UICorner", BindBtn)
    BindBtn.MouseButton1Click:Connect(function() if IsBinding then return end IsBinding = true; BindBtn.Text = "..."; local conn; conn = UIS.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then BindBtn.Text = i.KeyCode.Name; callback(i.KeyCode); conn:Disconnect(); task.wait(0.1); IsBinding = false end end) end)
end

-- --- PAGE CONTENT ---
-- Movement
CreateInput("SPEED", UDim2.new(0, 10, 0, 10), WalkSpeed, Pages.Movement, function(v) WalkSpeed = v end)
CreateInput("SPIN SPEED", UDim2.new(0, 10, 0, 45), SpinSpeed, Pages.Movement, function(v) SpinSpeed = v end)
CreateInput("JUMP", UDim2.new(0, 10, 0, 80), JumpPower, Pages.Movement, function(v) JumpPower = v end)
CreateInput("FLY SPD", UDim2.new(0, 10, 0, 115), FlySpeed, Pages.Movement, function(v) FlySpeed = v end)

-- Visuals
CreateToggle("ESP MASTER", UDim2.new(0, 10, 0, 10), false, Pages.Visuals, function(s) ESP_Config.Enabled = s if not s then for _, p in pairs(Players:GetPlayers()) do removeESP(p) end end end)
CreateToggle("Show Boxes", UDim2.new(0, 10, 0, 45), false, Pages.Visuals, function(s) ESP_Config.Boxes = s end)
CreateToggle("Show Names", UDim2.new(0, 10, 0, 80), false, Pages.Visuals, function(s) ESP_Config.Names = s end)
CreateToggle("Show Health", UDim2.new(0, 10, 0, 115), false, Pages.Visuals, function(s) ESP_Config.Health = s end)
CreateToggle("Glow (Highlight)", UDim2.new(0, 10, 0, 150), false, Pages.Visuals, function(s) ESP_Config.Glow = s end)
CreateToggle("Wall Check", UDim2.new(0, 10, 0, 185), false, Pages.Visuals, function(s) ESP_Config.VisCheck = s end)

-- Combat (Aimbot)
CreateToggle("AIMBOT MASTER", UDim2.new(0, 10, 0, 10), false, Pages.Combat, function(s) Aim_Config.Enabled = s end)
CreateToggle("Show FOV Circle", UDim2.new(0, 10, 0, 45), false, Pages.Combat, function(s) Aim_Config.ShowFOV = s end)
CreateToggle("LMB (Instant)", UDim2.new(0, 10, 0, 80), false, Pages.Combat, function(s) Aim_Config.LMB_Active = s end)
CreateToggle("RMB (Smooth)", UDim2.new(0, 10, 0, 115), false, Pages.Combat, function(s) Aim_Config.RMB_Active = s end)
CreateInput("FOV Radius", UDim2.new(0, 10, 0, 150), Aim_Config.Radius, Pages.Combat, function(v) Aim_Config.Radius = v FOVCircle.Radius = v end)

-- Keybinds
CreateBind("FLY KEY", UDim2.new(0, 10, 0, 10), FlyKey, Pages.Keybinds, function(k) FlyKey = k end)
CreateBind("NOCLIP", UDim2.new(0, 10, 0, 45), NoclipKey, Pages.Keybinds, function(k) NoclipKey = k end)
CreateBind("S3X KEY", UDim2.new(0, 10, 0, 80), S3xKey, Pages.Keybinds, function(k) S3xKey = k end)
CreateBind("3313 KEY", UDim2.new(0, 10, 0, 115), SpinKey, Pages.Keybinds, function(k) SpinKey = k end)
CreateBind("MENU", UDim2.new(0, 10, 0, 150), MenuKey, Pages.Keybinds, function(k) MenuKey = k end)

-- Fun
CreateToggle("S3X", UDim2.new(0, 10, 0, 10), false, Pages.Fun, function(s) S3xEnabled = s if not s then IsS3xing = false end end)
CreateToggle("3313 SPIN", UDim2.new(0, 10, 0, 45), false, Pages.Fun, function(s) Spin3313Enabled = s if not s then IsSpinning = false end end)

-- --- MAIN LOGIC LOOP ---
RunService.Stepped:Connect(function()
    if Noclip and Player.Character then for _, v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = WalkSpeed; Player.Character.Humanoid.JumpPower = JumpPower end
    if IsSpinning and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(SpinSpeed/60), 0) end
    if IsS3xing and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local t, d = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local dist = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude if dist < d then t, d = p, dist end end end
        if t then Player.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1 + math.sin(tick()*25)*1.5) end
    end
end)

RunService.RenderStepped:Connect(function()
    -- FOV Position & Visibility
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = Aim_Config.Enabled and Aim_Config.ShowFOV

    -- AIMBOT LOGIC
    if Aim_Config.Enabled then
        if (Aim_Config.LMB_Active and HoldingLMB) or (Aim_Config.RMB_Active and HoldingRMB) then
            local target = getClosestPlayerInFOV()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local speed = (Aim_Config.LMB_Active and HoldingLMB) and Aim_Config.Instant or Aim_Config.Smooth
                local targetPos = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetPos, speed)
            end
        end
    end

    -- FLY LOGIC
    if Flying and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        if hrp:FindFirstChild("FlyV") then
            local move = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            hrp.FlyV.Velocity = move * FlySpeed; hrp.FlyG.CFrame = Camera.CFrame
        end
    end

    -- ESP LOGIC (Integrated from your original)
    if ESP_Config.Enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player then
                if not ESP_Objects[p] then createESP(p) end
                local obj = ESP_Objects[p]
                local char = p.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local root = char.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local visible = isVisible(char:FindFirstChild("Head"))
                        local color = (ESP_Config.VisCheck and not visible) and HIDDEN_COLOR or VISIBLE_COLOR
                        
                        if ESP_Config.Boxes then
                            local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                            obj.Box.Size = Vector2.new(3 * scale, 4.5 * scale); obj.Box.Position = Vector2.new(pos.X - (3 * scale)/2, pos.Y - (4.5 * scale)/2)
                            obj.Box.Color = color; obj.Box.Visible = true
                        else obj.Box.Visible = false end
                        
                        obj.Name.Visible = ESP_Config.Names
                        if ESP_Config.Names then obj.Name.Position = Vector2.new(pos.X, pos.Y - 40); obj.Name.Color = color end
                        
                        obj.Health.Visible = ESP_Config.Health
                        if ESP_Config.Health then 
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            obj.Health.Text = math.floor(hum.Health) .. "%"; 
                            obj.Health.Position = Vector2.new(pos.X, pos.Y - 25); 
                            obj.Health.Color = Color3.fromHSV(hum.Health/300, 1, 1) 
                        end
                        
                        if ESP_Config.Glow then
                            local g = char:FindFirstChild("SakurasiGlow") or Instance.new("Highlight", char); g.Name = "SakurasiGlow"; g.OutlineColor = color; g.FillColor = color; g.FillTransparency = 0.5
                        elseif char:FindFirstChild("SakurasiGlow") then char.SakurasiGlow:Destroy() end
                    else obj.Box.Visible = false; obj.Name.Visible = false; obj.Health.Visible = false end
                else obj.Box.Visible = false; obj.Name.Visible = false; obj.Health.Visible = false end
            end
        end
    end
end)

-- --- INPUT HANDLING ---
UIS.InputBegan:Connect(function(i, gpe)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then HoldingLMB = true end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRMB = true end
    if gpe or IsBinding then return end
    
    local char = Player.Character
    if i.KeyCode == MenuKey then 
        MainFrame.Visible = not MainFrame.Visible
        MainScale.Scale = MainFrame.Visible and 1 or 0
    elseif i.KeyCode == FlyKey and char and char:FindFirstChild("HumanoidRootPart") then
        Flying = not Flying
        if Flying then
            local bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.Name = "FlyV"; bv.MaxForce = Vector3.new(1e6,1e6,1e6)
            local bg = Instance.new("BodyGyro", char.HumanoidRootPart); bg.Name = "FlyG"; bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
            char.Humanoid.PlatformStand = true
        else
            char.Humanoid.PlatformStand = false
            if char.HumanoidRootPart:FindFirstChild("FlyV") then char.HumanoidRootPart.FlyV:Destroy() end
            if char.HumanoidRootPart:FindFirstChild("FlyG") then char.HumanoidRootPart.FlyG:Destroy() end
        end
        ShowNotify("Fly", Flying and "ON" or "OFF", Flying)
    elseif i.KeyCode == NoclipKey then Noclip = not Noclip; ShowNotify("Noclip", Noclip and "ON" or "OFF", Noclip)
    elseif i.KeyCode == S3xKey then if not S3xEnabled then ShowNotify("Enable S3X in menu!", "", false) else IsS3xing = not IsS3xing; ShowNotify("S3X", IsS3xing and "ON" or "OFF", IsS3xing) end
    elseif i.KeyCode == SpinKey then if not Spin3313Enabled then ShowNotify("Enable 3313 in menu!", "", false) else IsSpinning = not IsSpinning; ShowNotify("3313 Spin", IsSpinning and "ON" or "OFF", IsSpinning) end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then HoldingLMB = false end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRMB = false end
end)

Players.PlayerRemoving:Connect(removeESP)
ShowNotify("Nexus Loaded", "Sakurasi Edition", true)
