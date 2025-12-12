local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- Переменная для хранения оригинальных настроек
local OriginalSettings = {
    Technology = nil,
    GlobalShadows = nil,
    ShadowSoftness = nil,
    Brightness = nil,
    EnvironmentDiffuseScale = nil,
    EnvironmentSpecularScale = nil,
    Ambient = nil,
    ColorShift_Bottom = nil,
    ColorShift_Top = nil,
    OutdoorAmbient = nil
}

-- Оригинальные настройки эффектов
local OriginalEffects = {
    Bloom = {Enabled = nil, Intensity = nil},
    ColorCorrection = {Enabled = nil, Saturation = nil, Contrast = nil},
    SunRays = {Enabled = nil, Intensity = nil},
    Atmosphere = {Haze = nil, Density = nil, Glare = nil}
}

-- Оригинальные отражения объектов
local OriginalReflections = {}

-- Флаг состояния
local isPotatoModeActive = false

-- Сохраняем оригинальные настройки перед изменением
function saveOriginalSettings()
    print("💾 Сохраняю оригинальные настройки...")
    
    -- Сохраняем настройки освещения
    OriginalSettings.Technology = Lighting.Technology
    OriginalSettings.GlobalShadows = Lighting.GlobalShadows
    OriginalSettings.ShadowSoftness = Lighting.ShadowSoftness
    OriginalSettings.Brightness = Lighting.Brightness
    OriginalSettings.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
    OriginalSettings.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    OriginalSettings.Ambient = Lighting.Ambient
    OriginalSettings.ColorShift_Bottom = Lighting.ColorShift_Bottom
    OriginalSettings.ColorShift_Top = Lighting.ColorShift_Top
    OriginalSettings.OutdoorAmbient = Lighting.OutdoorAmbient
    
    -- Сохраняем настройки эффектов
    local bloom = Lighting:FindFirstChild("BloomEffect")
    if bloom then
        OriginalEffects.Bloom.Enabled = bloom.Enabled
        OriginalEffects.Bloom.Intensity = bloom.Intensity
    end
    
    local colorCorrection = Lighting:FindFirstChild("ColorCorrectionEffect")
    if colorCorrection then
        OriginalEffects.ColorCorrection.Enabled = colorCorrection.Enabled
        OriginalEffects.ColorCorrection.Saturation = colorCorrection.Saturation
        OriginalEffects.ColorCorrection.Contrast = colorCorrection.Contrast
    end
    
    local sunRays = Lighting:FindFirstChild("SunRaysEffect")
    if sunRays then
        OriginalEffects.SunRays.Enabled = sunRays.Enabled
        OriginalEffects.SunRays.Intensity = sunRays.Intensity
    end
    
    local atmosphere = Lighting:FindFirstChild("Atmosphere")
    if atmosphere then
        OriginalEffects.Atmosphere.Haze = atmosphere.Haze
        OriginalEffects.Atmosphere.Density = atmosphere.Density
        OriginalEffects.Atmosphere.Glare = atmosphere.Glare
    end
    
    -- Сохраняем отражения объектов
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Reflectance > 0 then
            OriginalReflections[obj] = obj.Reflectance
        end
    end
    
    print("✅ Оригинальные настройки сохранены")
end

function enablePotatoMode()
    if isPotatoModeActive then return end
    
    print("🌙 Включаю Night Mode...")
    
    -- Сохраняем настройки перед первым включением
    if not OriginalSettings.Technology then
        saveOriginalSettings()
    end
    
    -- 1. Отключаем все пост-эффекты
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    -- 2. Настраиваем освещение для производительности
    Lighting.Technology = Enum.Technology.Legacy
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Brightness = 0.8  -- Темнее для ночного режима
    Lighting.EnvironmentDiffuseScale = 0.2
    Lighting.EnvironmentSpecularScale = 0.2
    
    -- 3. Темные, холодные цвета для ночного режима
    Lighting.Ambient = Color3.fromRGB(30, 40, 50)
    Lighting.ColorShift_Bottom = Color3.fromRGB(40, 50, 70)
    Lighting.ColorShift_Top = Color3.fromRGB(80, 100, 120)
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 60, 80)
    
    -- 4. Минимальные настройки эффектов
    local bloom = Lighting:FindFirstChild("BloomEffect")
    if bloom then
        bloom.Enabled = false
        bloom.Intensity = 0.05
    end
    
    local colorCorrection = Lighting:FindFirstChild("ColorCorrectionEffect")
    if colorCorrection then
        colorCorrection.Enabled = false
        colorCorrection.Saturation = 0.6
        colorCorrection.Contrast = 0.1
        colorCorrection.TintColor = Color3.fromRGB(180, 200, 220) -- Холодный оттенок
    end
    
    local sunRays = Lighting:FindFirstChild("SunRaysEffect")
    if sunRays then
        sunRays.Enabled = false
        sunRays.Intensity = 0
    end
    
    local atmosphere = Lighting:FindFirstChild("Atmosphere")
    if atmosphere then
        atmosphere.Haze = 0.8
        atmosphere.Density = 0.3
        atmosphere.Glare = 0
        atmosphere.Color = Color3.fromRGB(50, 70, 100) -- Ночное небо
    end
    
    -- 5. Убираем все отражения (запоминаем что убрали)
    for obj, _ in pairs(OriginalReflections) do
        if obj.Parent then
            pcall(function()
                obj.Reflectance = 0
            end)
        end
    end
    
    isPotatoModeActive = true
    print("✅ Night Mode включен")
    return true
