return function(shared)
    local player = shared.player
    local gui = shared.gui
    local settings = shared.settings
    local saveSetting = shared.saveSetting
    local colors = shared.colors
    local createToggle = shared.createToggle
    local createSlider = shared.createSlider
    local UIS = game:GetService("UserInputService")
    local runService = game:GetService("RunService")
    local tweenService = game:GetService("TweenService")
    
    local content = shared.contents["RENDER"]
    
    local fullbrightEnabled = settings.fullbright
    local fullbrightConnection = nil
    
    createToggle(content, "Fullbright", 15, settings.fullbright, function(enabled)
        fullbrightEnabled = enabled
        if enabled then
            if fullbrightConnection then fullbrightConnection:Disconnect() end
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 999999
            game.Lighting.GlobalShadows = false
            game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            game.Lighting.ExposureCompensation = 0.5
            fullbrightConnection = runService.Heartbeat:Connect(function()
                if not fullbrightEnabled then fullbrightConnection:Disconnect(); return end
                game.Lighting.Brightness = 2
                game.Lighting.ClockTime = 14
                game.Lighting.FogEnd = 999999
            end)
        else
            if fullbrightConnection then fullbrightConnection:Disconnect(); fullbrightConnection = nil end
            game.Lighting.Brightness = 1
            game.Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            game.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            game.Lighting.ExposureCompensation = 0
        end
    end, "fullbright")
    
    createToggle(content, "Optimization", 50, settings.optimization, function(enabled)
        if enabled then
            game.Lighting.GlobalShadows = false
            game.Lighting.ShadowSoftness = 0
        else
            game.Lighting.GlobalShadows = true
            game.Lighting.ShadowSoftness = 0.5
        end
    end, "optimization")
    
    local fpsOverlay = Instance.new("TextLabel", gui)
    fpsOverlay.Size = UDim2.new(0, 80, 0, 25)
    fpsOverlay.Position = UDim2.new(settings.fpsPos[1], settings.fpsPos[2], settings.fpsPos[3], settings.fpsPos[4])
    fpsOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fpsOverlay.BackgroundTransparency = 0.5
    fpsOverlay.BorderSizePixel = 0
    fpsOverlay.Text = "FPS: 0"
    fpsOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsOverlay.TextSize = 14
    fpsOverlay.Font = Enum.Font.GothamBold
    fpsOverlay.TextXAlignment = Enum.TextXAlignment.Center
    fpsOverlay.Visible = settings.fps
    fpsOverlay.ZIndex = 10
    Instance.new("UICorner", fpsOverlay).CornerRadius = UDim.new(0, 6)

    local fpsDragging = false
    local fpsDragStart = nil
    local fpsStartPos = nil

    fpsOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fpsDragging = true
            fpsDragStart = input.Position
            fpsStartPos = fpsOverlay.Position
            fpsOverlay.BackgroundTransparency = 0.3
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not fpsDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - fpsDragStart
            local newX = fpsStartPos.X.Offset + delta.X
            local newY = fpsStartPos.Y.Offset + delta.Y
            local screenSize = workspace.CurrentCamera.ViewportSize
            newX = math.clamp(newX, 0, screenSize.X - fpsOverlay.AbsoluteSize.X)
            newY = math.clamp(newY, 0, screenSize.Y - fpsOverlay.AbsoluteSize.Y)
            fpsOverlay.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fpsDragging = false
            fpsOverlay.BackgroundTransparency = 0.5
            saveSetting("fpsPos", {fpsOverlay.Position.X.Scale, fpsOverlay.Position.X.Offset, fpsOverlay.Position.Y.Scale, fpsOverlay.Position.Y.Offset})
        end
    end)

    local lastFpsUpdate = 0
    local fpsValue = 0
    local frameCount = 0

    runService.RenderStepped:Connect(function(deltaTime)
        frameCount = frameCount + 1
        lastFpsUpdate = lastFpsUpdate + deltaTime
        if lastFpsUpdate >= 1 then
            fpsValue = math.floor(frameCount / lastFpsUpdate + 0.5)
            if fpsOverlay and fpsOverlay.Parent then
                fpsOverlay.Text = "FPS: " .. fpsValue
            end
            frameCount = 0
            lastFpsUpdate = 0
        end
    end)

    createToggle(content, "FPS", 85, settings.fps, function(enabled)
        fpsOverlay.Visible = enabled
    end, "fps")
    
    local minimapEnabled = settings.minimap
    local minimapNicknames = settings.minimapNicknames
    local minimapDistance = settings.minimapDistance
    local minimapZoom = settings.minimapZoom
    local minimapRotate = settings.minimapRotate
    local minimapTrail = settings.minimapTrail
    local minimapDanger = settings.minimapDanger

    local minimapFrame = Instance.new("Frame", gui)
    minimapFrame.Size = UDim2.new(0, 150, 0, 150)
    minimapFrame.Position = UDim2.new(settings.minimapPos[1], settings.minimapPos[2], settings.minimapPos[3], settings.minimapPos[4])
    minimapFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    minimapFrame.BackgroundTransparency = 0.3
    minimapFrame.BorderSizePixel = 0
    minimapFrame.Visible = settings.minimap
    minimapFrame.ZIndex = 100
    minimapFrame.ClipsDescendants = true
    Instance.new("UICorner", minimapFrame).CornerRadius = UDim.new(1, 0)
    local minimapStroke = Instance.new("UIStroke", minimapFrame)
    minimapStroke.Color = Color3.fromRGB(100, 100, 100)
    minimapStroke.Thickness = 2

    local minimapDragging = false
    local minimapDragStart = nil
    local minimapStartPos = nil

    minimapFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minimapDragging = true
            minimapDragStart = input.Position
            minimapStartPos = minimapFrame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not minimapDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - minimapDragStart
            local newX = minimapStartPos.X.Offset + delta.X
            local newY = minimapStartPos.Y.Offset + delta.Y
            local screenSize = workspace.CurrentCamera.ViewportSize
            newX = math.clamp(newX, 0, screenSize.X - minimapFrame.AbsoluteSize.X)
            newY = math.clamp(newY, 0, screenSize.Y - minimapFrame.AbsoluteSize.Y)
            minimapFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minimapDragging = false
            saveSetting("minimapPos", {minimapFrame.Position.X.Scale, minimapFrame.Position.X.Offset, minimapFrame.Position.Y.Scale, minimapFrame.Position.Y.Offset})
        end
    end)

    local zoomOutBtn = Instance.new("TextButton", minimapFrame)
    zoomOutBtn.Size = UDim2.new(0, 20, 0, 20)
    zoomOutBtn.Position = UDim2.new(0, 2, 0, 2)
    zoomOutBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    zoomOutBtn.BackgroundTransparency = 0.5
    zoomOutBtn.BorderSizePixel = 0
    zoomOutBtn.Text = "-"
    zoomOutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    zoomOutBtn.TextSize = 16
    zoomOutBtn.Font = Enum.Font.GothamBold
    zoomOutBtn.ZIndex = 102
    Instance.new("UICorner", zoomOutBtn).CornerRadius = UDim.new(0, 4)

    local zoomInBtn = Instance.new("TextButton", minimapFrame)
    zoomInBtn.Size = UDim2.new(0, 20, 0, 20)
    zoomInBtn.Position = UDim2.new(1, -22, 0, 2)
    zoomInBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    zoomInBtn.BackgroundTransparency = 0.5
    zoomInBtn.BorderSizePixel = 0
    zoomInBtn.Text = "+"
    zoomInBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    zoomInBtn.TextSize = 16
    zoomInBtn.Font = Enum.Font.GothamBold
    zoomInBtn.ZIndex = 102
    Instance.new("UICorner", zoomInBtn).CornerRadius = UDim.new(0, 4)

    zoomOutBtn.Activated:Connect(function()
        minimapZoom = math.max(0.1, minimapZoom - 0.1)
        settings.minimapZoom = minimapZoom
        saveSetting("minimapZoom", minimapZoom)
    end)

    zoomInBtn.Activated:Connect(function()
        minimapZoom = math.min(2, minimapZoom + 0.1)
        settings.minimapZoom = minimapZoom
        saveSetting("minimapZoom", minimapZoom)
    end)

    local nLabel = Instance.new("TextLabel", minimapFrame)
    nLabel.Size = UDim2.new(0, 15, 0, 15)
    nLabel.Position = UDim2.new(0.5, -7, 0, 2)
    nLabel.BackgroundTransparency = 1
    nLabel.Text = "N"
    nLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nLabel.TextSize = 14
    nLabel.Font = Enum.Font.GothamBold
    nLabel.ZIndex = 102

    local sLabel = Instance.new("TextLabel", minimapFrame)
    sLabel.Size = UDim2.new(0, 15, 0, 15)
    sLabel.Position = UDim2.new(0.5, -7, 1, -17)
    sLabel.BackgroundTransparency = 1
    sLabel.Text = "S"
    sLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sLabel.TextSize = 14
    sLabel.Font = Enum.Font.GothamBold
    sLabel.ZIndex = 102

    local wLabel = Instance.new("TextLabel", minimapFrame)
    wLabel.Size = UDim2.new(0, 15, 0, 15)
    wLabel.Position = UDim2.new(0, 2, 0.5, -7)
    wLabel.BackgroundTransparency = 1
    wLabel.Text = "W"
    wLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    wLabel.TextSize = 14
    wLabel.Font = Enum.Font.GothamBold
    wLabel.ZIndex = 102

    local eLabel = Instance.new("TextLabel", minimapFrame)
    eLabel.Size = UDim2.new(0, 15, 0, 15)
    eLabel.Position = UDim2.new(1, -17, 0.5, -7)
    eLabel.BackgroundTransparency = 1
    eLabel.Text = "E"
    eLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    eLabel.TextSize = 14
    eLabel.Font = Enum.Font.GothamBold
    eLabel.ZIndex = 102

    local containerFrame = Instance.new("Frame", minimapFrame)
    containerFrame.Size = UDim2.new(1, 0, 1, 0)
    containerFrame.BackgroundTransparency = 1
    containerFrame.ZIndex = 101

    local myDot = Instance.new("Frame", minimapFrame)
    myDot.Size = UDim2.new(0, 8, 0, 8)
    myDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    myDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    myDot.BorderSizePixel = 0
    myDot.ZIndex = 103
    Instance.new("UICorner", myDot).CornerRadius = UDim.new(1, 0)
    myDot.Visible = false

    local directionLine = Instance.new("Frame", minimapFrame)
    directionLine.Size = UDim2.new(0, 15, 0, 2)
    directionLine.Position = UDim2.new(0.5, -3, 0.5, -1)
    directionLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    directionLine.BorderSizePixel = 0
    directionLine.ZIndex = 103
    directionLine.AnchorPoint = Vector2.new(0, 0.5)
    directionLine.Visible = false

    local trailDots = {}
    local trailPositions = {}
    local dangerDots = {}
    local minimapPlayerDots = {}
    local minimapNpcDots = {}

    local function clearTrail()
        for _, dot in pairs(trailDots) do
            dot:Destroy()
        end
        trailDots = {}
        trailPositions = {}
    end

    local function clearDanger()
        for _, dot in pairs(dangerDots) do
            dot:Destroy()
        end
        dangerDots = {}
    end

    runService.RenderStepped:Connect(function()
        if not minimapEnabled then
            myDot.Visible = false
            directionLine.Visible = false
            nLabel.Visible = false
            sLabel.Visible = false
            wLabel.Visible = false
            eLabel.Visible = false
            for _, data in pairs(minimapPlayerDots) do
                data.dot.Visible = false
                if data.label then data.label.Visible = false end
            end
            for _, dot in pairs(minimapNpcDots) do
                dot.Visible = false
            end
            for _, dot in pairs(trailDots) do
                dot.Visible = false
            end
            for _, dot in pairs(dangerDots) do
                dot.Visible = false
            end
            return
        end
        
        myDot.Visible = true
        directionLine.Visible = true
        nLabel.Visible = true
        sLabel.Visible = true
        wLabel.Visible = true
        eLabel.Visible = true
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local myPos = player.Character.HumanoidRootPart.Position
        local mapSize = 150
        local cameraRotation = 0
        
        if minimapRotate then
            local lookVector = workspace.CurrentCamera.CFrame.LookVector
            cameraRotation = -math.deg(math.atan2(lookVector.X, lookVector.Z))
            containerFrame.Rotation = cameraRotation
        else
            containerFrame.Rotation = 0
        end
        
        local lookVector = player.Character.HumanoidRootPart.CFrame.LookVector
        local angle = math.atan2(lookVector.X, lookVector.Z)
        directionLine.Rotation = math.deg(angle) + 180
        
        if minimapTrail then
            table.insert(trailPositions, myPos)
            if #trailPositions > 20 then
                table.remove(trailPositions, 1)
            end
            while #trailDots < #trailPositions do
                local dot = Instance.new("Frame", minimapFrame)
                dot.Size = UDim2.new(0, 3, 0, 3)
                dot.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                dot.BackgroundTransparency = 0.5
                dot.BorderSizePixel = 0
                dot.ZIndex = 98
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                table.insert(trailDots, dot)
            end
            while #trailDots > #trailPositions do
                local dot = table.remove(trailDots)
                dot:Destroy()
            end
            for i, pos in ipairs(trailPositions) do
                local relative = pos - myPos
                local dotX = (relative.X * minimapZoom) + mapSize/2 - 1.5
                local dotZ = (relative.Z * minimapZoom) + mapSize/2 - 1.5
                if minimapRotate then
                    local rad = math.rad(cameraRotation)
                    local rotatedX = (dotX - mapSize/2) * math.cos(rad) - (dotZ - mapSize/2) * math.sin(rad) + mapSize/2
                    local rotatedZ = (dotX - mapSize/2) * math.sin(rad) + (dotZ - mapSize/2) * math.cos(rad) + mapSize/2
                    dotX, dotZ = rotatedX, rotatedZ
                end
                dotX = math.clamp(dotX, -3, mapSize)
                dotZ = math.clamp(dotZ, -3, mapSize)
                trailDots[i].Position = UDim2.new(0, dotX, 0, dotZ)
                trailDots[i].Visible = true
                trailDots[i].BackgroundTransparency = 0.5 - (i / #trailPositions) * 0.4
            end
        else
            clearTrail()
        end
        
        if minimapDanger then
            local dangerZones = {}
            if _G.AI and _G.AI.DangerZones then
                for _, zone in pairs(_G.AI.DangerZones) do
                    table.insert(dangerZones, zone.Pos)
                end
            end
            for i, pos in ipairs(dangerZones) do
                local dot = dangerDots[i]
                if not dot then
                    dot = Instance.new("Frame", minimapFrame)
                    dot.Size = UDim2.new(0, 12, 0, 12)
                    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    dot.BackgroundTransparency = 0.5
                    dot.BorderSizePixel = 0
                    dot.ZIndex = 99
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                    dangerDots[i] = dot
                end
                local relative = pos - myPos
                local dotX = (relative.X * minimapZoom) + mapSize/2 - 6
                local dotZ = (relative.Z * minimapZoom) + mapSize/2 - 6
                if minimapRotate then
                    local rad = math.rad(cameraRotation)
                    local rotatedX = (dotX - mapSize/2) * math.cos(rad) - (dotZ - mapSize/2) * math.sin(rad) + mapSize/2
                    local rotatedZ = (dotX - mapSize/2) * math.sin(rad) + (dotZ - mapSize/2) * math.cos(rad) + mapSize/2
                    dotX, dotZ = rotatedX, rotatedZ
                end
                dotX = math.clamp(dotX, -6, mapSize - 6)
                dotZ = math.clamp(dotZ, -6, mapSize - 6)
                dot.Position = UDim2.new(0, dotX, 0, dotZ)
                dot.Visible = true
            end
        else
            clearDanger()
        end
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if not minimapPlayerDots[target.UserId] then
                    local dot = Instance.new("Frame", containerFrame)
                    dot.Size = UDim2.new(0, 4, 0, 4)
                    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    dot.BorderSizePixel = 0
                    dot.ZIndex = 101
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                    
                    local nameLabel = Instance.new("TextLabel", containerFrame)
                    nameLabel.Size = UDim2.new(0, 60, 0, 14)
                    nameLabel.BackgroundTransparency = 0.5
                    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextSize = 10
                    nameLabel.Font = Enum.Font.Gotham
                    nameLabel.Visible = false
                    nameLabel.ZIndex = 102
                    Instance.new("UICorner", nameLabel).CornerRadius = UDim.new(0, 3)
                    
                    minimapPlayerDots[target.UserId] = {dot = dot, label = nameLabel}
                end
                
                local data = minimapPlayerDots[target.UserId]
                local dot = data.dot
                local nameLabel = data.label
                dot.Visible = true
                
                local targetPos = target.Character.HumanoidRootPart.Position
                local relative = targetPos - myPos
                
                local dotX = (relative.X * minimapZoom) + mapSize/2 - 2
                local dotZ = (relative.Z * minimapZoom) + mapSize/2 - 2
                
                if minimapRotate then
                    local rad = math.rad(cameraRotation)
                    local rotatedX = (dotX - mapSize/2) * math.cos(rad) - (dotZ - mapSize/2) * math.sin(rad) + mapSize/2
                    local rotatedZ = (dotX - mapSize/2) * math.sin(rad) + (dotZ - mapSize/2) * math.cos(rad) + mapSize/2
                    dotX, dotZ = rotatedX, rotatedZ
                end
                
                dotX = math.clamp(dotX, -4, mapSize)
                dotZ = math.clamp(dotZ, -4, mapSize)
                
                dot.Position = UDim2.new(0, dotX, 0, dotZ)
                
                if minimapNicknames or minimapDistance then
                    nameLabel.Visible = true
                    local text = ""
                    if minimapNicknames then text = text .. target.Name end
                    if minimapDistance then
                        local dist = math.floor(relative.Magnitude)
                        if minimapNicknames then text = text .. " | " end
                        text = text .. dist .. "m"
                    end
                    nameLabel.Text = text
                    if dotZ > mapSize/2 then
                        nameLabel.Position = UDim2.new(0, -28, 0, -16)
                    else
                        nameLabel.Position = UDim2.new(0, -28, 1, 2)
                    end
                else
                    nameLabel.Visible = false
                end
            else
                if minimapPlayerDots[target.UserId] then
                    minimapPlayerDots[target.UserId].dot.Visible = false
                    minimapPlayerDots[target.UserId].label.Visible = false
                end
            end
        end
        
        if settings.esp and settings.espNpc then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") and obj:FindFirstChild("HumanoidRootPart") then
                    local isPlayerCharacter = false
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr.Character == obj then isPlayerCharacter = true; break end
                    end
                    if not isPlayerCharacter then
                        local npcId = obj.Name
                        if not minimapNpcDots[npcId] then
                            local dot = Instance.new("Frame", containerFrame)
                            dot.Size = UDim2.new(0, 4, 0, 4)
                            dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            dot.BorderSizePixel = 0
                            dot.ZIndex = 101
                            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                            minimapNpcDots[npcId] = dot
                        end
                        
                        local dot = minimapNpcDots[npcId]
                        dot.Visible = true
                        
                        local targetPos = obj.HumanoidRootPart.Position
                        local relative = targetPos - myPos
                        
                        local dotX = (relative.X * minimapZoom) + mapSize/2 - 2
                        local dotZ = (relative.Z * minimapZoom) + mapSize/2 - 2
                        
                        if minimapRotate then
                            local rad = math.rad(cameraRotation)
                            local rotatedX = (dotX - mapSize/2) * math.cos(rad) - (dotZ - mapSize/2) * math.sin(rad) + mapSize/2
                            local rotatedZ = (dotX - mapSize/2) * math.sin(rad) + (dotZ - mapSize/2) * math.cos(rad) + mapSize/2
                            dotX, dotZ = rotatedX, rotatedZ
                        end
                        
                        dotX = math.clamp(dotX, -4, mapSize)
                        dotZ = math.clamp(dotZ, -4, mapSize)
                        
                        dot.Position = UDim2.new(0, dotX, 0, dotZ)
                    end
                end
            end
        end
    end)

    createToggle(content, "Minimap", 120, settings.minimap, function(enabled)
        minimapEnabled = enabled
        minimapFrame.Visible = enabled
    end, "minimap")

    createToggle(content, "Minimap Nicknames", 155, settings.minimapNicknames, function(enabled)
        minimapNicknames = enabled
    end, "minimapNicknames")

    createToggle(content, "Minimap Distance", 190, settings.minimapDistance, function(enabled)
        minimapDistance = enabled
    end, "minimapDistance")

    createToggle(content, "Minimap Rotate", 225, settings.minimapRotate, function(enabled)
        minimapRotate = enabled
    end, "minimapRotate")

    createToggle(content, "Minimap Trail", 260, settings.minimapTrail, function(enabled)
        minimapTrail = enabled
        if not enabled then clearTrail() end
    end, "minimapTrail")

    createToggle(content, "Minimap Danger", 295, settings.minimapDanger, function(enabled)
        minimapDanger = enabled
        if not enabled then clearDanger() end
    end, "minimapDanger")
end