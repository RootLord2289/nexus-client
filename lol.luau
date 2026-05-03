local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Flying, Noclip = false, false
local Spin3313Enabled = false
local IsSpinning = false
local FlySpeed, WalkSpeed, JumpPower = 50, 16, 50
local SpinSpeed = 3313
local FlyKey, NoclipKey, MenuKey = Enum.KeyCode.J, Enum.KeyCode.N, Enum.KeyCode.Insert
local SpinKey = Enum.KeyCode.V
local SpamKey = Enum.KeyCode.M
local IsBinding = false
-- --- CONFIGS ---
local ESP_Config = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Health = false,
    Glow = false,
    VisCheck = false
}
local Aim_Config = {
    Enabled = false,
    ShowFOV = false,
    LMB_Active = false,
    RMB_Active = false,
    Radius = 150,
    Smooth = 0.2,
    Instant = 1.0
}
-- --- CHEATS LIST CONFIG ---
local List_Config = {
    Enabled = false,
    Position = "TopRight"
}
local ActiveLabels = {}
local ESP_Objects = {}
local VISIBLE_COLOR = Color3.fromRGB(0, 255, 0)
local HIDDEN_COLOR = Color3.fromRGB(255, 0, 0)
local HoldingLMB, HoldingRMB = false, false
-- --- SPAM CONFIG ---
local ChatSpamEnabled = false
local ChatSpamDelay = 0.7
local ChatMessage = "Nexus is Boosting"
local function randomString(len)
    local chars = "abcdefghijklmnopqrstuvwxyz"
    local str = ""
    for i = 1, len do
        str = str .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return str
