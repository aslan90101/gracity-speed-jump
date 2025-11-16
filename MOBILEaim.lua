local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Переменная для отслеживания активного аима
local isAiming = false
local currentTarget = nil
local aimButton = nil

-- Функция для поиска ближайшего игрока
local function findClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local localPosition = localCharacter.HumanoidRootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local distance = (player.Character.Head.Position - localPosition).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

-- Функция для наведения камеры на голову цели
local function aimAtTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then
        return false
    end
    
    local targetPosition = target.Character.Head.Position
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    return true
end

-- Функция для симуляции выстрела
local function simulateShot()
    local character = LocalPlayer.Character
    if character then
        -- Пытаемся найти инструмент и активировать его
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        -- Альтернативный способ через VirtualInputManager
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.05)
        virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

-- Функция для начала аима
local function startAim()
    if isAiming then return end
    
    isAiming = true
    currentTarget = findClosestPlayer()
    
    if currentTarget then
        -- Наводимся на цель
        aimAtTarget(currentTarget)
        
        -- Ждем немного
        wait(0.01)
        
        -- Симулируем выстрел/удар
        simulateShot()
        
        -- Меняем цвет кнопки когда аим активен
        if aimButton then
            aimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        if aimButton then
            aimButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            wait(0.5)
            if aimButton then
                aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

-- Функция для остановки аима
local function stopAim()
    isAiming = false
    currentTarget = nil
    
    -- Возвращаем обычный цвет кнопки
    if aimButton then
        aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Функция создания кнопки аима
local function createAimButton()
    -- Проверяем, существует ли уже кнопка
    if aimButton and aimButton.Parent then
        return
    end
    
    -- Ждем пока PlayerGui будет доступен
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimBotGui"
    screenGui.DisplayOrder = 10
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Создаем кнопку
    aimButton = Instance.new("TextButton")
    aimButton.Name = "AimButton"
    aimButton.Size = UDim2.new(0, 120, 0, 60)
    aimButton.Position = UDim2.new(0, 20, 0.5, -30)
    aimButton.AnchorPoint = Vector2.new(0, 0.5)
    aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    aimButton.BackgroundTransparency = 0.3
    aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimButton.Text = "AIM"
    aimButton.TextScaled = true
    aimButton.Font = Enum.Font.GothamBold
    aimButton.TextStrokeTransparency = 0.5
    
    -- Стилизация кнопки
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = aimButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = aimButton
    
    aimButton.Parent = screenGui
    
    -- Обработчики для мобильных устройств
    local touchStartTime = 0
    
    aimButton.TouchTap:Connect(function()
        startAim()
        wait(0.1)
        stopAim()
    end)
    
    aimButton.TouchLongPress:Connect(function()
        startAim()
    end)
    
    -- Для долгого нажатия
    aimButton.TouchStarted:Connect(function()
        touchStartTime = tick()
    end)
    
    aimButton.TouchEnded:Connect(function()
        if tick() - touchStartTime > 0.5 then
            -- Долгое нажатие - останавливаем аим
            stopAim()
        end
    end)
    
    -- Анимация при нажатии
    aimButton.MouseButton1Down:Connect(function()
        local tween = TweenService:Create(aimButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 110, 0, 55)})
        tween:Play()
    end)
    
    aimButton.MouseButton1Up:Connect(function()
        local tween = TweenService:Create(aimButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 120, 0, 60)})
        tween:Play()
    end)
    
    print("Aim button created successfully!")
end

-- Обработка нажатия кнопки Q (для ПК)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        startAim()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Q then
        stopAim()
    end
end)

-- Обработка тапов на экране (альтернативный способ)
UserInputService.TouchStarted:Connect(function(touch, gameProcessedEvent)
    if gameProcessedEvent then return end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessedEvent)
    if gameProcessedEvent then return end
end)

-- Автоматическое создание кнопки при загрузке
local function initialize()
    -- Ждем пока игрок полностью загрузится
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    wait(2) -- Даем время на полную загрузку
    
    -- Создаем кнопку
    createAimButton()
end

-- Запускаем инициализацию
spawn(initialize)

-- Также создаем кнопку при появлении нового персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(2)
    createAimButton()
end)

-- Обновление камеры при активном аиме
RunService.RenderStepped:Connect(function()
    if isAiming and currentTarget then
        if not aimAtTarget(currentTarget) then
            -- Если цель потеряна, ищем новую
            currentTarget = findClosestPlayer()
            if not currentTarget then
                stopAim()
            end
        end
    end
end)

-- Убираем кнопку при выходе из игры
game:GetService("CoreGui").DescendantRemoving:Connect(function(descendant)
    if descendant == aimButton then
        aimButton = nil
    end
end)
