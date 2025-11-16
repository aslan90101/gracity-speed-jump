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

-- Функция для наведения камеры на цель
local function aimAtTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then
        return false
    end
    
    local targetPosition = target.Character.Head.Position
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    return true
end

-- Функция для автоматического нажатия (стрельбы)
local function simulateShot()
    local character = LocalPlayer.Character
    if character then
        -- Пытаемся найти инструмент и активировать его
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        -- Симуляция клика мыши для стрельбы
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
        -- Меняем цвет кнопки когда аим активен
        if aimButton then
            aimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            aimButton.Text = "AIMING"
        end
        
        -- Наводимся на цель
        aimAtTarget(currentTarget)
        
        -- Ждем немного для точности
        wait(0.05)
        
        -- АВТОМАТИЧЕСКОЕ НАЖАТИЕ после наводки
        simulateShot()
        
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
    
    -- Создаем кнопку
    aimButton = Instance.new("TextButton")
    aimButton.Name = "AimButton"
    aimButton.Size = UDim2.new(0, 150, 0, 70)
    aimButton.Position = UDim2.new(1, -160, 0, 20)
    aimButton.AnchorPoint = Vector2.new(1, 0)
    aimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    aimButton.BackgroundTransparency = 0.2
    aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimButton.Text = "AIM"
    aimButton.TextScaled = true
    aimButton.Font = Enum.Font.GothamBold
    aimButton.TextStrokeTransparency = 0.5
    aimButton.Modal = false
    aimButton.Active = true
    aimButton.Selectable = true
    aimButton.AutoButtonColor = false
    
    -- Стилизация кнопки
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = aimButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 3
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
                Size = UDim2.new(0, 140, 0, 65),
                BackgroundTransparency = 0.1
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
                Size = UDim2.new(0, 150, 0, 70),
                BackgroundTransparency = 0.2
            })
            tween:Play()
            
            if longPressActive then
                -- Если было долгое нажатие, останавливаем аим
                stopAim()
                longPressActive = false
            else
                -- Короткое нажатие - быстрый аим с авто-нажатием
                if tick() - touchStartTime < 0.3 then
                    startAim()
                    -- Автоматически останавливаем аим после выстрела
                    wait(0.1)
                    stopAim()
                end
            end
        end
    end)
    
    print("Aim button created successfully!")
end

-- Функция для проверки платформы (только мобильные устройства)
local function isMobile()
    return UserInputService.TouchEnabled
end

-- Основная инициализация
local function initialize()
    if not isMobile() then
        print("This script is for mobile devices only!")
        return
    end
    
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    wait(3)
    createAimButton()
    print("Mobile AimBot with auto-shot initialized!")
end

-- Запускаем инициализацию
spawn(initialize)

-- Создаем кнопку при появлении нового персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(3)
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

-- Очистка при выходе из игры
game:GetService("CoreGui").DescendantRemoving:Connect(function(descendant)
    if descendant == aimButton then
        aimButton = nil
    end
end)

-- Защита от множественного запуска
if _G.MobileAimBotLoaded then
    script:Destroy()
    return
end

_G.MobileAimBotLoaded = true

-- Пересоздаем кнопку если она пропала
while true do
    wait(5)
    if isMobile() and (not aimButton or not aimButton.Parent) then
        createAimButton()
    end
end
