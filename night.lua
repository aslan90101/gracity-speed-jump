local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Переменные для оригинальных настроек (расширенные, как во второй версии)
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
    OutdoorAmbient = nil,
    ClockTime = nil,
    TimeOfDay = nil
}

local OriginalEffects = {
    Bloom = {Enabled = nil, Intensity = nil},
    ColorCorrection = {Enabled = nil, Saturation = nil, Contrast = nil, TintColor = nil},
    SunRays = {Enabled = nil, Intensity = nil},
    Atmosphere = {Haze = nil, Density = nil, Glare = nil, Color = nil}
}

local OriginalReflections = {}
local OriginalSkySettings = {}
local OriginalClouds = {}

local isPotatoModeActive = false
local hintShown = false  -- Подсказка показывается только один раз

function saveOriginalSettings()
    print("💾 Сохраняю оригинальные настройки...")

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
    OriginalSettings.ClockTime = Lighting.ClockTime
    OriginalSettings.TimeOfDay = Lighting.TimeOfDay

    -- Эффекты
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
        OriginalEffects.ColorCorrection.TintColor = colorCorrection.TintColor
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
        OriginalEffects.Atmosphere.Color = atmosphere.Color
    end

    -- Отражения
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Reflectance > 0 then
            OriginalReflections[obj] = obj.Reflectance
        end
    end

    -- Небо
    for _, skyObj in pairs(Lighting:GetChildren()) do
        if skyObj:IsA("Sky") then
            OriginalSkySettings[skyObj.Name] = {
                CelestialBodiesShown = skyObj.CelestialBodiesShown,
                MoonAngularSize = skyObj.MoonAngularSize,
                MoonTextureId = skyObj.MoonTextureId,
                SkyboxBk = skyObj.SkyboxBk,
                SkyboxDn = skyObj.SkyboxDn,
                SkyboxFt = skyObj.SkyboxFt,
                SkyboxLf = skyObj.SkyboxLf,
                SkyboxRt = skyObj.SkyboxRt,
                SkyboxUp = skyObj.SkyboxUp,
                StarCount = skyObj.StarCount,
                SunAngularSize = skyObj.SunAngularSize,
                SunTextureId = skyObj.SunTextureId
            }
        end
    end

    -- Облака
    local clouds = Lighting:FindFirstChild("Clouds")
    if clouds then
        OriginalClouds.Color = clouds.Color
        OriginalClouds.Cover = clouds.Cover
        OriginalClouds.Density = clouds.Density
    end

    print("✅ Оригинальные настройки сохранены")
end

function enablePotatoMode()
    if isPotatoModeActive then return end

    print("🌙 Включаю Night Mode...")

    if not OriginalSettings.Technology then
        saveOriginalSettings()
    end

    -- Отключаем все пост-эффекты (как в первой версии)
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end

    Lighting.Technology = Enum.Technology.Legacy
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Brightness = 0.8
    Lighting.EnvironmentDiffuseScale = 0.2
    Lighting.EnvironmentSpecularScale = 0.2

    -- Темные, холодные цвета (из первой версии)
    Lighting.Ambient = Color3.fromRGB(30, 40, 50)
    Lighting.ColorShift_Bottom = Color3.fromRGB(40, 50, 70)
    Lighting.ColorShift_Top = Color3.fromRGB(80, 100, 120)
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 60, 80)

    -- Минимальные настройки эффектов (точно как в первой версии)
    local bloom = Lighting:FindFirstChild("BloomEffect")
    if bloom then
        bloom.Enabled = false
        bloom.Intensity = 0.05
    end

    local colorCorrection = Lighting:FindFirstChild("ColorCorrectionEffect")
    if colorCorrection then
        colorCorrection.Enabled = false  -- Отключаем, как в первой версии
        colorCorrection.Saturation = 0.6
        colorCorrection.Contrast = 0.1
        colorCorrection.TintColor = Color3.fromRGB(180, 200, 220)
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
        atmosphere.Color = Color3.fromRGB(50, 70, 100)  -- Значение из первой версии
    end

    -- Небо и облака (оставляем из второй версии для красивого ночного вида)
    for _, skyObj in pairs(Lighting:GetChildren()) do
        if skyObj:IsA("Sky") then
            skyObj.CelestialBodiesShown = true
            skyObj.MoonAngularSize = 11
            skyObj.StarCount = 3000
            skyObj.SkyboxBk = ""
            skyObj.SkyboxDn = ""
            skyObj.SkyboxFt = ""
            skyObj.SkyboxLf = ""
            skyObj.SkyboxRt = ""
            skyObj.SkyboxUp = ""
        end
    end

    local clouds = Lighting:FindFirstChild("Clouds")
    if clouds then
        clouds.Color = Color3.fromRGB(30, 30, 40)
        clouds.Cover = 0.4
        clouds.Density = 0.7
    end

    -- Убираем отражения
    for obj, _ in pairs(OriginalReflections) do
        if obj.Parent then
            pcall(function()
                obj.Reflectance = 0
            end)
        end
    end

    -- Время суток (добавлено из второй версии для полноты ночного эффекта)
    Lighting.ClockTime = 0
    Lighting.TimeOfDay = "00:00:00"

    isPotatoModeActive = true
    print("✅ Night Mode включен")
