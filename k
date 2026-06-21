-- ============================================
-- УНИВЕРСАЛЬНЫЙ ЧИТ-СКРИПТ (УЧЕБНАЯ ВЕРСИЯ)
-- ============================================

-- 1. СОЗДАЁМ ГЛАВНОЕ МЕНЮ (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ESPButton = Instance.new("TextButton")
local AimbotButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local SpeedButton = Instance.new("TextButton")
local TeleportButton = Instance.new("TextButton")

-- Настройка внешнего вида меню
ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.2

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ЧИТ МЕНЮ (F1 для скрытия)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

-- Функция для создания кнопок
local function CreateButton(parent, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = color or Color3.fromRGB(70, 70, 70)
    btn.BorderSizePixel = 0
    return btn
end

ESPButton = CreateButton(MainFrame, "ESP (Вкл)", 35, Color3.fromRGB(0, 150, 0))
AimbotButton = CreateButton(MainFrame, "Аимбот (Вкл)", 70, Color3.fromRGB(0, 150, 0))
FlyButton = CreateButton(MainFrame, "Полет (Вкл)", 105, Color3.fromRGB(0, 150, 0))
SpeedButton = CreateButton(MainFrame, "Скорость x2", 140, Color3.fromRGB(0, 150, 0))
TeleportButton = CreateButton(MainFrame, "Телепорт к игроку", 175, Color3.fromRGB(0, 150, 0))

-- ============================================
-- 2. ПЕРЕМЕННЫЕ ДЛЯ НАСТРОЕК
-- ============================================
local espEnabled = false
local aimbotEnabled = false
local flyEnabled = false
local speedMultiplier = 1
local targetPlayer = nil

-- ============================================
-- 3. ESP (ВИДЕТЬ ВСЕХ СКВОЗЬ СТЕНЫ)
-- ============================================
local espObjects = {}

local function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Создаём рамку вокруг игрока
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)  -- Размер под человека
    box.Adornee = player.Character.HumanoidRootPart
    box.Color3 = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.ZIndex = 10
    box.Parent = player.Character.HumanoidRootPart
    
    -- Создаём линию до игрока (трассер)
    local tracer = Instance.new("SelectionBox")
    tracer.Adornee = player.Character.HumanoidRootPart
    tracer.Color3 = Color3.fromRGB(0, 255, 0)
    tracer.LineThickness = 0.1
    tracer.Transparency = 0.5
    tracer.Parent = player.Character.HumanoidRootPart
    
    -- Добавляем в список для удаления
    table.insert(espObjects, box)
    table.insert(espObjects, tracer)
end

local function UpdateESP()
    -- Удаляем старые ESP-объекты
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

-- ============================================
-- 4. АИМБОТ (АВТОПРИЦЕЛИВАНИЕ)
-- ============================================
local function GetClosestPlayer()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closest = nil
    local closestDist = math.huge
    local root = character.HumanoidRootPart
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (root.Position - targetRoot.Position).Magnitude
            
            -- Проверяем, видим ли игрока (не за стеной)
            local ray = Ray.new(root.Position, (targetRoot.Position - root.Position).Unit * dist)
            local hit = workspace:FindPartOnRay(ray, character)
            
            if hit and (hit:IsDescendantOf(player.Character) or dist < closestDist) then
                closest = player
                closestDist = dist
            end
        end
    end
    
    return closest
end

-- Функция для наведения на цель
local function AimAtPlayer(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Получаем позицию головы врага
    local head = player.Character:FindFirstChild("Head") or player.Character.HumanoidRootPart
    local targetPos = head.Position
    
    -- Вычисляем угол для наведения
    local camera = workspace.CurrentCamera
    local vector = (targetPos - camera.CFrame.Position).Unit
    local newCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
    
    -- Плавно наводим прицел (чтобы не спалиться)
    camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.3)
end

-- ============================================
-- 5. ПОЛЁТ (FLY)
-- ============================================
local flyVelocity = nil

local function ToggleFly()
    flyEnabled = not flyEnabled
    FlyButton.Text = flyEnabled and "Полет (Выкл)" or "Полет (Вкл)"
    FlyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if flyEnabled then
        -- Убираем гравитацию
        character.Humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = character.HumanoidRootPart
    else
        -- Возвращаем гравитацию
        character.Humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

-- Управление полётом (WASD + пробел)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not flyEnabled or not flyVelocity then return end
    
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    
    local moveVector = Vector3.new(0, 0, 0)
    local speed = 50
    
    -- Клавиши управления
    if input.KeyCode == Enum.KeyCode.W then
        moveVector = moveVector + character.HumanoidRootPart.CFrame.LookVector * speed
    end
    if input.KeyCode == Enum.KeyCode.S then
        moveVector = moveVector - character.HumanoidRootPart.CFrame.LookVector * speed
    end
    if input.KeyCode == Enum.KeyCode.A then
        moveVector = moveVector - character.HumanoidRootPart.CFrame.RightVector * speed
    end
    if input.KeyCode == Enum.KeyCode.D then
        moveVector = moveVector + character.HumanoidRootPart.CFrame.RightVector * speed
    end
    if input.KeyCode == Enum.KeyCode.Space then
        moveVector = moveVector + Vector3.new(0, speed, 0)
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        moveVector = moveVector - Vector3.new(0, speed, 0)
    end
    
    flyVelocity.Velocity = moveVector
end)

