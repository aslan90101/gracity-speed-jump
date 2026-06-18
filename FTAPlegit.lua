-- бинды: Q - аим, F - толчек
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local Q_HELD = false

local function getNearestPlayer()
	local nearest = nil
	local minDist = math.huge
	
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local otherChar = otherPlayer.Character
			if otherChar and otherChar:FindFirstChild("HumanoidRootPart") and otherChar:FindFirstChild("Humanoid") and otherChar.Humanoid.Health > 0 then
				local otherRoot = otherChar.HumanoidRootPart
				local dist = (rootPart.Position - otherRoot.Position).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = otherRoot
				end
			end
		end
	end
	
	return nearest
end

local function Push()
	if not rootPart or not rootPart.Parent then return end
	
	local dir = camera.CFrame.LookVector
	dir = dir.Unit
	
	local force = 111
	
	rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + (dir * force)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Q then
		Q_HELD = true
	end
	
	if input.KeyCode == Enum.KeyCode.F then
		Push()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Q then
		Q_HELD = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not character or not character.Parent then return end
	
	if Q_HELD then
		local target = getNearestPlayer()
		if target then
			local targetPos = target.Position
			local camPos = camera.CFrame.Position
			camera.CFrame = CFrame.lookAt(camPos, targetPos)
		end
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	rootPart = character:WaitForChild("HumanoidRootPart")
end)
