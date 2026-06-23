-- ============================================
-- ВЕРСИЯ С ПЛАВАЮЩЕЙ ИКОНКОЙ ПОВЕРХ ВСЕГО
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
local espObjects = {}
local menuVisible = true
local isDragging = false
local dragStart = nil
local dragStartPos = nil

-- ============================================
-- 1. ГЛАВНЫЙ GUI (ЭКРАН)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  -- Чтобы быть поверх всего

-- ============================================
-- 2. ПЛАВАЮЩАЯ ИКОНКА (ПОВЕРХ ВСЕГО)
-- ============================================
local IconButton = Instance.new("ImageButton")
IconButton.Parent = ScreenGui
IconButton.Size = UDim2.new(0, 50, 0, 50)
IconButton.Position = UDim2.new(0.02, 0, 0.02, 0)  -- Левый верхний угол
IconButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
IconButton.BackgroundTransparency = 0.15
IconButton.BorderSizePixel = 0
IconButton.Image = "rbxassetid://7074833319"  -- Круглая текстура
IconButton.ImageColor3 = Color3.fromRGB(100, 150, 255)
IconButton.ImageTransparency = 0.3
IconButton.ZIndex = 9999  -- Максимальный приоритет

-- Текст на иконке
local IconText = Instance.new("TextLabel")
IconText.Parent = IconButton
IconText.Size = UDim2.new(1, 0, 1, 0)
IconText.Text = "⚡"
IconText.TextColor3 = Color3.fromRGB(255, 255, 255)
IconText.BackgroundTransparency = 1
IconText.TextScaled = true
IconText.Font = Enum.Font.GothamBold
IconText.ZIndex = 9999

-- Подсказка при наведении (Tooltip)
local Tooltip = Instance.new("TextLabel")
Tooltip.Parent = IconButton
Tooltip.Size = UDim2.new(0, 120, 0, 25)
Tooltip.Position = UDim2.new(0.5, -60, 1, 5)
Tooltip.Text = "Чит меню (клик)"
Tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
Tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Tooltip.BackgroundTransparency = 0.3
Tooltip.TextScaled = true
Tooltip.Font = Enum.Font.GothamMedium
Tooltip.Visible = false
Tooltip.ZIndex = 9999

-- Показать подсказку при наведении
IconButton.MouseEnter:Connect(function()
    Tooltip.Visible = true
end)
IconButton.MouseLeave:Connect(function()
    Tooltip.Visible = false
end)

-- ============================================
-- 3. ПЕРЕТАСКИВАНИЕ ИКОНКИ (ЧЕРЕЗ МЫШЬ)
-- ============================================
IconButton.MouseButton1Down:Connect(function()
    isDragging = true
    dragStart = UserInput.GetMouseLocation()
    dragStartPos = IconButton.Position
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Перетаскивание через RenderStepped (плавное)
RunService.RenderStepped:Connect(function()
    if isDragging then
        local mousePos = UserInput.GetMouseLocation()
        local delta = mousePos - dragStart
        
        -- Конвертируем пиксели в UDim2
        local newX = dragStartPos.X.Scale + (delta.X / Camera.ViewportSize.X)
        local newY = dragStartPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y)
        
        -- Ограничиваем, чтобы иконка не уходила за экран
        newX = math.clamp(newX, 0, 0.95)
        newY = math.clamp(newY, 0, 0.95)
        
        IconButton.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

-- ============================================
-- 4. ОСНОВНОЕ МЕНЮ
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 180, 0, 220)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.ZIndex = 100

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Text = "🔧 Чит (F1)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.ZIndex = 100

-- Функция кнопок
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
    b.ZIndex = 100
    return b
end

local ESPBtn = Btn(MainFrame, "ESP [Выкл]", 33)
local AimBtn = Btn(MainFrame, "Аимбот [Выкл]", 63)
local FlyBtn = Btn(MainFrame, "Полет [Выкл]", 93)
local SpeedBtn = Btn(MainFrame, "Скорость x1", 123)
local TpBtn = Btn(MainFrame, "Телепорт [F2]", 153)

-- ============================================
-- 5. КРУГ АИМБОТА
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
AimbotCircle.ZIndex = 50

-- ============================================
-- 6. ФУНКЦИЯ ВИДИМОСТИ (Raycast)
-- ============================================
local function IsVisible(origin, target)
    local direction = (target - origin).Unit
    local distance = (origin - target).Magnitude
    local ray = Ray.new(origin, direction * distance)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    
    if hit then
        if hit:IsDescendantOf(target.Parent) then
            return true
        end
        return false
    end
    return true
end

-- ============================================
-- 7. ESP
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
                local visible = IsVisible(Camera.CFrame.Position, root.Position)
                local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                local transp = visible and 0.3 or 0.5
                
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3.5, 5.5, 2)
                box.Adornee = root
                box.Color3 = color
                box.Transparency = transp
                box.ZIndex = 10
                box.AlwaysOnTop = true
                box.Parent = root
                table.insert(espObjects, box)
                
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = root
                billboard.Size = UDim2.new(0, 120, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.Parent = root
                billboard.AlwaysOnTop = true
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = billboard
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.TextStrokeTransparency = 0.2
                table.insert(espObjects, billboard)
            end
        end
    end
end

-- Обновление цветов в реальном времени
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local visible = IsVisible(Camera.CFrame.Position, root.Position)
                local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                local transp = visible and 0.3 or 0.5
                
                for _, obj in pairs(root:GetChildren()) do
                    if obj:IsA("BoxHandleAdornment") then
                        obj.Color3 = color
                        obj.Transparency = transp
                    end
                    if obj:IsA("BillboardGui") then
                        for _, child in pairs(obj:GetChildren()) do
                            if child:IsA("TextLabel") then
                                child.TextColor3 = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 8. АИМБОТ
-- ============================================
local function GetClosestVisiblePlayer()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local closest = nil
    local closestDist = aimbotRadius
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if not IsVisible(Camera.CFrame.Position, root.Position) then
                    continue
                end
                
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
-- 9. ПОЛЁТ
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
-- 10. СКОРОСТЬ
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
-- 11. ТЕЛЕПОРТ (F2)
-- ============================================
local function DoTeleport()
    local char = LocalPlayer.Character
    if not char then return end
    
    local closest = nil
    local closestDist = math.huge
    
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
    
    if closest and closest.Character then
        local root = closest.Character:FindFirstChild("HumanoidRootPart")
        if root then
            char.HumanoidRootPart.CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 3)
        end
    end
end

-- ============================================
-- 12. ПОДКЛЮЧЕНИЕ КНОПОК
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
-- 13. УПРАВЛЕНИЕ ИКОНКОЙ И МЕНЮ
-- ============================================

-- Открытие/закрытие меню через иконку
IconButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
end)

-- Закрытие меню через F1
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end
    if input.KeyCode == Enum.KeyCode.F2 then
        DoTeleport()
    end
end)

-- ============================================
-- 14. ОСНОВНОЙ ЦИКЛ (АИМБОТ)
-- ============================================
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetClosestVisiblePlayer()
        if target then
            AimAtPlayer(target)
        end
    end
end)

-- ============================================
-- 15. ВОССТАНОВЛЕНИЕ ПОСЛЕ СМЕРТИ
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

print("✅ Чит загружен!")
print("⚡ Иконка в левом верхнем углу - клик для меню")
print("🔄 Иконку можно перетаскивать")
print("F1 - меню | F2 - телепорт")
print("🟢 ESP: Зелёный = видим, Красный = за стеной")
