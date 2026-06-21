-- ============================================
-- ЛЁГКАЯ ВЕРСИЯ (БЕЗ КРАШЕЙ)
-- ============================================

local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ПЕРЕМЕННЫЕ
local espEnabled = false
local aimbotEnabled = false
local flyEnabled = false
local speedMultiplier = 1
local aimbotRadius = 200
local selectedTarget = nil
local espObjects = {}
local isMenuOpen = true

-- ============================================
-- 1. СОЗДАНИЕ GUI (МИНИМАЛЬНОЕ)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 180, 0, 320)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true

-- ЗАГОЛОВОК
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Чит (F1)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

-- ФУНКЦИЯ КНОПОК
local function Btn(parent, text, y, color)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0.85, 0, 0, 24)
    b.Position = UDim2.new(0.075, 0, 0, y)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 65)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    return b
end

local ESPBtn = Btn(MainFrame, "ESP [Выкл]", 30, Color3.fromRGB(50, 50, 65))
local AimBtn = Btn(MainFrame, "Аимбот [Выкл]", 58, Color3.fromRGB(50, 50, 65))
local FlyBtn = Btn(MainFrame, "Полет [Выкл]", 86, Color3.fromRGB(50, 50, 65))
local SpeedBtn = Btn(MainFrame, "Скорость x1", 114, Color3.fromRGB(50, 50, 65))
local TpBtn = Btn(MainFrame, "Телепорт", 142, Color3.fromRGB(50, 50, 65))

-- СПИСОК ИГРОКОВ
local PlayerFrame = Instance.new("ScrollingFrame")
PlayerFrame.Parent = MainFrame
PlayerFrame.Size = UDim2.new(0.85, 0, 0, 80)
PlayerFrame.Position = UDim2.new(0.075, 0, 0, 175)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
PlayerFrame.BorderSizePixel = 0

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Parent = PlayerFrame
PlayerLayout.SortOrder = Enum.SortOrder.Name

-- ============================================
-- 2. ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ
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
-- 3. ESP (УПРОЩЁННЫЙ)
-- ============================================
local function UpdateESP()
    -- Удаляем старые объекты
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Просто создаём рамку (без сложных проверок)
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3, 5, 1.5)
                box.Adornee = root
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.Transparency = 0.3
                box.ZIndex = 10
                box.Parent = root
                table.insert(espObjects, box)
            end
        end
    end
end

-- ============================================
-- 4. АИМБОТ (УПРОЩЁННЫЙ)
-- ============================================
local function GetClosestPlayer()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < aimbotRadius and dist < closestDist then
                        closest = player
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    return closest
end

-- ============================================
-- 5. ПОЛЁТ (ПРОСТОЙ)
-- ============================================
local flyVelocity = nil

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
    else
        char.Humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

-- ============================================
-- 6. УПРАВЛЕНИЕ ПОЛЁТОМ
-- ============================================
UserInput.InputBegan:Connect(function(input)
    if not flyEnabled or not flyVelocity then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local speed = 50
    local move = Vector3.new(0, 0, 0)
    local root = char.HumanoidRootPart
    
    if input.KeyCode == Enum.KeyCode.W then
        move = move + root.CFrame.LookVector * speed
    end
    if input.KeyCode == Enum.KeyCode.S then
        move = move - root.CFrame.LookVector * speed
    end
    if input.KeyCode == Enum.KeyCode.A then
        move = move - root.CFrame.RightVector * speed
    end
    if input.KeyCode == Enum.KeyCode.D then
        move = move + root.CFrame.RightVector * speed
    end
    if input.KeyCode == Enum.KeyCode.Space then
        move = move + Vector3.new(0, speed, 0)
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        move = move - Vector3.new(0, speed, 0)
    end
    
    flyVelocity.Velocity = move
end)

-- ============================================
-- 7. ОСТАЛЬНЫЕ ФУНКЦИИ
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

local function DoTeleport()
    local target = selectedTarget or GetClosestPlayer()
    if target and target.Character then
        local char = LocalPlayer.Character
        if char and char.HumanoidRootPart then
            local root = target.Character.HumanoidRootPart
            if root then
                char.HumanoidRootPart.CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 3)
            end
        end
    end
end

-- ============================================
-- 8. ПОДКЛЮЧЕНИЕ КНОПОК
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
end)

FlyBtn.MouseButton1Click:Connect(ToggleFly)
SpeedBtn.MouseButton1Click:Connect(ToggleSpeed)
TpBtn.MouseButton1Click:Connect(DoTeleport)

-- ============================================
-- 9. КЛАВИШИ
-- ============================================
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- 10. ОСНОВНЫЕ ЦИКЛЫ (ОПТИМИЗИРОВАННЫЕ)
-- ============================================

-- Аимбот (только когда включён)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if head then
                local newCF = CFrame.lookAt(Camera.CFrame.Position, head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(newCF, 0.3)
            end
        end
    end
end)

-- ============================================
-- 11. ВОССТАНОВЛЕНИЕ ПОСЛЕ СМЕРТИ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    local char = LocalPlayer.Character
    if char then
        if speedMultiplier > 1 then
            char.Humanoid.WalkSpeed = 16 * speedMultiplier
        end
        if espEnabled then
            UpdateESP()
        end
    end
end)

print("✅ Чит загружен! F1 - меню")
