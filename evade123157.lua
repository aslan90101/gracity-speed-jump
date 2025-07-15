-- Custom Menu for Roblox Evade with ESP and Auto-Jump
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global variables
getgenv().toggleespmpt = true
getgenv().mptespcolour = Color3.fromRGB(255, 255, 255)
getgenv().mptespdistance = 100000
getgenv().mptespthickness = 2
getgenv().autojumpmpt = true

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomEvadeMenu"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.Text = "Evade Custom Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

-- ESP Toggle
local EspToggleButton = Instance.new("TextButton")
EspToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
EspToggleButton.Position = UDim2.new(0.05, 0, 0, 40)
EspToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
EspToggleButton.Text = "ESP Toggle: ON"
EspToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggleButton.TextSize = 14
EspToggleButton.Parent = MainFrame

EspToggleButton.MouseButton1Click:Connect(function()
    getgenv().toggleespmpt = not getgenv().toggleespmpt
    EspToggleButton.Text = "ESP Toggle: " .. (getgenv().toggleespmpt and "ON" or "OFF")
end)

-- ESP Color Picker (Simplified)
local ColorPickerButton = Instance.new("TextButton")
ColorPickerButton.Size = UDim2.new(0.9, 0, 0, 30)
ColorPickerButton.Position = UDim2.new(0.05, 0, 0, 80)
ColorPickerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorPickerButton.Text = "Change ESP Color"
ColorPickerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorPickerButton.TextSize = 14
ColorPickerButton.Parent = MainFrame

local ColorFrame = Instance.new("Frame")
ColorFrame.Size = UDim2.new(0, 150, 0, 100)
ColorFrame.Position = UDim2.new(0.05, 0, 0, 120)
ColorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ColorFrame.Visible = false
ColorFrame.Parent = MainFrame

local RSlider = Instance.new("TextBox")
RSlider.Size = UDim2.new(0.9, 0, 0, 20)
RSlider.Position = UDim2.new(0.05, 0, 0, 10)
RSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RSlider.Text = "R: 255"
RSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
RSlider.Parent = ColorFrame

local GSlider = Instance.new("TextBox")
GSlider.Size = UDim2.new(0.9, 0, 0, 20)
GSlider.Position = UDim2.new(0.05, 0, 0, 40)
GSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GSlider.Text = "G: 255"
GSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
GSlider.Parent = ColorFrame

local BSlider = Instance.new("TextBox")
BSlider.Size = UDim2.new(0.9, 0, 0, 20)
BSlider.Position = UDim2.new(0.05, 0, 0, 70)
BSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BSlider.Text = "B: 255"
BSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
BSlider.Parent = ColorFrame

ColorPickerButton.MouseButton1Click:Connect(function()
    ColorFrame.Visible = not ColorFrame.Visible
end)

local function UpdateColor()
    local r = tonumber(RSlider.Text:match("%d+")) or 255
    local g = tonumber(GSlider.Text:match("%d+")) or 255
    local b = tonumber(BSlider.Text:match("%d+")) or 255
    getgenv().mptespcolour = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
end

RSlider.FocusLost:Connect(UpdateColor)
GSlider.FocusLost:Connect(UpdateColor)
BSlider.FocusLost:Connect(UpdateColor)

-- ESP Distance Slider
local DistanceSlider = Instance.new("TextBox")
DistanceSlider.Size = UDim2.new(0.9, 0, 0, 30)
DistanceSlider.Position = UDim2.new(0.05, 0, 0, 230)
DistanceSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DistanceSlider.Text = "ESP Distance: 100000"
DistanceSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceSlider.TextSize = 14
DistanceSlider.Parent = MainFrame

DistanceSlider.FocusLost:Connect(function()
    local value = tonumber(DistanceSlider.Text:match("%d+")) or 100000
    getgenv().mptespdistance = math.clamp(value, 1, 100000)
    DistanceSlider.Text = "ESP Distance: " .. getgenv().mptespdistance
end)

