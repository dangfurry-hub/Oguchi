--// PROJECT ZENO HUB - FINAL FIXED ESP + CAMLOCK + SLIDER

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === GUI SETUP ===
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ZenoHub"
gui.ResetOnSpawn = false

local hub = Instance.new("Frame", gui)
hub.Size = UDim2.new(0, 300, 0, 400)
hub.Position = UDim2.new(0.5, -150, 0.5, -200)
hub.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hub.BackgroundTransparency = 0.2
hub.Active = true
hub.Draggable = true
Instance.new("UICorner", hub).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", hub)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "PROJECT ZENO"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(0,200,255)

local infoFrame = Instance.new("Frame", hub)
infoFrame.Size = UDim2.new(1,-20,0,100)
infoFrame.Position = UDim2.new(0,10,1,-150)
infoFrame.BackgroundColor3 = Color3.fromRGB(10,10,15)
infoFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0,8)

local infoLabel = Instance.new("TextLabel", infoFrame)
infoLabel.Size = UDim2.new(1,-10,1,-10)
infoLabel.Position = UDim2.new(0,5,0,5)
infoLabel.TextColor3 = Color3.fromRGB(255,255,255)
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.RichText = true
infoLabel.Text = ""

local buttonContainer = Instance.new("ScrollingFrame", hub)
buttonContainer.Size = UDim2.new(1,-20,0,220)
buttonContainer.Position = UDim2.new(0,10,0,40)
buttonContainer.CanvasSize = UDim2.new(0,0,0,800)
buttonContainer.ScrollBarThickness = 6
buttonContainer.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", buttonContainer)
layout.Padding = UDim.new(0,6)

local function makeButton(text)
    local b = Instance.new("TextButton", buttonContainer)
    b.Size = UDim2.new(1, -10, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(30,30,45)
    b.Text = text
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(200,200,200)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

-- === STATE ===
local ESP_ON, CAMLOCK_ON, NOLAG_ON, SPEED_ON, FRUITESP_ON = false,false,false,false,false
local speedValue = 50
local currentTarget = nil
local espObjects = {}

-- === NEAREST PLAYER ===
local function getNearestEnemy()
    local closest, dist = nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") 
            and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local mag = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                dist = mag
                closest = plr
            end
        end
    end
    return closest
end

-- === ESP HANDLER ===
local function createESP(plr)
    if espObjects[plr] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(0,255,0)
    highlight.OutlineTransparency = 0
    highlight.Parent = plr.Character
    espObjects[plr] = highlight
end

local function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
end

local function refreshESP()
    if ESP_ON then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                createESP(plr)
            end
        end
    else
        for _,obj in pairs(espObjects) do
            obj:Destroy()
        end
        espObjects = {}
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if ESP_ON then
            task.wait(1)
            createESP(plr)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

-- === TOGGLE BUTTON (Z) ===
local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0,58,0,58)
toggleBtn.Position = UDim2.new(0,18,0.5,-29)
toggleBtn.BackgroundColor3 = Color3.fromRGB(14,18,26)
toggleBtn.Image = "rbxassetid://91450237981205"
toggleBtn.AutoButtonColor = false
toggleBtn.Draggable = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
toggleBtn.MouseButton1Click:Connect(function()
    hub.Visible = not hub.Visible
end)

-- === CAMLOCK WINDOW ===
local camlockWindow = Instance.new("Frame", gui)
camlockWindow.Size = UDim2.new(0, 200, 0, 100)
camlockWindow.Position = UDim2.new(0.5, -100, 0.2, 0)
camlockWindow.BackgroundColor3 = Color3.fromRGB(25,25,35)
camlockWindow.Visible = false
camlockWindow.Active = true
camlockWindow.Draggable = true
Instance.new("UICorner", camlockWindow).CornerRadius = UDim.new(0,8)

local camlockTitle = Instance.new("TextLabel", camlockWindow)
camlockTitle.Size = UDim2.new(1,0,0,30)
camlockTitle.BackgroundTransparency = 1
camlockTitle.Text = "Camlock"
camlockTitle.Font = Enum.Font.GothamBold
camlockTitle.TextSize = 16
camlockTitle.TextColor3 = Color3.fromRGB(0,200,255)

local camlockBtn = Instance.new("TextButton", camlockWindow)
camlockBtn.Size = UDim2.new(1,-20,0,30)
camlockBtn.Position = UDim2.new(0,10,0,40)
camlockBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
camlockBtn.Text = "Camlock [OFF]"
camlockBtn.TextColor3 = Color3.fromRGB(200,200,200)
camlockBtn.Font = Enum.Font.GothamBold
camlockBtn.TextSize = 14
Instance.new("UICorner", camlockBtn).CornerRadius = UDim.new(0,6)

