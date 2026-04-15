local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local Flying, Noclip = false, false
local S3xEnabled, Spin3313Enabled = false, false
local IsSpinning, IsS3xing = false, false
local FlySpeed, WalkSpeed, JumpPower = 50, 16, 50
local SpinSpeed = 3313 
local FlyKey, NoclipKey, MenuKey = Enum.KeyCode.J, Enum.KeyCode.N, Enum.KeyCode.Insert
local S3xKey, SpinKey = Enum.KeyCode.H, Enum.KeyCode.V
local IsBinding = false

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
NotifyFrame.BorderSizePixel = 0
NotifyFrame.ZIndex = 1000
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
NotifyLabel.ZIndex = 1001

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

-- --- MAIN MENU ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
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

local Pages = { Movement = Instance.new("Frame", ContentFrame), Keybinds = Instance.new("Frame", ContentFrame), Fun = Instance.new("Frame", ContentFrame) }
for name, frame in pairs(Pages) do
    frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.Visible = (name == "Movement")
end

local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 40); btn.Position = UDim2.new(0.05, 0, 0, pos); btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); btn.BackgroundTransparency = (name == "Movement") and 0 or 1
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        for pName, p in pairs(Pages) do
            p.Visible = (pName == name)
            if Sidebar:FindFirstChild(pName) then Sidebar[pName].BackgroundTransparency = (pName == name) and 0 or 1 end
        end
    end)
    btn.Name = name
end

CreateTab("Movement", 15); CreateTab("Keybinds", 65); CreateTab("Fun", 115)

local function CreateToggle(text, pos, default, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 210, 0, 35); btn.Position = pos
    btn.BackgroundColor3 = default and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state; btn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
        btn.Text = text .. ": " .. (state and "ON" or "OFF"); callback(state)
    end)
end

local function CreateInput(text, pos, default, parent, callback)
    local Label = Instance.new("TextLabel", parent)
    Label.Text = text; Label.Size = UDim2.new(0, 100, 0, 35); Label.Position = pos; Label.TextColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1; Label.Font = Enum.Font.GothamBold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Input = Instance.new("TextBox", parent)
    Input.Size = UDim2.new(0, 100, 0, 35); Input.Position = pos + UDim2.new(0, 110, 0, 0); Input.Text = tostring(default)
    Input.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Input.TextColor3 = Color3.new(1, 1, 1); Input.Font = Enum.Font.GothamBold; Input.TextSize = 16
    Input.ClearTextOnFocus = false -- ВОТ ЭТО ОСТАВЛЯЕТ ТЕКСТ ПРИ КЛИКЕ
    Instance.new("UICorner", Input)
    
    local lastValidValue = tostring(default)
    
    Input:GetPropertyChangedSignal("Text"):Connect(function()
        local filtered = Input.Text:gsub("%D", "") -- Только цифры
        if filtered ~= Input.Text then
            Input.Text = filtered
        end
    end)

    Input.FocusLost:Connect(function()
        local num = tonumber(Input.Text)
        if num then
            lastValidValue = Input.Text
            callback(num)
        else
            Input.Text = lastValidValue -- Возвращает старое, если стер всё
        end
    end)
end

local function CreateBind(text, pos, defaultKey, parent, callback)
    local Label = Instance.new("TextLabel", parent)
    Label.Text = text; Label.Size = UDim2.new(0, 100, 0, 35); Label.Position = pos; Label.TextColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1; Label.Font = Enum.Font.GothamBold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local BindBtn = Instance.new("TextButton", parent)
    BindBtn.Size = UDim2.new(0, 100, 0, 35); BindBtn.Position = pos + UDim2.new(0, 110, 0, 0); BindBtn.Text = defaultKey.Name
    BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); BindBtn.TextColor3 = Color3.new(1, 1, 1); BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextSize = 14
    Instance.new("UICorner", BindBtn)
    BindBtn.MouseButton1Click:Connect(function()
        if IsBinding then return end
        IsBinding, BindBtn.Text = true, "..."
        local conn; conn = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                BindBtn.Text = i.KeyCode.Name; callback(i.KeyCode); conn:Disconnect(); task.wait(0.1); IsBinding = false
            end
        end)
    end)
