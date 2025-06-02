
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")


local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true


local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 90)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 60)


local DragBar = Instance.new("Frame")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(1, 0, 0, 30)
DragBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DragBar.Parent = MainFrame
Instance.new("UICorner", DragBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "Teleport to Player"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(225, 225, 225)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = DragBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = DragBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)


local InputBox = Instance.new("TextBox")
InputBox.Name = "NameBox"
InputBox.PlaceholderText = "Enter player name..."
InputBox.ClearTextOnFocus = false
InputBox.Text = "" 
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 16
InputBox.TextColor3 = Color3.fromRGB(230, 230, 230)
InputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
InputBox.Size = UDim2.new(0, 200, 0, 30)
InputBox.Position = UDim2.new(0, 10, 0, 40)
InputBox.Parent = MainFrame
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)

local GoBtn = Instance.new("TextButton")
GoBtn.Name = "GoBtn"
GoBtn.Text = "Go"
GoBtn.Font = Enum.Font.Gotham
GoBtn.TextSize = 16
GoBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
GoBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GoBtn.Size = UDim2.new(0, 60, 0, 30)
GoBtn.Position = UDim2.new(1, -70, 0, 40)
GoBtn.Parent = MainFrame
Instance.new("UICorner", GoBtn).CornerRadius = UDim.new(0, 6)


local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title or "TeleportUI";
        Text = text or "";
        Duration = duration or 3;
    })
end


local function teleportTo(nameStr)
    if not nameStr or nameStr == "" then
        notify("Error","Please enter a player name.")
        return
    end
    local query = string.lower(nameStr)
    local target
    for _, plr in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(plr.DisplayName), query, 1, true)
        or string.find(string.lower(plr.Name), query, 1, true) then
            target = plr
            break
        end
    end
    if not target then
        notify("Player Not Found","No player matches '"..nameStr.."'.")
        return
    end

    local function getHRP(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    local success, err = pcall(function()
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local theirChar = target.Character or target.CharacterAdded:Wait()
        local mineHRP = getHRP(myChar)
        local theirsHRP = getHRP(theirChar)
        if not mineHRP or not theirsHRP then error("Character missing HumanoidRootPart.") end

        mineHRP.CFrame = theirsHRP.CFrame + Vector3.new(0,3,0)
    end)
    if success then
        notify("Success","Teleported to "..target.Name..".")
    else
        notify("Teleport Failed", err)
    end
end


GoBtn.MouseButton1Click:Connect(function()
    teleportTo(InputBox.Text)
end)
InputBox.FocusLost:Connect(function(enter)
    if enter then teleportTo(InputBox.Text) end
end)


local dragging, dragInput, dragStart, startPos
DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
DragBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = newPos}):Play()
    end
end)


UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.K then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