end
local function getBypassedMessage(msg)
    local styles = {
        function() return msg .. " ." end,
        function() return msg .. " .." end,
        function() return msg .. " ..." end,
        function() return msg .. " " .. randomString(math.random(2,5)) end,
        function() return msg .. " [" .. randomString(3) .. "]" end,
        function() return msg .. " |" .. randomString(2) end,
        function() return msg .. " <" .. randomString(3) .. ">" end,
    }
    return styles[math.random(1, #styles)]()
end
task.spawn(function()
    while task.wait(ChatSpamDelay) do
        if not ChatSpamEnabled then continue end
        local finalMsg = getBypassedMessage(ChatMessage)
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            pcall(function()
                tcs.TextChannels.RBXGeneral:SendAsync(finalMsg)
            end)
        else
            pcall(function()
                game:GetService("ReplicatedStorage")
                    .DefaultChatSystemChatEvents
                    .SayMessageRequest:FireServer(finalMsg, "All")
            end)
        end
    end
end)
-- ==================== THEMES SYSTEM ====================
local CurrentTheme = {
    Background = Color3.fromRGB(25, 25, 25),
    Secondary = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(46, 204, 113)
}
local Themes = {
    ["Dark Emerald"] = {Bg = Color3.fromRGB(15, 15, 15), Sec = Color3.fromRGB(25, 25, 25), Txt = Color3.fromRGB(240, 240, 240), Acc = Color3.fromRGB(46, 204, 113)},
    ["Midnight Purple"] = {Bg = Color3.fromRGB(15, 10, 25), Sec = Color3.fromRGB(25, 20, 40), Txt = Color3.fromRGB(255, 255, 255), Acc = Color3.fromRGB(155, 89, 182)},
    ["Ocean Blue"] = {Bg = Color3.fromRGB(10, 20, 30), Sec = Color3.fromRGB(20, 35, 50), Txt = Color3.fromRGB(230, 240, 255), Acc = Color3.fromRGB(52, 152, 219)},
    ["Crimson Red"] = {Bg = Color3.fromRGB(20, 5, 5), Sec = Color3.fromRGB(40, 15, 15), Txt = Color3.fromRGB(255, 220, 220), Acc = Color3.fromRGB(231, 76, 60)},
    ["Sakura Pink"] = {Bg = Color3.fromRGB(30, 15, 25), Sec = Color3.fromRGB(50, 25, 40), Txt = Color3.fromRGB(255, 240, 245), Acc = Color3.fromRGB(255, 105, 180)},
    ["Golden Amber"] = {Bg = Color3.fromRGB(20, 18, 10), Sec = Color3.fromRGB(35, 30, 15), Txt = Color3.fromRGB(255, 250, 230), Acc = Color3.fromRGB(241, 196, 15)},
    ["Steel Gray"] = {Bg = Color3.fromRGB(30, 30, 35), Sec = Color3.fromRGB(45, 45, 55), Txt = Color3.fromRGB(255, 255, 255), Acc = Color3.fromRGB(149, 165, 166)}
}
local UI_Elements = {
    Backgrounds = {},
    Secondary = {},
    Texts = {},
    Accents = {}
}
local function ApplyTheme(themeName)
    local t = Themes[themeName]
    if not t then return end
    CurrentTheme.Background = t.Bg
    CurrentTheme.Secondary = t.Sec
    CurrentTheme.Text = t.Txt
    CurrentTheme.Accent = t.Acc
    for _, obj in pairs(UI_Elements.Backgrounds) do
        obj.BackgroundColor3 = t.Bg
    end
    for _, obj in pairs(UI_Elements.Secondary) do
        if obj:GetAttribute("Active") then
            obj.BackgroundColor3 = t.Acc
        else
            obj.BackgroundColor3 = t.Sec
        end
    end
    for _, obj in pairs(UI_Elements.Texts) do
        obj.TextColor3 = t.Txt
    end
    for _, container in pairs(ActiveLabels) do
        container.BackgroundColor3 = t.Sec
        local lbl = container:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.TextColor3 = t.Txt
            local cleanName = lbl.Text:split(":")[1]
            lbl.Text = cleanName .. ": <font color='rgb(" .. math.floor(t.Acc.R*255) .. "," .. math.floor(t.Acc.G*255) .. "," .. math.floor(t.Acc.B*255) .. ")'>ON</font>"
        end
    end
    NotifyFrame.BackgroundColor3 = t.Sec
    NotifyLabel.TextColor3 = t.Txt
end
-- ==================== FOV CIRCLE ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Aim_Config.Radius
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.5
-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nexus"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
-- ==================== CHEATS LIST UI ====================
local ListFrame = Instance.new("Frame", ScreenGui)
ListFrame.Size = UDim2.new(0, 250, 0, 500)
ListFrame.BackgroundTransparency = 1
ListFrame.Visible = false
local ListLayout = Instance.new("UIListLayout", ListFrame)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
local function UpdateListPos()
    if List_Config.Position == "TopLeft" then
        ListFrame.Position = UDim2.new(0, 15, 0, 15)
        ListFrame.AnchorPoint = Vector2.new(0, 0)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    elseif List_Config.Position == "TopRight" then
        ListFrame.Position = UDim2.new(1, -15, 0, 15)
        ListFrame.AnchorPoint = Vector2.new(1, 0)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    elseif List_Config.Position == "BottomLeft" then
        ListFrame.Position = UDim2.new(0, 15, 1, -15)
        ListFrame.AnchorPoint = Vector2.new(0, 1)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    elseif List_Config.Position == "BottomRight" then
        ListFrame.Position = UDim2.new(1, -15, 1, -15)
        ListFrame.AnchorPoint = Vector2.new(1, 1)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    end
end
local function UpdateCheatList(name, state)
    if state and List_Config.Enabled then
        if not ActiveLabels[name] then
            local container = Instance.new("Frame", ListFrame)
            container.AutomaticSize = Enum.AutomaticSize.X
            container.Size = UDim2.new(0, 0, 0, 0)
            container.ClipsDescendants = true
            container.BackgroundColor3 = CurrentTheme.Secondary
            container.BackgroundTransparency = 1
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            local padding = Instance.new("UIPadding", container)
            padding.PaddingLeft = UDim.new(0, 12); padding.PaddingRight = UDim.new(0, 12)
            local acc = CurrentTheme.Accent
            local accStr = "rgb(" .. math.floor(acc.R*255) .. "," .. math.floor(acc.G*255) .. "," .. math.floor(acc.B*255) .. ")"
            local Label = Instance.new("TextLabel", container)
            Label.AutomaticSize = Enum.AutomaticSize.X
            Label.Size = UDim2.new(0, 0, 0, 32)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = CurrentTheme.Text
            Label.TextTransparency = 1
            Label.TextSize = 15
            Label.Font = Enum.Font.GothamBold
            Label.RichText = true
            Label.Text = name .. ": <font color='" .. accStr .. "'>ON</font>"
            table.insert(UI_Elements.Secondary, container)
            table.insert(UI_Elements.Texts, Label)
            ActiveLabels[name] = container
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 0, 32), BackgroundTransparency = 0 }):Play()
            TweenService:Create(Label, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
        end
    else
        if ActiveLabels[name] then
            local item = ActiveLabels[name]
            ActiveLabels[name] = nil
            local t1 = TweenService:Create(item, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
            local t2 = TweenService:Create(item:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { TextTransparency = 1 })
            t1:Play(); t2:Play()
            t1.Completed:Connect(function() item:Destroy() end)
        end
    end
end
-- ==================== NOTIFY SYSTEM ====================
local NotifyFrame = Instance.new("Frame", ScreenGui)
NotifyFrame.Size = UDim2.new(0, 240, 0, 45)
NotifyFrame.Position = UDim2.new(0.5, 0, 0, -100)
NotifyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
NotifyFrame.BackgroundColor3 = CurrentTheme.Secondary
Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 10)
table.insert(UI_Elements.Backgrounds, NotifyFrame)
local NotifyScale = Instance.new("UIScale", NotifyFrame)
NotifyScale.Scale = 0
local NotifyLabel = Instance.new("TextLabel", NotifyFrame)
NotifyLabel.Size = UDim2.new(1, 0, 1, 0)
NotifyLabel.BackgroundTransparency = 1
NotifyLabel.TextColor3 = CurrentTheme.Text
NotifyLabel.Font = Enum.Font.GothamBold
NotifyLabel.TextSize = 14
NotifyLabel.RichText = true
table.insert(UI_Elements.Texts, NotifyLabel)
local activeTweenPos, activeTweenScale
local notifyTimer = 0
local function ShowNotify(feature, status, isEnabled)
    local acc = CurrentTheme.Accent
    local accStr = "rgb(" .. math.floor(acc.R*255) .. "," .. math.floor(acc.G*255) .. "," .. math.floor(acc.B*255) .. ")"
    local statusColor = isEnabled and accStr or "rgb(231, 76, 60)"
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
-- ==================== AIMBOT & ESP FUNCTIONS ====================
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
local function isVisible(targetPart)
    if not targetPart then return false end
    local char = Player.Character
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
    if p.Character and p.Character:FindFirstChild("SakurasiGlow") then
        p.Character.SakurasiGlow:Destroy()
    end
end
-- ==================== MAIN UI ====================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = CurrentTheme.Background
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
table.insert(UI_Elements.Backgrounds, MainFrame)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
-- ==================== LOGO ====================
local LogoFrame = Instance.new("Frame", Sidebar)
LogoFrame.Size = UDim2.new(1, 0, 0, 50)
LogoFrame.Position = UDim2.new(0, 0, 0, 0)
LogoFrame.BackgroundTransparency = 1
local LogoText = Instance.new("TextLabel", LogoFrame)
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "NEXUS"
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 24
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextXAlignment = Enum.TextXAlignment.Center
local LogoGradient = Instance.new("UIGradient", LogoText)
LogoGradient.Rotation = 45
task.spawn(function()
    local counter = 0
    while task.wait(0.05) do
        counter = counter + 0.05
        if counter > 1 then counter = 0 end
        LogoGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(counter, 0.6, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((counter + 0.1) % 1, 0.6, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((counter + 0.2) % 1, 0.6, 1))
        })
    end
end)
local LogoStroke = Instance.new("UIStroke", LogoText)
LogoStroke.Color = CurrentTheme.Accent
LogoStroke.Thickness = 1
LogoStroke.Transparency = 0.5
table.insert(UI_Elements.Backgrounds, Sidebar)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -130, 1, -45)
ContentFrame.Position = UDim2.new(0, 125, 0, 40)
ContentFrame.BackgroundTransparency = 1
local Pages = {
    Movement = Instance.new("Frame", ContentFrame),
    Visuals = Instance.new("ScrollingFrame", ContentFrame),
    Combat = Instance.new("Frame", ContentFrame),
    Keybinds = Instance.new("Frame", ContentFrame),
    Fun = Instance.new("ScrollingFrame", ContentFrame),
    Themes = Instance.new("ScrollingFrame", ContentFrame)
}
for name, frame in pairs(Pages) do
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = (name == "Movement")
    if frame:IsA("ScrollingFrame") then
        frame.ScrollBarThickness = 2
        frame.CanvasSize = UDim2.new(0, 0, 0, name == "Themes" and 300 or (name == "Fun" and 350 or 450))
        frame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    end
