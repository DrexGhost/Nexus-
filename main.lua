local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DeltaMenu"
gui.ResetOnSpawn = false

local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local colors = {
    bg = Color3.fromRGB(10, 10, 10),
    accent = Color3.fromRGB(20, 20, 20),
    button = Color3.fromRGB(25, 25, 25),
    buttonHover = Color3.fromRGB(35, 35, 35),
    text = Color3.fromRGB(210, 210, 210),
    toggleOn = Color3.fromRGB(60, 120, 60),
    toggleOff = Color3.fromRGB(50, 50, 50)
}

local settings = {
    menuOpen = true,
    fullbright = false,
    optimization = false,
    fps = false,
    minimap = false,
    minimapNicknames = true,
    minimapDistance = true,
    minimapZoom = 0.5,
    minimapRotate = false,
    minimapTrail = false,
    minimapDanger = false,
    fly = false,
    noclip = false,
    speed = 16,
    targetPlayer = false,
    hitbox = false,
    hitboxSize = 5,
    esp = false,
    espPlayers = true,
    espNick = true,
    espDist = true,
    espNpc = false,
    aimbot = false,
    aimbotPlayers = true,
    aimbotNpc = false,
    wallCheck = true,
    autoShoot = false,
    aimbotSpeed = 5,
    aimbotPart = "Head",
    aimbotFov = 100,
    showFovCircle = false,
    antiAfk = false,
    markerPos = nil,
    autoTeleport = false,
    selectedPlayer = "",
    openBtnPos = {0.5, -19, 0.5, -19},
    fpsPos = {0, 10, 0, 10},
    minimapPos = {1, -130, 0, 10},
    menuPos = {0.5, -300, 0.5, -150}
}

local dataStore = nil

function loadSettings()
    local success, result = pcall(function()
        if not player:FindFirstChild("DeltaSettings") then
            local ds = Instance.new("Folder")
            ds.Name = "DeltaSettings"
            ds.Parent = player
        end
        return player.DeltaSettings
    end)
    if success and result then
        dataStore = result
        for name, value in pairs(settings) do
            local stored = dataStore:FindFirstChild(name)
            if stored then
                if name == "markerPos" then
                    local x = dataStore:FindFirstChild("markerX")
                    local y = dataStore:FindFirstChild("markerY")
                    local z = dataStore:FindFirstChild("markerZ")
                    if x and y and z then
                        settings.markerPos = Vector3.new(x.Value, y.Value, z.Value)
                    end
                elseif name == "minimapPos" then
                    local x = dataStore:FindFirstChild("minimapX")
                    local y = dataStore:FindFirstChild("minimapY")
                    local xs = dataStore:FindFirstChild("minimapXS")
                    local ys = dataStore:FindFirstChild("minimapYS")
                    if x and y and xs and ys then
                        settings.minimapPos = {x.Value, xs.Value, y.Value, ys.Value}
                    end
                else
                    settings[name] = stored.Value
                end
            end
        end
    end
end

function saveSetting(name, value)
    settings[name] = value
    if dataStore then
        if name == "markerPos" then
            if value then
                local x = dataStore:FindFirstChild("markerX") or Instance.new("NumberValue", dataStore)
                x.Name = "markerX"
                x.Value = value.X
                local y = dataStore:FindFirstChild("markerY") or Instance.new("NumberValue", dataStore)
                y.Name = "markerY"
                y.Value = value.Y
                local z = dataStore:FindFirstChild("markerZ") or Instance.new("NumberValue", dataStore)
                z.Name = "markerZ"
                z.Value = value.Z
            else
                for _, n in ipairs({"markerX","markerY","markerZ"}) do
                    local v = dataStore:FindFirstChild(n)
                    if v then v:Destroy() end
                end
            end
        elseif name == "minimapPos" then
            local x = dataStore:FindFirstChild("minimapX") or Instance.new("NumberValue", dataStore)
            x.Name = "minimapX"
            x.Value = value[1]
            local xs = dataStore:FindFirstChild("minimapXS") or Instance.new("NumberValue", dataStore)
            xs.Name = "minimapXS"
            xs.Value = value[2]
            local y = dataStore:FindFirstChild("minimapY") or Instance.new("NumberValue", dataStore)
            y.Name = "minimapY"
            y.Value = value[3]
            local ys = dataStore:FindFirstChild("minimapYS") or Instance.new("NumberValue", dataStore)
            ys.Name = "minimapYS"
            ys.Value = value[4]
        else
            local stored = dataStore:FindFirstChild(name)
            if not stored then
                if typeof(value) == "string" then
                    stored = Instance.new("StringValue")
                elseif typeof(value) == "number" then
                    stored = Instance.new("NumberValue")
                else
                    stored = Instance.new("BoolValue")
                end
                stored.Name = name
                stored.Parent = dataStore
            end
            stored.Value = value
        end
    end