camlockBtn.MouseButton1Click:Connect(function()
    CAMLOCK_ON = not CAMLOCK_ON
    camlockBtn.Text = "Camlock ["..(CAMLOCK_ON and "ON" or "OFF").."]"
    if CAMLOCK_ON then
        currentTarget = getNearestEnemy()
    else
        currentTarget = nil
    end
end)

-- Camlock follow (chỉnh hạ cam theo khoảng cách)
RunService.RenderStepped:Connect(function()
    if CAMLOCK_ON then
        if not currentTarget or not currentTarget.Character 
            or not currentTarget.Character:FindFirstChild("HumanoidRootPart") 
            or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearestEnemy()
        end
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = currentTarget.Character.HumanoidRootPart
            local camPos = Camera.CFrame.Position

            -- Tính khoảng cách camera ↔ HRP
            local distance = (camPos - hrp.Position).Magnitude

            -- Offset xuống theo khoảng cách (0.05 = hệ số, có thể chỉnh)
            local offset = Vector3.new(0, -distance * 0.1, 0)

            -- Aim vào HRP nhưng đã hạ xuống
            Camera.CFrame = CFrame.new(camPos, hrp.Position + offset)
        end
    end
end)
-- === BUTTONS ===
local espBtn = makeButton("ESP [OFF]")
espBtn.MouseButton1Click:Connect(function()
    ESP_ON = not ESP_ON
    espBtn.Text = "ESP ["..(ESP_ON and "ON" or "OFF").."]"
    refreshESP()
end)

local camBtn = makeButton("Camlock Menu")
camBtn.MouseButton1Click:Connect(function()
    camlockWindow.Visible = not camlockWindow.Visible
end)

local nolagBtn = makeButton("NoLag [OFF]")
nolagBtn.MouseButton1Click:Connect(function()
    NOLAG_ON = not NOLAG_ON
    nolagBtn.Text = "NoLag ["..(NOLAG_ON and "ON" or "OFF").."]"
    if NOLAG_ON then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
    end
end)

local speedBtn = makeButton("Speed [OFF]")
speedBtn.MouseButton1Click:Connect(function()
    SPEED_ON = not SPEED_ON
    speedBtn.Text = "Speed ["..(SPEED_ON and "ON" or "OFF").."]"
end)

-- Slider
local sliderFrame = Instance.new("Frame", buttonContainer)
sliderFrame.Size = UDim2.new(1,-10,0,40)
sliderFrame.BackgroundColor3 = Color3.fromRGB(30,30,45)
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0,6)

local sliderBar = Instance.new("Frame", sliderFrame)
sliderBar.Size = UDim2.new(1,-20,0,6)
sliderBar.Position = UDim2.new(0,10,0.5,-3)
sliderBar.BackgroundColor3 = Color3.fromRGB(80,80,100)

local sliderKnob = Instance.new("Frame", sliderBar)
sliderKnob.Size = UDim2.new(0,10,0,16)
sliderKnob.Position = UDim2.new(0,0,0.5,-8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200,200,255)
sliderKnob.Active = true
sliderKnob.Draggable = true
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1,0)

local sliderValueLabel = Instance.new("TextLabel", sliderFrame)
sliderValueLabel.Size = UDim2.new(1,0,0,20)
sliderValueLabel.BackgroundTransparency = 1
sliderValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
sliderValueLabel.Font = Enum.Font.GothamBold
sliderValueLabel.TextSize = 12
sliderValueLabel.Text = "Speed: 50"

sliderKnob.Changed:Connect(function()
    local barAbsSize = sliderBar.AbsoluteSize.X
    local knobPos = math.clamp(sliderKnob.Position.X.Offset, 0, barAbsSize-10)
    local percent = knobPos / (barAbsSize-10)
    speedValue = math.floor(50 + (500-50)*percent)
    sliderValueLabel.Text = "Speed: "..speedValue
end)

local fruitBtn = makeButton("Fruit ESP [OFF]")
fruitBtn.MouseButton1Click:Connect(function()
    FRUITESP_ON = not FRUITESP_ON
    fruitBtn.Text = "Fruit ESP ["..(FRUITESP_ON and "ON" or "OFF").."]"
end)

local hopBtn = makeButton("Server Hop")
hopBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId)
end)

-- === INFO PANEL UPDATE ===
local function buildInfoText()
    local function line(name,state)
        return "<b><font color='"..(state and "#00FF00" or "#FF3C3C").."'>"..name..": "..(state and "ON" or "OFF").."</font></b>"
    end
    return table.concat({
        line("ESP",ESP_ON),
        line("Camlock",CAMLOCK_ON),
        line("NoLag",NOLAG_ON),
        line("Speed",SPEED_ON),
        line("FruitESP",FRUITESP_ON),
    },"\n")
end

RunService.RenderStepped:Connect(function()
    infoLabel.Text = buildInfoText()
    if SPEED_ON and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and not SPEED_ON then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
end)
