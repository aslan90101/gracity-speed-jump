-- ESP Script for Roblox (Fixed Respawn Issue)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

-- Создаем интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Чекбокс для включения/выключения ESP
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0, 120, 0, 35)
toggleFrame.Position = UDim2.new(0, 10, 1, -45)
toggleFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
toggleFrame.BackgroundTransparency = 0.3
toggleFrame.BorderSizePixel = 1
toggleFrame.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
toggleFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 5)
UICorner.Parent = toggleFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundTransparency = 1
toggleButton.Text = "ESP: OFF"
toggleButton.TextColor3 = Color3.new(1, 0.3, 0.3)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = toggleFrame

-- Таблицы для хранения ESP объектов
local espFolders = {}
local espConnections = {}
local espEnabled = false

-- Функция очистки ESP игрока
local function cleanupPlayerESP(player)
    if espConnections[player] then
        for _, connection in pairs(espConnections[player]) do
            if connection and typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
        espConnections[player] = nil
    end
    
    if espFolders[player] then
        espFolders[player]:Destroy()
        espFolders[player] = nil
    end
end

-- Функция получения цвета команды
local function getTeamColor(player)
    if player and player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.new(1, 1, 1)
end

-- Функция создания Highlight
local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.FillTransparency = 0.9
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    return highlight
end

-- Функция создания ESP для игрока
local function createESP(player)
    if player == localPlayer then return end
    
    -- Очищаем старые ESP если есть
    cleanupPlayerESP(player)
    
    local character = player.Character
    if not character then
        -- Ждем появления персонажа
        local characterConnection
        characterConnection = player.CharacterAdded:Connect(function(newChar)
            wait(2) -- Даем время на полное возрождение
            createESP(player)
        end)
        
        espConnections[player] = espConnections[player] or {}
        espConnections[player].characterAdded = characterConnection
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        -- Ждем появления humanoid
        wait(1)
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
    end
    
    -- Создаем папку для ESP объектов игрока
    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name .. "_ESP"
    espFolder.Parent = screenGui
    espFolders[player] = espFolder
    
    -- Создаем Highlight
    local highlight = createHighlight(character)
    highlight.Parent = espFolder
    
    -- Флаг для отслеживания состояния
    local isAlive = true
    
    -- Функция обновления ESP
    local function updateESP()
        if not espEnabled or not character or not character.Parent then
            cleanupPlayerESP(player)
            return
        end
        
        -- Проверяем жив ли игрок
        if humanoid.Health <= 0 then
            if isAlive then
                isAlive = false
                -- Не очищаем сразу, а ждем возрождения
                for _, obj in pairs(espFolder:GetChildren()) do
                    if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("TextLabel") then
                        obj.Visible = false
                    end
                end
                highlight.Enabled = false
            end
            return
        else
            if not isAlive then
                -- Игрок возродился
                isAlive = true
                highlight.Enabled = true
            end
        end
        
        local head = character:FindFirstChild("Head")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not head or not humanoidRootPart then 
            return
        end
        
        -- Получаем позицию на экране
        local headPos, headOnScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
        
        if not headOnScreen then
            -- Скрываем ESP если игрок не на экране
            for _, obj in pairs(espFolder:GetChildren()) do
                if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("TextLabel") then
                    obj.Visible = false
                end
            end
            return
        end
        
        -- Обновляем Highlight цвет
        highlight.OutlineColor = getTeamColor(player)
        highlight.Enabled = true
        
        -- Создаем или обновляем круг с аватаром
        local avatarCircle = espFolder:FindFirstChild("AvatarCircle")
        if not avatarCircle then
            avatarCircle = Instance.new("Frame")
            avatarCircle.Name = "AvatarCircle"
            avatarCircle.Size = UDim2.new(0, 50, 0, 50)
            avatarCircle.BackgroundColor3 = getTeamColor(player)
            avatarCircle.BorderSizePixel = 2
            avatarCircle.BorderColor3 = Color3.new(1, 1, 1)
            avatarCircle.ZIndex = 10
            
            local UICorner2 = Instance.new("UICorner")
            UICorner2.CornerRadius = UDim.new(1, 0)
            UICorner2.Parent = avatarCircle
            
            local avatarImage = Instance.new("ImageLabel")
            avatarImage.Name = "Avatar"
            avatarImage.Size = UDim2.new(0, 42, 0, 42)
            avatarImage.Position = UDim2.new(0, 4, 0, 4)
            avatarImage.BackgroundTransparency = 1
            avatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            avatarImage.ZIndex = 11
            
            local UICorner3 = Instance.new("UICorner")
            UICorner3.CornerRadius = UDim.new(1, 0)
            UICorner3.Parent = avatarImage
            
            avatarImage.Parent = avatarCircle
            
            -- Загружаем аватар
            spawn(function()
                local success, result = pcall(function()
                    return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if success and avatarImage and avatarImage.Parent then
                    avatarImage.Image = result
                end
            end)
            
            avatarCircle.Parent = espFolder
        end
        
        -- Создаем или обновляем имя
        local nameLabel = espFolder:FindFirstChild("DisplayName")
        if not nameLabel then
            nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "DisplayName"
            nameLabel.Size = UDim2.new(0, 0, 0, 20)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.DisplayName
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.ZIndex = 10
            nameLabel.Parent = espFolder
        end
        
        -- Обновляем позиции
        avatarCircle.Position = UDim2.new(0, headPos.X - 25, 0, headPos.Y - 100)
        avatarCircle.Visible = true
        
        -- Автоматический размер для текста
        local textSize = game:GetService("TextService"):GetTextSize(player.DisplayName, 14, Enum.Font.GothamBold, Vector2.new(1000, 20))
        nameLabel.Size = UDim2.new(0, textSize.X + 10, 0, 20)
        nameLabel.Position = UDim2.new(0, headPos.X - (textSize.X + 10) / 2, 0, headPos.Y - 40)
        nameLabel.Visible = true
        
        -- Показываем все элементы
        for _, obj in pairs(espFolder:GetChildren()) do
            if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("TextLabel") then
                obj.Visible = true
            end
        end
    end
    
    -- Соединение для обновления
    local renderConnection
    local function startESP()
        if renderConnection then
            renderConnection:Disconnect()
        end
        
        renderConnection = RunService.RenderStepped:Connect(updateESP)
        
        -- Сохраняем соединения
        espConnections[player] = espConnections[player] or {}
        espConnections[player].render = renderConnection
    end
    
    -- Обработчик возрождения
    local function onRespawn()
        wait(2) -- Даем время на полное возрождение
        if espEnabled and player and player.Parent then
            cleanupPlayerESP(player)
            wait(0.5)
            createESP(player)
        end
    end
    
    -- Соединения для событий
    espConnections[player] = espConnections[player] or {}
    
    -- Соединение для смерти и возрождения
    espConnections[player].humanoidDied = humanoid.Died:Connect(onRespawn)
    
    -- Соединение для удаления персонажа
    espConnections[player].ancestryChanged = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            onRespawn()
        end
    end)
    
    if espEnabled then
        startESP()
    end