end

function disablePotatoMode()
    if not isPotatoModeActive then return end
    
    print("🌙 Выключаю Night Mode...")
    
    -- 1. Восстанавливаем настройки освещения
    if OriginalSettings.Technology then
        Lighting.Technology = OriginalSettings.Technology
        Lighting.GlobalShadows = OriginalSettings.GlobalShadows
        Lighting.ShadowSoftness = OriginalSettings.ShadowSoftness
        Lighting.Brightness = OriginalSettings.Brightness
        Lighting.EnvironmentDiffuseScale = OriginalSettings.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = OriginalSettings.EnvironmentSpecularScale
        Lighting.Ambient = OriginalSettings.Ambient
        Lighting.ColorShift_Bottom = OriginalSettings.ColorShift_Bottom
        Lighting.ColorShift_Top = OriginalSettings.ColorShift_Top
        Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
    else
        -- Стандартные настройки если не сохранили
        Lighting.Technology = Enum.Technology.ShadowMap
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.4
        Lighting.Brightness = 2.0
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 0.8
        Lighting.Ambient = Color3.fromRGB(70, 80, 100)
        Lighting.ColorShift_Bottom = Color3.fromRGB(100, 120, 160)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 245, 230)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
    
    -- 2. Восстанавливаем эффекты
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = true
        end
    end
    
    -- 3. Восстанавливаем конкретные настройки эффектов
    local bloom = Lighting:FindFirstChild("BloomEffect")
    if bloom and OriginalEffects.Bloom.Enabled ~= nil then
        bloom.Enabled = OriginalEffects.Bloom.Enabled
        bloom.Intensity = OriginalEffects.Bloom.Intensity
    end
    
    local colorCorrection = Lighting:FindFirstChild("ColorCorrectionEffect")
    if colorCorrection and OriginalEffects.ColorCorrection.Enabled ~= nil then
        colorCorrection.Enabled = OriginalEffects.ColorCorrection.Enabled
        colorCorrection.Saturation = OriginalEffects.ColorCorrection.Saturation
        colorCorrection.Contrast = OriginalEffects.ColorCorrection.Contrast
    end
    
    local sunRays = Lighting:FindFirstChild("SunRaysEffect")
    if sunRays and OriginalEffects.SunRays.Enabled ~= nil then
        sunRays.Enabled = OriginalEffects.SunRays.Enabled
        sunRays.Intensity = OriginalEffects.SunRays.Intensity
    end
    
    local atmosphere = Lighting:FindFirstChild("Atmosphere")
    if atmosphere and OriginalEffects.Atmosphere.Haze ~= nil then
        atmosphere.Haze = OriginalEffects.Atmosphere.Haze
        atmosphere.Density = OriginalEffects.Atmosphere.Density
        atmosphere.Glare = OriginalEffects.Atmosphere.Glare
    end
    
    -- 4. Восстанавливаем отражения объектов
    for obj, reflectance in pairs(OriginalReflections) do
        if obj.Parent then
            pcall(function()
                obj.Reflectance = reflectance
            end)
        end
    end
    
    -- 5. Удаляем временные данные
    for obj, _ in pairs(OriginalReflections) do
        if not obj.Parent then
            OriginalReflections[obj] = nil
        end
    end
    
    isPotatoModeActive = false
    print("✅ Night Mode выключен, все настройки восстановлены")
    return true
end

