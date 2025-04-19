return function(context)
    local OrionLib = context.OrionLib
    local Window = context.Window

local MurderTab = Window:MakeTab({ 
    Name = "Murder Mystery", 
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

-- Секция "Перегляд через стіни"
local SectionViewThroughWalls = MurderTab:AddSection({ 
    Name = "Перегляд через стіни" 
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local roles
local highlightEnabled = false -- Изначально выключено

-- > Functions < --
function CreateHighlight() -- Создаем Highlight только при включенном состоянии
    if not highlightEnabled then return end
    for i, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and not v.Character:FindFirstChild("Highlight") then
            Instance.new("Highlight", v.Character)
        end
    end
end

function UpdateHighlights() -- Обновляем цвета Highlight
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Highlight") then
            local Highlight = v.Character:FindFirstChild("Highlight")
            if v.Name == Sheriff and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(0, 0, 225) -- Синий для Шерифа
            elseif v.Name == Murder and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(225, 0, 0) -- Красный для Убийцы
            elseif v.Name == Hero and IsAlive(v) and not IsAlive(game.Players[Sheriff]) then
                Highlight.FillColor = Color3.fromRGB(0, 0, 225) -- Желтый для Героя
            else
                Highlight.FillColor = Color3.fromRGB(0, 225, 0) -- Зеленый для остальных
            end
        end
    end
end

function IsAlive(Player) -- Проверка, жив ли игрок
    for i, v in pairs(roles) do
        if Player.Name == i then
            return not v.Killed and not v.Dead
        end
    end
    return false
end

RunService.RenderStepped:Connect(function()
    roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    for i, v in pairs(roles) do
        if v.Role == "Murderer" then
            Murder = i
        elseif v.Role == 'Sheriff' then
            Sheriff = i
        elseif v.Role == 'Hero' then
            Hero = i
        end
    end
    if highlightEnabled then
        CreateHighlight()
        UpdateHighlights()
    end
end)

SectionViewThroughWalls:AddToggle({
    Name = "Виділення гравців",
    Default = false, -- Изначально выключено
    Callback = function(state)
        highlightEnabled = state -- Обновляем состояние Highlight
        if not highlightEnabled then
            -- Отключаем Highlight у всех игроков, если оно выключено
            for _, v in pairs(Players:GetChildren()) do
                if v.Character and v.Character:FindFirstChild("Highlight") then
                    v.Character.Highlight:Destroy() -- Удаляем Highlight
                end
            end
        end
    end
})

local Esp = false
local EspOperator = false

function MakeHighlight()
    for _, v in pairs(game.Players:GetChildren()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = v.Character:FindFirstChild("Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "Highlight"
                highlight.Parent = v.Character
            end

            local color
            if v.Name == Sheriff and IsAlive(v) then
                color = Color3.new(0, 0, 250)
            elseif v.Name == Murder and IsAlive(v) then
                color = Color3.new(8, 0, 0)
            elseif v.Name == Hero and IsAlive(v) and not IsAlive(game.Players[Sheriff]) then
                color = Color3.new(10, 15, 0)
            else
                color = Color3.new(0, 350, 0)
            end

            if highlight.FillColor ~= color then
                highlight.FillColor = color
            end
        end
    end
end

function ClearHighlight()
    for _, v in pairs(game.Players:GetChildren()) do
        if v.Character then
            local highlight = v.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

game:GetService('RunService').RenderStepped:connect(function()
    if Esp == true and EspOperator == false then
        EspOperator = true
        pcall(MakeHighlight)
        wait(3)
        EspOperator = false
    end
end)

SectionViewThroughWalls:AddToggle({
    Name = "Виділення гравців (2)",
    Default = false,
    Callback = function(State)
        Esp = State
        if not Esp then
            ClearHighlight()
        end
    end
})

-- Секция "Телепорт"
local SectionTeleport = MurderTab:AddSection({ 
    Name = "Телепорт" 
})

SectionTeleport:AddButton({
    Name = "Телепорт на карту",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name == "Spawn" or v.Name == "PlayerSpawn") and v.Parent.Parent.Name ~= "Lobby" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end
})     

SectionTeleport:AddButton({
    Name = "Телепорт в лобі",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent.Name == "Spawns" and v.Parent.Parent.Name == "Lobby" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end
})

-- Секция "Функції для пістолета"
local SectionGunFunctions = MurderTab:AddSection({ 
    Name = "Функції для пістолета" 
})

GunDrop = nil
workspace.DescendantAdded:Connect(function(part)
    if part.Name == "GunDrop" then
        GunDrop = part
    end
end)

workspace.DescendantRemoving:Connect(function(part)
    if part.Name == "GunDrop" then
        GunDrop = nil
    end
end)

SectionGunFunctions:AddButton({
    Name = "Отримати пістолет",
    Callback = function()
        if GunDrop then
            local old = game.Players.LocalPlayer.Character:GetChildren()
            local LP
            for i = 1, #old do
                if old[i].Name == "HumanoidRootPart" then
                    LP = old[i].CFrame
                end
            end
            wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = GunDrop.CFrame * CFrame.new(0, 2, 0)
            wait(0.15)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = LP
        else
            local CoreGui = game:GetService("StarterGui")
            CoreGui:SetCore("SendNotification", {
                Title = "Скрипт",
                Text = "Пістолет не знайдено",
                Duration = 2.3,
            })
        end
    end
})

local function AutoGetGunActive()
    local GunFound = false
    getgenv().AutoGetGun = true
    while getgenv().AutoGetGun do
        spawn(function()
            if not GunFound and GunDrop then
                GunFound = true
                local old = game.Players.LocalPlayer.Character:GetChildren()
                local LP
                for i = 1, #old do
                    if old[i].Name == "HumanoidRootPart" then
                        LP = old[i].CFrame
                    end
                end
                wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = GunDrop.CFrame * CFrame.new(0, 2, 0)
                wait(0.15)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = LP
                wait(2)
                if GunDrop then
                    GunFound = false
                end
            end
            if not GunDrop then
                GunFound = false
            end
            if not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or game.Players.LocalPlayer.Character.Humanoid.Health == 0 or game.Players.LocalPlayer.Character.Humanoid.Health <= 1 then
                GunFound = false
            end
        end)
        wait(0.1)
    end
end

SectionGunFunctions:AddToggle({
    Name = "Автоматично отримати пістолет",
    Default = false,
    Callback = function(State)
        if State then
            getgenv().AutoGetGun = true
            AutoGetGunActive()
        else
            getgenv().AutoGetGun = false
        end
    end
})

local LocateGun = false
local LocateGunOperator = false

SectionGunFunctions:AddToggle({
    Name = "Автоматичне виділення пістолета",
    Default = false,
    Callback = function(State)
        LocateGun = State
        if not LocateGun then
            LocateGunOperator = false
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v.Name == "Gun_Locate" then
                    v:Destroy()
                end
            end
        end
    end
})

game:GetService('RunService').Heartbeat:connect(function()
    if LocateGun then
        if GunDrop then
            if not LocateGunOperator then
                LocateGunOperator = true
                if GunDrop and not GunDrop:FindFirstChild("Gun_Locate") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Gun_Locate"
                    highlight.FillColor = Color3.new(1, 1, 0) -- Yellow color
                    highlight.Parent = GunDrop

                    local BillboardGui = Instance.new("BillboardGui")
                    local TextLabel = Instance.new("TextLabel")

                    BillboardGui.Parent = GunDrop
                    BillboardGui.Name = "Gun_Locate"
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.LightInfluence = 1
                    BillboardGui.Size = UDim2.new(0, 100, 0, 50)
                    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)

                    TextLabel.Parent = BillboardGui
                    TextLabel.BackgroundColor3 = Color3.new(1, 1, 0)
                    TextLabel.BackgroundTransparency = 0.5
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.Text = "Пістолет тут!"
                    TextLabel.TextColor3 = Color3.new(1, 0, 0)
                    TextLabel.TextScaled = true
                end
            end
        else
            LocateGunOperator = false
        end
    end
end)

-- Секция "Фічі для шеріфа"
local SectionShootMurd = MurderTab:AddSection({ 
    Name = "Фічі для шеріфа" 
})

local player = game.Players.LocalPlayer
local coreGui = game:GetService("CoreGui")

-- Создание ScreenGui в CoreGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = coreGui
screenGui.Name = "ShootMurderGui"

local button = Instance.new("TextButton")
button.Parent = screenGui
button.Text = "Постріл"
button.Size = UDim2.new(0, 100, 0, 100) -- Изначально размер кнопки 100x100
button.Position = UDim2.new(0.5, 0, 0.48, 0) -- Размещение по центру экрана
button.AnchorPoint = Vector2.new(0.5, 0.5)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Цвет кнопки
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextScaled = true -- Автоматическое масштабирование текста
button.TextSize = 20 -- Базовый размер текста

-- Блокируем удаление кнопки
screenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        screenGui.Parent = coreGui
    end
end)

-- Изначально кнопка скрыта
button.Visible = false

-- Функция для отображения/скрытия кнопки
local function toggleButton(visible)
    button.Visible = visible
    if visible then
        button.Position = UDim2.new(0.5, 0, 0.48, 0) -- Обновляем позицию при отображении
    end
end

-- Реализация перетаскивания кнопки
local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Слайдер для изменения размера кнопки
SectionShootMurd:AddSlider({
    Name = "Радіус кнопки",
    Min = 1,
    Max = 30,
    Default = 10,
    Callback = function(value)
        local newSize = UDim2.new(0, value * 10, 0, value * 10)
        local tween = game:GetService("TweenService"):Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = newSize})
        tween:Play()
    end
})

-- Переключатель для регулировки прозрачности кнопки
SectionShootMurd:AddToggle({
    Name = "Прозорість кнопки",
    Default = true,
    Callback = function(state)
        button.BackgroundTransparency = state and 0 or 1
        button.TextTransparency = state and 0 or 1
    end
})

-- Основной скрипт выстрела
local function shootMurderer()
    local function findMurderer()
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
                return player
            end
        end
        return nil
    end

    local murderer = findMurderer()
    if not murderer or not murderer.Character then
        warn("Мардер не знайдено!")
        return
    end

    local gun = player.Backpack:FindFirstChild("Gun")
    if not gun then
        warn("Пістолет не знайдено в рюкзаку!")
        return
    end

    if gun:FindFirstChild("Reloading") and gun.Reloading.Value == true then
        warn("Пістолет перезаряджається!")
        return
    end

    if not player.Character:FindFirstChild("Gun") then
        player.Character.Humanoid:EquipTool(gun)
    end

    if not player.Character:FindFirstChild("Gun") then
        warn("Пістолет не екіпірований!")
        return
    end

    if gun and gun:FindFirstChild("CanShoot") and not gun.CanShoot.Value then
        warn("Пістолет не готовий до пострілу!")
        return
    end

    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then
        warn("Не знайдено HumanoidRootPart у мардера!")
        return
    end

    -- Получаем текущую позицию мардера и его скорость
    local targetPosition = murdererHRP.Position
    local murdererVelocity = murderer.Character.HumanoidRootPart.AssemblyLinearVelocity

    -- Предсказать положение мардера через небольшое время (например, 0.2 секунд)
    local timePrediction = 0.2
    local predictedPosition = targetPosition + murdererVelocity * timePrediction

    -- Выстрел в предсказанное положение
    local args = {
        [1] = 1,
        [2] = predictedPosition,
        [3] = "AH2"
    }

    local success, err = pcall(function()
        player.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
    end)
end

-- Переменная для проверки подключения обработчика
local isButtonConnected = false

-- Переключатель для включения/выключения кнопки пострела
local isFKeyEnabled = false -- Флаг, который проверяет, включен ли выстрел на F

SectionShootMurd:AddToggle({
    Name = "Вкл/Выкл постріл на F",
    Default = false,
    Callback = function(state)
        isFKeyEnabled = state
    end
})

-- Добавление функционала клавиши "F"
local function onKeyPress(input)
    if isFKeyEnabled and input.KeyCode == Enum.KeyCode.F then
        shootMurderer() -- Выстрел по нажатию клавиши F
    end
end

-- Подключаем обработчик клавиши "F"
game:GetService("UserInputService").InputBegan:Connect(onKeyPress)

-- Добавление переключателя для кнопки
SectionShootMurd:AddToggle({
    Name = "Вкл кнопку постріл в мардера",
    Default = false,
    Callback = function(state)
        if state then
            toggleButton(true)
            button.MouseButton1Click:Connect(shootMurderer)
        else
            toggleButton(false)
        end
    end
})


    
local FlingSection = MurderTab:AddSection({
    Name = "Флінг"
})

-- Створюємо динамічний список гравців
local playerDropdown
local function updatePlayerList()
    local players = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        table.insert(players, player.Name)
    end
    if playerDropdown then
        playerDropdown:Refresh(players, true)
    else
        playerDropdown = FlingSection:AddDropdown({
            Name = "Виберіть гравця",
            Options = players,
            Default = "None",
            Callback = function(selected)
            end
        })
    end
end

-- Оновлюємо список гравців при підключенні/відключенні
updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Додаємо кнопку Start Fling
FlingSection:AddButton({
    Name = "Почати флінг",
    Callback = function()
        local selectedPlayer = playerDropdown and playerDropdown.Value
        if selectedPlayer and selectedPlayer ~= "None" then
            ActiveFling(selectedPlayer)
        else
            print("Будь ласка, виберіть гравця для флінга.")
        end
    end
})

-- Функція ActiveFling
function ActiveFling(TargetName)
    getgenv().activefling = true
    while getgenv().activefling do
        local TargetPlayer = game.Players:FindFirstChild(TargetName)
        if TargetPlayer then
            -- Тут викликається флинговая функція для цільового гравця
            local function SkidFling(TargetPlayer)
                local Players = game:GetService("Players")
                local Player = Players.LocalPlayer
                local Character = Player.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Humanoid and Humanoid.RootPart

                local TCharacter = TargetPlayer.Character
                local THumanoid
                local TRootPart
                local THead
                local Accessory
                local Handle

                if TCharacter:FindFirstChildOfClass("Humanoid") then
                    THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
                end
                if THumanoid and THumanoid.RootPart then
                    TRootPart = THumanoid.RootPart
                end
                if TCharacter:FindFirstChild("Head") then
                    THead = TCharacter.Head
                end
                if TCharacter:FindFirstChildOfClass("Accessory") then
                    Accessory = TCharacter:FindFirstChildOfClass("Accessory")
                end
                if Accessory and Accessory:FindFirstChild("Handle") then
                    Handle = Accessory.Handle
                end

                if Character and Humanoid and RootPart then
                    if RootPart.Velocity.Magnitude < 50 then
                        getgenv().OldPos = RootPart.CFrame
                    end
                    if THead then
                        workspace.CurrentCamera.CameraSubject = THead
                    elseif not THead and Handle then
                        workspace.CurrentCamera.CameraSubject = Handle
                    elseif THumanoid and TRootPart then
                        workspace.CurrentCamera.CameraSubject = THumanoid
                    end
                    if not TCharacter:FindFirstChildWhichIsA("BasePart") then
                        return
                    end

                    local FPos = function(BasePart, Pos, Ang)
                        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    end

                    local SFBasePart = function(BasePart)
                        local TimeToWait = 2
                        local Time = tick()
                        local Angle = 0

                        repeat
                            if RootPart and THumanoid then
                                if BasePart.Velocity.Magnitude < 50 then
                                    Angle = Angle + 100
                                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                                    task.wait()
                                else
                                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                end
                            else
                                break
                            end
        
                        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait or getgenv().flingloop == false
                        getgenv().activefling = false -- Остановка флинга после успешного завершения
                    end

                    workspace.FallenPartsDestroyHeight = 0/0

                    local BV = Instance.new("BodyVelocity")
                    BV.Name = "EpixVel"
                    BV.Parent = RootPart
                    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
                    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                    if TRootPart and THead then
                        if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                            SFBasePart(THead)
                        else
                            SFBasePart(TRootPart)
                        end
                    elseif TRootPart and not THead then
                        SFBasePart(TRootPart)
                    elseif not TRootPart and THead then
                        SFBasePart(THead)
                    elseif not TRootPart and not THead and Accessory and Handle then
                        SFBasePart(Handle)
                    end

                    BV:Destroy()
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                    workspace.CurrentCamera.CameraSubject = Humanoid
                    repeat
                        RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                        Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                        Humanoid:ChangeState("GettingUp")
                        table.foreach(Character:GetChildren(), function(_, x)
                            if x:IsA("BasePart") then
                                x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                            end
                        end)
                        task.wait()
                    until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                    workspace.FallenPartsDestroyHeight = getgenv().FPDH
                end
            end

            SkidFling(TargetPlayer)
        end
        task.wait(0.1)
    end
end

-- Ініціалізація
OrionLib:Init()

-- Секция "Інше"
local SectionOther = MurderTab:AddSection({ 
    Name = "Інше" 
})

local part = Instance.new("Part")
part.Name = "CameraPart"
part.Color = Color3.new(0,0,0)
part.Material = Enum.Material.Plastic
part.Transparency = 1
part.Position = Vector3.new(0,10000,0)
part.Size = Vector3.new(1,0.5,1)
part.CastShadow = true
part.Anchored = true
part.CanCollide = false
part.Parent = workspace

local MURDERER = nil
local AvoidMurder = false
local AvoidOperator = false

local function AvoidReset()
 MURDERER = nil
 if AvoidOperator == true then
   game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
   workspace:FindFirstChild("CameraPart").CFrame = CFrame.new(0,200000,0)
   game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = AvoidPs
   AvoidOperator = false
 end
end

game:GetService('RunService').RenderStepped:connect(function()
if AvoidMurder == true then
   if MURDERER == nil then
      roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
      for i, v in pairs(roles) do
        if v.Role == "Murderer" then
           Murder = i
        end
      end

      for _, v in pairs(game.Players:GetChildren()) do
        if v ~= game.Players.LocalPlayer and v.Character then
           if v.Name == Murder and IsAlive(v) then
              MURDERER = v
           end
        end
      end
   else
      if MURDERER.Name ~= game.Players.LocalPlayer.Name then 
         if MURDERER.Character:FindFirstChild("Knife") or MURDERER.Backpack:FindFirstChild("Knife") then else
            AvoidReset()
         end
         if MURDERER.Character.Humanoid.Health <= 0 then
            AvoidReset()
         end
         wait(0.1)
         if not game.Players:FindFirstChild(MURDERER.Name) then
            AvoidReset()
         end
         if AvoidOperator == false and math.floor((MURDERER.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude) <= 20 or AvoidOperator == false and math.floor((MURDERER.Character.HumanoidRootPart.Position - workspace:FindFirstChild("CameraPart").Position).magnitude) <= 20 then
            AvoidOperator = true
            local old = game.Players.LocalPlayer.Character:getChildren() 
            for i=1,#old do 
              if old[i].Name == "HumanoidRootPart" then 
                 AvoidPs = old[i].CFrame 
              end 
            end
            workspace:FindFirstChild("CameraPart").CFrame = game.Players.LocalPlayer.Character.Head.CFrame
            ---Teleport To Lobby
            for i,v in pairs(workspace:GetDescendants()) do
              if v:IsA("BasePart") and v.Parent.Name == "Spawns" and v.Parent.Parent.Name == "Lobby" then
                 game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0,3,0)
              end
            end
            ---
            game.Workspace.CurrentCamera.CameraSubject = workspace:FindFirstChild("CameraPart")
         end
         if AvoidOperator == true and math.floor((MURDERER.Character.HumanoidRootPart.Position - workspace:FindFirstChild("CameraPart").Position).magnitude) >= 20 then
            AvoidOperator = false
            game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
            workspace:FindFirstChild("CameraPart").CFrame = CFrame.new(0,200000,0)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = AvoidPs
         end
      end
   end
end
end)

SectionOther:AddToggle({
    Name = "Автоматичне уникнення мардера",
    Default = false,
    Callback = function(State)
        AvoidMurder = State
        if not AvoidMurder then
            if AvoidOperator == true and MURDERER.Character:FindFirstChild("HumanoidRootPart") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = AvoidPs
            end
            MURDERER = nil
            AvoidPs = nil
            AvoidMurder = false
            AvoidOperator = false
            workspace:FindFirstChild("CameraPart").CFrame = CFrame.new(0,200000,0)
            game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        end
    end
})

SectionOther:AddButton({
    Name = "Фейкова смерть",
    Callback = function()
        local humanoid = game:GetService("Players").LocalPlayer.Character.Humanoid
        if not humanoid.Sit then
            humanoid.Sit = true
            wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
        end
    end
})
end