end

loadSettings()

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 300)
main.Position = UDim2.new(settings.menuPos[1], settings.menuPos[2], settings.menuPos[3], settings.menuPos[4])
main.BackgroundColor3 = colors.bg
main.BorderSizePixel = 0
main.Visible = settings.menuOpen
main.ClipsDescendants = true
main.Name = "MainFrame"
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BorderSizePixel = 0
topBar.Name = "TopBar"
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0, 100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DELTA"
titleLabel.TextColor3 = colors.text
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Name = "CloseBtn"
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseEnter:Connect(function()
    tweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    tweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}):Play()
end)

local sideBar = Instance.new("Frame", main)
sideBar.Size = UDim2.new(0, 110, 1, -35)
sideBar.Position = UDim2.new(0, 0, 0, 35)
sideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
sideBar.BorderSizePixel = 0
sideBar.Name = "SideBar"
Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 8)

local contentFrame = Instance.new("Frame", main)
contentFrame.Size = UDim2.new(1, -110, 1, -35)
contentFrame.Position = UDim2.new(0, 110, 0, 35)
contentFrame.BackgroundColor3 = colors.accent
contentFrame.BorderSizePixel = 0
contentFrame.Name = "ContentFrame"
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 38, 0, 38)
openBtn.Position = UDim2.new(settings.openBtnPos[1], settings.openBtnPos[2], settings.openBtnPos[3], settings.openBtnPos[4])
openBtn.BackgroundColor3 = colors.bg
openBtn.BorderSizePixel = 0
openBtn.Text = "Δ"
openBtn.TextColor3 = colors.text
openBtn.TextSize = 22
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = not settings.menuOpen
openBtn.ZIndex = 10
openBtn.Name = "OpenBtn"
openBtn.AutoButtonColor = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local openBtnDragging = false
local openBtnDragStart = nil
local openBtnStartPos = nil
local openBtnHasMoved = false

openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openBtnDragging = true
        openBtnHasMoved = false
        openBtnDragStart = input.Position
        openBtnStartPos = openBtn.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not openBtnDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - openBtnDragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
            openBtnHasMoved = true
        end
        local newX = openBtnStartPos.X.Offset + delta.X
        local newY = openBtnStartPos.Y.Offset + delta.Y
        local screenSize = workspace.CurrentCamera.ViewportSize
        newX = math.clamp(newX, 0, screenSize.X - openBtn.AbsoluteSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - openBtn.AbsoluteSize.Y)
        openBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openBtnDragging = false
        saveSetting("openBtnPos", {openBtn.Position.X.Scale, openBtn.Position.X.Offset, openBtn.Position.Y.Scale, openBtn.Position.Y.Offset})
    end
end)

openBtn.Activated:Connect(function()
    if not openBtnHasMoved then
        toggleMenu()
    end
end)

local tabs = {}
local contents = {}
local tabNames = {"RENDER", "ESP", "MOVEMENT", "COMBAT", "TELEPORT", "SETTING"}

local function addButtonStroke(button, color, thickness)
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = color or Color3.fromRGB(100, 100, 100)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
end

