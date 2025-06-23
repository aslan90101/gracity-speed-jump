-- Создаем ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "CustomMenu"

-- Создаем основной фрейм меню
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 150)
MenuFrame.Position = UDim2.new(0.5, -100, 0, 10) -- Позиция вверху экрана
MenuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MenuFrame.BorderSizePixel = 0
MenuFrame.Parent = ScreenGui
MenuFrame.Active = true
MenuFrame.Draggable = true

-- Закругленные углы для фрейма
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MenuFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Infinite Jump Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MenuFrame

-- Фрейм для чекбокса
local CheckboxFrame = Instance.new("Frame")
CheckboxFrame.Size = UDim2.new(0.8, 0, 0, 30)
CheckboxFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
CheckboxFrame.BackgroundTransparency = 1
CheckboxFrame.Parent = MenuFrame

-- Чекбокс
local CheckboxButton = Instance.new("TextButton")
CheckboxButton.Size = UDim2.new(0, 20, 0, 20)
CheckboxButton.Position = UDim2.new(0, 0, 0, 5)
CheckboxButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CheckboxButton.Text = ""
CheckboxButton.Parent = CheckboxFrame

-- Текст чекбокса
local CheckboxLabel = Instance.new("TextLabel")
CheckboxLabel.Size = UDim2.new(0.8, 0, 0, 30)
CheckboxLabel.Position = UDim2.new(0.15, 0, 0, 0)
CheckboxLabel.BackgroundTransparency = 1
CheckboxLabel.Text = "Infinite Jump: OFF"
CheckboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckboxLabel.Font = Enum.Font.SourceSans
CheckboxLabel.TextSize = 16
CheckboxLabel.Parent = CheckboxFrame

-- Переменная для состояния чекбокса
local infJumpEnabled = false

-- Функция для бесконечного прыжка
local UserInputService = game:GetService("UserInputService")
local function enableInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled then
            local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- Логика чекбокса
CheckboxButton.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        CheckboxButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        CheckboxLabel.Text = "Infinite Jump: ON"
        enableInfiniteJump()
    else
        CheckboxButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CheckboxLabel.Text = "Infinite Jump: OFF"
    end
end)