-- ESP Thickness Slider
local ThicknessSlider = Instance.new("TextBox")
ThicknessSlider.Size = UDim2.new(0.9, 0, 0, 30)
ThicknessSlider.Position = UDim2.new(0.05, 0, 0, 270)
ThicknessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ThicknessSlider.Text = "ESP Thickness: 2"
ThicknessSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
ThicknessSlider.TextSize = 14
ThicknessSlider.Parent = MainFrame

ThicknessSlider.FocusLost:Connect(function()
    local value = tonumber(ThicknessSlider.Text:match("%d+")) or 2
    getgenv().mptespthickness = math.clamp(value, 1, 30)
    ThicknessSlider.Text = "ESP Thickness: " .. getgenv().mptespthickness
end)

-- Auto Jump Toggle and Keybind
local AutoJumpButton = Instance.new("TextButton")
AutoJumpButton.Size = UDim2.new(0.9, 0, 0, 30)
AutoJumpButton.Position = UDim2.new(0.05, 0, 0, 310)
AutoJumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoJumpButton.Text = "Auto Jump: ON (E)"
AutoJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoJumpButton.TextSize = 14
AutoJumpButton.Parent = MainFrame

local currentKey = Enum.KeyCode.E
AutoJumpButton.MouseButton1Click:Connect(function()
    getgenv().autojumpmpt = not getgenv().autojumpmpt
    AutoJumpButton.Text = "Auto Jump: " .. (getgenv().autojumpmpt and "ON" or "OFF") .. " (" .. currentKey.Name .. ")"
end)

-- Keybind Setting
local KeybindButton = Instance.new("TextButton")
KeybindButton.Size = UDim2.new(0.9, 0, 0, 30)
KeybindButton.Position = UDim2.new(0.05, 0, 0, 350)
KeybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeybindButton.Text = "Set Auto Jump Keybind"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindButton.TextSize = 14
KeybindButton.Parent = MainFrame

local waitingForKey = false
KeybindButton.MouseButton1Click:Connect(function()
    waitingForKey = true
    KeybindButton.Text = "Press a Key..."
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if waitingForKey and not processed and input.UserInputType == Enum.UserInputType.Keyboard then
        currentKey = input.KeyCode
        waitingForKey = false
        KeybindButton.Text = "Set Auto Jump Keybind"
        AutoJumpButton.Text = "Auto Jump: " .. (getgenv().autojumpmpt and "ON" or "OFF") .. " (" .. currentKey.Name .. ")"
    elseif input.KeyCode == currentKey and not processed then
        getgenv().autojumpmpt = not getgenv().autojumpmpt
        AutoJumpButton.Text = "Auto Jump: " .. (getgenv().autojumpmpt and "ON" or "OFF") .. " (" .. currentKey.Name .. ")"
    end
end)

-- Auto Jump Function
local function autojump()
    if LocalPlayer.Character then
        LocalPlayer.Character:WaitForChild("Humanoid").StateChanged:Connect(function(old, new)
            if new == Enum.HumanoidStateType.Landed and getgenv().autojumpmpt then
                LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end
autojump()
LocalPlayer.CharacterAdded:Connect(autojump)

-- ESP Function
local function esp(plr)
    if not Players:GetPlayerFromCharacter(plr) then
        local line = Drawing.new("Line")
        RunService.RenderStepped:Connect(function()
            if plr:FindFirstChild("HumanoidRootPart") then
                local pos = plr.HumanoidRootPart.Position
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude) or math.huge
                if distance <= getgenv().mptespdistance then
                    local vector, screen = Camera:WorldToViewportPoint(pos)
                    if screen then
                        line.Visible = getgenv().toggleespmpt
                        line.Thickness = getgenv().mptespthickness
                        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(vector.X, vector.Y)
                        line.Color = getgenv().mptespcolour
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                pcall(function()
                    line.Visible = false
                end)
            end
            if not plr:FindFirstChild("HumanoidRootPart") or not plr:IsDescendantOf(workspace) then
                pcall(function()
                    line:Remove()
                end)
            end
        end)
    end
end

for _, v in pairs(workspace.Game.Players:GetChildren()) do
    esp(v)
end
workspace.Game.Players.ChildAdded:Connect(esp)

-- Toggle Menu Visibility
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Delete and not processed then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
