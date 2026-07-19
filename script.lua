-- Dead Rails - Bring Bonds To Player
-- Bonds come to you, you don't move!

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Settings
local AutoBring = false

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BondBring"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Text = "BOND BRINGER"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleBtn.Text = "Bring Bonds: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, 2)
Status.BackgroundTransparency = 1
Status.Text = "Ready - Bonds will come to you"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    AutoBring = not AutoBring
    ToggleBtn.Text = "Bring Bonds: " .. (AutoBring and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = AutoBring and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    Status.Text = AutoBring and "Bringing bonds to you..." or "Ready"
end)

-- Draggable
local dragging = false
local dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Main loop - brings bonds to player
task.spawn(function()
    while true do
        task.wait(0.2)
        
        if AutoBring then
            local Character = LocalPlayer.Character
            if not Character then 
                Status.Text = "Waiting for character..."
                continue 
            end
            
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            if not HRP then 
                Status.Text = "Waiting for HRP..."
                continue 
            end
            
            local playerPos = HRP.Position
            local brought = 0
            
            -- Find and bring bonds
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not AutoBring then break end
                
                local name = obj.Name:lower()
                
                -- Check for bond/money items
                if name:find("bond") or name:find("treasury") or name:find("money") or name:find("cash") or name:find("gold") or name:find("loot") then
                    
                    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
                        
                        -- Check if it's collectable (not anchored or can be moved)
                        local dist = (obj.Position - playerPos).Magnitude
                        
                        -- Only bring if within range and not already at player
                        if dist > 5 and dist < 1000 then
                            brought = brought + 1
                            Status.Text = "Bringing: " .. obj.Name
                            
                            -- Move bond to player
                            pcall(function()
                                -- Unanchor if needed
                                if obj.Anchored then
                                    obj.Anchored = false
                                end
                                
                                -- Move to player position + random offset so they don't stack
                                local offset = Vector3.new(
                                    math.random(-3, 3),
                                    math.random(2, 5),
                                    math.random(-3, 3)
                                )
                                obj.CFrame = CFrame.new(playerPos + offset)
                                
                                -- Make sure it falls to ground
                                obj.Velocity = Vector3.new(0, 0, 0)
                            end)
                            
                            task.wait(0.1)
                        end
                    end
                end
            end
            
            if brought > 0 then
                Status.Text = "Brought " .. brought .. " items!"
                task.wait(0.5)
            else
                Status.Text = "No bonds nearby..."
                task.wait(1)
            end
        end
    end
end)

-- Also check for ProximityPrompts on bonds and trigger them
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if AutoBring then
            local Character = LocalPlayer.Character
            if not Character then continue end
            
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            if not HRP then continue end
            
            -- Find proximity prompts near player and fire them
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local parent = obj.Parent
                    if parent and parent:IsA("BasePart") then
                        local dist = (parent.Position - HRP.Position).Magnitude
                        if dist < 10 then
                            pcall(function()
                                fireproximityprompt(obj, 0)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

print("Bond Bringer Loaded! Toggle ON and bonds will come to you!")
