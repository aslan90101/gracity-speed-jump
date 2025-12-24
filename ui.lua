-- =============================================
-- EndorisUI Library v1.2 (by Grok для тебя)
-- Открытие/закрытие: K
-- Драг: сверху по названию
-- Цветовая схема: серая, современная
-- =============================================

local EndorisUI = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

function EndorisUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Endoris UI"

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EndorisUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 620, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Top Drag Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 8)
    TopBarCorner.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Drag Functionality
    local dragging = false
    local dragInput, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tabs Frame (Left)
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Name = "TabsFrame"
    TabsFrame.Size = UDim2.new(0, 150, 1, -35)
    TabsFrame.Position = UDim2.new(0, 0, 0, 35)
    TabsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabsFrame.BorderSizePixel = 0
    TabsFrame.Parent = MainFrame

    local TabsList = Instance.new("UIListLayout")
    TabsList.Padding = UDim.new(0, 5)
    TabsList.Parent = TabsFrame

    -- Content Frame (Right)
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -150, 1, -35)
    ContentFrame.Position = UDim2.new(0, 150, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 5
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.Parent = MainFrame

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = ContentFrame

    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 16)
    end)

    -- Toggle UI Visibility (K key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.K then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local Tabs = {}
    local CurrentTab = nil

    local function SelectTab(tabName)
        for name, frame in pairs(Tabs) do
            frame.Visible = (name == tabName)
        end
        CurrentTab = tabName
    end

    -- Create Tab
    function EndorisUI:NewTab(tabName)
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.Parent = TabsFrame

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentFrame

        local TabList = Instance.new("UIListLayout")
        TabList.Padding = UDim.new(0, 6)
        TabList.Parent = TabContent

        Tabs[tabName] = TabContent

        TabButton.MouseButton1Click:Connect(function()
            SelectTab(tabName)
            TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            for _, btn in pairs(TabsFrame:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                end
            end
        end)

        -- First tab auto-select
        if not CurrentTab then
            SelectTab(tabName)
            TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end

        local Tab = {}

        -- Section
        function Tab:NewSection(sectionName)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, -16, 0, 0)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent

            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Size = UDim2.new(1, 0, 0, 30)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = " " .. sectionName
            SectionTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 15
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame

            local SectionList = Instance.new("UIListLayout")
            SectionList.Padding = UDim.new(0, 6)
            SectionList.Parent = SectionFrame

            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 10)
            SectionPadding.PaddingRight = UDim.new(0, 10)
            SectionPadding.PaddingTop = UDim.new(0, 5)
            SectionPadding.PaddingBottom = UDim.new(0, 5)
            SectionPadding.Parent = SectionFrame

            local Section = {}

            -- Toggle
            function Section:NewToggle(name, default, callback)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = SectionFrame

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextSize = 14
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame

                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                ToggleSwitch.Position = UDim2.new(1, -45, 0.5, -10)
                ToggleSwitch.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                ToggleSwitch.Parent = ToggleFrame

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(0, 10)
                SwitchCorner.Parent = ToggleSwitch

                local SwitchButton = Instance.new("Frame")
                SwitchButton.Size = UDim2.new(0, 16, 0, 16)
                SwitchButton.Position = UDim2.new(0, 2, 0.5, -8)
                SwitchButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                SwitchButton.Parent = ToggleSwitch

                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 8)
                ButtonCorner.Parent = SwitchButton

                local state = default or false

                local function updateToggle()
                    if state then
                        TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
                        TweenService:Create(SwitchButton, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                    else
                        TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
                        TweenService:Create(SwitchButton, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                    end
                end

                updateToggle()

                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        updateToggle()
                        if callback then callback(state) end
                    end
                end)

                return ToggleFrame
            end

            -- Slider
            function Section:NewSlider(name, min, max, default, callback, isInteger)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SectionFrame

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = name .. ": " .. (default or min)
                SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextSize = 14
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, 0, 0, 10)
                SliderBar.Position = UDim2.new(0, 0, 0, 25)
                SliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                SliderBar.Parent = SliderFrame

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(0, 5)
                BarCorner.Parent = SliderBar

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                Fill.Parent = SliderBar

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 5)
                FillCorner.Parent = Fill

                local dragging = false

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                SliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * relativeX
                        if isInteger then value = math.floor(value + 0.5) end
                        Fill.Size = UDim2.new(relativeX, 0, 1, 0)
                        SliderLabel.Text = name .. ": " .. tostring(value)
                        if callback then callback(value) end
                    end
                end)

                -- Init
                local initVal = default or min
                if isInteger then initVal = math.floor(initVal + 0.5) end
                Fill.Size = UDim2.new((initVal - min) / (max - min), 0, 1, 0)
                SliderLabel.Text = name .. ": " .. tostring(initVal)
                if callback then callback(initVal) end
            end

            -- Button
            function Section:NewButton(name, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 35)
                Button.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                Button.Text = name
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Font = Enum.Font.GothamBold
                Button.TextSize = 14
                Button.Parent = SectionFrame

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Button

                Button.MouseButton1Click:Connect(callback)
            end

            -- TextBox
            function Section:NewTextBox(name, placeholder, callback)
                local TextBoxFrame = Instance.new("Frame")
                TextBoxFrame.Size = UDim2.new(1, 0, 0, 35)
                TextBoxFrame.BackgroundTransparency = 1
                TextBoxFrame.Parent = SectionFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 15)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = TextBoxFrame

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1, 0, 0, 25)
                Box.Position = UDim2.new(0, 0, 0, 15)
                Box.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                Box.PlaceholderText = placeholder or ""
                Box.Text = ""
                Box.TextColor3 = Color3.fromRGB(255, 255, 255)
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 14
                Box.Parent = TextBoxFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 5)
                BoxCorner.Parent = Box

                Box.FocusLost:Connect(function(enterPressed)
                    if enterPressed and callback then
                        callback(Box.Text)
                    end
                end)
            end

            -- Dropdown
            function Section:NewDropdown(name, options, callback)
                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 35)
                DropFrame.BackgroundTransparency = 1
                DropFrame.Parent = SectionFrame

                local DropButton = Instance.new("TextButton")
                DropButton.Size = UDim2.new(1, 0, 1, 0)
                DropButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                DropButton.Text = name .. ": " .. (options[1] or "Select")
                DropButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                DropButton.Font = Enum.Font.Gotham
                DropButton.TextSize = 14
                DropButton.Parent = DropFrame

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 6)
                DropCorner.Parent = DropButton

                local DropList = Instance.new("ScrollingFrame")
                DropList.Size = UDim2.new(1, 0, 0, 100)
                DropList.Position = UDim2.new(0, 0, 1, 5)
                DropList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                DropList.Visible = false
                DropList.ScrollBarThickness = 4
                DropList.Parent = DropFrame

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = DropList

                local DropCorner2 = Instance.new("UICorner")
                DropCorner2.CornerRadius = UDim.new(0, 6)
                DropCorner2.Parent = DropList

                DropButton.MouseButton1Click:Connect(function()
                    DropList.Visible = not DropList.Visible
                end)

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 13
                    OptBtn.Parent = DropList

                    OptBtn.MouseButton1Click:Connect(function()
                        DropButton.Text = name .. ": " .. opt
                        DropList.Visible = false
                        if callback then callback(opt) end
                    end)
                end
            end

            -- MultiDropdown
            function Section:NewMultiDropdown(name, options, callback)
                local selected = {}
                local MultiFrame = Instance.new("Frame")
                MultiFrame.Size = UDim2.new(1, 0, 0, 35)
                MultiFrame.BackgroundTransparency = 1
                MultiFrame.Parent = SectionFrame

                local MultiButton = Instance.new("TextButton")
                MultiButton.Size = UDim2.new(1, 0, 1, 0)
                MultiButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                MultiButton.Text = name .. ": None"
                MultiButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                MultiButton.Font = Enum.Font.Gotham
                MultiButton.TextSize = 14
                MultiButton.Parent = MultiFrame

                local MultiCorner = Instance.new("UICorner")
                MultiCorner.CornerRadius = UDim.new(0, 6)
                MultiCorner.Parent = MultiButton

                local MultiList = Instance.new("ScrollingFrame")
                MultiList.Size = UDim2.new(1, 0, 0, 100)
                MultiList.Position = UDim2.new(0, 0, 1, 5)
                MultiList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                MultiList.Visible = false
                MultiList.ScrollBarThickness = 4
                MultiList.Parent = MultiFrame

                local MultiLayout = Instance.new("UIListLayout")
                MultiLayout.Parent = MultiList

                MultiButton.MouseButton1Click:Connect(function()
                    MultiList.Visible = not MultiList.Visible
                end)

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 13
                    OptBtn.Parent = MultiList

                    OptBtn.MouseButton1Click:Connect(function()
                        if table.find(selected, opt) then
                            table.remove(selected, table.find(selected, opt))
                        else
                            table.insert(selected, opt)
                        end
                        MultiButton.Text = name .. ": " .. (#selected > 0 and table.concat(selected, ", ") or "None")
                        if callback then callback(selected) end
                    end)
                end
            end

            -- Label
            function Section:NewLabel(text)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 25)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(180, 180, 180)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SectionFrame
            end

            return Section
        end

        return Tab
    end

    -- Notification
    function EndorisUI:Notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title or "Notification",
            Text = text or "",
            Duration = duration or 5
        })
    end

    return EndorisUI
end

return EndorisUI
