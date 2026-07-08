return function(shared)
    local player = shared.player
    local settings = shared.settings
    local saveSetting = shared.saveSetting
    local createToggle = shared.createToggle
    local runService = game:GetService("RunService")
    
    local content = shared.contents["ESP"]
    
    local espEnabled = settings.esp
    local espPlayersEnabled = settings.espPlayers
    local espNickEnabled = settings.espNick
    local espDistEnabled = settings.espDist
    local espNpcEnabled = settings.espNpc
    
    local playerEspObjects = {}
    local playerEspConnections = {}
    local npcEspObjects = {}
    local npcEspConnections = {}
    
    local function clearESP()
        for _, obj in pairs(playerEspObjects) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        playerEspObjects = {}
        for _, conn in pairs(playerEspConnections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        playerEspConnections = {}
        for _, obj in pairs(npcEspObjects) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        npcEspObjects = {}
        for _, conn in pairs(npcEspConnections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        npcEspConnections = {}
    end
    
    local function createESPforPlayer(target)
        if not espEnabled or not espPlayersEnabled then return end
        if target == player then return end
        if not target.Character then return end
        
        local function setupESP()
            local character = target.Character
            local head = character:FindFirstChild("Head")
            if not head then return end
            
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head
            
            local info = Instance.new("TextLabel", billboard)
            info.Size = UDim2.new(1, 0, 1, 0)
            info.BackgroundTransparency = 1
            info.TextColor3 = Color3.fromRGB(255, 255, 255)
            info.TextSize = 14
            info.Font = Enum.Font.GothamSemibold
            info.TextStrokeTransparency = 0.3
            
            local highlight = Instance.new("Highlight")
            highlight.Adornee = character
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = character
            
            table.insert(playerEspObjects, billboard)
            table.insert(playerEspObjects, highlight)
            
            local function updateESP()
                if not billboard or not billboard.Parent then return end
                local text = ""
                if espNickEnabled then text = text .. target.Name .. "\n" end
                if espDistEnabled and player.Character and player.Character:FindFirstChild("Head") then
                    local dist = math.floor((player.Character.Head.Position - head.Position).Magnitude + 0.5)
                    text = text .. dist .. "m"
                end
                info.Text = text
            end
            
            local updateConnection = runService.RenderStepped:Connect(function()
                if not espEnabled or not espPlayersEnabled then
                    updateConnection:Disconnect()
                    return
                end
                updateESP()
            end)
            table.insert(playerEspConnections, updateConnection)
        end
        
        if target.Character:FindFirstChild("Head") then
            setupESP()
        end
        local charConn = target.CharacterAdded:Connect(function()
            task.wait(0.5)
            setupESP()
        end)
        table.insert(playerEspConnections, charConn)
    end
    
    local function createESPforNPC(npcModel)
        if not espNpcEnabled or not espEnabled then return end
        if not npcModel:FindFirstChild("Humanoid") or not npcModel:FindFirstChild("Head") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = npcModel
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = npcModel
        
        table.insert(npcEspObjects, highlight)
        local updateConnection = runService.RenderStepped:Connect(function()
            if not espEnabled or not espNpcEnabled then
                updateConnection:Disconnect()
                return
            end
        end)
        table.insert(npcEspConnections, updateConnection)
    end
    
    local function refreshAllESP()
        clearESP()
        if not espEnabled then return end
        
        if espPlayersEnabled then
            for _, target in pairs(game.Players:GetPlayers()) do
                if target ~= player then
                    createESPforPlayer(target)
                end
            end
        end
        
        if espNpcEnabled then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
                    local isPlayerCharacter = false
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr.Character == obj then
                            isPlayerCharacter = true
                            break
                        end
                    end
                    if not isPlayerCharacter then
                        createESPforNPC(obj)
                    end
                end
            end
        end
    end
    
    createToggle(content, "ESP", 15, settings.esp, function(enabled)
        espEnabled = enabled
        if enabled then
            refreshAllESP()
        else
            clearESP()
        end
    end, "esp")
    
    createToggle(content, "Players", 50, settings.espPlayers, function(enabled)
        espPlayersEnabled = enabled
        if espEnabled then refreshAllESP() end
    end, "espPlayers")
    
    createToggle(content, "NPC", 85, settings.espNpc, function(enabled)
        espNpcEnabled = enabled
        if espEnabled then refreshAllESP() end
    end, "espNpc")
    
    createToggle(content, "Nickname", 120, settings.espNick, function(enabled)
        espNickEnabled = enabled
    end, "espNick")
    
    createToggle(content, "Distance", 155, settings.espDist, function(enabled)
        espDistEnabled = enabled
    end, "espDist")
    
    game.Players.PlayerAdded:Connect(function(newPlayer)
        if espEnabled and espPlayersEnabled then
            createESPforPlayer(newPlayer)
        end
    end)
    
    game.Players.PlayerRemoving:Connect(function()
        if espEnabled then refreshAllESP() end
    end)
    
    player.CharacterAdded:Connect(function()
        if espEnabled then
            task.wait(0.5)
            refreshAllESP()
        end
    end)
    
    spawn(function()
        while true do
            if espEnabled and espNpcEnabled then
                refreshAllESP()
            end
            task.wait(5)
        end
    end)
end