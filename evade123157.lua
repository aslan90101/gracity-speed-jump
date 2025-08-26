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
getgenv().superjumpforce = 5
getgenv().superjumpenabled = false
getgenv().superjumpkey = Enum.KeyCode.F
getgenv().autojumpindicator = true

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomEvadeMenu"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 300)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.Text = "Evade Custom Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleLabel

-- Scrolling Frame for menu items
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500) -- Adjust based on content height
ScrollingFrame.Parent = MainFrame

-- Auto Jump Indicator
local IndicatorFrame = Instance.new("Frame")
IndicatorFrame.Size = UDim2.new(0, 30, 0, 30)
IndicatorFrame.Position = UDim2.new(1, -40, 0, 10)
IndicatorFrame.BackgroundColor3 = getgenv().autojumpmpt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
IndicatorFrame.BorderSizePixel = 0
IndicatorFrame.Visible = getgenv().autojumpindicator
IndicatorFrame.Parent = ScreenGui

local IndicatorCorner = Instance.new("UICorner")
IndicatorCorner.CornerRadius = UDim.new(0.5, 0)
IndicatorCorner.Parent = IndicatorFrame

local IndicatorStroke = Instance.new("UIStroke")
IndicatorStroke.Thickness = 4
IndicatorStroke.Color = getgenv().autojumpmpt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
IndicatorStroke.Transparency = 0.3
IndicatorStroke.Parent = IndicatorFrame

local IndicatorGradient = Instance.new("UIGradient")
IndicatorGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1)
})
IndicatorGradient.Parent = IndicatorStroke

-- ESP Toggle
local EspToggleButton = Instance.new("TextButton")
EspToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
EspToggleButton.Position = UDim2.new(0.05, 0, 0, 10)
EspToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
EspToggleButton.Text = "ESP Toggle: ON"
EspToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggleButton.TextSize = 14
EspToggleButton.Parent = ScrollingFrame

local EspToggleCorner = Instance.new("UICorner")
EspToggleCorner.CornerRadius = UDim.new(0, 8)
EspToggleCorner.Parent = EspToggleButton

EspToggleButton.MouseButton1Click:Connect(function()
    getgenv().toggleespmpt = not getgenv().toggleespmpt
    EspToggleButton.Text = "ESP Toggle: " .. (getgenv().toggleespmpt and "ON" or "OFF")
end)

-- ESP Color Picker
local ColorPickerButton = Instance.new("TextButton")
ColorPickerButton.Size = UDim2.new(0.9, 0, 0, 30)
ColorPickerButton.Position = UDim2.new(0.05, 0, 0, 50)
ColorPickerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorPickerButton.Text = "Change ESP Color"
ColorPickerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorPickerButton.TextSize = 14
ColorPickerButton.Parent = ScrollingFrame

local ColorPickerCorner = Instance.new("UICorner")
ColorPickerCorner.CornerRadius = UDim.new(0, 8)
ColorPickerCorner.Parent = ColorPickerButton

local ColorFrame = Instance.new("Frame")
ColorFrame.Size = UDim2.new(0, 150, 0, 100)
ColorFrame.Position = UDim2.new(0.05, 0, 0, 90)
ColorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ColorFrame.Visible = false
ColorFrame.Parent = ScrollingFrame

local ColorFrameCorner = Instance.new("UICorner")
ColorFrameCorner.CornerRadius = UDim.new(0, 8)
ColorFrameCorner.Parent = ColorFrame

local RSlider = Instance.new("TextBox")
RSlider.Size = UDim2.new(0.9, 0, 0, 20)
RSlider.Position = UDim2.new(0.05, 0, 0, 10)
RSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RSlider.Text = "R: 255"
RSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
RSlider.Parent = ColorFrame

local RSliderCorner = Instance.new("UICorner")
RSliderCorner.CornerRadius = UDim.new(0, 6)
RSliderCorner.Parent = RSlider

local GSlider = Instance.new("TextBox")
GSlider.Size = UDim2.new(0.9, 0, 0, 20)
GSlider.Position = UDim2.new(0.05, 0, 0, 40)
GSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GSlider.Text = "G: 255"
GSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
GSlider.Parent = ColorFrame

local GSliderCorner = Instance.new("UICorner")
GSliderCorner.CornerRadius = UDim.new(0, 6)
GSliderCorner.Parent = GSlider

local BSlider = Instance.new("TextBox")
BSlider.Size = UDim2.new(0.9, 0, 0, 20)
BSlider.Position = UDim2.new(0.05, 0, 0, 70)
BSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BSlider.Text = "B: 255"
BSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
BSlider.Parent = ColorFrame

local BSliderCorner = Instance.new("UICorner")
BSliderCorner.CornerRadius = UDim.new(0, 6)
BSliderCorner.Parent = BSlider

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

