-- ============================================
-- ФИНАЛЬНАЯ РАБОЧАЯ ВЕРСИЯ
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
local aimbotRadius = 300
local selectedTarget = nil
local espObjects = {}
local espEnabled = false
local aimbotTarget = nil  -- Цель для аимбота (вручную выбранная)

-- ============================================
-- 1. GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 220, 0, 420)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Text = "🔧 Чит (F1)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

local function Btn(parent, text, y, color)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0.9, 0, 0, 26)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    return b
end

local ESPBtn = Btn(MainFrame, "ESP [Выкл]", 33)
local AimBtn = Btn(MainFrame, "Аимбот [Выкл]", 63)
local FlyBtn = Btn(MainFrame, "Полет [Выкл]", 93)
local SpeedBtn = Btn(MainFrame, "Скорость x1", 123)
local TpBtn = Btn(MainFrame, "Телепорт", 153)

-- Радиус
local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Parent = MainFrame
RadiusLabel.Size = UDim2.new(0.5, 0, 0, 20)
RadiusLabel.Position = UDim2.new(0.05, 0, 0, 188)
RadiusLabel.Text = "Радиус: 300"
RadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.TextSize = 12

local RadiusInput = Instance.new("TextBox")
RadiusInput.Parent = MainFrame
RadiusInput.Size = UDim2.new(0.25, 0, 0, 20)
RadiusInput.Position = UDim2.new(0.6, 0, 0, 188)
RadiusInput.Text = "300"
RadiusInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusInput.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
RadiusInput.TextSize = 12

-- Список игроков для аимбота
local AimTargetLabel = Instance.new("TextLabel")
AimTargetLabel.Parent = MainFrame
AimTargetLabel.Size = UDim2.new(0.9, 0, 0, 18)
AimTargetLabel.Position = UDim2.new(0.05, 0, 0, 215)
AimTargetLabel.Text = "🎯 Цель для аимбота:"
AimTargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimTargetLabel.BackgroundTransparency = 1
AimTargetLabel.TextSize = 12

local AimTargetFrame = Instance.new("ScrollingFrame")
AimTargetFrame.Parent = MainFrame
AimTargetFrame.Size = UDim2.new(0.9, 0, 0, 60)
AimTargetFrame.Position = UDim2.new(0.05, 0, 0, 237)
AimTargetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
AimTargetFrame.BorderSizePixel = 0

local AimTargetLayout = Instance.new("UIListLayout")
AimTargetLayout.Parent = AimTargetFrame
AimTargetLayout.SortOrder = Enum.SortOrder.Name

-- Список игроков для телепорта
local TpTargetLabel = Instance.new("TextLabel")
TpTargetLabel.Parent = MainFrame
TpTargetLabel.Size = UDim2.new(0.9, 0, 0, 18)
TpTargetLabel.Position = UDim2.new(0.05, 0, 0, 302)
TpTargetLabel.Text = "📋 Цель для телепорта:"
TpTargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TpTargetLabel.BackgroundTransparency = 1
TpTargetLabel.TextSize = 12

local TpTargetFrame = Instance.new("ScrollingFrame")
TpTargetFrame.Parent = MainFrame
TpTargetFrame.Size = UDim2.new(0.9, 0, 0, 60)
TpTargetFrame.Position = UDim2.new(0.05, 0, 0, 324)
TpTargetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TpTargetFrame.BorderSizePixel = 0

local TpTargetLayout = Instance.new("UIListLayout")
TpTargetLayout.Parent = TpTargetFrame
TpTargetLayout.SortOrder = Enum.SortOrder.Name

