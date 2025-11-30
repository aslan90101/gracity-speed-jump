-- ServerScriptService → Script
-- Endoris Ultimate Destroyer (музыка грузится мгновенно)

local Blacklist = {
    "CAPRICORNTOP228",
    "ZuuIknown",
    "noname322",
    -- добавляй ники сюда
}

local kickMessage = "вас заблокировал создатель скрипта Endoris, сосите хуй и больше не используйте этот скрипт. Endoris: аха изи еблан нищий соси хуец пидорас ебливый"

local RICKROLL = "rbxassetid://1838457617"  -- Never Gonna Give You Up (громкий и вечный)

local function endorisFinale(plr)
    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = plr:WaitForChild("PlayerGui")

    -- === МУЗЫКА С МГНОВЕННОЙ ЗАГРУЗКОЙ ===
    local music = Instance.new("Sound")
    music.SoundId = RICKROLL
    music.Volume = 10
    music.Looped = false
    music.Parent = gui
    music:Play()                 -- начинаем играть сразу
    music.TimePosition = 0
    game:GetService("ContentProvider"):PreloadAsync({music})  -- если вдруг ещё не загружено

    -- === ДВА ХУЯ-ШТОРКИ С ВЕНАМИ ===
    local function createDick(left)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, 750, 0, 3800)
        d.Position = left and UDim2.new(0, -900, 0.5, -1900) or UDim2.new(1, 150, 0.5, -1900)
        d.BackgroundColor3 = Color3.fromRGB(255, 140, 160)
        d.BorderSizePixel = 0
        d.Parent = gui

        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,200,210)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(230,90,120))
        }
        grad.Rotation = left and 90 or -90
        grad.Parent = d

        Instance.new("UICorner", d).CornerRadius = UDim.new(0, 380)

        local head = Instance.new("Frame")
        head.Size = UDim2.new(0, 850, 0, 850)
        head.Position = UDim2.new(0.5, -425, 0, -420)
        head.BackgroundColor3 = Color3.fromRGB(255, 80, 130)
        head.Parent = d
        Instance.new("UICorner", head).CornerRadius = UDim.new(1, 0)

        for i = 1, 7 do
            local v = Instance.new("Frame")
            v.Size = UDim2.new(0, 100, 0, math.random(1500,3000))
            v.Position = UDim2.new(0, math.random(150,600), 0, math.random(300,900))
            v.BackgroundColor3 = Color3.fromRGB(200,50,100)
            v.Rotation = math.random(-35,35)
            v.Parent = d
            Instance.new("UICorner", v).CornerRadius = UDim.new(0, 50)
        end

        d:TweenPosition(left and UDim2.new(0, -300, 0.5, -1900) or UDim2.new(1, -550, 0.5, -1900), "Out", "Bounce", 1.4, true)
    end
    createDick(true)
    createDick(false)

    -- === НАДПИСЬ "СОСИ ХУЙ" ===
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,0.35,0)
    txt.Position = UDim2.new(0,0,0.32,0)
    txt.BackgroundTransparency = 1
    txt.Text = "СОСИ ХУЙ"
    txt.TextColor3 = Color3.new(1,0,0)
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.new(0,0,0)
    txt.Font = Enum.Font.GothamBlack
    txt.TextSize = 180
    txt.Parent = gui

    -- === 4 ТРЯСУЩИХСЯ ЧЕРЕПА (гарантированно рабочий ассет) ===
    local SKULL = "rbxassetid://137321300"
    for side, x in pairs({Left = 0.05, Right = 0.75}) do
        for i = 1, 2 do
            local s = Instance.new("ImageLabel")
            s.Size = UDim2.new(0,220,0,220)
            s.Position = UDim2.new(x,0,0.25 + i*0.25,0)
            s.BackgroundTransparency = 1
            s.Image = SKULL
            s.Parent = gui

            task.spawn(function()
                while s.Parent do
                    s.Position = s.Position + UDim2.new(0, math.random(-20,20), 0, math.random(-20,20))
                    s.Rotation = math.random(-25,25)
                    task.wait(0.05)
                end
            end)
        end
    end

    -- === Ровно 5 секунд адского шоу → кик ===
    task.wait(5)
    gui:Destroy()
    plr:Kick(kickMessage)
end

-- === Проверка игроков ===
game.Players.PlayerAdded:Connect(function(plr)
    for _, bad in Blacklist do
        if plr.Name:lower() == bad:lower() then
            task.spawn(function()
                plr:WaitForChild("PlayerGui", 10)
                endorisFinale(plr)
            end)
            break
        end
    end
end)

for _, plr in game.Players:GetPlayers() do
    for _, bad in Blacklist do
        if plr.Name:lower() == bad:lower() then
            task.spawn(function()
                plr:WaitForChild("PlayerGui", 10)
                endorisFinale(plr)
            end)
            break
        end
    end
end