end

function disablePotatoMode()
    if not isPotatoModeActive then return end

    print("🌙 Выключаю Night Mode...")

    -- Восстановление основных настроек освещения
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
        Lighting.ClockTime = OriginalSettings.ClockTime or 14
        Lighting.TimeOfDay = OriginalSettings.TimeOfDay or "14:00:00"
    end

    -- Восстановление конкретных эффектов
    local bloom = Lighting:FindFirstChild("BloomEffect")
    if bloom and OriginalEffects.Bloom.Enabled ~= nil then
        bloom.Enabled = OriginalEffects.Bloom.Enabled
        bloom.Intensity = OriginalEffects.Bloom.Intensity
    end

    local colorCorrection = Lighting:FindFirstChild("ColorCorrectionEffect")
    if colorCorrection and OriginalEffects.ColorCorrection.Enabled ~= nil then
        colorCorrection.Enabled = OriginalEffects.ColorCorrection.Enabled
        colorCorrection.Saturation = OriginalEffects.ColorCorrection.Saturation or 0
        colorCorrection.Contrast = OriginalEffects.ColorCorrection.Contrast or 0
        colorCorrection.TintColor = OriginalEffects.ColorCorrection.TintColor or Color3.new(1,1,1)
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
        atmosphere.Color = OriginalEffects.Atmosphere.Color
    end

    -- Восстановление неба
    for skyName, settings in pairs(OriginalSkySettings) do
        local skyObj = Lighting:FindFirstChild(skyName)
        if skyObj and skyObj:IsA("Sky") then
            for prop, value in pairs(settings) do
                skyObj[prop] = value
            end
        end
    end

    -- Восстановление облаков
    local clouds = Lighting:FindFirstChild("Clouds")
    if clouds and OriginalClouds.Color then
        clouds.Color = OriginalClouds.Color
        clouds.Cover = OriginalClouds.Cover
        clouds.Density = OriginalClouds.Density
    end

    -- Восстановление отражений
    for obj, reflectance in pairs(OriginalReflections) do
        if obj.Parent then
            pcall(function()
                obj.Reflectance = reflectance
            end)
        end
    end

    isPotatoModeActive = false
    print("✅ Night Mode выключен")
end

function togglePotatoMode()
    if isPotatoModeActive then
        disablePotatoMode()
    else
        enablePotatoMode()
    end
    updateButtonDisplay()
end

