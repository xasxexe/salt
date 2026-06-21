-- ============================================
-- ПОЛНОСТЬЮ РАБОЧИЙ ЧИТ-СКРИПТ (ВСЕ ФИКСЫ)
-- ============================================

-- ============================================
-- 1. ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================
local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Настройки
local espEnabled = false
local aimbotEnabled = false
local flyEnabled = false
local speedMultiplier = 1
local aimbotRadius = 200
local selectedTarget = nil
local playerList = {}
local lastPlayerUpdate = 0

-- ============================================
-- 2. СОЗДАНИЕ GUI (НЕ ИСЧЕЗАЕТ)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false  -- ВАЖНО: не сбрасывается при смерти!

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔧 Чит Меню (F1)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Title.TextScaled = true

-- Крестик закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 2)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
CloseButton.BackgroundTransparency = 0.5
CloseButton.BorderSizePixel = 0

-- Функция создания кнопок
local function CreateButton(parent, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = color or Color3.fromRGB(55, 55, 70)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    return btn
end

-- Кнопки
local ESPButton = CreateButton(MainFrame, "ESP (Выкл)", 35, Color3.fromRGB(60, 60, 80))
local AimbotButton = CreateButton(MainFrame, "Аимбот (Выкл)", 68, Color3.fromRGB(60, 60, 80))
local FlyButton = CreateButton(MainFrame, "Полет (Выкл)", 101, Color3.fromRGB(60, 60, 80))
local SpeedButton = CreateButton(MainFrame, "Скорость x1", 134, Color3.fromRGB(60, 60, 80))
local TeleportButton = CreateButton(MainFrame, "Телепорт (выбрать цель)", 167, Color3.fromRGB(60, 60, 80))

-- Настройки радиуса
local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Parent = MainFrame
RadiusLabel.Size = UDim2.new(0.5, 0, 0, 20)
RadiusLabel.Position = UDim2.new(0.05, 0, 0, 205)
RadiusLabel.Text = "Радиус аима: 200"
RadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.TextSize = 13

local RadiusInput = Instance.new("TextBox")
RadiusInput.Parent = MainFrame
RadiusInput.Size = UDim2.new(0.25, 0, 0, 20)
RadiusInput.Position = UDim2.new(0.6, 0, 0, 205)
RadiusInput.Text = "200"
RadiusInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
RadiusInput.TextSize = 13

-- Список игроков для телепорта
local PlayerListLabel = Instance.new("TextLabel")
PlayerListLabel.Parent = MainFrame
PlayerListLabel.Size = UDim2.new(0.9, 0, 0, 20)
PlayerListLabel.Position = UDim2.new(0.05, 0, 0, 235)
PlayerListLabel.Text = "📋 Игроки для телепорта:"
PlayerListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerListLabel.BackgroundTransparency = 1
PlayerListLabel.TextSize = 13

local PlayerListBox = Instance.new("ScrollingFrame")
PlayerListBox.Parent = MainFrame
PlayerListBox.Size = UDim2.new(0.9, 0, 0, 120)
PlayerListBox.Position = UDim2.new(0.05, 0, 0, 258)
PlayerListBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
PlayerListBox.BorderSizePixel = 0

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Parent = PlayerListBox
PlayerListLayout.SortOrder = Enum.SortOrder.Name

-- ============================================
-- 3. ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ (КАЖДЫЕ 5 СЕКУНД)
-- ============================================
local function UpdatePlayerList()
    -- Очищаем старый список
    for _, child in pairs(PlayerListBox:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Обновляем список игроков
    playerList = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player)
        end
    end
    
    -- Создаём кнопки для каждого игрока
    for _, player in pairs(playerList) do
        local btn = Instance.new("TextButton")
        btn.Parent = PlayerListBox
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.Text = player.Name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        
        -- При нажатии выбираем цель
        btn.MouseButton1Click:Connect(function()
            selectedTarget = player
            TeleportButton.Text = "Телепорт к: " .. player.Name
            TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
    end
end

-- Обновляем список каждые 5 секунд
game:GetService("RunService").Heartbeat:Connect(function()
    if tick() - lastPlayerUpdate > 5 then
        lastPlayerUpdate = tick()
        UpdatePlayerList()
    end
end)

-- Первое обновление
UpdatePlayerList()

-- ============================================
-- 4. ESP (РАБОТАЕТ И МЕНЯЕТ ЦВЕТ)
-- ============================================
local espObjects = {}

local function IsVisible(origin, target)
    local direction = (target - origin).Unit
    local distance = (origin - target).Magnitude
    local ray = Ray.new(origin, direction * distance)
    local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    
    if hit then
        -- Проверяем, является ли препятствие частью цели
        if hit:IsDescendantOf(target.Parent) then
            return true
        end
        return false
    end
    return true
end

local function UpdateESP()
    -- Удаляем старые ESP объекты
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local visible = IsVisible(Camera.CFrame.Position, root.Position)
                local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                -- Рамка
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3.5, 5.5, 2)
                box.Adornee = root
                box.Color3 = color
                box.Transparency = 0.3
                box.ZIndex = 10
                box.Parent = root
                table.insert(espObjects, box)
                
                -- Линия
                local line = Instance.new("SelectionBox")
                line.Adornee = root
                line.Color3 = color
                line.LineThickness = 0.1
                line.Transparency = 0.3
                line.Parent = root
                table.insert(espObjects, line)
            end
        end
    end
end

-- ============================================
-- 5. АИМБОТ (С КРУГОМ И РАДИУСОМ)
-- ============================================
local aimbotCircle = Instance.new("ImageLabel")
aimbotCircle.Parent = ScreenGui
aimbotCircle.Size = UDim2.new(0, 400, 0, 400)
aimbotCircle.Position = UDim2.new(0.5, -200, 0.5, -200)
aimbotCircle.BackgroundTransparency = 1
aimbotCircle.Image = "rbxassetid://7074833319"
aimbotCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
aimbotCircle.ImageTransparency = 0.8
aimbotCircle.Visible = false
aimbotCircle.ZIndex = 999

-- Обновление круга
RadiusInput.FocusLost:Connect(function()
    local val = tonumber(RadiusInput.Text)
    if val and val > 0 and val < 1000 then
        aimbotRadius = val
        local size = aimbotRadius * 2
        aimbotCircle.Size = UDim2.new(0, size, 0, size)
        aimbotCircle.Position = UDim2.new(0.5, -aimbotRadius, 0.5, -aimbotRadius)
        RadiusLabel.Text = "Радиус аима: " .. aimbotRadius
    else
        RadiusInput.Text = tostring(aimbotRadius)
    end
end)

local function GetClosestPlayerInRadius()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closest = nil
    local closestDist = aimbotRadius
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Проверяем видимость (только видимых)
                if not IsVisible(Camera.CFrame.Position, root.Position) then
                    continue
                end
                
                local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if not onScreen then continue end
                
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                if dist < closestDist then
                    closest = player
                    closestDist = dist
                end
            end
        end
    end
    
    return closest
end

local function AimAtPlayer(player)
    if not player or not player.Character then
        return
    end
    
    local target = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
    if not target then return end
    
    local targetPos = target.Position
    local newCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.5)
