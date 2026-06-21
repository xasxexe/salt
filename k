-- ============================================
-- УЛУЧШЕННЫЙ ЧИТ-СКРИПТ (С ДВИГАЕМЫМ GUI И УМНЫМ ESP)
-- ============================================

-- ============================================
-- 1. ДВИГАЕМОЕ GUI МЕНЮ
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local DragButton = Instance.new("TextButton")  -- Кнопка для перетаскивания
local CloseButton = Instance.new("TextButton") -- Кнопка закрытия

-- Настройка главного окна
ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 220, 0, 380)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -190) -- По центру экрана
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true  -- Встроенная функция перетаскивания!

-- Заголовок с возможностью перетаскивания
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔧 Чит Меню (F1)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.TextScaled = true

-- Кнопка закрытия (крестик)
CloseButton.Parent = MainFrame
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 2)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
CloseButton.BackgroundTransparency = 0.5
CloseButton.BorderSizePixel = 0

-- Функция для создания кнопок с подписями
local function CreateButton(parent, text, yPos, color, subText)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 70)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    return btn
end

-- Создаём кнопки
local ESPButton = CreateButton(MainFrame, "ESP (Вкл)", 35, Color3.fromRGB(0, 150, 0))
local AimbotButton = CreateButton(MainFrame, "Аимбот (Вкл)", 68, Color3.fromRGB(0, 150, 0))
local FlyButton = CreateButton(MainFrame, "Полет (Вкл)", 101, Color3.fromRGB(0, 150, 0))
local SpeedButton = CreateButton(MainFrame, "Скорость x1", 134, Color3.fromRGB(0, 150, 0))
local TeleportButton = CreateButton(MainFrame, "Телепорт к игроку", 167, Color3.fromRGB(0, 150, 0))

-- Дополнительные настройки для ESP и аимбота
local ESPSettingsLabel = Instance.new("TextLabel")
ESPSettingsLabel.Parent = MainFrame
ESPSettingsLabel.Size = UDim2.new(0.9, 0, 0, 20)
ESPSettingsLabel.Position = UDim2.new(0.05, 0, 0, 200)
ESPSettingsLabel.Text = "⚙️ Настройки ESP:"
ESPSettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ESPSettingsLabel.BackgroundTransparency = 1
ESPSettingsLabel.TextSize = 14

-- Ползунок для радиуса аимбота
local AimbotRadiusLabel = Instance.new("TextLabel")
AimbotRadiusLabel.Parent = MainFrame
AimbotRadiusLabel.Size = UDim2.new(0.5, 0, 0, 20)
AimbotRadiusLabel.Position = UDim2.new(0.05, 0, 0, 225)
AimbotRadiusLabel.Text = "Радиус аима: 200"
AimbotRadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimbotRadiusLabel.BackgroundTransparency = 1
AimbotRadiusLabel.TextSize = 12

local AimbotRadiusSlider = Instance.new("TextBox")
AimbotRadiusSlider.Parent = MainFrame
AimbotRadiusSlider.Size = UDim2.new(0.3, 0, 0, 20)
AimbotRadiusSlider.Position = UDim2.new(0.6, 0, 0, 225)
AimbotRadiusSlider.Text = "200"
AimbotRadiusSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotRadiusSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
AimbotRadiusSlider.TextSize = 12

-- ============================================
-- 2. ПЕРЕМЕННЫЕ
-- ============================================
local espEnabled = false
local aimbotEnabled = false
local flyEnabled = false
local speedMultiplier = 1
local aimbotRadius = 200

-- ============================================
-- 3. УМНЫЙ ESP (СКРЫВАЕТ ЗА СТЕНАМИ, МЕНЯЕТ ЦВЕТ)
-- ============================================
local espObjects = {}
local espLines = {}

-- Функция проверки видимости (Raycast)
local function IsVisible(origin, target)
    local ray = Ray.new(origin, (target - origin).Unit * (origin - target).Magnitude)
    local hit, position = workspace:FindPartOnRay(ray, game.Players.LocalPlayer.Character)
    
    if hit and hit:IsDescendantOf(target.Parent) then
        return true  -- Цель видна напрямую
    end
    return false
