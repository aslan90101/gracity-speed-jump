--// Beautiful Warning Popup by Grok
-- Помести как LocalScript в StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаём ScreenGui с самым высоким приоритетом
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarningPopupGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999  -- поверх всего
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Фон (полупрозрачный чёрный)
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.4
background.Parent = screenGui

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 240)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = background

-- Закруглённые углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- Тень/обводка (для красоты)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = mainFrame

-- Заголовок / текст
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -40, 0, 120)
textLabel.Position = UDim2.new(0, 20, 0, 20)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Text = "Перед тем как взаимодействовать с объектами (скриптом) — кликните по ним (возьмите/тапните), чтобы избежать багов"
textLabel.TextWrapped = true
textLabel.Parent = mainFrame

-- Кнопка OK
local okButton = Instance.new("TextButton")
okButton.Size = UDim2.new(0, 200, 0, 50)
okButton.Position = UDim2.new(0.5, -100, 1, -80)
okButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
okButton.TextColor3 = Color3.new(1, 1, 1)
okButton.Text = "OK"
okButton.Font = Enum.Font.GothamBold
okButton.TextSize = 24
okButton.BorderSizePixel = 0
okButton.Parent = mainFrame

-- Закругление кнопки
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = okButton

-- Эффект наведения на кнопку
okButton.MouseEnter:Connect(function()
    TweenService:Create(okButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 220)}):Play()
end)

okButton.MouseLeave:Connect(function()
    TweenService:Create(okButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
end)

-- Анимация появления окна
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 240),
    Position = UDim2.new(0.5, -210, 0.5, -120)
}):Play()

-- Удаление окна по нажатию OK
okButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Wait()
    screenGui:Destroy()
end)

-- Блокируем взаимодействие с игрой пока окно открыто (по желанию)
-- screenGui.Enabled = true (уже включено)
