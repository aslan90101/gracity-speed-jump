local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- скопировал даун
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

-- скопировал скрипт ты сын шлюхи
local function aimAtTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then
        return
    end
    
    local targetPosition = target.Character.Head.Position
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
end

-- пидор пошёл нахуй отсюда
local function simulateMouseClick()
    local mouse = LocalPlayer:GetMouse()
    mouse1press()
    wait()
    mouse1release()
end

-- сын бляди нахуй иди
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end -- пизда твеой мамки сочная была
    
    if input.KeyCode == Enum.KeyCode.Q then
        local targetPlayer = findClosestPlayer()
        if targetPlayer then
            -- сын хуйни
            aimAtTarget(targetPlayer)
            
            -- ждёи пока твой отец умрёт
            wait(0.03)
            
            -- Выполняем клик по сарке твоей
            simulateMouseClick()
        end
    end
end)

-- Обновление пизды твоей матери новыми хуями
RunService.RenderStepped:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        local targetPlayer = findClosestPlayer()
        if targetPlayer then
            aimAtTarget(targetPlayer)
        end
    end
end)