end

-- Функция создания ESP для игрока
local function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = player.Character.HumanoidRootPart
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    -- Проверяем видимость
    local visible = IsVisible(camera.CFrame.Position, rootPart.Position)
    
    -- Выбираем цвет: красный (за стеной) или зелёный (видим)
    local espColor = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    
    -- Создаём рамку вокруг игрока
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(3.5, 5.5, 2)
    box.Adornee = rootPart
    box.Color3 = espColor
    box.Transparency = 0.4
    box.ZIndex = 10
    box.Parent = rootPart
    
    -- Создаём линию до игрока (трассер)
    local line = Instance.new("SelectionBox")
    line.Adornee = rootPart
    line.Color3 = espColor
    line.LineThickness = 0.15
    line.Transparency = 0.3
    line.Parent = rootPart
    
    -- Добавляем в списки
    table.insert(espObjects, box)
    table.insert(espObjects, line)
end

-- Обновление ESP
local function UpdateESP()
    -- Удаляем старые объекты
    for _, obj in pairs(espObjects) do
        obj:Destroy()
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    -- Создаём ESP для всех игроков
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            CreateESP(player)
        end
    end
end

-- Постоянное обновление цветов (каждый кадр)
game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then return end
    
    local camera = workspace.CurrentCamera
    local localPlayer = game.Players.LocalPlayer
    
    -- Обновляем ESP-объекты для каждого игрока
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Проверяем видимость
                local visible = IsVisible(camera.CFrame.Position, rootPart.Position)
                local espColor = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                -- Обновляем цвет всех ESP-объектов этого игрока
                for _, obj in pairs(rootPart:GetChildren()) do
                    if obj:IsA("BoxHandleAdornment") or obj:IsA("SelectionBox") then
                        obj.Color3 = espColor
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 4. УМНЫЙ АИМБОТ С РАДИУСОМ И КРУГОМ
-- ============================================

-- Создаём круг для аимбота (визуальный индикатор)
local AimbotCircle = Instance.new("ImageLabel")
AimbotCircle.Parent = ScreenGui
AimbotCircle.Size = UDim2.new(0, aimbotRadius * 2, 0, aimbotRadius * 2)
AimbotCircle.Position = UDim2.new(0.5, -aimbotRadius, 0.5, -aimbotRadius)
AimbotCircle.BackgroundTransparency = 1
AimbotCircle.Image = "rbxassetid://7074833319"  -- Круглая текстура
AimbotCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
AimbotCircle.ImageTransparency = 0.7
AimbotCircle.Visible = false  -- По умолчанию скрыт

-- Обновление круга при изменении радиуса
AimbotRadiusSlider.FocusLost:Connect(function()
    local newRadius = tonumber(AimbotRadiusSlider.Text)
    if newRadius and newRadius > 0 then
        aimbotRadius = newRadius
        AimbotCircle.Size = UDim2.new(0, aimbotRadius * 2, 0, aimbotRadius * 2)
        AimbotCircle.Position = UDim2.new(0.5, -aimbotRadius, 0.5, -aimbotRadius)
        AimbotRadiusLabel.Text = "Радиус аима: " .. aimbotRadius
    else
        AimbotRadiusSlider.Text = tostring(aimbotRadius)
    end
end)

-- Показывать/скрывать круг вместе с аимботом
local function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    AimbotButton.Text = aimbotEnabled and "Аимбот (Выкл)" or "Аимбот (Вкл)"
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    AimbotCircle.Visible = aimbotEnabled
end

-- Функция поиска ближайшего игрока в радиусе
local function GetClosestPlayerInRadius()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closest = nil
    local closestDist = aimbotRadius
    local camera = workspace.CurrentCamera
    
    -- Получаем центр экрана для расчета угла
    local viewportSize = camera.ViewportSize
    local centerScreen = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            
            -- Проверяем, видим ли игрока (не за стеной)
            local visible = IsVisible(camera.CFrame.Position, rootPart.Position)
            if not visible then continue end  -- Пропускаем невидимых
            
            -- Проецируем позицию игрока на экран
            local screenPos, onScreen = camera:WorldToScreenPoint(rootPart.Position)
            if not onScreen then continue end
            
            -- Считаем расстояние от центра экрана до игрока (в пикселях)
            local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
            
            -- Проверяем, попадает ли в радиус
            if distFromCenter < closestDist then
                closest = player
                closestDist = distFromCenter
            end
        end
    end
    
    return closest