end
local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.Text = name
    btn.BackgroundColor3 = (name == "Movement") and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = (name == "Movement") and 0 or 1
    btn.TextColor3 = CurrentTheme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Name = name
    Instance.new("UICorner", btn)
    table.insert(UI_Elements.Secondary, btn)
    table.insert(UI_Elements.Texts, btn)
    btn.MouseButton1Click:Connect(function()
        for pName, p in pairs(Pages) do
            p.Visible = (pName == name)
            local tabBtn = Sidebar:FindFirstChild(pName)
            if tabBtn then
                tabBtn.BackgroundTransparency = (pName == name) and 0 or 1
            end
        end
    end)
end
CreateTab("Movement", 65)
CreateTab("Visuals", 105)
CreateTab("Combat", 145)
CreateTab("Keybinds", 185)
CreateTab("Fun", 225)
CreateTab("Themes", 265)
-- ==================== UI CREATORS ====================
local function CreateToggle(text, pos, default, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 210, 0, 30)
    btn.Position = pos
    btn:SetAttribute("Active", default)
    btn.BackgroundColor3 = default and CurrentTheme.Accent or CurrentTheme.Secondary
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = CurrentTheme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn)
    table.insert(UI_Elements.Secondary, btn)
    table.insert(UI_Elements.Texts, btn)
    btn.MouseButton1Click:Connect(function()
        local currentState = btn:GetAttribute("Active") or false
        local newState = not currentState
        btn:SetAttribute("Active", newState)
        btn.BackgroundColor3 = newState and CurrentTheme.Accent or CurrentTheme.Secondary
        btn.Text = text .. ": " .. (newState and "ON" or "OFF")
        callback(newState)
    end)
    return btn
