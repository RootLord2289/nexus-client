local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("Ultimate_Clicker") then CoreGui.Ultimate_Clicker:Destroy() end

local screen = Instance.new("ScreenGui")
screen.Name = "Ultimate_Clicker"
screen.Parent = CoreGui

local enabled = false
local cps = 20
local visible = false
local lastNotifyId = 0

local notifyLabel = Instance.new("TextLabel", screen)
notifyLabel.Size = UDim2.new(1, 0, 0, 0)
notifyLabel.Position = UDim2.new(0, 0, 0.4, 0)
notifyLabel.BackgroundTransparency = 1
notifyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifyLabel.TextTransparency = 1
notifyLabel.Font = Enum.Font.GothamBold
notifyLabel.TextSize = 60
notifyLabel.TextScaled = true
notifyLabel.RichText = true

local function showNotify(status)
    lastNotifyId = lastNotifyId + 1
    local currentId = lastNotifyId
    
    local color = status and "rgb(0, 255, 120)" or "rgb(255, 60, 60)"
    local text = status and "ON" or "OFF"
    
    notifyLabel.Text = "Clicker: <font color='"..color.."'>"..text.."</font>"
    notifyLabel.Size = UDim2.new(1, 0, 0, 0)
    notifyLabel.TextTransparency = 0
    
    TweenService:Create(notifyLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(1, 0, 0, 120)
    }):Play()
    
    task.delay(1.0, function()
        if lastNotifyId == currentId then
            TweenService:Create(notifyLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        end
    end)
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 0, 0, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Visible = false
main.ClipsDescendants = true
main.Parent = screen

local targetSize = UDim2.new(0, 240, 0, 150)
local targetPos = UDim2.new(0.5, -120, 0.5, -75)

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(45, 45, 45)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "CLICKER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local input = Instance.new("TextBox", main)
input.Size = UDim2.new(0.85, 0, 0, 40)
input.Position = UDim2.new(0.075, 0, 0.35, 0)
input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
input.Text = "20 CPS"
input.TextColor3 = Color3.fromRGB(0, 120, 255)
input.Font = Enum.Font.GothamBold
input.TextSize = 14
Instance.new("UICorner", input)

local hint = Instance.new("TextLabel", main)
hint.Size = UDim2.new(1, 0, 0, 30)
hint.Position = UDim2.new(0, 0, 0.7, 0)
hint.BackgroundTransparency = 1
hint.Text = "[G] Toggle | [H] Hide"
hint.TextColor3 = Color3.fromRGB(100, 100, 100)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 12

input.FocusLost:Connect(function()
    local val = tonumber(input.Text:match("%d+")) or 20
    cps = math.clamp(val, 1, 240)
    input.Text = cps .. " CPS"
end)

local function animateUI(show)
    local currentPos = main.Position
    local currentSize = main.Size

    if show then
        main.Visible = true
        if currentSize.X.Offset > 50 then
            TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 240, 0, 150)
            }):Play()
        else
            main.Size = UDim2.new(0, 0, 0, 0)
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 240, 0, 150),
                Position = UDim2.new(0.5, -120, 0.5, -75)
            }):Play()
        end
    else
        local t = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = currentPos + UDim2.new(0, main.Size.X.Offset/2, 0, main.Size.Y.Offset/2)
        })
        t:Play()
        t.Completed:Connect(function() if not visible then main.Visible = false end end)
    end
end

task.spawn(function()
    while true do
        if enabled then
            if mouse1click then mouse1click() else
                mouse1press() task.wait(0.01) mouse1release()
            end
        end
        task.wait(1/cps)
    end
end)

UserInputService.InputBegan:Connect(function(key, gpe)
    if gpe then return end
    if key.KeyCode == Enum.KeyCode.G then
        enabled = not enabled
        showNotify(enabled)
    elseif key.KeyCode == Enum.KeyCode.H then
        visible = not visible
        animateUI(visible)
    end
end)

local d, s, p
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true s = i.Position p = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - s
    main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
