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
Title.Text = "Gravity Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MenuFrame

-- Фрейм для слайдера
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
SliderFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.Parent = MenuFrame

-- Ползунок слайдера
local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(0, 10, 0, 20)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.Text = ""
SliderButton.Parent = SliderFrame

-- Текст текущего значения гравитации
local GravityLabel = Instance.new("TextLabel")
GravityLabel.Size = UDim2.new(0.8, 0, 0, 30)
GravityLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
GravityLabel.BackgroundTransparency = 1
GravityLabel.Text = "Gravity: 196.2"
GravityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GravityLabel.Font = Enum.Font.SourceSans
GravityLabel.TextSize = 16
GravityLabel.Parent = MenuFrame

-- Функция установки гравитации игрока
local function setGravity(gravity)
    game.Workspace.Gravity = gravity
    GravityLabel.Text = "Gravity: " .. math.floor(gravity * 10) / 10
end

-- Логика слайдера
local UserInputService = game:GetService("UserInputService")
local dragging = false

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local frameAbsPos = SliderFrame.AbsolutePosition.X
        local frameWidth = SliderFrame.AbsoluteSize.X
        local relativeX = math.clamp((mouseX - frameAbsPos) / frameWidth, 0, 1)
        
        -- Вычисляем позицию ползунка
        SliderButton.Position = UDim2.new(relativeX, -5, 0, 0)
        
        -- Вычисляем гравитацию (от 1 до 400)
        local gravity = 1 + (relativeX * 399)
        setGravity(gravity)
    end
end)

-- Начальная установка гравитации
setGravity(196.2)
