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
local isAimButtonPressed = false

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
    aimButton.Position = UDim2.new(1, -140, 0.5, -30) -- Правая сторона экрана
    aimButton.AnchorPoint = Vector2.new(1, 0.5)
    aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    aimButton.BackgroundTransparency = 0.3
    aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimButton.Text = "AIM"
    aimButton.TextScaled = true
    aimButton.Font = Enum.Font.GothamBold
    aimButton.TextStrokeTransparency = 0.5
    aimButton.Modal = false -- Важно: позволяет другим элементам получать ввод
    aimButton.Active = true
    aimButton.Selectable = true
    
    -- Стилизация кнопки
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = aimButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = aimButton
    
    aimButton.Parent = screenGui
    
    -- Переменные для отслеживания касаний
    local touchStartTime = 0
    local longPressActive = false
    local currentTouchInput = nil
    
    -- Обработка начала касания кнопки
    aimButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            currentTouchInput = input
            isAimButtonPressed = true
            touchStartTime = tick()
            longPressActive = false
            
            -- Анимация нажатия
            local tween = TweenService:Create(aimButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 110, 0, 55),
                BackgroundTransparency = 0.2
            })
            tween:Play()
            
            -- Запускаем проверку долгого нажатия
            spawn(function()
                wait(0.5) -- 0.5 секунды для долгого нажатия
                if isAimButtonPressed and tick() - touchStartTime >= 0.5 then
                    longPressActive = true
                    startAim()
                end
            end)
        end
    end)
    
    -- Обработка окончания касания кнопки
    aimButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and input == currentTouchInput then
            currentTouchInput = nil
            isAimButtonPressed = false
            
            -- Анимация отпускания
            local tween = TweenService:Create(aimButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 120, 0, 60),
                BackgroundTransparency = 0.3
            })
            tween:Play()
            
            if longPressActive then
                -- Если было долгое нажатие, останавливаем аим
                stopAim()
                longPressActive = false
            else
                -- Короткое нажатие - быстрый аим
                if tick() - touchStartTime < 0.5 then
                    startAim()
                    wait(0.1)
                    stopAim()
                end
            end
        end
    end)
    
    -- Для ПК - обычное нажатие мышкой
    aimButton.MouseButton1Down:Connect(function()
        local tween = TweenService:Create(aimButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 110, 0, 55),
            BackgroundTransparency = 0.2
        })
        tween:Play()
    end)
    
    aimButton.MouseButton1Up:Connect(function()
        local tween = TweenService:Create(aimButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 120, 0, 60),
            BackgroundTransparency = 0.3
        })
        tween:Play()
        
        -- Для ПК - быстрый аим по клику
        startAim()
        wait(0.1)
        stopAim()
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

-- Функция для проверки, находится ли касание в области джойстика
local function isTouchInJoystickArea(touchPosition)
    -- Предполагаем, что джойстик находится в левой части экрана
    local screenSize = Camera.ViewportSize
    local joystickArea = {
        X = {0, screenSize.X * 0.4},  -- Левые 40% экрана
        Y = {screenSize.Y * 0.4, screenSize.Y * 0.8}  -- Центральная часть по вертикали
    }
    
    return touchPosition.X >= joystickArea.X[1] and 
           touchPosition.X <= joystickArea.X[2] and
           touchPosition.Y >= joystickArea.Y[1] and 
           touchPosition.Y <= joystickArea.Y[2]
end

-- Обработчик для пропуска касаний в области джойстика
UserInputService.TouchStarted:Connect(function(touch, gameProcessedEvent)
    if gameProcessedEvent then return end
    
    -- Если касание в области джойстика, не обрабатываем его
    if isTouchInJoystickArea(touch.Position) then
        return
    end
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

-- Дополнительная защита: пересоздаем кнопку если она была удалена
while true do
    wait(10)
    if not aimButton or not aimButton.Parent then
        createAimButton()
    end
end