end

-- Функция наведения на цель
local function AimAtPlayer(player)
    if not player or not player.Character then
        return
    end
    
    local camera = workspace.CurrentCamera
    local targetPos = player.Character:FindFirstChild("Head") and player.Character.Head.Position or player.Character.HumanoidRootPart.Position
    
    -- Плавное наведение (скорость 0.4)
    local vector = (targetPos - camera.CFrame.Position).Unit
    local newCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
    camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.4)
end

-- ============================================
-- 5. ПОЛЁТ (УЛУЧШЕННЫЙ)
-- ============================================
local flyVelocity = nil
local flyConnection = nil

local function ToggleFly()
    flyEnabled = not flyEnabled
    FlyButton.Text = flyEnabled and "Полет (Выкл)" or "Полет (Вкл)"
    FlyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if flyEnabled then
        character.Humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = character.HumanoidRootPart
        
        -- Управление через WASD
        flyConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not flyEnabled or not flyVelocity then return end
            
            local char = game.Players.LocalPlayer.Character
            if not char then return end
            
            local moveVector = Vector3.new(0, 0, 0)
            local speed = 60
            
            if input.KeyCode == Enum.KeyCode.W then
                moveVector = moveVector + char.HumanoidRootPart.CFrame.LookVector * speed
            end
            if input.KeyCode == Enum.KeyCode.S then
                moveVector = moveVector - char.HumanoidRootPart.CFrame.LookVector * speed
            end
            if input.KeyCode == Enum.KeyCode.A then
                moveVector = moveVector - char.HumanoidRootPart.CFrame.RightVector * speed
            end
            if input.KeyCode == Enum.KeyCode.D then
                moveVector = moveVector + char.HumanoidRootPart.CFrame.RightVector * speed
            end
            if input.KeyCode == Enum.KeyCode.Space then
                moveVector = moveVector + Vector3.new(0, speed, 0)
            end
            if input.KeyCode == Enum.KeyCode.LeftShift then
                moveVector = moveVector - Vector3.new(0, speed, 0)
            end
            
            flyVelocity.Velocity = moveVector
        end)
    else
        character.Humanoid.PlatformStand = false
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
-- 6. ОСТАЛЬНЫЕ ФУНКЦИИ
-- ============================================

-- Скорость
local function ToggleSpeed()
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then
        return
    end
    
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

-- Телепорт
local function TeleportToPlayer(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local targetRoot = player.Character.HumanoidRootPart
    local behind = targetRoot.Position - targetRoot.CFrame.LookVector * 4
    
    character.HumanoidRootPart.CFrame = CFrame.new(behind)
end

local function SelectTeleportTarget()
    TeleportToPlayer(GetClosestPlayerInRadius() or GetClosestPlayer())
end

-- ============================================
-- 7. ПОДКЛЮЧЕНИЕ КНОПОК
-- ============================================
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "ESP (Выкл)" or "ESP (Вкл)"
    ESPButton.BackgroundColor3 = espEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    UpdateESP()
end)

AimbotButton.MouseButton1Click:Connect(ToggleAimbot)

FlyButton.MouseButton1Click:Connect(ToggleFly)

SpeedButton.MouseButton1Click:Connect(ToggleSpeed)

TeleportButton.MouseButton1Click:Connect(SelectTeleportTarget)

-- Закрытие меню
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Показать меню по F1
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- 8. ОСНОВНОЙ ЦИКЛ (Аимбот работает постоянно)
-- ============================================
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetClosestPlayerInRadius()
        if target then
            AimAtPlayer(target)
        end
    end
end)

print("✅ Улучшенный чит загружен! Нажми F1 для меню.")
print("🎯 ESP: Зелёный = видим, Красный = за стеной")
print("🔄 GUI можно перетаскивать за заголовок")