end

-- --- SETTINGS ---
CreateInput("SPEED", UDim2.new(0, 10, 0, 10), WalkSpeed, Pages.Movement, function(v) WalkSpeed = v end)
CreateInput("SPIN SPEED", UDim2.new(0, 10, 0, 50), SpinSpeed, Pages.Movement, function(v) SpinSpeed = v end)
CreateInput("JUMP", UDim2.new(0, 10, 0, 90), JumpPower, Pages.Movement, function(v) JumpPower = v end)
CreateInput("FLY SPD", UDim2.new(0, 10, 0, 130), FlySpeed, Pages.Movement, function(v) FlySpeed = v end)

CreateBind("FLY KEY", UDim2.new(0, 10, 0, 10), FlyKey, Pages.Keybinds, function(k) FlyKey = k end)
CreateBind("NOCLIP", UDim2.new(0, 10, 0, 50), NoclipKey, Pages.Keybinds, function(k) NoclipKey = k end)
CreateBind("S3X KEY", UDim2.new(0, 10, 0, 90), S3xKey, Pages.Keybinds, function(k) S3xKey = k end)
CreateBind("3313 KEY", UDim2.new(0, 10, 0, 130), SpinKey, Pages.Keybinds, function(k) SpinKey = k end)
CreateBind("MENU", UDim2.new(0, 10, 0, 170), MenuKey, Pages.Keybinds, function(k) MenuKey = k end)

CreateToggle("S3X", UDim2.new(0, 10, 0, 10), false, Pages.Fun, function(s) S3xEnabled = s if not s then IsS3xing = false end end)
CreateToggle("3313 SPIN", UDim2.new(0, 10, 0, 55), false, Pages.Fun, function(s) Spin3313Enabled = s if not s then IsSpinning = false end end)

local menuVisible = true
local function ToggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        MainFrame.Visible = true
        TweenService:Create(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    else
        local t = TweenService:Create(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        t:Play(); t.Completed:Connect(function() if not menuVisible then MainFrame.Visible = false end end)
    end
end

-- --- LOGIC ---
RunService.Stepped:Connect(function()
    if Noclip and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = WalkSpeed; Player.Character.Humanoid.JumpPower = JumpPower
    end
    if IsSpinning and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(SpinSpeed/60), 0)
    end
    if IsS3xing and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local t = nil; local d = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < d then t, d = p, dist end
            end
        end
        if t then Player.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1 + math.sin(tick()*25)*1.5) end
    end
end)

-- --- FLY RENDER ---
RunService.RenderStepped:Connect(function()
    if Flying and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        if hrp:FindFirstChild("FlyV") then
            local cam = workspace.CurrentCamera
            local move = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            hrp.FlyV.Velocity = move * FlySpeed
            hrp.FlyG.CFrame = cam.CFrame
        end
    end
end)

UIS.InputBegan:Connect(function(i, gpe)
    if gpe or IsBinding then return end
    local char = Player.Character
    if i.KeyCode == MenuKey then ToggleMenu()
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
    elseif i.KeyCode == S3xKey then
        if not S3xEnabled then ShowNotify("Enable S3X in menu first!", "", false) else IsS3xing = not IsS3xing; ShowNotify("S3X", IsS3xing and "ON" or "OFF", IsS3xing) end
    elseif i.KeyCode == SpinKey then
        if not Spin3313Enabled then ShowNotify("Enable 3313 in menu first!", "", false) else IsSpinning = not IsSpinning; ShowNotify("3313 Spin", IsSpinning and "ON" or "OFF", IsSpinning) end
    end
end)

ShowNotify("Nexus Loaded", "", true)