end
local function CreateInput(text, pos, default, parent, callback)
    local Label = Instance.new("TextLabel", parent)
    Label.Text = text
    Label.Size = UDim2.new(0, 100, 0, 30)
    Label.Position = pos
    Label.TextColor3 = CurrentTheme.Text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(UI_Elements.Texts, Label)
    local Input = Instance.new("TextBox", parent)
    Input.Size = UDim2.new(0, 100, 0, 30)
    Input.Position = pos + UDim2.new(0, 110, 0, 0)
    Input.Text = tostring(default)
    Input.BackgroundColor3 = CurrentTheme.Secondary
    Input.TextColor3 = CurrentTheme.Text
    Input.Font = Enum.Font.GothamBold
    Input.TextSize = 14
    Input.ClearTextOnFocus = false
    Instance.new("UICorner", Input)
    table.insert(UI_Elements.Secondary, Input)
    table.insert(UI_Elements.Texts, Input)
    Input.FocusLost:Connect(function()
        local num = tonumber(Input.Text)
        if num then callback(num) end
    end)
end
local function CreateBind(text, pos, defaultKey, parent, callback)
    local Label = Instance.new("TextLabel", parent)
    Label.Text = text
    Label.Size = UDim2.new(0, 100, 0, 30)
    Label.Position = pos
    Label.TextColor3 = CurrentTheme.Text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(UI_Elements.Texts, Label)
    local BindBtn = Instance.new("TextButton", parent)
    BindBtn.Size = UDim2.new(0, 100, 0, 30)
    BindBtn.Position = pos + UDim2.new(0, 110, 0, 0)
    BindBtn.Text = defaultKey.Name
    BindBtn.BackgroundColor3 = CurrentTheme.Secondary
    BindBtn.TextColor3 = CurrentTheme.Text
    BindBtn.Font = Enum.Font.GothamBold
    BindBtn.TextSize = 12
    Instance.new("UICorner", BindBtn)
    table.insert(UI_Elements.Secondary, BindBtn)
    table.insert(UI_Elements.Texts, BindBtn)
    BindBtn.MouseButton1Click:Connect(function()
        if IsBinding then return end
        IsBinding = true
        BindBtn.Text = "..."
        local conn
        conn = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                BindBtn.Text = i.KeyCode.Name
                callback(i.KeyCode)
                conn:Disconnect()
                task.wait(0.1)
                IsBinding = false
            end
        end)
    end)