-- GUI (из второй версии — фиксированная кнопка + подсказка)
local function createNightModeGUI()
    local playerGui = player:WaitForChild("PlayerGui")

    if playerGui:FindFirstChild("NightModeGUI") then
        playerGui:FindFirstChild("NightModeGUI"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NightModeGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local nightModeButton = Instance.new("TextButton")
    nightModeButton.Name = "NightModeButton"
    nightModeButton.Size = UDim2.new(0, 100, 0, 35)
    nightModeButton.Position = UDim2.new(1, -110, 1, -45)
    nightModeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    nightModeButton.BackgroundTransparency = 0.4
    nightModeButton.BorderSizePixel = 0
    nightModeButton.Text = "NightMode"
    nightModeButton.TextColor3 = Color3.fromRGB(180, 200, 255)
    nightModeButton.Font = Enum.Font.GothamMedium
    nightModeButton.TextSize = 12
    nightModeButton.AutoButtonColor = false
    nightModeButton.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = nightModeButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 80, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = nightModeButton

    -- Подсказка один раз
    if not hintShown then
        local hintFrame = Instance.new("Frame")
        hintFrame.Size = UDim2.new(0, 260, 0, 90)
        hintFrame.Position = UDim2.new(1, -270, 1, -145)
        hintFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        hintFrame.BackgroundTransparency = 0.3
        hintFrame.Parent = screenGui

        local hintCorner = Instance.new("UICorner")
        hintCorner.CornerRadius = UDim.new(0, 8)
        hintCorner.Parent = hintFrame

        local hintStroke = Instance.new("UIStroke")
        hintStroke.Color = Color3.fromRGB(80, 120, 180)
        hintStroke.Thickness = 1.5
        hintStroke.Transparency = 0.6
        hintStroke.Parent = hintFrame

        local hintText = Instance.new("TextLabel")
        hintText.Size = UDim2.new(1, -20, 1, -40)
        hintText.Position = UDim2.new(0, 10, 0, 5)
        hintText.BackgroundTransparency = 1
        hintText.Text = "Команды переключения:\n/night | /nightmode | /nm"
        hintText.TextColor3 = Color3.fromRGB(180, 220, 255)
        hintText.Font = Enum.Font.GothamMedium
        hintText.TextSize = 14
        hintText.TextXAlignment = Enum.TextXAlignment.Left
        hintText.Parent = hintFrame

        local okButton = Instance.new("TextButton")
        okButton.Size = UDim2.new(0, 80, 0, 28)
        okButton.Position = UDim2.new(0.5, -40, 1, -35)
        okButton.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
        okButton.Text = "ОК"
        okButton.TextColor3 = Color3.fromRGB(200, 230, 255)
        okButton.Font = Enum.Font.GothamBold
        okButton.TextSize = 14
        okButton.Parent = hintFrame

        local okCorner = Instance.new("UICorner")
        okCorner.CornerRadius = UDim.new(0, 6)
        okCorner.Parent = okButton

        okButton.MouseButton1Click:Connect(function()
            hintFrame:Destroy()
            hintShown = true
        end)
    end

    function updateButtonDisplay()
        if isPotatoModeActive then
            nightModeButton.Text = "🌙 ON"
            nightModeButton.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
            nightModeButton.BackgroundTransparency = 0.3
            nightModeButton.TextColor3 = Color3.fromRGB(150, 200, 255)
            stroke.Color = Color3.fromRGB(80, 120, 180)
        else
            nightModeButton.Text = "NightMode"
            nightModeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            nightModeButton.BackgroundTransparency = 0.4
            nightModeButton.TextColor3 = Color3.fromRGB(180, 200, 255)
            stroke.Color = Color3.fromRGB(60, 80, 120)
        end
    end

    nightModeButton.MouseButton1Click:Connect(togglePotatoMode)

    nightModeButton.MouseEnter:Connect(function()
        nightModeButton.BackgroundTransparency = isPotatoModeActive and 0.15 or 0.25
        nightModeButton.TextColor3 = Color3.fromRGB(200, 220, 255)
    end)

    nightModeButton.MouseLeave:Connect(updateButtonDisplay)

    updateButtonDisplay()
end

-- Запуск
spawn(function()
    wait(3)
    saveOriginalSettings()
    createNightModeGUI()

    player.CharacterAdded:Connect(function()
        wait(2)
        if not player.PlayerGui:FindFirstChild("NightModeGUI") then
            createNightModeGUI()
        end
    end)

    player.Chatted:Connect(function(msg)
        local lower = msg:lower()
        if lower == "/night" or lower == "/nightmode" or lower == "/nm" then
            togglePotatoMode()
        end
    end)

    print("🌙 Night Mode System Ready! Команды: /night | /nm")
end)

_G.NightMode = {
    Enable = enablePotatoMode,
    Disable = disablePotatoMode,
    Toggle = togglePotatoMode,
    IsActive = function() return isPotatoModeActive end
}
