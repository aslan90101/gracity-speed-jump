local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Переменные для аима
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

-- Функция для плавного наведения камеры на цель
local function aimAtTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then
        return false
    end
    
    local targetPosition = target.Character.Head.Position
    local currentCFrame = Camera.CFrame
    
    -- Плавное перемещение камеры
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {}
    goal.CFrame = CFrame.new(currentCFrame.Position, targetPosition)
    
    local tween = TweenService:Create(Camera, tweenInfo, goal)
    tween:Play()
    
    return true
end

-- Функция для начала аима
local function startAim()
    if isAiming then return end
    
    isAiming = true
    currentTarget = findClosestPlayer()
    
    if currentTarget then
        -- Меняем цвет кнопки когда аим активен
        if aimButton then
            aimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            aimButton.Text = "AIMING"
        end
    else
        if aimButton then
            aimButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            aimButton.Text = "NO TARGET"
            wait(0.5)
            if aimButton then
                aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                aimButton.Text = "AIM"
            end
        end
        isAiming = false
    end
end

-- Функция для остановки аима
local function stopAim()
    isAiming = false
    currentTarget = nil
    
    -- Возвращаем обычный цвет кнопки
    if aimButton then
        aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        aimButton.Text = "AIM"
    end
end

-- Функция создания кнопки аима
local function createAimButton()
    -- Проверяем, существует ли уже кнопка
    if aimButton and aimButton.Parent then
        aimButton:Destroy()
    end
    
    -- Ждем пока PlayerGui будет доступен
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Удаляем старый ScreenGui если есть
    local oldGui = playerGui:FindFirstChild("AimBotGui")
    if oldGui then
        oldGui:Destroy()
    end
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimBotGui"
    screenGui.DisplayOrder = 100
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Создаем кнопку в левой части экрана
    aimButton = Instance.new("TextButton")
    aimButton.Name = "AimButton"
    aimButton.Size = UDim2.new(0, 120, 0, 60)
    
    -- Позиция: левая сторона, выше контроллера ходьбы
    aimButton.Position = UDim2.new(0, 30, 0, 50) -- 30 от левого края, 50 от верхнего
    aimButton.AnchorPoint = Vector2.new(0, 0)
    aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    aimButton.BackgroundTransparency = 0.3
    aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimButton.Text = "AIM"
    aimButton.TextScaled = true
    aimButton.Font = Enum.Font.GothamBold
    aimButton.TextStrokeTransparency = 0.5
    aimButton.Modal = false
    aimButton.Active = true
    aimButton.Selectable = true
    aimButton.AutoButtonColor = false
    aimButton.ZIndex = 100
    
    -- Стилизация кнопки
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = aimButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = aimButton
    
    -- Добавляем тень для лучшей видимости
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = aimButton
    
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
                wait(0.3)
                if isAimButtonPressed and tick() - touchStartTime >= 0.3 then
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
                stopAim()
                longPressActive = false
            else
                if tick() - touchStartTime < 0.3 then
                    startAim()
                end
            end
        end
    end)
    
    print("Aim button created in left side!")
end

-- Функция для проверки платформы
local function isMobile()
    return UserInputService.TouchEnabled
end

-- Основная инициализация
local function initialize()
    if not isMobile() then
        return
    end
    
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    wait(2)
    createAimButton()
end

-- Запускаем инициализацию
spawn(initialize)

-- Создаем кнопку при появлении нового персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(2)
    if isMobile() then
        createAimButton()
    end
end)

-- Обновление камеры при активном аиме
RunService.Heartbeat:Connect(function()
    if isAiming and currentTarget then
        if not aimAtTarget(currentTarget) then
            stopAim()
        end
    end
end)

-- Пересоздаем кнопку если она пропала
while true do
    wait(5)
    if isMobile() and (not aimButton or not aimButton.Parent) then
        createAimButton()
    end
end