end

-- Функция обновления всех ESP
local function refreshAllESP()
    if not espEnabled then return end
    
    print("Обновление всех ESP...")
    
    -- Очищаем все старые ESP
    for player, _ in pairs(espFolders) do
        cleanupPlayerESP(player)
    end
    
    -- Создаем ESP для всех игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            spawn(function()
                createESP(player)
            end)
        end
    end
end

-- Функция переключения ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        toggleButton.Text = "ESP: ON"
        toggleButton.TextColor3 = Color3.new(0.3, 1, 0.3)
        
        -- Создаем ESP для всех существующих игроков
        refreshAllESP()
    else
        toggleButton.Text = "ESP: OFF"
        toggleButton.TextColor3 = Color3.new(1, 0.3, 0.3)
        
        -- Удаляем все ESP
        for player, _ in pairs(espFolders) do
            cleanupPlayerESP(player)
        end
    end
end

-- Обработчик клика по кнопке
toggleButton.MouseButton1Click:Connect(toggleESP)

-- Обработчики для новых игроков
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        spawn(function()
            wait(2) -- Даем время на загрузку
            createESP(player)
        end)
    end
    
    -- Отслеживаем смену персонажа
    player.CharacterAdded:Connect(function(character)
        if espEnabled then
            wait(2) -- Даем время на полное возрождение
            createESP(player)
        end
    end)
end)

-- Обработчик для игроков, которые вышли
Players.PlayerRemoving:Connect(function(player)
    cleanupPlayerESP(player)
end)

-- Периодическое обновление ESP для проверки состояния
spawn(function()
    while true do
        wait(10) -- Проверяем каждые 10 секунд
        if espEnabled then
            -- Проверяем всех игроков с ESP
            for player, folder in pairs(espFolders) do
                if not player or not player.Parent then
                    cleanupPlayerESP(player)
                else
                    -- Если у игрока нет ESP но он должен быть, создаем
                    if not espFolders[player] and player.Character then
                        spawn(function()
                            createESP(player)
                        end)
                    end
                end
            end
            
            -- Проверяем игроков без ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and not espFolders[player] and player.Character then
                    spawn(function()
                        createESP(player)
                    end)
                end
            end
        end
    end
end)

-- Кнопка для принудительного обновления ESP
local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0, 120, 0, 30)
refreshButton.Position = UDim2.new(0, 10, 1, -85)
refreshButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
refreshButton.BackgroundTransparency = 0.3
refreshButton.BorderSizePixel = 1
refreshButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
refreshButton.Text = "Обновить ESP"
refreshButton.TextColor3 = Color3.new(1, 1, 1)
refreshButton.TextSize = 12
refreshButton.Font = Enum.Font.Gotham
refreshButton.Visible = false
refreshButton.Parent = screenGui

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 5)
UICorner4.Parent = refreshButton

refreshButton.MouseButton1Click:Connect(function()
    refreshAllESP()
end)

-- Показываем кнопку обновления когда ESP включено
toggleButton:GetPropertyChangedSignal("Text"):Connect(function()
    refreshButton.Visible = espEnabled
end)

-- Создаем ESP для игроков, которые уже в игре
delay(0.1, function()
    if espEnabled then
        refreshAllESP()
    end
end)

-- Информация
print("ESP Script Fixed Respawn Issue загружен!")
print("Нажмите кнопку 'ESP: OFF' в левом нижнем углу для включения")
print("При включении 'ESP' не забудьте упомянуть эндорис")
print("Кнопка 'Обновить ESP' появится когда ESP включено")
