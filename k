-- ============================================
-- ЧИТ НА ОСНОВЕ ПЕРВОЙ РАБОЧЕЙ ВЕРСИИ
-- ============================================

local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============================================
-- ПЕРЕМЕННЫЕ
-- ============================================
local espEnabled = false
local aimbotEnabled = false
local flyEnabled = false
local speedMultiplier = 1
local aimbotRadius = 250
local espObjects = {}
local selectedTarget = nil

-- ============================================
-- 1. СОЗДАНИЕ GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 200, 0, 370)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Text = "Чит Меню (F1)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)

local function Btn(parent, text, y, color)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0.9, 0, 0, 26)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 65)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    return b
end

local ESPBtn = Btn(MainFrame, "ESP [Выкл]", 33, Color3.fromRGB(50, 50, 65))
local AimBtn = Btn(MainFrame, "Аимбот [Выкл]", 63, Color3.fromRGB(50, 50, 65))
local FlyBtn = Btn(MainFrame, "Полет [Выкл]", 93, Color3.fromRGB(50, 50, 65))
local SpeedBtn = Btn(MainFrame, "Скорость x1", 123, Color3.fromRGB(50, 50, 65))
local TpBtn = Btn(MainFrame, "Телепорт", 153, Color3.fromRGB(50, 50, 65))

-- Радиус
local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Parent = MainFrame
RadiusLabel.Size = UDim2.new(0.5, 0, 0, 20)
RadiusLabel.Position = UDim2.new(0.05, 0, 0, 188)
RadiusLabel.Text = "Радиус: 250"
RadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.TextSize = 12

local RadiusInput = Instance.new("TextBox")
RadiusInput.Parent = MainFrame
RadiusInput.Size = UDim2.new(0.25, 0, 0, 20)
RadiusInput.Position = UDim2.new(0.6, 0, 0, 188)
RadiusInput.Text = "250"
RadiusInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
RadiusInput.TextSize = 12

-- Список игроков
local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Parent = MainFrame
PlayerLabel.Size = UDim2.new(0.9, 0, 0, 18)
PlayerLabel.Position = UDim2.new(0.05, 0, 0, 215)
PlayerLabel.Text = "Цели для телепорта:"
PlayerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.TextSize = 12

local PlayerFrame = Instance.new("ScrollingFrame")
PlayerFrame.Parent = MainFrame
PlayerFrame.Size = UDim2.new(0.9, 0, 0, 75)
PlayerFrame.Position = UDim2.new(0.05, 0, 0, 237)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
PlayerFrame.BorderSizePixel = 0

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Parent = PlayerFrame
PlayerLayout.SortOrder = Enum.SortOrder.Name

-- ============================================
-- 2. КРУГ АИМБОТА
-- ============================================
local AimbotCircle = Instance.new("ImageLabel")
AimbotCircle.Parent = ScreenGui
AimbotCircle.Size = UDim2.new(0, 500, 0, 500)
AimbotCircle.Position = UDim2.new(0.5, -250, 0.5, -250)
AimbotCircle.BackgroundTransparency = 1
AimbotCircle.Image = "rbxassetid://7074833319"
AimbotCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
AimbotCircle.ImageTransparency = 0.85
AimbotCircle.Visible = false
AimbotCircle.ZIndex = 999

-- Обновление круга при изменении радиуса
RadiusInput.FocusLost:Connect(function()
    local val = tonumber(RadiusInput.Text)
    if val and val > 0 and val < 1000 then
        aimbotRadius = val
        local size = aimbotRadius * 2
        AimbotCircle.Size = UDim2.new(0, size, 0, size)
        AimbotCircle.Position = UDim2.new(0.5, -aimbotRadius, 0.5, -aimbotRadius)
        RadiusLabel.Text = "Радиус: " .. aimbotRadius
    else
        RadiusInput.Text = tostring(aimbotRadius)
    end
end)

-- ============================================
-- 3. ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ
-- ============================================
local function UpdatePlayerList()
    for _, child in pairs(PlayerFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerFrame
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.Text = player.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            btn.BorderSizePixel = 0
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamMedium
            
            btn.MouseButton1Click:Connect(function()
                selectedTarget = player
                TpBtn.Text = "Тп к: " .. player.Name
                TpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            end)
        end
    end
end

UpdatePlayerList()
game.Players.PlayerAdded:Connect(UpdatePlayerList)
game.Players.PlayerRemoving:Connect(UpdatePlayerList)

-- ============================================
-- 4. ESP (РАБОТАЕТ)
-- ============================================
local function UpdateESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Рамка
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3.5, 5.5, 2)
                box.Adornee = root
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.Transparency = 0.25
                box.ZIndex = 10
                box.Parent = root
                table.insert(espObjects, box)
                
                -- Имя над игроком
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = root
                billboard.Size = UDim2.new(0, 100, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.Parent = root
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = billboard
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                table.insert(espObjects, billboard)
            end
        end
    end
end

-- ============================================
-- 5. АИМБОТ (С КРУГОМ)
-- ============================================
local function GetClosestPlayerInRadius()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local closest = nil
    local closestDist = aimbotRadius
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                    if dist < closestDist then
                        closest = player
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    return closest
end

local function AimAtPlayer(player)
    if not player or not player.Character then return end
    local target = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
    if not target then return end
    
    local newCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, 0.4)