-- ============================================
-- 6. СКОРОСТЬ (SPEED HACK)
-- ============================================
local function ToggleSpeed()
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then
        return
    end
    
    if speedMultiplier == 1 then
        speedMultiplier = 2
        SpeedButton.Text = "Скорость x3"
        character.Humanoid.WalkSpeed = 32  -- Стандартная скорость 16
    elseif speedMultiplier == 2 then
        speedMultiplier = 3
        SpeedButton.Text = "Скорость x1"
        character.Humanoid.WalkSpeed = 16
        speedMultiplier = 1
    end
end

-- ============================================
-- 7. ТЕЛЕПОРТ К ИГРОКУ
-- ============================================
local function TeleportToPlayer(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Телепортируемся за спину врага
    local targetRoot = player.Character.HumanoidRootPart
    local behind = targetRoot.Position - targetRoot.CFrame.LookVector * 3
    
    character.HumanoidRootPart.CFrame = CFrame.new(behind)
end

-- Выбор цели для телепорта (по нажатию на имя в чате)
local function SelectTeleportTarget()
    local players = {}
    for i, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(players, i .. ". " .. player.Name)
        end
    end
    
    -- В реальном чите здесь было бы GUI меню выбора
    -- Для примера просто телепортируемся к ближайшему
    TeleportToPlayer(GetClosestPlayer())
end

-- ============================================
-- 8. ПОДКЛЮЧЕНИЕ КНОПОК К ФУНКЦИЯМ
-- ============================================
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "ESP (Выкл)" or "ESP (Вкл)"
    ESPButton.BackgroundColor3 = espEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    UpdateESP()
end)

AimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotButton.Text = aimbotEnabled and "Аимбот (Выкл)" or "Аимбот (Вкл)"
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
end)

FlyButton.MouseButton1Click:Connect(ToggleFly)

SpeedButton.MouseButton1Click:Connect(ToggleSpeed)

TeleportButton.MouseButton1Click:Connect(SelectTeleportTarget)

-- ============================================
-- 9. ОСНОВНОЙ ЦИКЛ (ОБНОВЛЕНИЕ КАЖДЫЙ КАДР)
-- ============================================
game:GetService("RunService").RenderStepped:Connect(function()
    -- Аимбот
    if aimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            AimAtPlayer(target)
        end
    end
    
    -- Обновление ESP (если появились новые игроки)
    if espEnabled then
        UpdateESP()
    end
end)

-- ============================================
-- 10. СКРЫТИЕ МЕНЮ ПО F1
-- ============================================
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Чит загружен! Нажми F1 для скрытия/показа меню.")