-- Функция переключения режима
function togglePotatoMode()
    if isPotatoModeActive then
        disablePotatoMode()
        return false
    else
        enablePotatoMode()
        return true
    end
end

-- Создаем маленький полупрозрачный чекбокс в правом нижнем углу
local function createNightModeGUI()
    if not player:FindFirstChild("PlayerGui") then
        wait(1)
    end
    
    -- Удаляем старый GUI если есть
    local oldGUI = player.PlayerGui:FindFirstChild("NightModeGUI")
    if oldGUI then
        oldGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NightModeGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Маленькая кнопка в правом нижнем углу
    local nightModeButton = Instance.new("TextButton")
    nightModeButton.Name = "NightModeButton"
    nightModeButton.Size = UDim2.new(0, 100, 0, 35) -- Маленький размер
    nightModeButton.Position = UDim2.new(1, -110, 1, -45) -- Правый нижний угол
    nightModeButton.AnchorPoint = Vector2.new(0, 0)
    
    -- Полупрозрачный темный фон
    nightModeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    nightModeButton.BackgroundTransparency = 0.4 -- Полупрозрачность
    nightModeButton.BorderSizePixel = 0
    
    -- Текст NightMode
    nightModeButton.Text = "NightMode"
    nightModeButton.TextColor3 = Color3.fromRGB(180, 200, 255) -- Светло-синий текст
    nightModeButton.Font = Enum.Font.GothamMedium
    nightModeButton.TextSize = 12
    
    -- Скругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = nightModeButton
    
    -- Тонкая рамка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 80, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = nightModeButton
    
    nightModeButton.Parent = screenGui
    
    -- Обновляем отображение кнопки
    local function updateButtonDisplay()
        if isPotatoModeActive then
            nightModeButton.Text = "🌙 ON"
            nightModeButton.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
            nightModeButton.BackgroundTransparency = 0.3
            nightModeButton.TextColor3 = Color3.fromRGB(150, 200, 255)
        else
            nightModeButton.Text = "NightMode"
            nightModeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            nightModeButton.BackgroundTransparency = 0.4
            nightModeButton.TextColor3 = Color3.fromRGB(180, 200, 255)
        end
    end
    
    -- Обработчик клика
    nightModeButton.MouseButton1Click:Connect(function()
        local success = togglePotatoMode()
        if success then
            updateButtonDisplay()
        end
    end)
    
    -- Эффекты наведения (слегка подсвечиваем)
    nightModeButton.MouseEnter:Connect(function()
        local currentTransparency = nightModeButton.BackgroundTransparency
        nightModeButton.BackgroundTransparency = currentTransparency - 0.15
        nightModeButton.TextColor3 = Color3.fromRGB(200, 220, 255)
    end)
    
    nightModeButton.MouseLeave:Connect(function()
        updateButtonDisplay()
    end)
    
    -- Анимация при нажатии
    nightModeButton.MouseButton1Down:Connect(function()
        local originalSize = nightModeButton.Size
        nightModeButton.Size = UDim2.new(0, 95, 0, 33)
    end)
    
    nightModeButton.MouseButton1Up:Connect(function()
        nightModeButton.Size = UDim2.new(0, 100, 0, 35)
    end)
    
    -- Первоначальное отображение
    updateButtonDisplay()
    
    -- Делаем кнопку перетаскиваемой (опционально)
    local dragging = false
    local dragStart, startPos
    
    nightModeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = nightModeButton.Position
        end
    end)
    
    nightModeButton.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            nightModeButton.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    nightModeButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    print("✅ Night Mode GUI создан (правый нижний угол)")
    return screenGui
end

-- Автоматическое сохранение настроек при старте
spawn(function()
    wait(3) -- Ждем полной загрузки
    
    saveOriginalSettings()
    
    -- Создаем GUI
    createNightModeGUI()
    
    -- Команда в чат
    player.Chatted:Connect(function(message)
        local msg = message:lower()
        
        if msg == "/night" or msg == "/nightmode" or msg == "/nm" then
            local wasEnabled = togglePotatoMode()
            print(wasEnabled and "🌙 Night Mode ВКЛЮЧЕН" or "🌙 Night Mode ВЫКЛЮЧЕН")
        end
    end)
    
    print("🌙 Night Mode System Ready!")
    print("Команды: /night - переключить режим")
end)

-- Экспортируем функции для глобального доступа
_G.NightMode = {
    Enable = enablePotatoMode,
    Disable = disablePotatoMode,
    Toggle = togglePotatoMode,
    IsActive = function() return isPotatoModeActive end
}
