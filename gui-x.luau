local UIS = game:GetService("UserInputService")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local activeGuis = {}
local isHidden = false

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
        if not isHidden then
            activeGuis = {}
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    table.insert(activeGuis, gui)
                    gui.Enabled = false
                end
            end
            isHidden = true
        else
            for _, gui in pairs(activeGuis) do
                if gui and gui.Parent then
                    gui.Enabled = true
                end
            end
            isHidden = false
        end
    end
end)
