return function(shared)
    local player = shared.player
    local settings = shared.settings
    local saveSetting = shared.saveSetting
    local createToggle = shared.createToggle
    local createSlider = shared.createSlider
    local UIS = game:GetService("UserInputService")
    local runService = game:GetService("RunService")
    
    local content = shared.contents["MOVEMENT"]
    
    local flyEnabled = settings.fly
    local flyConnection = nil
    local mobileFlyGui = nil
    local mobileInput = {forward = false, back = false, left = false, right = false, up = false, down = false}
    
    local function createMobileFlyUI()
        if mobileFlyGui then mobileFlyGui:Destroy() end
        mobileFlyGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
        mobileFlyGui.Name = "DeltaMobileFly"
        mobileFlyGui.ResetOnSpawn = false
        mobileFlyGui.Enabled = false
        
        local moveFrame = Instance.new("Frame", mobileFlyGui)
        moveFrame.Size = UDim2.new(0, 150, 0, 150)
        moveFrame.Position = UDim2.new(0, 20, 0.7, -75)
        moveFrame.BackgroundTransparency = 1
        
        local btnSize = 50
        
        local function createBtn(name, posX, posY, xDir, yDir)
            local btn = Instance.new("TextButton", moveFrame)
            btn.Size = UDim2.new(0, btnSize, 0, btnSize)
            btn.Position = UDim2.new(0, posX, 0, posY)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            btn.BackgroundTransparency = 0.5
            btn.BorderSizePixel = 0
            btn.Text = name
            btn.TextColor3 = shared.colors.text
            btn.TextSize = 20
            btn.Font = Enum.Font.GothamBold
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    if xDir == 1 then mobileInput.right = true
                    elseif xDir == -1 then mobileInput.left = true
                    elseif yDir == 1 then mobileInput.forward = true
                    elseif yDir == -1 then mobileInput.back = true
                    end
                end
            end)
            btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    if xDir == 1 then mobileInput.right = false
                    elseif xDir == -1 then mobileInput.left = false
                    elseif yDir == 1 then mobileInput.forward = false
                    elseif yDir == -1 then mobileInput.back = false
                    end
                end
            end)
            return btn
        end
        
        createBtn("W", 50, 0, 0, 1)
        createBtn("S", 50, 100, 0, -1)
        createBtn("A", 0, 50, -1, 0)
        createBtn("D", 100, 50, 1, 0)
        
        local upBtn = Instance.new("TextButton", mobileFlyGui)
        upBtn.Size = UDim2.new(0, 60, 0, 60)
        upBtn.Position = UDim2.new(1, -80, 0.7, -80)
        upBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        upBtn.BackgroundTransparency = 0.5
        upBtn.BorderSizePixel = 0
        upBtn.Text = "▲"
        upBtn.TextColor3 = shared.colors.text
        upBtn.TextSize = 24
        upBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 8)
        
        local downBtn = Instance.new("TextButton", mobileFlyGui)
        downBtn.Size = UDim2.new(0, 60, 0, 60)
        downBtn.Position = UDim2.new(1, -80, 0.7, 0)
        downBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        downBtn.BackgroundTransparency = 0.5
        downBtn.BorderSizePixel = 0
        downBtn.Text = "▼"
        downBtn.TextColor3 = shared.colors.text
        downBtn.TextSize = 24
        downBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 8)
        
        upBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then mobileInput.up = true end
        end)
        upBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then mobileInput.up = false end
        end)
        downBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then mobileInput.down = true end
        end)
        downBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then mobileInput.down = false end
        end)
    end
    
    local function setupFly(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local root = character.HumanoidRootPart
        
        local bodyGyro = root:FindFirstChild("FlyGyro")
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "FlyGyro"
            bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
            bodyGyro.Parent = root
        end
        
        local bodyVelocity = root:FindFirstChild("FlyVelocity")
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlyVelocity"
            bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
            bodyVelocity.Parent = root
        end
        
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        return bodyGyro, bodyVelocity
    end
    
    local function cleanupFly()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyVelocity") and v.Name == "FlyVelocity" then v:Destroy() end
                if v:IsA("BodyGyro") and v.Name == "FlyGyro" then v:Destroy() end
            end
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if mobileFlyGui then
            mobileFlyGui.Enabled = false
        end
    end
    
    createToggle(content, "Fly", 15, settings.fly, function(enabled)
        flyEnabled = enabled
        if enabled then
            if UIS.TouchEnabled and not mobileFlyGui then createMobileFlyUI() end
            if mobileFlyGui then mobileFlyGui.Enabled = true end
            if player.Character then
                local bodyGyro, bodyVelocity = setupFly(player.Character)
                if flyConnection then flyConnection:Disconnect() end
                flyConnection = runService.Heartbeat:Connect(function()
                    if not flyEnabled then cleanupFly(); return end
                    if not bodyVelocity or not bodyVelocity.Parent or not bodyGyro or not bodyGyro.Parent then return end
                    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                    local moveVector = Vector3.zero
                    if UIS.TouchEnabled then
                        if mobileInput.forward then moveVector += workspace.CurrentCamera.CFrame.LookVector end
                        if mobileInput.back then moveVector -= workspace.CurrentCamera.CFrame.LookVector end
                        if mobileInput.left then moveVector -= workspace.CurrentCamera.CFrame.RightVector end
                        if mobileInput.right then moveVector += workspace.CurrentCamera.CFrame.RightVector end
                        if mobileInput.up then moveVector += Vector3.new(0, 1, 0) end
                        if mobileInput.down then moveVector -= Vector3.new(0, 1, 0) end
                    else
                        if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector += workspace.CurrentCamera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector -= workspace.CurrentCamera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector -= workspace.CurrentCamera.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector += workspace.CurrentCamera.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0, 1, 0) end
                        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector -= Vector3.new(0, 1, 0) end
                    end
                    bodyVelocity.Velocity = moveVector * 50
                end)
            end
        else
            cleanupFly()
        end
    end, "fly")
    
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = settings.speed
        if flyEnabled then
            task.wait(0.1)
            cleanupFly()
            if UIS.TouchEnabled and not mobileFlyGui then createMobileFlyUI() end
            if mobileFlyGui then mobileFlyGui.Enabled = true end
            local bodyGyro, bodyVelocity = setupFly(character)
            if flyConnection then flyConnection:Disconnect() end
            flyConnection = runService.Heartbeat:Connect(function()
                if not flyEnabled then cleanupFly(); return end
                if not bodyVelocity or not bodyVelocity.Parent or not bodyGyro or not bodyGyro.Parent then return end                bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                local moveVector = Vector3.zero
                if UIS.TouchEnabled then
                    if mobileInput.forward then moveVector += workspace.CurrentCamera.CFrame.LookVector end
                    if mobileInput.back then moveVector -= workspace.CurrentCamera.CFrame.LookVector end
                    if mobileInput.left then moveVector -= workspace.CurrentCamera.CFrame.RightVector end
                    if mobileInput.right then moveVector += workspace.CurrentCamera.CFrame.RightVector end
                    if mobileInput.up then moveVector += Vector3.new(0, 1, 0) end
                    if mobileInput.down then moveVector -= Vector3.new(0, 1, 0) end
                else
                    if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector += workspace.CurrentCamera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector -= workspace.CurrentCamera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector -= workspace.CurrentCamera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector += workspace.CurrentCamera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector -= Vector3.new(0, 1, 0) end
                end
                bodyVelocity.Velocity = moveVector * 50
            end)
        end
        if noclipEnabled then applyNoclip() end
    end)
    
    local noclipEnabled = settings.noclip
    local noclipConnection = nil
    
    local function applyNoclip()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    
    local function removeNoclip()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    
    createToggle(content, "Noclip", 50, settings.noclip, function(enabled)
        noclipEnabled = enabled
        if enabled then
            applyNoclip()
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = runService.Stepped:Connect(function()
                if noclipEnabled then applyNoclip() end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            removeNoclip()
        end
    end, "noclip")
    
    createSlider(content, "Speed", 85, 16, 200, settings.speed, function(value)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end, "speed")
    
    local targetPlayerEnabled = settings.targetPlayer
    local targetPlayerConnection = nil
    
    local function findNearestPlayer()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = player.Character.HumanoidRootPart.Position
        local nearest = nil
        local minDist = math.huge
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                local dist = (target.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = target
                end
            end
        end
        return nearest
    end
    
    createToggle(content, "Target Player", 120, settings.targetPlayer, function(enabled)
        targetPlayerEnabled = enabled
        if enabled then
            if targetPlayerConnection then targetPlayerConnection:Disconnect() end
            targetPlayerConnection = runService.Heartbeat:Connect(function()
                if not targetPlayerEnabled then
                    if targetPlayerConnection then targetPlayerConnection:Disconnect() end
                    return
                end
                local target = findNearestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(target.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            if targetPlayerConnection then
                targetPlayerConnection:Disconnect()
                targetPlayerConnection = nil
            end
        end
    end, "targetPlayer")
    
    local hitboxEnabled = settings.hitbox
    local hitboxSize = settings.hitboxSize
    local hitboxParts = {}
    
    local function applyHitbox()
        local sizeMultiplier = hitboxSize / 5
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local headHitbox = head:FindFirstChild("DeltaHitbox_Head")
                    if not headHitbox then
                        headHitbox = Instance.new("Part")
                        headHitbox.Name = "DeltaHitbox_Head"
                        headHitbox.Size = Vector3.new(2, 2, 2)
                        headHitbox.Transparency = 1
                        headHitbox.CanCollide = true
                        headHitbox.Anchored = false
                        headHitbox.Massless = true
                        headHitbox.Parent = target.Character
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = headHitbox
                        weld.Part1 = head
                        weld.Parent = headHitbox
                    end
                    headHitbox.Size = Vector3.new(2 * sizeMultiplier, 2 * sizeMultiplier, 2 * sizeMultiplier)
                    table.insert(hitboxParts, headHitbox)
                end
                local torso = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso")
                if torso then
                    local torsoHitbox = torso:FindFirstChild("DeltaHitbox_Torso")
                    if not torsoHitbox then
                        torsoHitbox = Instance.new("Part")
                        torsoHitbox.Name = "DeltaHitbox_Torso"
                        torsoHitbox.Size = Vector3.new(2, 2, 2)
                        torsoHitbox.Transparency = 1
                        torsoHitbox.CanCollide = true
                        torsoHitbox.Anchored = false
                        torsoHitbox.Massless = true
                        torsoHitbox.Parent = target.Character
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = torsoHitbox
                        weld.Part1 = torso
                        weld.Parent = torsoHitbox
                    end
                    torsoHitbox.Size = Vector3.new(2 * sizeMultiplier, 2 * sizeMultiplier, 2 * sizeMultiplier)
                    table.insert(hitboxParts, torsoHitbox)
                end
            end
        end
    end
    
    local function removeHitbox()
        for _, part in ipairs(hitboxParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        hitboxParts = {}
    end
    
    createToggle(content, "Hitbox", 155, settings.hitbox, function(enabled)
        hitboxEnabled = enabled
        if enabled then
            applyHitbox()
        else
            removeHitbox()
        end
    end, "hitbox")
    
    createSlider(content, "Hitbox Size", 190, 1, 10, settings.hitboxSize, function(value)
        hitboxSize = value
        if hitboxEnabled then
            removeHitbox()
            applyHitbox()
        end
    end, "hitboxSize")
end