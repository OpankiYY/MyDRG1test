-- ========================================================================================================================================
-- [[ DRAGON SCRIPT GLOBAL MERGED EDITION: V16.2.0 ]]
-- ========================================================================================================================================
-- СОСТАВ СБОРКИ:
-- 1. AOE KILLAURA GOLEMS (350M)
-- 2. KILLAURA VS PIRATES (200M)
-- 3. AUTO STORE FRUITS (WITH INVENTORY MONITORING)
-- 4. AUTO REMOVE PREHISTORIC (500S TIMER)
-- 5. AUTO REMOVE PREHISTORIC (390S RELIC ACTIVATION TIMER)
-- 6. PERMANENT FPS LOCK (10 FPS)
-- 7. NICKNAME MONITOR (POSITION ADJUSTED HIGHER)
-- ========================================================================================================================================

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

-- [[ РАЗДЕЛ 1: ОБЪЯВЛЕНИЕ ВСЕХ СЕРВИСОВ ]]

local PlayersServiceInstance = game:GetService("Players")
local WorkspaceServiceInstance = game:GetService("Workspace")
local ReplicatedStorageServiceInstance = game:GetService("ReplicatedStorage")
local RunServiceInstance = game:GetService("RunService")
local CoreGuiServiceInstance = game:GetService("CoreGui")
local StarterGuiServiceInstance = game:GetService("StarterGui")
local VirtualUserInstance = game:GetService("VirtualUser")
local HttpServiceInstance = game:GetService("HttpService")

-- [[ РАЗДЕЛ 2: ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ И НАСТРОЙКИ ]]

local LocalPlayerInstance = PlayersServiceInstance.LocalPlayer
local PlayerCharacterModel = LocalPlayerInstance.Character or LocalPlayerInstance.CharacterAdded:Wait()
local PlayerHumanoidRootPart = PlayerCharacterModel:WaitForChild("HumanoidRootPart")

-- Параметры Kill-Aura
local AOE_KILL_AURA_RADIUS = 350
local PIRATE_KILL_AURA_RADIUS = 200
local ATTACK_EXECUTION_INTERVAL = 0.025
local TARGET_GOLEM_NAMES_LIST = {"Golem", "Lava Golem", "Ice Golem", "Stone Golem"}

-- Параметры островов
local ISLAND_MAX_STAY_SECONDS = 390
local GlobalIslandMonitoringData = {
    CurrentIslandInstance = nil,
    IsTimerRunningStatus = false,
    ActivationTickTimestamp = 0
}

-- [[ РАЗДЕЛ 3: МОДУЛЬ NICKNAME MONITOR (ИЗМЕНЕНО ПОЛОЖЕНИЕ) ]]

local function InitializeNicknameMonitor()
    local ExistingMonitor = CoreGuiServiceInstance:FindFirstChild("DragonNicknameGui")
    if ExistingMonitor then ExistingMonitor:Destroy() end

    local NicknameScreenGui = Instance.new("ScreenGui")
    NicknameScreenGui.Name = "DragonNicknameGui"
    NicknameScreenGui.Parent = CoreGuiServiceInstance
    NicknameScreenGui.ResetOnSpawn = false

    local NicknameLabel = Instance.new("TextLabel")
    NicknameLabel.Size = UDim2.new(0, 300, 0, 50)
    -- ПОЗИЦИЯ ИЗМЕНЕНА: Поднято выше (0.2 вместо 0.5 по вертикали)
    NicknameLabel.Position = UDim2.new(0.5, -150, 0.2, -25)
    NicknameLabel.BackgroundTransparency = 1
    NicknameLabel.Text = "PLAYER: " .. LocalPlayerInstance.Name
    NicknameLabel.TextColor3 = Color3.fromRGB(255, 140, 0) -- Оранжевый стиль Dragon
    NicknameLabel.TextSize = 28
    NicknameLabel.Font = Enum.Font.GothamBold
    NicknameLabel.Parent = NicknameScreenGui
end