-- ============================================
-- 2. КРУГ АИМБОТА
-- ============================================
local AimbotCircle = Instance.new("ImageLabel")
AimbotCircle.Parent = ScreenGui
AimbotCircle.Size = UDim2.new(0, 600, 0, 600)
AimbotCircle.Position = UDim2.new(0.5, -300, 0.5, -300)
AimbotCircle.BackgroundTransparency = 1
AimbotCircle.Image = "rbxassetid://7074833319"
AimbotCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
AimbotCircle.ImageTransparency = 0.85
AimbotCircle.Visible = false
AimbotCircle.ZIndex = 999

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
-- 3. ОБНОВЛЕНИЕ СПИСКОВ ИГРОКОВ
-- ============================================
local function UpdatePlayerLists()
    -- Очищаем оба списка
    for _, child in pairs(AimTargetFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, child in pairs(TpTargetFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Кнопка для аимбота
            local aimBtn = Instance.new("TextButton")
            aimBtn.Parent = AimTargetFrame
            aimBtn.Size = UDim2.new(1, 0, 0, 20)
            aimBtn.Text = player.Name
            aimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            aimBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            aimBtn.BorderSizePixel = 0
            aimBtn.TextSize = 11
            aimBtn.Font = Enum.Font.GothamMedium
            
            aimBtn.MouseButton1Click:Connect(function()
                aimbotTarget = player
                AimBtn.Text = "Аим: " .. player.Name
                AimBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                print("Цель аимбота: " .. player.Name)
            end)
            
            -- Кнопка для телепорта
            local tpBtn = Instance.new("TextButton")
            tpBtn.Parent = TpTargetFrame
            tpBtn.Size = UDim2.new(1, 0, 0, 20)
            tpBtn.Text = player.Name
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            tpBtn.BorderSizePixel = 0
            tpBtn.TextSize = 11
            tpBtn.Font = Enum.Font.GothamMedium
            
            tpBtn.MouseButton1Click:Connect(function()
                selectedTarget = player
                TpBtn.Text = "Тп к: " .. player.Name
                TpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                print("Цель телепорта: " .. player.Name)
            end)
        end
    end
end

UpdatePlayerLists()
game.Players.PlayerAdded:Connect(UpdatePlayerLists)
game.Players.PlayerRemoving:Connect(UpdatePlayerLists)

-- ============================================
-- 4. ESP (РАБОТАЕТ ЧЕРЕЗ СТЕНЫ)
-- ============================================
-- Включаем возможность видеть сквозь стены
local function MakeESPVisibleThroughWalls()
    -- Меняем настройки камеры, чтобы видеть сквозь стены
    Camera.FieldOfView = 70
    -- Дополнительно: убираем туман
    game:GetService("Lighting").FogEnd = 999999
end

local function UpdateESP()
    -- Удаляем старые объекты
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    MakeESPVisibleThroughWalls()
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Рамка
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3.5, 5.5, 2)
                box.Adornee = root
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.Transparency = 0.2
                box.ZIndex = 10
                box.AlwaysOnTop = true  -- ВАЖНО: показывает поверх всего
                box.Parent = root
                table.insert(espObjects, box)
                
                -- Линия до игрока
                local line = Instance.new("SelectionBox")
                line.Adornee = root
                line.Color3 = Color3.fromRGB(0, 255, 0)
                line.LineThickness = 0.15
                line.Transparency = 0.3
                line.Parent = root
                table.insert(espObjects, line)
                
                -- Имя над головой
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = root
                billboard.Size = UDim2.new(0, 120, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.Parent = root
                billboard.AlwaysOnTop = true  -- Поверх всего
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = billboard
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.TextStrokeTransparency = 0.3
                table.insert(espObjects, billboard)
            end
        end
    end
end

-- ============================================
-- 5. АИМБОТ (ВЫБОР ЦЕЛИ ВРУЧНУЮ)
-- ============================================
local function GetAimbotTarget()
    -- Если выбрана конкретная цель
    if aimbotTarget and aimbotTarget.Character then
        return aimbotTarget
    end
    
    -- Иначе ищем ближайшего в радиусе
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
    Camera.CFrame = Camera.CFrame:Lerp(newCF, 0.35)
end

-- ============================================
-- 6. ПОЛЁТ (РАБОТАЕТ)
-- ============================================
local flyVelocity = nil
local flyKeys = {W = false, S = false, A = false, D = false, Space = false, Shift = false}

local function UpdateFly()
    if not flyEnabled or not flyVelocity then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local speed = 50
    local move = Vector3.new(0, 0, 0)
    local root = char.HumanoidRootPart
    
    if flyKeys.W then move = move + root.CFrame.LookVector * speed end
    if flyKeys.S then move = move - root.CFrame.LookVector * speed end
    if flyKeys.A then move = move - root.CFrame.RightVector * speed end
    if flyKeys.D then move = move + root.CFrame.RightVector * speed end
    if flyKeys.Space then move = move + Vector3.new(0, speed, 0) end
    if flyKeys.Shift then move = move - Vector3.new(0, speed, 0) end
    
    flyVelocity.Velocity = move
end

local function ToggleFly()
    flyEnabled = not flyEnabled
    FlyBtn.Text = flyEnabled and "Полет [Вкл]" or "Полет [Выкл]"
    FlyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 60)
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if flyEnabled then
        char.Humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = char.HumanoidRootPart
    else
        char.Humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

-- Управление полётом
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true; UpdateFly() end
end)

UserInput.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false; UpdateFly() end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false; UpdateFly() end
end)

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
    local target = selectedTarget
    if not target or not target.Character then
        -- Если цель не выбрана, берём ближайшего
        local closest = nil
        local closestDist = math.huge
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (char.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closest = player
                        closestDist = dist
                    end
                end
            end
        end
        target = closest
    end
    
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
    ESPBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 60)
    UpdateESP()
end)

AimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimBtn.Text = aimbotEnabled and "Аимбот [Вкл]" or "Аимбот [Выкл]"
    AimBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 60)
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

-- Аимбот
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetAimbotTarget()
        if target then
            AimAtPlayer(target)
        end
    end
end)

-- ============================================
-- 12. ВОССТАНОВЛЕНИЕ ПОСЛЕ СМЕРТИ
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
print("🎯 Выбери цель для аимбота в списке 'Цель для аимбота'")
print("📋 Выбери цель для телепорта в списке 'Цель для телепорта'")
print("🔄 Если цель не выбрана - работает по ближайшему")