local function createToggle(parent, text, posY, defaultState, callback, settingName)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, posY)
    toggleFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = colors.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", toggleFrame)
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -40, 0.5, -10)
    toggle.BackgroundColor3 = defaultState and colors.toggleOn or colors.toggleOff
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", toggle)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = colors.text
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local enabled = defaultState or false
    if defaultState and callback then
        callback(true)
    end

    local function switch()
        enabled = not enabled
        if enabled then
            toggle.BackgroundColor3 = colors.toggleOn
            tweenService:Create(dot, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            toggle.BackgroundColor3 = colors.toggleOff
            tweenService:Create(dot, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        if settingName then saveSetting(settingName, enabled) end
        if callback then callback(enabled) end
    end

    toggle.Activated:Connect(switch)
    return toggle
end

local function createSlider(parent, text, posY, min, max, default, callback, settingName)
    local sliderFrame = Instance.new("Frame", parent)
    sliderFrame.Size = UDim2.new(1, -20, 0, 50)
    sliderFrame.Position = UDim2.new(0, 10, 0, posY)
    sliderFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = colors.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBg = Instance.new("Frame", sliderFrame)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 28)
    sliderBg.BackgroundColor3 = colors.button
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", sliderBg)
    local percent = (default - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragBtn = Instance.new("TextButton", sliderBg)
    dragBtn.Size = UDim2.new(0, 18, 0, 18)
    dragBtn.Position = UDim2.new(percent, -9, 0.5, -9)
    dragBtn.BackgroundColor3 = colors.text
    dragBtn.BorderSizePixel = 0
    dragBtn.Text = ""
    dragBtn.AutoButtonColor = false
    Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)

    local function updateSlider()
        local mousePos = UIS:GetMouseLocation()
        local guiPos = sliderBg.AbsolutePosition
        local guiSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp((mousePos.X - guiPos.X) / guiSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativeX + 0.5)
        label.Text = text .. ": " .. value
        tweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
        tweenService:Create(dragBtn, TweenInfo.new(0.1), {Position = UDim2.new(relativeX, -9, 0.5, -9)}):Play()
        if settingName then saveSetting(settingName, value) end
        if callback then callback(value) end
    end

    local function onSliderStart()
        updateSlider()
        local connection
        connection = runService.RenderStepped:Connect(function()
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                connection:Disconnect()
                return
            end
            updateSlider()
        end)
    end

    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onSliderStart()
        end
    end)

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onSliderStart()
        end
    end)
end

for i, name in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton", sideBar)
    tabBtn.Size = UDim2.new(1, -10, 0, 26)
    tabBtn.Position = UDim2.new(0, 5, 0, 8 + (i - 1) * 31)
    tabBtn.BackgroundColor3 = colors.button
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = colors.text
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    addButtonStroke(tabBtn, Color3.fromRGB(80, 80, 80), 1)

    local content = Instance.new("ScrollingFrame", contentFrame)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
    content.CanvasSize = UDim2.new(0, 0, 0, 500)
    content.Visible = false
    content.BorderSizePixel = 0
    content.ScrollingEnabled = true

    tabs[name] = tabBtn
    contents[name] = content

    tabBtn.MouseEnter:Connect(function()
        tweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.buttonHover}):Play()
    end)
    tabBtn.MouseLeave:Connect(function()
        if contents[name].Visible == false then
            tweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.button}):Play()
        end
    end)

    local function selectTab()
        for _, c in pairs(contents) do
            c.Visible = false
        end
        for _, b in pairs(tabs) do
            tweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = colors.button}):Play()
        end
        content.Visible = true
        tweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end

    tabBtn.Activated:Connect(selectTab)
end

tabs["RENDER"].BackgroundColor3 = Color3.fromRGB(45, 45, 45)
contents["RENDER"].Visible = true

local function toggleMenu()
    settings.menuOpen = not settings.menuOpen
    saveSetting("menuOpen", settings.menuOpen)
    
    if settings.menuOpen then
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 300)
        local tween = tweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 300)})
        tween:Play()
        openBtn.Visible = false
    else
        local tween = tweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 300)})
        tween:Play()
        tween.Completed:Connect(function()
            main.Visible = false
        end)
        openBtn.Visible = true
    end
end

closeBtn.Activated:Connect(toggleMenu)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then toggleMenu() end
end)

local shared = {
    player = player,
    gui = gui,
    settings = settings,
    saveSetting = saveSetting,
    colors = colors,
    tabs = tabs,
    contents = contents,
    createToggle = createToggle,
    createSlider = createSlider,
    addButtonStroke = addButtonStroke
}

-- ЗАМЕНИ ССЫЛКИ НА СВОИ!
local GITHUB_BASE = "https://raw.githubusercontent.com/TVOY_AKKAUNT/NexusX/main/"

local function loadModule(name)
    local url = GITHUB_BASE .. name .. ".lua"
    print("Загрузка: " .. url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result then
        local fn, err = loadstring(result)
        if fn then
            fn(shared)
            print(name .. " загружен!")
        else
            warn("Ошибка в " .. name .. ": " .. err)
        end
    else
        warn("Не удалось загрузить " .. name)
    end
end

loadModule("render")
loadModule("esp")
loadModule("movement")
loadModule("combat")
loadModule("teleport")
loadModule("settings")