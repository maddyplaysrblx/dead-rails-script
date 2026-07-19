-- ============================================
-- DEAD RAILS SCRIPT - FIXED VERSION
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Settings = {
    AutoFarm = false,
    GodMode = false,
    InfiniteAmmo = false,
    DoubleDamage = false,
    ESP = false,
    SpeedHack = false,
    AutoRevive = false,
    WalkSpeed = 50,
    JumpPower = 100
}

-- Debug function
local function Debug(msg)
    print("[DeadRails] " .. msg)
end

-- Wait for character
local function GetCharacter()
    local char = LocalPlayer.Character
    if not char then
        LocalPlayer.CharacterAdded:Wait()
        char = LocalPlayer.Character
    end
    return char
end

-- Wait for Humanoid
local function GetHumanoid()
    local char = GetCharacter()
    local humanoid = char:WaitForChild("Humanoid", 5)
    return humanoid
end

-- Wait for HumanoidRootPart
local function GetHRP()
    local char = GetCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    return hrp
end

-- ============================================
-- UI CREATION
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeadRailsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Make draggable
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "DEAD RAILS HUB"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollingFrame

-- ============================================
-- TOGGLE BUTTONS
-- ============================================

local ToggleButtons = {}

local function CreateToggle(name, settingKey)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Button.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
        Button.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        Debug(name .. " toggled: " .. tostring(Settings[settingKey]))
    end)
    
    Button.Parent = ScrollingFrame
    ToggleButtons[settingKey] = Button
    return Button
end

CreateToggle("Auto Farm Bonds", "AutoFarm")
CreateToggle("God Mode", "GodMode")
CreateToggle("Infinite Ammo", "InfiniteAmmo")
CreateToggle("Double Damage", "DoubleDamage")
CreateToggle("ESP Monsters", "ESP")
CreateToggle("Speed Hack", "SpeedHack")
CreateToggle("Auto Revive Teammates", "AutoRevive")

-- ============================================
-- ACTION BUTTONS
-- ============================================

local function CreateActionButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(70, 70, 150)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        local success, err = pcall(callback)
        if not success then
            Debug("Error in " .. name .. ": " .. tostring(err))
        end
    end)
    
    Button.Parent = ScrollingFrame
end

CreateActionButton("Teleport to Outpost", function()
    local hrp = GetHRP()
    local outpost = Workspace:FindFirstChild("Outpost") or Workspace:FindFirstChild("SafeZone") or Workspace:FindFirstChild("Base")
    if outpost and hrp then
        hrp.CFrame = outpost:GetPivot() + Vector3.new(0, 5, 0)
        Debug("Teleported to Outpost")
    else
        Debug("Outpost not found!")
    end
end)

CreateActionButton("Teleport to Train", function()
    local hrp = GetHRP()
    local train = Workspace:FindFirstChild("Train") or Workspace:FindFirstChild("Vehicle") or Workspace:FindFirstChild("TrainModel")
    if train and hrp then
        hrp.CFrame = train:GetPivot() + Vector3.new(0, 5, 0)
        Debug("Teleported to Train")
    else
        Debug("Train not found!")
    end
end)

CreateActionButton("Collect All Loot", function()
    local hrp = GetHRP()
    local collected = 0
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and (item.Name:lower():find("bond") or item.Name:lower():find("money") or item.Name:lower():find("cash") or item.Name:lower():find("loot")) then
            hrp.CFrame = item.CFrame + Vector3.new(0, 2, 0)
            collected = collected + 1
            task.wait(0.2)
        end
    end
    Debug("Collected " .. collected .. " items")
end)

-- ============================================
-- FEATURES
-- ============================================

-- God Mode
RunService.Heartbeat:Connect(function()
    if Settings.GodMode then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- Auto Farm
task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoFarm then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("bond") or obj.Name:lower():find("money") or obj.Name:lower():find("cash")) then
                        local dist = (obj.Position - hrp.Position).Magnitude
                        if dist < 200 then
                            hrp.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- ESP
local ESPObjects = {}
RunService.Heartbeat:Connect(function()
    if Settings.ESP then
        -- Clear old ESP
        for obj, gui in pairs(ESPObjects) do
            if not obj or not obj.Parent then
                gui:Destroy()
                ESPObjects[obj] = nil
            end
        end
        
        -- Find enemies
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                if obj.Name:lower():find("zombie") or obj.Name:lower():find("monster") or obj.Name:lower():find("enemy") or obj.Name:lower():find("wolf") then
                    if not ESPObjects[obj] then
                        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
                        if hrp then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "ESP"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 100, 0, 40)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.Adornee = hrp
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.TextSize = 14
                            label.Text = obj.Name
                            label.Parent = billboard
                            
                            billboard.Parent = hrp
                            ESPObjects[obj] = billboard
                        end
                    end
                end
            end
        end
    else
        -- Clear ESP when disabled
        for obj, gui in pairs(ESPObjects) do
            gui:Destroy()
        end
        ESPObjects = {}
    end
end)

-- Auto Revive
task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoRevive then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if humanoid and hrp and (humanoid.Health <= 0 or humanoid.PlatformStand) then
                            myHRP.CFrame = hrp.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if Settings.SpeedHack then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
    end
end)

-- Infinite Ammo
task.spawn(function()
    while true do
        task.wait(0.2)
        if Settings.InfiniteAmmo then
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        -- Try common ammo value names
                        for _, name in pairs({"Ammo", "Clip", "Bullets", "AmmoCount", "CurrentAmmo"}) do
                            local val = tool:FindFirstChild(name)
                            if val and val:IsA("ValueBase") then
                                val.Value = 999
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Double Damage
task.spawn(function()
    while true do
        task.wait(0.2)
        if Settings.DoubleDamage then
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local damage = tool:FindFirstChild("Damage") or tool:FindFirstChild("BaseDamage")
                        if damage and damage:IsA("ValueBase") and damage.Value < 1000 then
                            damage.Value = damage.Value * 2
                        end
                    end
                end
            end
        end
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Debug("Character respawned")
end)

Debug("Script Loaded! Click buttons to toggle features.")
