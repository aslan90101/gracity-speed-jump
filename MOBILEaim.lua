local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
        return
    end
    
    local targetPosition = target.Character.Head.Position
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
end

-- Функция для симуляции клика ЛКМ
local function simulateMouseClick()
    local mouse = LocalPlayer:GetMouse()
    mouse1press()
    wait()
    mouse1release()
end

-- Основная логика обработки нажатия клавиши Q
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end -- Игнорируем ввод, если он обрабатывается игрой (например, чат)
    
    if input.KeyCode == Enum.KeyCode.Q then
        local targetPlayer = findClosestPlayer()
        if targetPlayer then
            -- Наводимся на голову цели
            aimAtTarget(targetPlayer)
            
            -- Ждем 10 миллисекунд
            wait(0.01)
            
            -- Выполняем клик ЛКМ
            simulateMouseClick()
        end
    end
end)

-- Обновление камеры каждый кадр, чтобы удерживать прицел
RunService.RenderStepped:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        local targetPlayer = findClosestPlayer()
        if targetPlayer then
            aimAtTarget(targetPlayer)
        end
    end
end)
