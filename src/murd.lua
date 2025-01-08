-- Load the Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/KlorPe000/KlorPeLib/main/source'))()

-- Create the main window if it hasn't been created yet
local Window = OrionLib:MakeWindow({
    Name = "KlorPeHub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "KlorPeTest"
})

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
    Name = "Отримати Gun Drop",
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
                Title = "Скріпт",
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
    Name = "Автоматично отримати Gun Drop",
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
                    TextLabel.Text = "GUN LOCATE!"
                    TextLabel.TextColor3 = Color3.new(1, 0, 0)
                    TextLabel.TextScaled = true
                end
            end
        else
            LocateGunOperator = false
        end
    end
end)

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
