local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local slots = {}
local menuVisible = false
local isBinding = false

-- Luxury Palette
local COL_ACCENT = Color3.fromRGB(210, 180, 140) 
local COL_BG = Color3.fromRGB(30, 25, 20)        
local COL_SLOT = Color3.fromRGB(45, 35, 30)      
local COL_TEXT = Color3.fromRGB(245, 245, 220)   

local T_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local sg = Instance.new("ScreenGui")
sg.Name = "SakurasiEliteWarp"
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end

local canvas = Instance.new("CanvasGroup")
canvas.Size = UDim2.new(0, 380, 0, 0)
canvas.Position = UDim2.new(0.5, -190, 0.4, 0)
canvas.BackgroundColor3 = COL_BG
canvas.GroupTransparency = 1
canvas.BorderSizePixel = 0
canvas.Visible = false -- Полностью скрыт изначально
canvas.Parent = sg

local mainCorner = Instance.new("UICorner", canvas)
mainCorner.CornerRadius = UDim.new(0, 20)

local stroke = Instance.new("UIStroke", canvas)
stroke.Color = COL_ACCENT
stroke.Thickness = 1.5
stroke.Transparency = 0.4

local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(1, 0, 0, 40)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = canvas

local uiList = Instance.new("UIListLayout", canvas)
uiList.Padding = UDim.new(0, 15)
uiList.HorizontalAlignment = "Center"

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 340, 0, 55)
addBtn.BackgroundColor3 = COL_ACCENT
addBtn.Text = "SAVE NEW POSITION"
addBtn.TextColor3 = COL_BG
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 16
addBtn.AutoButtonColor = false
addBtn.Parent = canvas
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 15)

-- Очередь уведомлений
local lastNotify = nil
local function notify(txt, col)
    if lastNotify then lastNotify:Destroy() end
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 500, 0, 60)
    n.Position = UDim2.new(0.5, 0, 0.25, 0)
    n.AnchorPoint = Vector2.new(0.5, 0.5)
    n.BackgroundTransparency = 1
    n.TextColor3 = col or COL_TEXT
    n.Font = Enum.Font.GothamBold
    n.TextSize = 20
    n.Text = "—  " .. txt:upper() .. "  —"
    n.TextTransparency = 1
    n.Parent = sg
    lastNotify = n
    TS:Create(n, T_INFO, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.3, 0)}):Play()
    task.delay(1.2, function()
        if n then
            TS:Create(n, T_INFO, {TextTransparency = 1}):Play()
            game:GetService("Debris"):AddItem(n, 0.5)
        end
    end)
end

-- Drag Logic
local dragging, dragStart, startPos
dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = canvas.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        canvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function updateMenu()
    if menuVisible then
        canvas.Visible = true
        local targetHeight = 40 + 55 + (#slots * 80) + 25
        TS:Create(canvas, T_INFO, {Size = UDim2.new(0, 380, 0, targetHeight), GroupTransparency = 0}):Play()
    else
        local closeTween = TS:Create(canvas, T_INFO, {Size = UDim2.new(0, 380, 0, 0), GroupTransparency = 1})
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if not menuVisible then canvas.Visible = false end
        end)
    end
end

local function createSlot(cf)
    if #slots >= 5 then notify("MEMORY FULL", Color3.fromRGB(255, 100, 100)) return end
    
    local slotData = {cf = cf, key = nil}
    local sFrame = Instance.new("Frame")
    sFrame.Size = UDim2.new(0, 340, 0, 65)
    sFrame.BackgroundColor3 = COL_SLOT
    sFrame.Parent = canvas
    Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 15)
    
    sFrame.Size = UDim2.new(0, 0, 0, 65)
    TS:Create(sFrame, BOUNCE, {Size = UDim2.new(0, 340, 0, 65)}):Play()
    
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(0.4, 0, 1, 0)
    lab.Position = UDim2.new(0.08, 0, 0, 0)
    lab.BackgroundTransparency = 1
    lab.Text = "SLOT " .. (#slots + 1)
    lab.TextColor3 = COL_ACCENT
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 13
    lab.TextXAlignment = "Left"
    lab.Parent = sFrame
    
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 26, 0, 26)
    delBtn.Position = UDim2.new(0, -8, 0, -8)
    delBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    delBtn.Text = "×"
    delBtn.TextColor3 = COL_TEXT
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextSize = 16
    delBtn.Parent = sFrame
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(1, 0)
    
    delBtn.MouseEnter:Connect(function()
        TS:Create(delBtn, T_INFO, {BackgroundColor3 = Color3.fromRGB(180, 50, 50), Size = UDim2.new(0, 30, 0, 30)}):Play()
    end)
    delBtn.MouseLeave:Connect(function()
        TS:Create(delBtn, T_INFO, {BackgroundColor3 = Color3.fromRGB(120, 40, 40), Size = UDim2.new(0, 26, 0, 26)}):Play()
    end)

    local bind = Instance.new("TextButton")
    bind.Size = UDim2.new(0, 120, 0, 35)
    bind.Position = UDim2.new(0.95, -120, 0.5, -17)
    bind.BackgroundColor3 = COL_BG
    bind.Text = "ASSIGN"
    bind.TextColor3 = COL_ACCENT
    bind.Font = Enum.Font.GothamBold
    bind.TextSize = 11
    bind.Parent = sFrame
    Instance.new("UICorner", bind)

    delBtn.MouseButton1Click:Connect(function()
        for i, v in ipairs(slots) do if v == slotData then table.remove(slots, i) break end end
        sFrame:Destroy()
        updateMenu()
        notify("REMOVED", COL_ACCENT)
    end)

    local pulse = TS:Create(bind, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Size = UDim2.new(0, 130, 0, 40),
        Position = UDim2.new(0.95, -125, 0.5, -20),
        TextColor3 = Color3.new(1, 1, 1)
    })

    bind.MouseButton1Click:Connect(function()
        if isBinding then return end
        isBinding = true
        bind.Text = "..."
        pulse:Play()
        
        local con
        con = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local k = input.KeyCode
                if k == Enum.KeyCode.X then
                    notify("X IS RESERVED", Color3.fromRGB(255, 100, 100))
                else
                    local used = false
                    for _, s in pairs(slots) do if s.key == k then used = true end end
                    if used then notify("USED", COL_ACCENT) else
                        slotData.key = k
                        bind.Text = k.Name:upper()
                        notify("BOUND: "..k.Name, COL_ACCENT)
                        -- Защита от мгновенного использования
                        task.wait(0.1)
                    end
                end
                pulse:Cancel()
                TS:Create(bind, T_INFO, {Size = UDim2.new(0, 120, 0, 35), Position = UDim2.new(0.95, -120, 0.5, -17), TextColor3 = COL_ACCENT}):Play()
                isBinding = false
                con:Disconnect()
            end
        end)
    end)
    
    table.insert(slots, slotData)
    updateMenu()
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe and input.KeyCode ~= Enum.KeyCode.X then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        menuVisible = not menuVisible
        updateMenu()
    end
    
    if not isBinding and not dragging then
        for _, s in pairs(slots) do
            if s.key and input.KeyCode == s.key then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = s.cf
                    notify("WARP", COL_ACCENT)
                end
            end
        end
    end
end)

addBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        createSlot(char.HumanoidRootPart.CFrame)
    end
end)