end

-- ============================================
-- 6. ПОЛЁТ (НОРМАЛЬНЫЙ)
-- ============================================
local flyVelocity = nil
local flyConnection = nil

local function ToggleFly()
    flyEnabled = not flyEnabled
    FlyBtn.Text = flyEnabled and "Полет [Вкл]" or "Полет [Выкл]"
    FlyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 65)
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if flyEnabled then
        char.Humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = char.HumanoidRootPart
        
        -- Управление через InputBegan + InputEnded
        local moveVector = Vector3.new(0, 0, 0)
        local keys = {W = false, S = false, A = false, D = false, Space = false, Shift = false}
        
        local function UpdateFly()
            if not flyEnabled or not flyVelocity then return end
            local char = LocalPlayer.Character
            if not char then return end
            
            local speed = 50
            local move = Vector3.new(0, 0, 0)
            local root = char.HumanoidRootPart
            
            if keys.W then move = move + root.CFrame.LookVector * speed end
            if keys.S then move = move - root.CFrame.LookVector * speed end
            if keys.A then move = move - root.CFrame.RightVector * speed end
            if keys.D then move = move + root.CFrame.RightVector * speed end
            if keys.Space then move = move + Vector3.new(0, speed, 0) end
            if keys.Shift then move = move - Vector3.new(0, speed, 0) end
            
            flyVelocity.Velocity = move
        end
        
        local function onKey(input, state)
            if input.KeyCode == Enum.KeyCode.W then keys.W = state end
            if input.KeyCode == Enum.KeyCode.S then keys.S = state end
            if input.KeyCode == Enum.KeyCode.A then keys.A = state end
            if input.KeyCode == Enum.KeyCode.D then keys.D = state end
            if input.KeyCode == Enum.KeyCode.Space then keys.Space = state end
            if input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = state end
            UpdateFly()
        end
        
        flyConnection = UserInput.InputBegan:Connect(function(input) onKey(input, true) end)
        UserInput.InputEnded:Connect(function(input) onKey(input, false) end)
    else
        char.Humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end

-- ============================================
-- 7. СКОРОСТЬ
-- ============================================
local function ToggleSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    
    if speedMultiplier == 1 then
        speedMultiplier = 2
        SpeedBtn.Text = "Скорость x2"
        char.Humanoid.WalkSpeed = 32
    elseif speedMultiplier == 2 then
        speedMultiplier = 3
        SpeedBtn.Text = "Скорость x3"
        char.Humanoid.WalkSpeed = 48
    else
        speedMultiplier = 1
        SpeedBtn.Text = "Скорость x1"
        char.Humanoid.WalkSpeed = 16
    end
end

-- ============================================
-- 8. ТЕЛЕПОРТ
-- ============================================
local function DoTeleport()
    local target = selectedTarget or GetClosestPlayerInRadius()
    if not target or not target.Character then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    char.HumanoidRootPart.CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 3)
end

-- ============================================
-- 9. ПОДКЛЮЧЕНИЕ КНОПОК
-- ============================================
ESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPBtn.Text = espEnabled and "ESP [Вкл]" or "ESP [Выкл]"
    ESPBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 65)
    UpdateESP()
end)

AimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimBtn.Text = aimbotEnabled and "Аимбот [Вкл]" or "Аимбот [Выкл]"
    AimBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 65)
    AimbotCircle.Visible = aimbotEnabled
end)

FlyBtn.MouseButton1Click:Connect(ToggleFly)
SpeedBtn.MouseButton1Click:Connect(ToggleSpeed)
TpBtn.MouseButton1Click:Connect(DoTeleport)

-- ============================================
-- 10. КЛАВИШИ
-- ============================================
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- 11. ОСНОВНЫЕ ЦИКЛЫ
-- ============================================

-- Аимбот (каждый кадр)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetClosestPlayerInRadius()
        if target then
            AimAtPlayer(target)
        end
    end
end)

-- ============================================
-- 12. ВОССТАНОВЛЕНИЕ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    local char = LocalPlayer.Character
    if char then
        if speedMultiplier > 1 then
            char.Humanoid.WalkSpeed = 16 * speedMultiplier
        end
        if espEnabled then
            wait(0.3)
            UpdateESP()
        end
    end
end)

print("✅ Чит загружен! F1 - меню")
print("🎯 Круг аимбота виден при включении")
print("📋 Выбери игрока в списке для телепорта")
