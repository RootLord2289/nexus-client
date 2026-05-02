local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local recording = {}
local isRecording = false
local isPlaying = false
local shouldStopPlayback = false

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "Sakurasi_Ultimate_Recorder"
screenGui.ResetOnSpawn = false

local notifyLabel = Instance.new("TextLabel", screenGui)
notifyLabel.Size = UDim2.new(1, 0, 0, 100)
notifyLabel.Position = UDim2.new(0, 0, 0.4, 0)
notifyLabel.BackgroundTransparency = 1
notifyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifyLabel.TextTransparency = 1
notifyLabel.Font = Enum.Font.GothamBold
notifyLabel.TextSize = 55
notifyLabel.TextScaled = true

local function showNotify(text)
    notifyLabel.Text = text
    notifyLabel.Size = UDim2.new(1, 0, 0, 0)
    TweenService:Create(notifyLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back), {TextTransparency = 0, Size = UDim2.new(1, 0, 0, 100)}):Play()
    task.delay(1.2, function()
        TweenService:Create(notifyLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    end)
end

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 320, 0, 90)
frame.Position = UDim2.new(0.5, -160, 1, 100)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.2
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.new(1, 1, 1)
stroke.Thickness = 2
stroke.Transparency = 0.6

local layout = Instance.new("UIListLayout", frame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 20)

local function toggleRecording()
    if isPlaying then return end
    if isRecording then
        isRecording = false
        showNotify("RECORDING SAVED")
    else
        recording = {}
        isRecording = true
        showNotify("RECORDING STARTED")
    end
end

local startBtn 

local function playRecording()
    if isRecording then return end
    
    if isPlaying then
        shouldStopPlayback = true
        return
    end

    if #recording == 0 then return end
    
    isPlaying = true
    shouldStopPlayback = false
    showNotify("STARTING REPLAY")
    startBtn.Text = "STOP REPLAY"
    startBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        root.Anchored = true
        for _, cf in ipairs(recording) do
            if shouldStopPlayback then break end
            root.CFrame = cf
            task.wait()
        end
        root.Anchored = false
    end
    
    isPlaying = false
    shouldStopPlayback = false
    startBtn.Text = "START"
    startBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    showNotify("REPLAY FINISHED")
end

local function createBtn(text, color)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 120, 0, 50)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, Size = UDim2.new(0, 125, 0, 55)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, Size = UDim2.new(0, 120, 0, 50)}):Play()
    end)
    
    return btn
end

local recBtn = createBtn("RECORD", Color3.fromRGB(180, 50, 50))
startBtn = createBtn("START", Color3.fromRGB(50, 180, 50))

recBtn.MouseButton1Click:Connect(toggleRecording)
startBtn.MouseButton1Click:Connect(playRecording)

RunService.RenderStepped:Connect(function()
    if isRecording then
        recBtn.Text = "STOP"
        recBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        recBtn.Text = "RECORD"
        recBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
    
    if isRecording and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(recording, player.Character.HumanoidRootPart.CFrame)
    end
end)

local isOpen = false
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        isOpen = not isOpen
        local targetPos = isOpen and UDim2.new(0.5, -160, 1, -130) or UDim2.new(0.5, -160, 1, 100)
        TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Position = targetPos}):Play()
    elseif input.KeyCode == Enum.KeyCode.F then
        toggleRecording()
    elseif input.KeyCode == Enum.KeyCode.J then
        playRecording()
    end
end)