end
-- ==================== CONTENT ====================
-- Movement
CreateInput("SPEED", UDim2.new(0, 10, 0, 10), WalkSpeed, Pages.Movement, function(v) WalkSpeed = v end)
CreateInput("SPIN SPEED", UDim2.new(0, 10, 0, 45), SpinSpeed, Pages.Movement, function(v) SpinSpeed = v end)
CreateInput("JUMP", UDim2.new(0, 10, 0, 80), JumpPower, Pages.Movement, function(v) JumpPower = v end)
CreateInput("FLY SPD", UDim2.new(0, 10, 0, 115), FlySpeed, Pages.Movement, function(v) FlySpeed = v end)
-- Visuals
CreateToggle("ESP MASTER", UDim2.new(0, 10, 0, 10), false, Pages.Visuals, function(s)
    ESP_Config.Enabled = s
    if not s then
        for _, p in pairs(Players:GetPlayers()) do
            removeESP(p)
        end
    end
    UpdateCheatList("ESP", s)
end)
CreateToggle("Show Boxes", UDim2.new(0, 10, 0, 45), false, Pages.Visuals, function(s) ESP_Config.Boxes = s end)
CreateToggle("Show Names", UDim2.new(0, 10, 0, 80), false, Pages.Visuals, function(s) ESP_Config.Names = s end)
CreateToggle("Show Health", UDim2.new(0, 10, 0, 115), false, Pages.Visuals, function(s) ESP_Config.Health = s end)
CreateToggle("Glow", UDim2.new(0, 10, 0, 150), false, Pages.Visuals, function(s) ESP_Config.Glow = s end)
CreateToggle("Wall Check", UDim2.new(0, 10, 0, 185), false, Pages.Visuals, function(s) ESP_Config.VisCheck = s end)
local Divider = Instance.new("TextLabel", Pages.Visuals)
Divider.Text = "- - Cheats List - -"
Divider.Size = UDim2.new(0, 210, 0, 20)
Divider.Position = UDim2.new(0, 10, 0, 220)
Divider.BackgroundTransparency = 1
Divider.TextColor3 = Color3.fromRGB(150, 150, 150)
Divider.Font = Enum.Font.GothamBold
Divider.TextSize = 10
table.insert(UI_Elements.Texts, Divider)
CreateToggle("Show List", UDim2.new(0, 10, 0, 245), false, Pages.Visuals, function(s)
    List_Config.Enabled = s
    ListFrame.Visible = s
    if not s then
        for n, l in pairs(ActiveLabels) do
            l:Destroy()
        end
        ActiveLabels = {}
    else
        UpdateCheatList("ESP", ESP_Config.Enabled)
        UpdateCheatList("Aimbot", Aim_Config.Enabled)
        UpdateCheatList("Fly", Flying)
        UpdateCheatList("Noclip", Noclip)
        UpdateCheatList("Spin", IsSpinning)
        UpdateCheatList("Spam", ChatSpamEnabled)
    end
end)
local PosBtn = Instance.new("TextButton", Pages.Visuals)
PosBtn.Size = UDim2.new(0, 210, 0, 25)
PosBtn.Position = UDim2.new(0, 10, 0, 280)
PosBtn.BackgroundColor3 = CurrentTheme.Secondary
PosBtn.Text = "Position: TopRight"
PosBtn.TextColor3 = CurrentTheme.Text
PosBtn.Font = Enum.Font.GothamBold
PosBtn.TextSize = 11
Instance.new("UICorner", PosBtn)
table.insert(UI_Elements.Secondary, PosBtn)
table.insert(UI_Elements.Texts, PosBtn)
local posTable = {"TopRight", "TopLeft", "BottomRight", "BottomLeft"}
local curPos = 1
PosBtn.MouseButton1Click:Connect(function()
    curPos = curPos % #posTable + 1
    List_Config.Position = posTable[curPos]
    PosBtn.Text = "Position: " .. List_Config.Position
    UpdateListPos()
end)
UpdateListPos()
-- Combat
CreateToggle("AIMBOT MASTER", UDim2.new(0, 10, 0, 10), false, Pages.Combat, function(s)
    Aim_Config.Enabled = s
    UpdateCheatList("Aimbot", s)
end)
CreateToggle("Show FOV", UDim2.new(0, 10, 0, 45), false, Pages.Combat, function(s) Aim_Config.ShowFOV = s end)
CreateToggle("LMB (Instant)", UDim2.new(0, 10, 0, 80), false, Pages.Combat, function(s) Aim_Config.LMB_Active = s end)
CreateToggle("RMB (Smooth)", UDim2.new(0, 10, 0, 115), false, Pages.Combat, function(s) Aim_Config.RMB_Active = s end)
CreateInput("FOV Radius", UDim2.new(0, 10, 0, 150), Aim_Config.Radius, Pages.Combat, function(v)
    Aim_Config.Radius = v
    FOVCircle.Radius = v
end)
-- Keybinds
CreateBind("FLY KEY", UDim2.new(0, 10, 0, 10), FlyKey, Pages.Keybinds, function(k) FlyKey = k end)
CreateBind("NOCLIP", UDim2.new(0, 10, 0, 45), NoclipKey, Pages.Keybinds, function(k) NoclipKey = k end)
CreateBind("3313 KEY", UDim2.new(0, 10, 0, 80), SpinKey, Pages.Keybinds, function(k) SpinKey = k end)
CreateBind("SPAM KEY", UDim2.new(0, 10, 0, 115), SpamKey, Pages.Keybinds, function(k) SpamKey = k end)
CreateBind("MENU", UDim2.new(0, 10, 0, 150), MenuKey, Pages.Keybinds, function(k) MenuKey = k end)
-- Fun
CreateToggle("3313 SPIN", UDim2.new(0, 10, 0, 10), false, Pages.Fun, function(s)
    Spin3313Enabled = s
    if not s then IsSpinning = false end
end)
-- Spam divider
local SpamDiv = Instance.new("TextLabel", Pages.Fun)
SpamDiv.Text = "- - Chat Spam - -"
SpamDiv.Size = UDim2.new(0, 210, 0, 20)
SpamDiv.Position = UDim2.new(0, 10, 0, 55)
SpamDiv.BackgroundTransparency = 1
SpamDiv.TextColor3 = Color3.fromRGB(150, 150, 150)
SpamDiv.Font = Enum.Font.GothamBold
SpamDiv.TextSize = 10
table.insert(UI_Elements.Texts, SpamDiv)
local SpamToggle = CreateToggle("SPAM", UDim2.new(0, 10, 0, 80), false, Pages.Fun, function(s)
    ChatSpamEnabled = s
    UpdateCheatList("Spam", s)
    ShowNotify("Spam", s and "ON" or "OFF", s)
end)
-- Message text input
local MsgLabel = Instance.new("TextLabel", Pages.Fun)
MsgLabel.Text = "Message:"
MsgLabel.Size = UDim2.new(0, 80, 0, 25)
MsgLabel.Position = UDim2.new(0, 10, 0, 118)
MsgLabel.BackgroundTransparency = 1
MsgLabel.TextColor3 = CurrentTheme.Text
MsgLabel.Font = Enum.Font.GothamBold
MsgLabel.TextSize = 11
MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(UI_Elements.Texts, MsgLabel)
local MsgInput = Instance.new("TextBox", Pages.Fun)
MsgInput.Size = UDim2.new(0, 130, 0, 30)
MsgInput.Position = UDim2.new(0, 90, 0, 118)
MsgInput.Text = ChatMessage
MsgInput.BackgroundColor3 = CurrentTheme.Secondary
MsgInput.TextColor3 = CurrentTheme.Text
MsgInput.Font = Enum.Font.Gotham
MsgInput.TextSize = 11
MsgInput.ClearTextOnFocus = false
Instance.new("UICorner", MsgInput)
table.insert(UI_Elements.Secondary, MsgInput)
table.insert(UI_Elements.Texts, MsgInput)
MsgInput.FocusLost:Connect(function()
    if MsgInput.Text ~= "" then
        ChatMessage = MsgInput.Text
    end
end)
-- Delay input
CreateInput("Delay(s)", UDim2.new(0, 10, 0, 153), ChatSpamDelay, Pages.Fun, function(v)
    ChatSpamDelay = math.max(0.3, v)
end)
-- ==================== THEMES PAGE ====================
local themeY = 10
for name, t in pairs(Themes) do
    local tBtn = Instance.new("TextButton", Pages.Themes)
    tBtn.Size = UDim2.new(0, 210, 0, 30)
    tBtn.Position = UDim2.new(0, 10, 0, themeY)
    tBtn.BackgroundColor3 = t.Bg
    tBtn.TextColor3 = t.Txt
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 11
    tBtn.Text = name
    tBtn.ClipsDescendants = true
    Instance.new("UICorner", tBtn)
    local gradient = Instance.new("UIGradient", tBtn)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, t.Bg),
        ColorSequenceKeypoint.new(0.5, t.Acc),
        ColorSequenceKeypoint.new(1, t.Sec),
    })
    gradient.Rotation = 90
    table.insert(UI_Elements.Secondary, tBtn)
    table.insert(UI_Elements.Texts, tBtn)
    tBtn.MouseButton1Click:Connect(function()
        ApplyTheme(name)
        ShowNotify("Theme", name, true)
    end)
    themeY = themeY + 35
