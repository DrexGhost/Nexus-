return function(shared)
    local player = shared.player
    local settings = shared.settings
    local saveSetting = shared.saveSetting
    local addButtonStroke = shared.addButtonStroke
    local tweenService = game:GetService("TweenService")
    
    local content = shared.contents["TELEPORT"]
    
    local titleLabel = Instance.new("TextLabel", content)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Teleport"
    titleLabel.TextColor3 = shared.colors.text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local markerSectionLabel = Instance.new("TextLabel", content)
    markerSectionLabel.Size = UDim2.new(1, -20, 0, 18)
    markerSectionLabel.Position = UDim2.new(0, 10, 0, 35)
    markerSectionLabel.BackgroundTransparency = 1
    markerSectionLabel.Text = "Marker Teleport"
    markerSectionLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    markerSectionLabel.TextSize = 12
    markerSectionLabel.Font = Enum.Font.Gotham
    
    local markerInfoLabel = Instance.new("TextLabel", content)
    markerInfoLabel.Size = UDim2.new(1, -20, 0, 20)
    markerInfoLabel.Position = UDim2.new(0, 10, 0, 55)
    markerInfoLabel.BackgroundTransparency = 1
    markerInfoLabel.TextColor3 = shared.colors.text
    markerInfoLabel.TextSize = 13
    markerInfoLabel.Font = Enum.Font.Gotham
    markerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local function updateMarkerLabel()
        if settings.markerPos then
            markerInfoLabel.Text = "Marker: " .. math.floor(settings.markerPos.X) .. ", " .. math.floor(settings.markerPos.Y) .. ", " .. math.floor(settings.markerPos.Z)
        else
            markerInfoLabel.Text = "Marker: not set"
        end
    end
    updateMarkerLabel()
    
    local btnRow = Instance.new("Frame", content)
    btnRow.Size = UDim2.new(1, -20, 0, 35)
    btnRow.Position = UDim2.new(0, 10, 0, 80)
    btnRow.BackgroundTransparency = 1
    
    local setMarkerBtn = Instance.new("TextButton", btnRow)
    setMarkerBtn.Size = UDim2.new(0, 120, 1, 0)
    setMarkerBtn.Position = UDim2.new(0, 0, 0, 0)
    setMarkerBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    setMarkerBtn.BorderSizePixel = 0
    setMarkerBtn.Text = "SET MARKER"
    setMarkerBtn.TextColor3 = shared.colors.text
    setMarkerBtn.TextSize = 13
    setMarkerBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", setMarkerBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(setMarkerBtn, Color3.fromRGB(120, 120, 120), 1)
    setMarkerBtn.MouseEnter:Connect(function()
        tweenService:Create(setMarkerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    setMarkerBtn.MouseLeave:Connect(function()
        tweenService:Create(setMarkerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    setMarkerBtn.Activated:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            settings.markerPos = player.Character.HumanoidRootPart.Position
            saveSetting("markerPos", settings.markerPos)
            updateMarkerLabel()
        end
    end)
    
    local autoTeleportEnabled = settings.autoTeleport
    local autoTpThread = nil
    
    local function stopAutoTeleport()
        if autoTpThread then
            task.cancel(autoTpThread)
            autoTpThread = nil
        end
    end
    
    local function startAutoTeleport()
        stopAutoTeleport()
        autoTpThread = task.spawn(function()
            while autoTeleportEnabled and settings.markerPos do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(settings.markerPos)
                end
                task.wait(1)
            end
            autoTpThread = nil
        end)
    end
    
    local autoTpBtn = Instance.new("TextButton", btnRow)
    autoTpBtn.Size = UDim2.new(0, 120, 1, 0)
    autoTpBtn.Position = UDim2.new(0.5, -60, 0, 0)
    autoTpBtn.BackgroundColor3 = settings.autoTeleport and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(20, 20, 20)
    autoTpBtn.BorderSizePixel = 0
    autoTpBtn.Text = "AUTO TP"
    autoTpBtn.TextColor3 = shared.colors.text
    autoTpBtn.TextSize = 13
    autoTpBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", autoTpBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(autoTpBtn, Color3.fromRGB(120, 120, 120), 1)
    
    autoTpBtn.MouseEnter:Connect(function()
        if not autoTeleportEnabled then
            tweenService:Create(autoTpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        else
            tweenService:Create(autoTpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 140, 80)}):Play()
        end
    end)
    autoTpBtn.MouseLeave:Connect(function()
        if not autoTeleportEnabled then
            tweenService:Create(autoTpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        else
            tweenService:Create(autoTpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 120, 60)}):Play()
        end
    end)
    
    autoTpBtn.Activated:Connect(function()
        if not settings.markerPos then return end
        autoTeleportEnabled = not autoTeleportEnabled
        settings.autoTeleport = autoTeleportEnabled
        saveSetting("autoTeleport", autoTeleportEnabled)
        if autoTeleportEnabled then
            autoTpBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            startAutoTeleport()
        else
            stopAutoTeleport()
        end
    end)
    
    if autoTeleportEnabled then
        startAutoTeleport()
    end
    
    local teleportBtn = Instance.new("TextButton", btnRow)
    teleportBtn.Size = UDim2.new(0, 120, 1, 0)
    teleportBtn.Position = UDim2.new(1, -120, 0, 0)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    teleportBtn.BorderSizePixel = 0
    teleportBtn.Text = "TELEPORT"
    teleportBtn.TextColor3 = shared.colors.text
    teleportBtn.TextSize = 13
    teleportBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(teleportBtn, Color3.fromRGB(120, 120, 120), 1)
    teleportBtn.MouseEnter:Connect(function()
        tweenService:Create(teleportBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    teleportBtn.MouseLeave:Connect(function()
        tweenService:Create(teleportBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    teleportBtn.Activated:Connect(function()
        if not settings.markerPos then return end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(settings.markerPos)
        end
    end)
    
    local clearBtn = Instance.new("TextButton", content)
    clearBtn.Size = UDim2.new(0, 120, 0, 28)
    clearBtn.Position = UDim2.new(0, 10, 0, 123)
    clearBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    clearBtn.BorderSizePixel = 0
    clearBtn.Text = "CLEAR MARKER"
    clearBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    clearBtn.TextSize = 12
    clearBtn.Font = Enum.Font.Gotham
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(clearBtn, Color3.fromRGB(120, 120, 120), 1)
    clearBtn.MouseEnter:Connect(function()
        tweenService:Create(clearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    clearBtn.MouseLeave:Connect(function()
        tweenService:Create(clearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    clearBtn.Activated:Connect(function()
        settings.markerPos = nil
        saveSetting("markerPos", nil)
        updateMarkerLabel()
        if autoTeleportEnabled then
            autoTeleportEnabled = false
            settings.autoTeleport = false
            saveSetting("autoTeleport", false)
            stopAutoTeleport()
        end
    end)
    
    local playerTpLabel = Instance.new("TextLabel", content)
    playerTpLabel.Size = UDim2.new(1, -20, 0, 18)
    playerTpLabel.Position = UDim2.new(0, 10, 0, 165)
    playerTpLabel.BackgroundTransparency = 1
    playerTpLabel.Text = "Player Teleport"
    playerTpLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    playerTpLabel.TextSize = 12
    playerTpLabel.Font = Enum.Font.Gotham
    
    local tpToPlayerBtn = Instance.new("TextButton", content)
    tpToPlayerBtn.Size = UDim2.new(1, -20, 0, 35)
    tpToPlayerBtn.Position = UDim2.new(0, 10, 0, 185)
    tpToPlayerBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tpToPlayerBtn.BorderSizePixel = 0
    tpToPlayerBtn.Text = "TP TO PLAYER"
    tpToPlayerBtn.TextColor3 = shared.colors.text
    tpToPlayerBtn.TextSize = 14
    tpToPlayerBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", tpToPlayerBtn).CornerRadius = UDim.new(0, 5)
    addButtonStroke(tpToPlayerBtn, Color3.fromRGB(120, 120, 120), 1)
    tpToPlayerBtn.MouseEnter:Connect(function()
        tweenService:Create(tpToPlayerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    tpToPlayerBtn.MouseLeave:Connect(function()
        tweenService:Create(tpToPlayerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    tpToPlayerBtn.Activated:Connect(function()
        if settings.selectedPlayer == "" then return end
        for _, target in pairs(game.Players:GetPlayers()) do
            if target.Name == settings.selectedPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                end
                break
            end
        end
    end)
    
    local playerDropdown = Instance.new("Frame", content)
    playerDropdown.Size = UDim2.new(1, -20, 0, 30)
    playerDropdown.Position = UDim2.new(0, 10, 0, 230)
    playerDropdown.BackgroundColor3 = shared.colors.button
    playerDropdown.BorderSizePixel = 0
    playerDropdown.ClipsDescendants = true
    Instance.new("UICorner", playerDropdown).CornerRadius = UDim.new(0, 5)
    addButtonStroke(playerDropdown, Color3.fromRGB(120, 120, 120), 1)
    
    local selectedPlayerBtn = Instance.new("TextButton", playerDropdown)
    selectedPlayerBtn.Size = UDim2.new(1, 0, 0, 30)
    selectedPlayerBtn.BackgroundTransparency = 1
    selectedPlayerBtn.Text = settings.selectedPlayer ~= "" and settings.selectedPlayer or "Choose player..."
    selectedPlayerBtn.TextColor3 = shared.colors.text
    selectedPlayerBtn.TextSize = 13
    selectedPlayerBtn.Font = Enum.Font.Gotham
    selectedPlayerBtn.TextXAlignment = Enum.TextXAlignment.Left
    selectedPlayerBtn.Position = UDim2.new(0, 10, 0, 0)
    
    local arrowLabel = Instance.new("TextLabel", playerDropdown)
    arrowLabel.Size = UDim2.new(0, 20, 0, 30)
    arrowLabel.Position = UDim2.new(1, -25, 0, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = shared.colors.text
    arrowLabel.TextSize = 12
    arrowLabel.Font = Enum.Font.Gotham
    
    local playersScroll = Instance.new("ScrollingFrame", playerDropdown)
    playersScroll.Size = UDim2.new(1, 0, 0, 0)
    playersScroll.Position = UDim2.new(0, 0, 0, 30)
    playersScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    playersScroll.BorderSizePixel = 0
    playersScroll.ClipsDescendants = true
    playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    playersScroll.ScrollBarThickness = 4
    playersScroll.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
    playersScroll.ScrollingEnabled = true
    
    local playersList = Instance.new("Frame", playersScroll)
    playersList.Size = UDim2.new(1, 0, 0, 0)
    playersList.BackgroundTransparency = 1
    playersList.BorderSizePixel = 0
    Instance.new("UIListLayout", playersList).SortOrder = Enum.SortOrder.Name
    
    local dropdownOpen = false
    local playerButtons = {}
    
    local function updatePlayerList()
        for _, b in ipairs(playerButtons) do
            b:Destroy()
        end
        playerButtons = {}
        
        local ySize = 0
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player then
                local pBtn = Instance.new("TextButton", playersList)
                pBtn.Size = UDim2.new(1, 0, 0, 28)
                pBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                pBtn.BorderSizePixel = 0
                pBtn.Text = target.Name
                pBtn.TextColor3 = shared.colors.text
                pBtn.TextSize = 12
                pBtn.Font = Enum.Font.Gotham
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.Name = target.Name
                
                pBtn.MouseEnter:Connect(function()
                    tweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                end)
                pBtn.MouseLeave:Connect(function()
                    tweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                end)
                
                local targetName = target.Name
                pBtn.Activated:Connect(function()
                    settings.selectedPlayer = targetName
                    selectedPlayerBtn.Text = targetName
                    saveSetting("selectedPlayer", targetName)
                    dropdownOpen = false
                    playerDropdown.Size = UDim2.new(1, -20, 0, 30)
                    playersScroll.Size = UDim2.new(1, 0, 0, 0)
                end)
                
                table.insert(playerButtons, pBtn)
                ySize = ySize + 28
            end
        end
        playersList.Size = UDim2.new(1, 0, 0, ySize)
        playersScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
        if ySize == 0 then
            local noPlayersLabel = Instance.new("TextLabel", playersList)
            noPlayersLabel.Size = UDim2.new(1, 0, 0, 28)
            noPlayersLabel.BackgroundTransparency = 1
            noPlayersLabel.Text = "No players"
            noPlayersLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            noPlayersLabel.TextSize = 12
            noPlayersLabel.Font = Enum.Font.Gotham
            noPlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(playerButtons, noPlayersLabel)
        end
    end
    
    updatePlayerList()
    
    selectedPlayerBtn.Activated:Connect(function()
        dropdownOpen = not dropdownOpen
        if dropdownOpen then
            playerDropdown.Size = UDim2.new(1, -20, 0, 200)
            playersScroll.Size = UDim2.new(1, 0, 0, 170)
            playersScroll.CanvasSize = UDim2.new(0, 0, 0, playersList.AbsoluteSize.Y)
        else
            playerDropdown.Size = UDim2.new(1, -20, 0, 30)
            playersScroll.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    
    local function refreshTab()
        updatePlayerList()
        updateMarkerLabel()
        if settings.selectedPlayer ~= "" then
            local found = false
            for _, target in pairs(game.Players:GetPlayers()) do
                if target.Name == settings.selectedPlayer then
                    found = true
                    break
                end
            end
            if not found then
                settings.selectedPlayer = ""
                saveSetting("selectedPlayer", "")
                selectedPlayerBtn.Text = "Choose player..."
            else
                selectedPlayerBtn.Text = settings.selectedPlayer
            end
        end
    end
    
    game.Players.PlayerAdded:Connect(function()
        if shared.contents["TELEPORT"].Visible then refreshTab() end
    end)
    game.Players.PlayerRemoving:Connect(function()
        if shared.contents["TELEPORT"].Visible then refreshTab() end
    end)
    
    shared.contents["TELEPORT"].GetPropertyChangedSignal("Visible"):Connect(function()
        if shared.contents["TELEPORT"].Visible then refreshTab() end
    end)
    
    content.CanvasSize = UDim2.new(0, 0, 0, 500)
end