-- [[ РАЗДЕЛ 4: МОДУЛЬ FPS LOCK (ПЕРМАНЕНТНЫЙ) ]]

task.spawn(function()
    if setfpscap then
        while true do
            pcall(function()
                setfpscap(10)
            end)
            task.wait(5)
        end
    end
end)

-- [[ РАЗДЕЛ 5: МОДУЛЬ AUTO-STORE FRUITS ]]

local CommunicationRemoteFunction = ReplicatedStorageServiceInstance:WaitForChild("Remotes"):WaitForChild("CommF_")

local function ExecuteFruitStorageLogic(ItemInstance)
    if ItemInstance:IsA("Tool") and string.find(ItemInstance.Name, "Fruit") then
        local FruitNameClean = string.gsub(ItemInstance.Name, " Fruit", "")
        pcall(function()
            CommunicationRemoteFunction:InvokeServer("StoreFruit", FruitNameClean .. "-" .. FruitNameClean, ItemInstance)
        end)
    end
end

local function SetupInventoryMonitoring(CharacterModel)
    local Backpack = LocalPlayerInstance:WaitForChild("Backpack")
    
    Backpack.ChildAdded:Connect(ExecuteFruitStorageLogic)
    CharacterModel.ChildAdded:Connect(ExecuteFruitStorageLogic)
    
    for _, Item in ipairs(Backpack:GetChildren()) do ExecuteFruitStorageLogic(Item) end
    for _, Item in ipairs(CharacterModel:GetChildren()) do ExecuteFruitStorageLogic(Item) end
end

-- [[ РАЗДЕЛ 6: МОДУЛЬ УДАЛЕНИЯ ОСТРОВОВ (ОБА ТАЙМЕРА) ]]

local function ProcessPrehistoricIsland(IslandObject)
    if IslandObject.Name == "PrehistoricIsland" then
        -- Сценарий 1: Удаление через 500 секунд после появления
        task.delay(500, function()
            if IslandObject.Parent then
                IslandObject:Destroy()
            end
        end)
    end
end

WorkspaceServiceInstance:WaitForChild("Map").ChildAdded:Connect(ProcessPrehistoricIsland)
for _, Obj in ipairs(WorkspaceServiceInstance.Map:GetChildren()) do ProcessPrehistoricIsland(Obj) end

-- Цикл мониторинга реликвии (390 секунд)
task.spawn(function()
    while true do
        task.wait(1)
        local MapFolder = WorkspaceServiceInstance:FindFirstChild("Map")
        if MapFolder then
            local Island = MapFolder:FindFirstChild("PrehistoricIsland")
            if Island then
                -- Поиск промпта реликвии
                local RelicFound = false
                for _, Descendant in ipairs(Island:GetDescendants()) do
                    if Descendant.Name == "Relic" and Descendant:FindFirstChildOfClass("ProximityPrompt") then
                        RelicFound = true
                        break
                    end
                end

                if not RelicFound and not GlobalIslandMonitoringData.IsTimerRunningStatus then
                    GlobalIslandMonitoringData.IsTimerRunningStatus = true
                    GlobalIslandMonitoringData.ActivationTickTimestamp = tick()
                end

                if GlobalIslandMonitoringData.IsTimerRunningStatus then
                    if tick() - GlobalIslandMonitoringData.ActivationTickTimestamp >= ISLAND_MAX_STAY_SECONDS then
                        Island:Destroy()
                        GlobalIslandMonitoringData.IsTimerRunningStatus = false
                    end
                end
            else
                GlobalIslandMonitoringData.IsTimerRunningStatus = false
            end
        end
    end
end)

-- [[ РАЗДЕЛ 7: МОДУЛЬ ОБЪЕДИНЕННОЙ KILL-AURA ]]

local NetworkFolder = ReplicatedStorageServiceInstance:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttackRemote = NetworkFolder:WaitForChild("RE/RegisterAttack")
local RegisterHitRemote = NetworkFolder:WaitForChild("RE/RegisterHit")