end
-- ==================== MENU TOGGLE ====================
local menuVisible = true
local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 1
local function ToggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        MainFrame.Visible = true
        TweenService:Create(MainScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    else
        local t = TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        t:Play()
        t.Completed:Connect(function()
            if not menuVisible then MainFrame.Visible = false end
        end)
    end
end
-- ==================== RUNNER & INPUT ====================
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = Aim_Config.Enabled and Aim_Config.ShowFOV
    if Aim_Config.Enabled and ((Aim_Config.LMB_Active and HoldingLMB) or (Aim_Config.RMB_Active and HoldingRMB)) then
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local speed = (Aim_Config.LMB_Active and HoldingLMB) and Aim_Config.Instant or Aim_Config.Smooth
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), speed)
        end
    end
    if Flying and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        if hrp:FindFirstChild("FlyV") then
            local move = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            hrp.FlyV.Velocity = move * FlySpeed
            hrp.FlyG.CFrame = Camera.CFrame
        end
    end
    if ESP_Config.Enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player then
                if not ESP_Objects[p] then createESP(p) end
                local obj, char = ESP_Objects[p], p.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                    if onScreen then
                        local color = (ESP_Config.VisCheck and not isVisible(char:FindFirstChild("Head"))) and HIDDEN_COLOR or VISIBLE_COLOR
                        if ESP_Config.Boxes then
                            local s = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                            obj.Box.Size = Vector2.new(3 * s, 4.5 * s)
                            obj.Box.Position = Vector2.new(pos.X - (3*s)/2, pos.Y - (4.5*s)/2)
                            obj.Box.Color = color
                            obj.Box.Visible = true
                        else
                            obj.Box.Visible = false
                        end
                        obj.Name.Visible = ESP_Config.Names
                        if ESP_Config.Names then
                            obj.Name.Position = Vector2.new(pos.X, pos.Y - 40)
                            obj.Name.Color = color
                        end
                        obj.Health.Visible = ESP_Config.Health
                        if ESP_Config.Health then
                            obj.Health.Text = math.floor(char.Humanoid.Health) .. "%"
                            obj.Health.Position = Vector2.new(pos.X, pos.Y - 25)
                            obj.Health.Color = Color3.fromHSV(char.Humanoid.Health/300, 1, 1)
                        end
                        if ESP_Config.Glow then
                            local g = char:FindFirstChild("SakurasiGlow") or Instance.new("Highlight", char)
                            g.Name = "SakurasiGlow"
                            g.OutlineColor = color
                            g.FillColor = color
                            g.FillTransparency = 0.5
                        elseif char:FindFirstChild("SakurasiGlow") then
                            char.SakurasiGlow:Destroy()
                        end
                    else
                        obj.Box.Visible = false
                        obj.Name.Visible = false
                        obj.Health.Visible = false
                    end
                else
                    if obj then
                        obj.Box.Visible = false
                        obj.Name.Visible = false
                        obj.Health.Visible = false
                    end
                end
            end
        end
    end