-- Auto Jump Indicator Checkbox
local IndicatorCheckbox = Instance.new("TextButton")
IndicatorCheckbox.Size = UDim2.new(0.9, 0, 0, 30)
IndicatorCheckbox.Position = UDim2.new(0.05, 0, 0, 160)
IndicatorCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
IndicatorCheckbox.Text = "Auto Jump Indicator: ON"
IndicatorCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
IndicatorCheckbox.TextSize = 14
IndicatorCheckbox.Parent = ScrollingFrame

local IndicatorCheckboxCorner = Instance.new("UICorner")
IndicatorCheckboxCorner.CornerRadius = UDim.new(0, 8)
IndicatorCheckboxCorner.Parent = IndicatorCheckbox

IndicatorCheckbox.MouseButton1Click:Connect(function()
    getgenv().autojumpindicator = not getgenv().autojumpindicator
    IndicatorCheckbox.Text = "Auto Jump Indicator: " .. (getgenv().autojumpindicator and "ON" or "OFF")
    IndicatorFrame.Visible = getgenv().autojumpindicator
end)

-- ESP Distance Slider
local DistanceSlider = Instance.new("TextBox")
DistanceSlider.Size = UDim2.new(0.9, 0, 0, 30)
DistanceSlider.Position = UDim2.new(0.05, 0, 0, 200)
DistanceSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DistanceSlider.Text = "ESP Distance: 100000"
DistanceSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceSlider.TextSize = 14
DistanceSlider.Parent = ScrollingFrame

local DistanceSliderCorner = Instance.new("UICorner")
DistanceSliderCorner.CornerRadius = UDim.new(0, 8)
DistanceSliderCorner.Parent = DistanceSlider

DistanceSlider.FocusLost:Connect(function()
    local value = tonumber(DistanceSlider.Text:match("%d+")) or 100000
    getgenv().mptespdistance = math.clamp(value, 1, 100000)
    DistanceSlider.Text = "ESP Distance: " .. getgenv().mptespdistance
end)

-- ESP Thickness Slider
local ThicknessSlider = Instance.new("TextBox")
ThicknessSlider.Size = UDim2.new(0.9, 0, 0, 30)
ThicknessSlider.Position = UDim2.new(0.05, 0, 0, 240)
ThicknessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ThicknessSlider.Text = "ESP Thickness: 2"
ThicknessSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
ThicknessSlider.TextSize = 14
ThicknessSlider.Parent = ScrollingFrame

local ThicknessSliderCorner = Instance.new("UICorner")
ThicknessSliderCorner.CornerRadius = UDim.new(0, 8)
ThicknessSliderCorner.Parent = ThicknessSlider

ThicknessSlider.FocusLost:Connect(function()
    local value = tonumber(ThicknessSlider.Text:match("%d+")) or 2
    getgenv().mptespthickness = math.clamp(value, 1, 30)
    ThicknessSlider.Text = "ESP Thickness: " .. getgenv().mptespthickness
end)

-- Auto Jump Toggle and Keybind
local AutoJumpButton = Instance.new("TextButton")
AutoJumpButton.Size = UDim2.new(0.9, 0, 0, 30)
AutoJumpButton.Position = UDim2.new(0.05, 0, 0, 280)
AutoJumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoJumpButton.Text = "Auto Jump: ON (E)"
AutoJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoJumpButton.TextSize = 14
AutoJumpButton.Parent = ScrollingFrame

local AutoJumpCorner = Instance.new("UICorner")
AutoJumpCorner.CornerRadius = UDim.new(0, 8)
AutoJumpCorner.Parent = AutoJumpButton

