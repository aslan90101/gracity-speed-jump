--anti-grab

local PS = game:GetService("Players")
local Player = PS.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RS = game:GetService("ReplicatedStorage")
local CE = RS:WaitForChild("CharacterEvents")
local R = game:GetService("RunService")
local BeingHeld = Player:WaitForChild("IsHeld")
local PlayerScripts = Player:WaitForChild("PlayerScripts")

--[[ Remotes ]]
local StruggleEvent = CE:WaitForChild("Struggle")

--[[ Anti-Explosion ]]
workspace.DescendantAdded:Connect(function(v)
if v:IsA("Explosion") then
v.BlastPressure = 0
end
end)

--[[ Anti-grab ]]

BeingHeld.Changed:Connect(function(C)
	if C == true then
		local char = Player.Character

		if BeingHeld.Value == true then
			local Event;
			Event = R.RenderStepped:Connect(function()
				if BeingHeld.Value == true then
					char["HumanoidRootPart"].AssemblyLinearVelocity = Vector3.new()
					StruggleEvent:FireServer(Player)
				elseif BeingHeld.Value == false then
					Event:Disconnect()
				end
			end)
		end
	end
end)

local function reconnect()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid") or Character:WaitForChild("Humanoid")
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	HumanoidRootPart:WaitForChild("FirePlayerPart"):Remove()

	Humanoid.Changed:Connect(function(C)
		if C == "Sit" and Humanoid.Sit == true then
			if Humanoid.SeatPart ~= nil and tostring(Humanoid.SeatPart.Parent) == "CreatureBlobman" then
			elseif Humanoid.SeatPart == nil then
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			Humanoid.Sit = false
			end
		end
	end)
end

reconnect()

Player.CharacterAdded:Connect(reconnect)