end)
RunService.Stepped:Connect(function()
    if Noclip and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = WalkSpeed
        Player.Character.Humanoid.JumpPower = JumpPower
    end
    if IsSpinning and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(SpinSpeed/60), 0)
    end
end)
UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 then HoldingLMB = true end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRMB = true end
    if IsBinding then return end
    if i.KeyCode == MenuKey then
        ToggleMenu()
    elseif i.KeyCode == FlyKey then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Flying = not Flying
            local hrp = Player.Character.HumanoidRootPart
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if Flying then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "FlyV"
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Velocity = Vector3.new(0, 0, 0)
                local bg = Instance.new("BodyGyro", hrp)
                bg.Name = "FlyG"
                bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                bg.CFrame = hrp.CFrame
                if hum then hum.PlatformStand = true end
            else
                if hrp:FindFirstChild("FlyV") then hrp.FlyV:Destroy() end
                if hrp:FindFirstChild("FlyG") then hrp.FlyG:Destroy() end
                if hum then hum.PlatformStand = false end
            end
            ShowNotify("Fly", Flying and "ON" or "OFF", Flying)
            UpdateCheatList("Fly", Flying)
        end
    elseif i.KeyCode == SpamKey then
        ChatSpamEnabled = not ChatSpamEnabled
        if SpamToggle then
            local newState = ChatSpamEnabled
            SpamToggle:SetAttribute("Active", newState)
            SpamToggle.BackgroundColor3 = newState and CurrentTheme.Accent or CurrentTheme.Secondary
            SpamToggle.Text = "SPAM: " .. (newState and "ON" or "OFF")
        end
        ShowNotify("Spam", ChatSpamEnabled and "ON" or "OFF", ChatSpamEnabled)
        UpdateCheatList("Spam", ChatSpamEnabled)
    elseif i.KeyCode == NoclipKey then
        Noclip = not Noclip
        ShowNotify("Noclip", Noclip and "ON" or "OFF", Noclip)
        UpdateCheatList("Noclip", Noclip)
    elseif i.KeyCode == SpinKey then
        if not Spin3313Enabled then
            ShowNotify("Enable 3313 in menu!", "", false)
        else
            IsSpinning = not IsSpinning
            ShowNotify("3313 Spin", IsSpinning and "ON" or "OFF", IsSpinning)
            UpdateCheatList("Spin", IsSpinning)
        end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then HoldingLMB = false end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRMB = false end
end)
Players.PlayerRemoving:Connect(removeESP)
ShowNotify("Nexus:", "Loaded", true)