end

-- ============================================
-- 6. ПОЛЁТ
-- ============================================
local flyBodyVelocity = nil
local flyConnection = nil

local function ToggleFly()
    flyEnabled = not flyEnabled
    FlyButton.Text = flyEnabled and "Полет (Вкл)" or "Полет (Выкл)"
    FlyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 80)
    
    local character = LocalPlayer.Character
    if not character then return end
    
    if flyEnabled then
        character.Humanoid.PlatformStand = true
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = character.HumanoidRootPart
        
        flyConnection = UserInput.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not flyEnabled or not flyBodyVelocity then return end
            
            local char = LocalPlayer.Character
            if not char or not char.HumanoidRootPart then return end
            
            local move = Vector3.new(0, 0, 0)
            local speed = 60
            
            if input.KeyCode == Enum.KeyCode.W then
                move = move + char.HumanoidRootPart.CFrame.LookVector * speed
            end
            if input.KeyCode == Enum.KeyCode.S then
                move = move - char.HumanoidRootPart.CFrame.LookVector * speed
            end
            if input.KeyCode == Enum.KeyCode.A then
                move = move - char.HumanoidRootPart.CFrame.RightVector * speed
            end
            if input.KeyCode == Enum.KeyCode.D then
                move = move + char.HumanoidRootPart.CFrame.RightVector * speed
            end
            if input.KeyCode == Enum.KeyCode.Space then
                move = move + Vector3.new(0, speed, 0)
            end
            if input.KeyCode == Enum.KeyCode.LeftShift then
                move = move - Vector3.new(0, speed, 0)
            end
            
            flyBodyVelocity.Velocity = move
        end)
    else
        character.Humanoid.PlatformStand = false
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
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
    local character = LocalPlayer.Character
    if not character then return end
    
    if speedMultiplier == 1 then
        speedMultiplier = 2
        SpeedButton.Text = "Скорость x3"
        character.Humanoid.WalkSpeed = 32
    elseif speedMultiplier == 2 then
        speedMultiplier = 3
        SpeedButton.Text = "Скорость x1"
        character.Humanoid.WalkSpeed = 16
        speedMultiplier = 1
    end
