-- ============================================
-- DEAD RAILS SCRIPT - Feature Rich
-- Features: Auto Farm, God Mode, ESP, Teleports, Auto Revive
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

-- UI Library (Simple UI Creation)
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeadRailsHub"
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Corner Radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
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
    
    -- Scrolling Frame for Buttons
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ScrollingFrame
    
    -- Function to create toggle buttons
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
        end)
        
        Button.Parent = ScrollingFrame
        return Button
    end
    
    -- Create Toggles
    CreateToggle("Auto Farm Bonds", "AutoFarm")
    CreateToggle("God Mode", "GodMode")
    CreateToggle("Infinite Ammo", "InfiniteAmmo")
    CreateToggle("Double Damage", "DoubleDamage")
    CreateToggle("ESP Monsters", "ESP")
    CreateToggle("Speed Hack", "SpeedHack")
    CreateToggle("Auto Revive Teammates", "AutoRevive")
    
    -- Teleport Buttons
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
        
        Button.MouseButton1Click:Connect(callback)
        Button.Parent = ScrollingFrame
    end
    
    CreateActionButton("Teleport to Outpost", function()
        local Outpost = Workspace:FindFirstChild("Outpost") or Workspace:FindFirstChild("SafeZone")
        if Outpost then
            LocalPlayer.Character:PivotTo(Outpost:GetPivot())
        end
    end)
    
    CreateActionButton("Teleport to Train", function()
        local Train = Workspace:FindFirstChild("Train") or Workspace:FindFirstChild("Vehicle")
        if Train then
            LocalPlayer.Character:PivotTo(Train:GetPivot())
        end
    end)
    
    CreateActionButton("Collect All Loot", function()
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("BasePart") and item.Name:lower():match("loot") or item.Name:lower():match("bond") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                    task.wait(0.1)
                end
            end
        end
    end)
    
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return ScreenGui
end

-- ============================================
-- FEATURE IMPLEMENTATIONS
-- ============================================

-- God Mode / Infinite Health
local function EnableGodMode()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        -- Prevent damage
        Humanoid.HealthChanged:Connect(function()
            if Settings.GodMode and Humanoid.Health < Humanoid.MaxHealth then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end)
        
        -- Remove damage events
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("Script") and v.Name:lower():match("damage") then
                v.Disabled = true
            end
        end
    end
end

-- Auto Farm Bonds
local function AutoFarmBonds()
    while task.wait(0.5) do
        if not Settings.AutoFarm then continue end
        
        -- Find bond spawns
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():match("bond") or obj.Name:lower():match("money") or obj.Name:lower():match("cash")) then
                local distance = (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 100 then
                    -- Teleport to bond and collect
                    local originalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                    LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                    task.wait(0.1)
                    fireproximityprompt(obj:FindFirstChildOfClass("ProximityPrompt") or obj, 0)
                end
            end
        end
    end
end

-- ESP for Monsters/Enemies
local ESPObjects = {}
local function CreateESP(target, name, color)
    if ESPObjects[target] then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP"
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = color or Color3.fromRGB(255, 0, 0)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextSize = 14
    TextLabel.Text = name
    
    TextLabel.Parent = Billboard
    
    -- Box
    local Box = Instance.new("BoxHandleAdornment")
    Box.Size = target.Size + Vector3.new(0.5, 0.5, 0.5)
    Box.Color3 = color or Color3.fromRGB(255, 0, 0)
    Box.AlwaysOnTop = true
    Box.Transparency = 0.5
    Box.Adornee = target
    Box.Parent = Billboard
    
    Billboard.Parent = target
    ESPObjects[target] = Billboard
    
    -- Cleanup when destroyed
    target.AncestryChanged:Connect(function()
        if not target:IsDescendantOf(Workspace) then
            Billboard:Destroy()
            ESPObjects[target] = nil
        end
    end)
end

local function UpdateESP()
    while task.wait(1) do
        if not Settings.ESP then
            -- Clear all ESP
            for _, esp in pairs(ESPObjects) do
                esp:Destroy()
            end
            ESPObjects = {}
            continue
        end
        
        -- Find enemies
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                if obj.Name:lower():match("zombie") or obj.Name:lower():match("monster") or obj.Name:lower():match("enemy") then
                    CreateESP(obj, obj.Name .. " [" .. math.floor(obj.Humanoid.Health) .. "HP]", Color3.fromRGB(255, 0, 0))
                end
            end
        end
        
        -- Find items
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():match("loot") or obj.Name:lower():match("item") or obj.Name:lower():match("weapon")) then
                CreateESP(obj, obj.Name, Color3.fromRGB(0, 255, 0))
            end
        end
    end
end

-- Auto Revive Teammates
local function AutoRevive()
    while task.wait(0.1) do
        if not Settings.AutoRevive then continue end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid and Humanoid.Health <= 0 or Humanoid.PlatformStand then
                    -- Teleport to downed teammate and revive
                    local HRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        local originalPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                        LocalPlayer.Character.HumanoidRootPart.CFrame = HRP.CFrame
                        task.wait(0.2)
                        
                        -- Simulate revive action
                        keypress(0x45) -- E key
                        task.wait(0.1)
                        keyrelease(0x45)
                        
                        task.wait(0.5)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
                    end
                end
            end
        end
    end
end

-- Speed Hack & Infinite Stamina
local function SpeedHack()
    while task.wait() do
        if Settings.SpeedHack then
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.WalkSpeed = Settings.WalkSpeed
                    Humanoid.JumpPower = Settings.JumpPower
                end
            end
        end
    end
end

-- Infinite Ammo / No Reload
local function InfiniteAmmo()
    while task.wait(0.1) do
        if not Settings.InfiniteAmmo then continue end
        
        local Character = LocalPlayer.Character
        if Character then
            for _, tool in pairs(Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                    tool.Ammo.Value = 999
                end
                if tool:IsA("Tool") and tool:FindFirstChild("Clip") then
                    tool.Clip.Value = 999
                end
            end
        end
    end
end

-- Double Damage
local function DoubleDamage()
    while task.wait(0.1) do
        if not Settings.DoubleDamage then continue end
        
        local Character = LocalPlayer.Character
        if Character then
            for _, tool in pairs(Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Damage") then
                    tool.Damage.Value = tool.Damage.Value * 2
                end
            end
        end
    end
end

-- Anti-AFK
local function AntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

-- ============================================
-- INITIALIZATION
-- ============================================

local function Initialize()
    -- Create UI
    CreateUI()
    
    -- Start loops
    task.spawn(AutoFarmBonds)
    task.spawn(UpdateESP)
    task.spawn(AutoRevive)
    task.spawn(SpeedHack)
    task.spawn(InfiniteAmmo)
    task.spawn(DoubleDamage)
    
    -- Character respawn handler
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if Settings.GodMode then
            EnableGodMode()
        end
    end)
    
    -- Initial god mode if enabled
    if LocalPlayer.Character then
        EnableGodMode()
    end
    
    AntiAFK()
    
    print("=== DEAD RAILS SCRIPT LOADED ===")
    print("Features: Auto Farm, God Mode, ESP, Teleports, Auto Revive")
end

-- Run
Initialize()
