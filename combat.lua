return function(shared)
    local player = shared.player
    local gui = shared.gui
    local settings = shared.settings
    local saveSetting = shared.saveSetting
    local createToggle = shared.createToggle
    local createSlider = shared.createSlider
    local UIS = game:GetService("UserInputService")
    local runService = game:GetService("RunService")
    local vim = game:GetService("VirtualInputManager")
    local tweenService = game:GetService("TweenService")
    
    local content = shared.contents["COMBAT"]
    
    local aimbotEnabled = settings.aimbot
    local aimbotPlayersEnabled = settings.aimbotPlayers
    local aimbotNpcEnabled = settings.aimbotNpc
    local wallCheck = settings.wallCheck
    local autoShoot = settings.autoShoot
    local aimbotSpeed = settings.aimbotSpeed
    local aimbotPart = settings.aimbotPart
    local aimbotFov = settings.aimbotFov
    local showFovCircle = settings.showFovCircle
    
    local fovCircle = Instance.new("ScreenGui", gui)
    fovCircle.Name = "FovCircle"
    fovCircle.ResetOnSpawn = false
    fovCircle.Enabled = false
    
    local circleFrame = Instance.new("Frame", fovCircle)
    circleFrame.Size = UDim2.new(0, aimbotFov, 0, aimbotFov)
    circleFrame.Position = UDim2.new(0.5, -aimbotFov/2, 0.5, -aimbotFov/2)
    circleFrame.BackgroundTransparency = 1
    circleFrame.ZIndex = 999
    Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)
    
    local circleStroke = Instance.new("UIStroke", circleFrame)
    circleStroke.Color = Color3.fromRGB(255, 0, 0)
    circleStroke.Thickness = 2
    
    local function updateFovCircle()
        if showFovCircle and aimbotEnabled then
            fovCircle.Enabled = true
            circleFrame.Size = UDim2.new(0, aimbotFov, 0, aimbotFov)
            circleFrame.Position = UDim2.new(0.5, -aimbotFov/2, 0.5, -aimbotFov/2)
        else
            fovCircle.Enabled = false
        end
    end
    
    local function getTargetPart(character)
        if not character then return nil end
        if aimbotPart == "Head" then
            return character:FindFirstChild("Head")
        elseif aimbotPart == "Torso" then
            return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        else
            local partMap = {
                ["Left Arm"] = "LeftUpperArm",
                ["Right Arm"] = "RightUpperArm",
                ["Left Leg"] = "LeftUpperLeg",
                ["Right Leg"] = "RightUpperLeg"
            }
            local partName = partMap[aimbotPart]
            if partName then return character:FindFirstChild(partName) end
        end
        return character:FindFirstChild("Head")
    end
    
    local function findTarget()
        if not aimbotEnabled then return nil end
        local camera = workspace.CurrentCamera
        local bestTarget = nil
        local bestDistance = aimbotFov
        
        if aimbotPlayersEnabled then
            for _, target in pairs(game.Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                    local targetPart = getTargetPart(target.Character)
                    if targetPart then
                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (targetPos - screenCenter).Magnitude
                            if distance < bestDistance then
                                if wallCheck then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                    rayParams.FilterDescendantsInstances = {player.Character}
                                    local ray = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000, rayParams)
                                    if ray and ray.Instance:IsDescendantOf(target.Character) then
                                        bestTarget = targetPart
                                        bestDistance = distance
                                    end
                                else
                                    bestTarget = targetPart
                                    bestDistance = distance
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if aimbotNpcEnabled then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                    local isPlayerCharacter = false
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr.Character == obj then
                            isPlayerCharacter = true
                            break
                        end
                    end
                    if not isPlayerCharacter then
                        local targetPart = getTargetPart(obj)
                        if targetPart then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                                local distance = (targetPos - screenCenter).Magnitude
                                if distance < bestDistance then
                                    if wallCheck then
                                        local rayParams = RaycastParams.new()
                                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                        rayParams.FilterDescendantsInstances = {player.Character}
                                        local ray = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000, rayParams)
                                        if ray and ray.Instance:IsDescendantOf(obj) then
                                            bestTarget = targetPart
                                            bestDistance = distance
                                        end
                                    else
                                        bestTarget = targetPart
                                        bestDistance = distance
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return bestTarget
    end
    
    createToggle(content, "Aimbot", 15, settings.aimbot, function(enabled)
        aimbotEnabled = enabled
        updateFovCircle()
    end, "aimbot")
    
    createToggle(content, "Wall Check", 50, settings.wallCheck, function(enabled)
        wallCheck = enabled
    end, "wallCheck")
    
    createToggle(content, "Auto Shoot", 85, settings.autoShoot, function(enabled)
        autoShoot = enabled
    end, "autoShoot")
    
    createToggle(content, "Aimbot Players", 120, settings.aimbotPlayers, function(enabled)
        aimbotPlayersEnabled = enabled
    end, "aimbotPlayers")
    
    createToggle(content, "Aimbot NPC", 155, settings.aimbotNpc, function(enabled)
        aimbotNpcEnabled = enabled
    end, "aimbotNpc")
    
    createSlider(content, "Speed", 190, 1, 20, settings.aimbotSpeed, function(value)
        aimbotSpeed = value
    end, "aimbotSpeed")
    
    createSlider(content, "FOV", 250, 1, 360, settings.aimbotFov, function(value)
        aimbotFov = value
        updateFovCircle()
    end, "aimbotFov")
    
    createToggle(content, "FOV Circle", 310, settings.showFovCircle, function(enabled)
        showFovCircle = enabled
        updateFovCircle()
    end, "showFovCircle")
    
    local aimbotPartDropdown = Instance.new("Frame", content)
    aimbotPartDropdown.Size = UDim2.new(1, -20, 0, 30)
    aimbotPartDropdown.Position = UDim2.new(0, 10, 0, 350)
    aimbotPartDropdown.BackgroundColor3 = shared.colors.button
    aimbotPartDropdown.BorderSizePixel = 0
    aimbotPartDropdown.ClipsDescendants = true
    Instance.new("UICorner", aimbotPartDropdown).CornerRadius = UDim.new(0, 5)
    
    local aimbotPartLabel = Instance.new("TextLabel", aimbotPartDropdown)
    aimbotPartLabel.Size = UDim2.new(1, 0, 0, 30)
    aimbotPartLabel.BackgroundTransparency = 1
    aimbotPartLabel.Text = "Part: " .. settings.aimbotPart
    aimbotPartLabel.TextColor3 = shared.colors.text
    aimbotPartLabel.TextSize = 13
    aimbotPartLabel.Font = Enum.Font.Gotham
    aimbotPartLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotPartLabel.Position = UDim2.new(0, 10, 0, 0)
    
    local aimbotPartList = Instance.new("Frame", aimbotPartDropdown)
    aimbotPartList.Size = UDim2.new(1, 0, 0, 0)
    aimbotPartList.Position = UDim2.new(0, 0, 0, 30)
    aimbotPartList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    aimbotPartList.BorderSizePixel = 0
    aimbotPartList.ClipsDescendants = true
    Instance.new("UIListLayout", aimbotPartList)
    
    local parts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    local aimbotPartOpen = false
    
    for _, partName in ipairs(parts) do
        local partBtn = Instance.new("TextButton", aimbotPartList)
        partBtn.Size = UDim2.new(1, 0, 0, 28)
        partBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        partBtn.BorderSizePixel = 0
        partBtn.Text = partName
        partBtn.TextColor3 = shared.colors.text
        partBtn.TextSize = 12
        partBtn.Font = Enum.Font.Gotham
        partBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        partBtn.MouseEnter:Connect(function()
            tweenService:Create(partBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        partBtn.MouseLeave:Connect(function()
            tweenService:Create(partBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        end)
        
        partBtn.Activated:Connect(function()
            settings.aimbotPart = partName
            aimbotPart = partName
            aimbotPartLabel.Text = "Part: " .. partName
            saveSetting("aimbotPart", partName)
            aimbotPartOpen = false
            aimbotPartList.Size = UDim2.new(1, 0, 0, 0)
            aimbotPartDropdown.Size = UDim2.new(1, -20, 0, 30)
        end)
    end
    
    aimbotPartLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            aimbotPartOpen = not aimbotPartOpen
            if aimbotPartOpen then
                aimbotPartList.Size = UDim2.new(1, 0, 0, 168)
                aimbotPartDropdown.Size = UDim2.new(1, -20, 0, 198)
            else
                aimbotPartList.Size = UDim2.new(1, 0, 0, 0)
                aimbotPartDropdown.Size = UDim2.new(1, -20, 0, 30)
            end
        end
    end)
    
    runService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        local target = findTarget()
        if target then
            local smoothness = math.clamp(aimbotSpeed / 20, 0.05, 1)
            local targetCFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCFrame, smoothness)
            if autoShoot then
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end)
end