local function GetEquippedMeleeWeapon()
    local Character = LocalPlayerInstance.Character
    if Character then
        local Tool = Character:FindFirstChildOfClass("Tool")
        if Tool and (Tool:FindFirstChild("Handle") or Tool:FindFirstChild("Animation")) then
            return Tool
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(ATTACK_EXECUTION_INTERVAL)
        local Character = LocalPlayerInstance.Character
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then continue end
        
        local CurrentRootPos = Character.HumanoidRootPart.Position
        local HasAttackedThisTick = false

        -- 1. АТАКА ГОЛЕМОВ
        local EnemiesFolder = WorkspaceServiceInstance:FindFirstChild("Enemies")
        if EnemiesFolder then
            for _, Enemy in ipairs(EnemiesFolder:GetChildren()) do
                if Enemy:FindFirstChild("Humanoid") and Enemy.Humanoid.Health > 0 and Enemy:FindFirstChild("HumanoidRootPart") then
                    local IsGolem = false
                    for _, NameTag in ipairs(TARGET_GOLEM_NAMES_LIST) do
                        if string.find(Enemy.Name, NameTag) then IsGolem = true break end
                    end

                    if IsGolem and (CurrentRootPos - Enemy.HumanoidRootPart.Position).Magnitude <= AOE_KILL_AURA_RADIUS then
                        if not HasAttackedThisTick then
                            RegisterAttackRemote:FireServer(ATTACK_EXECUTION_INTERVAL)
                            HasAttackedThisTick = true
                        end
                        RegisterHitRemote:FireServer(Enemy.HumanoidRootPart, {})
                    end
                end
            end
        end

        -- 2. АТАКА ПИРАТОВ
        for _, TargetPlayer in ipairs(PlayersServiceInstance:GetPlayers()) do
            if TargetPlayer ~= LocalPlayerInstance and TargetPlayer.Team and TargetPlayer.Team.Name == "Pirates" then
                local TargetChar = TargetPlayer.Character
                if TargetChar and TargetChar:FindFirstChild("Humanoid") and TargetChar.Humanoid.Health > 0 and TargetChar:FindFirstChild("HumanoidRootPart") then
                    if (CurrentRootPos - TargetChar.HumanoidRootPart.Position).Magnitude <= PIRATE_KILL_AURA_RADIUS then
                        if not HasAttackedThisTick then
                            RegisterAttackRemote:FireServer(ATTACK_EXECUTION_INTERVAL)
                            HasAttackedThisTick = true
                        end
                        RegisterHitRemote:FireServer(TargetChar.HumanoidRootPart, {})
                    end
                end
            end
        end
    end
end)

-- [[ РАЗДЕЛ 8: ИНИЦИАЛИЗАЦИЯ И ПЕРЕЗАПУСК ПРИ СМЕРТИ ]]

LocalPlayerInstance.CharacterAdded:Connect(function(NewCharacter)
    PlayerCharacterModel = NewCharacter
    PlayerHumanoidRootPart = NewCharacter:WaitForChild("HumanoidRootPart")
    SetupInventoryMonitoring(NewCharacter)
end)

-- Первичный запуск
InitializeNicknameMonitor()
SetupInventoryMonitoring(PlayerCharacterModel)

-- Анти-АФК система
LocalPlayerInstance.Idled:Connect(function()
    VirtualUserInstance:CaptureController()
    VirtualUserInstance:ClickButton2(Vector2.new(0, 0))
end)

print("[DRAGON-SYSTEM] ВСЕ 7 МОДУЛЕЙ УСПЕШНО ОБЪЕДИНЕНЫ И ОПТИМИЗИРОВАНЫ.")
StarterGuiServiceInstance:SetCore("SendNotification", {
    Title = "DRAGON MERGED",
    Text = "V16.2.0 LOADED SUCCESSFULLY",
    Duration = 10
})

-- ========================================================================================================================================
-- [[ КОНЕЦ ОБЪЕДИНЕННОГО СКРИПТА ]]
-- ========================================================================================================================================
