--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local v0=game:GetService("UserInputService");local v1=game:GetService("Players");local v2=game:GetService("RunService");local v3=workspace.CurrentCamera;local v4=v1.LocalPlayer;local function v5() local v8=nil;local v9=math.huge;local v10=v4.Character;if ( not v10 or  not v10:FindFirstChild("HumanoidRootPart")) then return nil;end local v11=v10.HumanoidRootPart.Position;for v19,v20 in pairs(v1:GetPlayers()) do if ((v20~=v4) and v20.Character and v20.Character:FindFirstChild("Head") and v20.Character:FindFirstChild("Humanoid") and (v20.Character.Humanoid.Health>(927 -(214 + 713)))) then local v24=(v20.Character.Head.Position-v11).Magnitude;if (v24<v9) then local v27=0 + 0 ;while true do if (v27==0) then v9=v24;v8=v20;break;end end end end end return v8;end local function v6(v12) local v13=0 + 0 ;local v14;while true do if (v13==0) then if ( not v12 or  not v12.Character or  not v12.Character:FindFirstChild("Head")) then return;end v14=v12.Character.Head.Position;v13=878 -(282 + 595) ;end if (v13==1) then v3.CFrame=CFrame.new(v3.CFrame.Position,v14);break;end end end local function v7() local v15=0;local v16;while true do if ((1638 -(1523 + 114))==v15) then wait();mouse1release();break;end if (v15==(0 + 0)) then v16=v4:GetMouse();mouse1press();v15=1 -0 ;end end end v0.InputBegan:Connect(function(v17,v18) if v18 then return;end if (v17.KeyCode==Enum.KeyCode.Q) then local v21=v5();if v21 then v6(v21);wait(0.01);v7();end end end);v2.RenderStepped:Connect(function() if v0:IsKeyDown(Enum.KeyCode.Q) then local v22=0;local v23;while true do if (v22==(1065 -(68 + 997))) then v23=v5();if v23 then v6(v23);end break;end end end end);