local currentKey = Enum.KeyCode.E
AutoJumpButton.MouseButton1Click:Connect(function()
    getgenv().autojumpmpt = not getgenv().autojumpmpt
    AutoJumpButton.Text = "Auto Jump: " .. (getgenv().autojumpmpt and "ON" or "OFF") .. " (" .. currentKey.Name .. ")"
    IndicatorFrame.BackgroundColor3 = getgenv().autojumpmpt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    IndicatorStroke.Color = getgenv().autojumpmpt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- Super Jump Toggle and Keybind
local SuperJumpButton = Instance.new("TextButton")
SuperJumpButton.Size = UDim2.new(0.9, 0, 0, 30)
SuperJumpButton.Position = UDim2.new(0.05, 0, 0, 320)
SuperJumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SuperJumpButton.Text = "Super Jump: OFF (F)"
SuperJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SuperJumpButton.TextSize = 14
SuperJumpButton.Parent = ScrollingFrame

local SuperJumpCorner = Instance.new("UICorner")
SuperJumpCorner.CornerRadius = UDim.new(0, 8)
SuperJumpCorner.Parent = SuperJumpButton

SuperJumpButton.MouseButton1Click:Connect(function()
    getgenv().superjumpenabled = not getgenv().superjumpenabled
    SuperJumpButton.Text = "Super Jump: " .. (getgenv().superjumpenabled and "ON" or "OFF") .. " (" .. getgenv().superjumpkey.Name .. ")"
end)

-- Super Jump Force Slider
local SuperJumpSlider = Instance.new("TextBox")
SuperJumpSlider.Size = UDim2.new(0.9, 0, 0, 30)
SuperJumpSlider.Position = UDim2.new(0.05, 0, 0, 360)
SuperJumpSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SuperJumpSlider.Text = "Super Jump Force: 5"
SuperJumpSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SuperJumpSlider.TextSize = 14
SuperJumpSlider.Parent = ScrollingFrame

local SuperJumpSliderCorner = Instance.new("UICorner")
SuperJumpSliderCorner.CornerRadius = UDim.new(0, 8)
SuperJumpSliderCorner.Parent = SuperJumpSlider

SuperJumpSlider.FocusLost:Connect(function()
    local value = tonumber(SuperJumpSlider.Text:match("%d+")) or 5
    getgenv().superjumpforce = math.clamp(value, 1, 10)
    SuperJumpSlider.Text = "Super Jump Force: " .. getgenv().superjumpforce
end)

-- Keybind Setting for Auto Jump
local KeybindButton = Instance.new("TextButton")
KeybindButton.Size = UDim2.new(0.9, 0, 0, 30)
KeybindButton.Position = UDim2.new(0.05, 0, 0, 390)
KeybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeybindButton.Text = "Set Auto Jump Keybind"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindButton.TextSize = 14
KeybindButton.Parent = ScrollingFrame

local KeybindButtonCorner = Instance.new("UICorner")
KeybindButtonCorner.CornerRadius = UDim.new(0, 8)
KeybindButtonCorner.Parent = KeybindButton

local waitingForKey = false
KeybindButton.MouseButton1Click:Connect(function()
    waitingForKey = true
    KeybindButton.Text = "Press a Key..."
end)

-- Super Jump Keybind Setting
local SuperJumpKeybindButton = Instance.new("TextButton")
SuperJumpKeybindButton.Size = UDim2.new(0.9, 0, 0, 30)
SuperJumpKeybindButton.Position = UDim2.new(0.05, 0, 0, 430)
SuperJumpKeybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SuperJumpKeybindButton.Text = "Set Super Jump Keybind"
SuperJumpKeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SuperJumpKeybindButton.TextSize = 14
SuperJumpKeybindButton.Parent = ScrollingFrame

local SuperJumpKeybindCorner = Instance.new("UICorner")
SuperJumpKeybindCorner.CornerRadius = UDim.new(0, 8)
SuperJumpKeybindCorner.Parent = SuperJumpKeybindButton

local waitingForSuperJumpKey = false
SuperJumpKeybindButton.MouseButton1Click:Connect(function()
    waitingForSuperJumpKey = true
    SuperJumpKeybindButton.Text = "Press a Key..."
end)

-- Input Handling for Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
    if waitingForKey and not processed and input.UserInputType == Enum.UserInputType.Keyboard then
        currentKey = input.KeyCode
        waitingForKey = false
        KeybindButton.Text = "Set Auto Jump Keybind"
        AutoJumpButton.Text = "Auto Jump: " .. (getgenv().autojumpmpt and "ON" or "OFF") .. " (" .. currentKey.Name .. ")"
    elseif waitingForSuperJumpKey and not processed and input.UserInputType == Enum.UserInputType.Keyboard then
        getgenv().superjumpkey = input.KeyCode
        waitingForSuperJumpKey = false
        SuperJumpKeybindButton.Text = "Set Super Jump Keybind"
        SuperJumpButton.Text = "Super Jump: " .. (getgenv().superjumpenabled and "ON" or "OFF") .. " (" .. getgenv().superjumpkey.Name .. ")"
    elseif input.KeyCode == currentKey and not processed then
        getgenv().autojumpmpt = not getgenv().autojumpmpt
        AutoJumpButton.Text = "Auto Jump: " .. (getgenv().autojumpmpt and "ON" or "OFF") .. " (" .. currentKey.Name .. ")"
        IndicatorFrame.BackgroundColor3 = getgenv().autojumpmpt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        IndicatorStroke.Color = getgenv().autojumpmpt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    elseif input.KeyCode == getgenv().superjumpkey and not processed and getgenv().superjumpenabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Velocity = Vector3.new(0, getgenv().superjumpforce * 20, 0)
            bodyVelocity.Parent = humanoidRootPart
            game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
        end
    elseif input.KeyCode == Enum.KeyCode.Home and not processed then
        MainFrame.Visible = not MainFrame.Visible
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