end

-- ============================================
-- 8. ТЕЛЕПОРТ
-- ============================================
local function TeleportToPlayer(player)
    if not player or not player.Character then
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local behind = targetRoot.Position - targetRoot.CFrame.LookVector * 4
    character.HumanoidRootPart.CFrame = CFrame.new(behind)
end

local function DoTeleport()
    if selectedTarget then
        TeleportToPlayer(selectedTarget)
    else
        -- Если цель не выбрана, телепортируем к ближайшему
        local closest = GetClosestPlayerInRadius()
        if closest then
            TeleportToPlayer(closest)
        end
    end
end

-- ============================================
-- 9. ПОДКЛЮЧЕНИЕ КНОПОК
-- ============================================
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "ESP (Вкл)" or "ESP (Выкл)"
    ESPButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 80)
    UpdateESP()
end)

AimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotButton.Text = aimbotEnabled and "Аимбот (Вкл)" or "Аимбот (Выкл)"
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 80)
    aimbotCircle.Visible = aimbotEnabled
end)

FlyButton.MouseButton1Click:Connect(ToggleFly)
SpeedButton.MouseButton1Click:Connect(ToggleSpeed)
TeleportButton.MouseButton1Click:Connect(DoTeleport)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Показать/скрыть меню по F1
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- 10. ОСНОВНЫЕ ЦИКЛЫ
-- ============================================

-- Обновление ESP (каждый кадр)
RunService.RenderStepped:Connect(function()
    if espEnabled then
        -- Обновляем цвета ESP в реальном времени
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local visible = IsVisible(Camera.CFrame.Position, root.Position)
                    local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    
                    for _, obj in pairs(root:GetChildren()) do
                        if obj:IsA("BoxHandleAdornment") or obj:IsA("SelectionBox") then
                            obj.Color3 = color
                        end
                    end
                end
            end
        end
    end
end)

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
-- 11. ВОССТАНОВЛЕНИЕ ПОСЛЕ СМЕРТИ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    -- Восстанавливаем скорость
    local character = LocalPlayer.Character
    if character then
        wait(0.5)
        if speedMultiplier == 2 then
            character.Humanoid.WalkSpeed = 32
        else
            character.Humanoid.WalkSpeed = 16
        end
    end
    
    -- Восстанавливаем ESP
    if espEnabled then
        wait(0.5)
        UpdateESP()
    end
end)

print("✅ Чит загружен! Нажми F1 для меню.")
print("📋 Список игроков обновляется каждые 5 секунд.")
print("🎯 ESP: Зелёный = видим, Красный = за стеной.")
print("🔄 GUI можно перетаскивать за заголовок.")
