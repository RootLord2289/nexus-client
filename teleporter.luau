local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local active = false
local connection = nil

-- Создаем один постоянный объект UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SakurasiCenterUI"
screenGui.IgnoreGuiInset = true
pcall(function() screenGui.Parent = CoreGui end)

local mainLabel = Instance.new("TextLabel")
mainLabel.Size = UDim2.new(0, 0, 0, 0) -- Начинаем с нулевого размера
mainLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
mainLabel.AnchorPoint = Vector2.new(0.5, 0.5)
mainLabel.BackgroundTransparency = 1
mainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mainLabel.TextTransparency = 1
mainLabel.Font = Enum.Font.GothamBold
mainLabel.TextSize = 50
mainLabel.Parent = screenGui

local function animateText(text, color)
    mainLabel.Text = text
    mainLabel.TextColor3 = color
    
    -- Параметры анимации: Увеличение (Back out)
    local openInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local closeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    
    local show = TweenService:Create(mainLabel, openInfo, {
        Size = UDim2.new(0, 500, 0, 100),
        TextTransparency = 0
    })
    
    local hide = TweenService:Create(mainLabel, closeInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        TextTransparency = 1
    })
    
    show:Play()
    show.Completed:Connect(function()
        task.wait(0.5)
        hide:Play()
    end)
end

local function getClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
            if dist < shortestDistance then
                closest = player
                shortestDistance = dist
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.H then
        active = not active
        
        if active then
            animateText("TELEPORT ON", Color3.fromRGB(0, 255, 150))
            connection = RunService.RenderStepped:Connect(function()
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        else
            animateText("TELEPORT OFF", Color3.fromRGB(255, 80, 80))
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
end)
