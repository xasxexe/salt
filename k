-- ============================================
-- МИНИМАЛЬНЫЙ РАБОЧИЙ АИМБОТ (НА ОСНОВЕ PROJECT BULLSHIT)
-- ============================================

local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local aimbotEnabled = false
local aimbotKey = Enum.UserInputType.MouseButton2  -- Правая кнопка мыши
local isAiming = false

-- Проверка видимости (Raycast)
local function IsVisible(target)
    local origin = Camera.CFrame.Position
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

-- Поиск ближайшего видимого врага
local function GetClosestVisiblePlayer()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local closest = nil
    local closestDist = 300  -- Радиус в пикселях
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Проверяем видимость
                if not IsVisible(root) then
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

-- Наведение
local function AimAtPlayer(player)
    if not player or not player.Character then return end
    local target = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
    if not target then return end
    
    local newCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, 0.35)
end

-- Клавиши для включения аимбота
UserInput.InputBegan:Connect(function(input)
    if input.UserInputType == aimbotKey then
        isAiming = true
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == aimbotKey then
        isAiming = false
    end
end)

-- GUI для включения/выключения
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 150, 0, 40)
Frame.Position = UDim2.new(0.5, -75, 0.9, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Frame.BackgroundTransparency = 0.1

local Btn = Instance.new("TextButton")
Btn.Parent = Frame
Btn.Size = UDim2.new(1, 0, 1, 0)
Btn.Text = "Аимбот [Выкл]"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Btn.BorderSizePixel = 0

Btn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    Btn.Text = aimbotEnabled and "Аимбот [Вкл]" or "Аимбот [Выкл]"
    Btn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 70)
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    if aimbotEnabled and isAiming then
        local target = GetClosestVisiblePlayer()
        if target then
            AimAtPlayer(target)
        end
    end
end)

print("✅ Аимбот загружен!")
print("🎯 Зажми правую кнопку мыши для наведения")
