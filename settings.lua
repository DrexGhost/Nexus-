return function(shared)
    local player = shared.player
    local settings = shared.settings
    local saveSetting = shared.saveSetting
    local createToggle = shared.createToggle
    local addButtonStroke = shared.addButtonStroke
    local tweenService = game:GetService("TweenService")
    local teleportService = game:GetService("TeleportService")
    
    local content = shared.contents["SETTING"]
    
    local devLabel = Instance.new("TextLabel", content)
    devLabel.Size = UDim2.new(1, -20, 0, 30)
    devLabel.Position = UDim2.new(0, 10, 0, 15)
    devLabel.BackgroundTransparency = 1
    devLabel.Text = "Developer: DrexGhost"
    devLabel.TextColor3 = shared.colors.text
    devLabel.TextSize = 16
    devLabel.Font = Enum.Font.GothamBold
    devLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = Instance.new("TextLabel", content)
    versionLabel.Size = UDim2.new(1, -20, 0, 25)
    versionLabel.Position = UDim2.new(0, 10, 0, 50)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Delta v1.0"
    versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    versionLabel.TextSize = 13
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local saveConfigBtn = Instance.new("TextButton", content)
    saveConfigBtn.Size = UDim2.new(0, 120, 0, 35)
    saveConfigBtn.Position = UDim2.new(0, 10, 0, 80)
    saveConfigBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    saveConfigBtn.BorderSizePixel = 0
    saveConfigBtn.Text = "SAVE CONFIG"
    saveConfigBtn.TextColor3 = shared.colors.text
    saveConfigBtn.TextSize = 12
    saveConfigBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", saveConfigBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(saveConfigBtn, Color3.fromRGB(120, 120, 120), 1)
    saveConfigBtn.MouseEnter:Connect(function()
        tweenService:Create(saveConfigBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    saveConfigBtn.MouseLeave:Connect(function()
        tweenService:Create(saveConfigBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    saveConfigBtn.Activated:Connect(function()
        for name, value in pairs(settings) do
            saveSetting(name, value)
        end
    end)
    
    local rejoinBtn = Instance.new("TextButton", content)
    rejoinBtn.Size = UDim2.new(0, 120, 0, 35)
    rejoinBtn.Position = UDim2.new(0, 10, 0, 130)
    rejoinBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    rejoinBtn.BorderSizePixel = 0
    rejoinBtn.Text = "REJOIN"
    rejoinBtn.TextColor3 = shared.colors.text
    rejoinBtn.TextSize = 14
    rejoinBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(rejoinBtn, Color3.fromRGB(120, 120, 120), 1)
    rejoinBtn.MouseEnter:Connect(function()
        tweenService:Create(rejoinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    rejoinBtn.MouseLeave:Connect(function()
        tweenService:Create(rejoinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    rejoinBtn.Activated:Connect(function()
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
    
    createToggle(content, "Anti AFK", 180, settings.antiAfk, function(enabled)
        if enabled then
            local vim = game:GetService("VirtualUser")
            spawn(function()
                while settings.antiAfk do
                    vim:CaptureController()
                    vim:ClickButton2(Vector2.new())
                    task.wait(120)
                end
            end)
        end
    end, "antiAfk")
end