repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

print("Drakonchiki build 1 v6 loaded - Golem Optimization & Config")

wait(3)

local args = {
    [1] = "SetTeam",
    [2] = "Marines"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

wait(4)

-- ========================================================================================================================================
-- [[ DRAGON SCRIPT EDITION: V15.9.1 - SPHERICAL ORBIT & RESTRICTED LOOKAT SYSTEM ]]
-- ========================================================================================================================================
-- АВТОР: АДАПТИВНАЯ ВЕРСИЯ ДЛЯ SELIWARE
-- СТАНДАРТЫ НАПИСАНИЯ КОДА:
-- 1. ПОЛНОЕ ОТСУТСТВИЕ СОКРАЩЕНИЙ В ИМЕНАХ ПЕРЕМЕННЫХ, ФУНКЦИЙ И ОБЪЕКТОВ.
-- 2. ИСКЛЮЧЕНИЕ ЛЮБОЙ АМАТОРСКОЙ ДЕЯТЕЛЬНОСТИ И СЖАТИЯ КОДА.
-- 3. ПРЕДОСТАВЛЕНИЕ ПОЛНОГО ИСХОДНОГО ТЕКСТА В ОДНОМ БЛОКЕ ИСПОЛНЕНИЯ.
-- 4. СТРОГОЕ СОБЛЮДЕНИЕ ЛОГИКИ ЛУТА ВЕРСИИ V8.2.
-- 5. ИСПОЛЬЗОВАНИЕ ПОЛНЫХ ПУТЕЙ И ЯВНОГО ОПРЕДЕЛЕНИЯ ВСЕХ СВОЙСТВ.
-- 6. ОБЪЕМ КОДА ОПТИМИЗИРОВАН ДЛЯ МАКСИМАЛЬНОЙ ПОДРОБНОСТИ (1000+ СТРОК).
-- ========================================================================================================================================

-- [[ СЕКЦИЯ 0: ГЛОБАЛЬНАЯ ПРОВЕРКА ЗАГРУЗКИ ИГРОВОГО ОКРУЖЕНИЯ ]]

if not game:IsLoaded() then
    local GameLoadedSignalWaitInstance = game.Loaded
    GameLoadedSignalWaitInstance:Wait()
end

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 1: ИНИЦИАЛИЗАЦИЯ ВСЕХ НЕОБХОДИМЫХ СЕРВИСОВ ROBLOX (БЕЗ СОКРАЩЕНИЙ) ]]
-- ========================================================================================================================================

local PlayersServiceInstance = game:GetService("Players")
local RunServiceInstance = game:GetService("RunService")
local ReplicatedStorageServiceInstance = game:GetService("ReplicatedStorage")
local WorkspaceServiceInstance = game:GetService("Workspace")
local TweenServiceInstance = game:GetService("TweenService")
local HttpServiceInstance = game:GetService("HttpService")
local UserInputServiceInstance = game:GetService("UserInputService")
local CoreGuiServiceInstance = game:GetService("CoreGui")
local VirtualInputManagerServiceInstance = game:GetService("VirtualInputManager")
local LightingServiceInstance = game:GetService("Lighting")
local DebrisServiceInstance = game:GetService("Debris")
local StarterGuiServiceInstance = game:GetService("StarterGui")
local StatsServiceInstance = game:GetService("Stats")
local TeleportServiceInstance = game:GetService("TeleportService")
local VirtualUserServiceInstance = game:GetService("VirtualUser")
local CollectionServiceInstance = game:GetService("CollectionService")
local ProximityPromptServiceInstance = game:GetService("ProximityPromptService")

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 2: ОБЪЕКТЫ ЛОКАЛЬНОГО ИГРОКА И ОБРАБОТКА СОСТОЯНИЙ ПЕРСОНАЖА ]]
-- ========================================================================================================================================

local LocalPlayerInstanceObject = PlayersServiceInstance.LocalPlayer
local PlayerCharacterModelObject = LocalPlayerInstanceObject.Character or LocalPlayerInstanceObject.CharacterAdded:Wait()
local PlayerHumanoidObject = PlayerCharacterModelObject:WaitForChild("Humanoid")
local PlayerHumanoidRootPartObject = PlayerCharacterModelObject:WaitForChild("HumanoidRootPart")
local CurrentGameCameraObject = WorkspaceServiceInstance.CurrentCamera

-- ФУНКЦИЯ ДЛЯ ОБНОВЛЕНИЯ ССЫЛОК ПРИ ПЕРЕРОЖДЕНИИ ПЕРСОНАЖА (RESPAWN HANDLER)
local function HandleLocalPlayerCharacterAddedEvent(NewCharacterModelObject)
    PlayerCharacterModelObject = NewCharacterModelObject
    PlayerHumanoidObject = NewCharacterModelObject:WaitForChild("Humanoid")
    PlayerHumanoidRootPartObject = NewCharacterModelObject:WaitForChild("HumanoidRootPart")
    CurrentGameCameraObject = WorkspaceServiceInstance.CurrentCamera
end

LocalPlayerInstanceObject.CharacterAdded:Connect(HandleLocalPlayerCharacterAddedEvent)

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 3: ОПРЕДЕЛЕНИЕ ССЫЛОК НА ОБЪЕКТЫ ИГРОВОГО МИРА И УДАЛЕННЫЕ СОБЫТИЯ ]]
-- ========================================================================================================================================

local BoatsFolderInWorkspaceObject = WorkspaceServiceInstance:WaitForChild("Boats")
local EnemiesFolderInWorkspaceObject = WorkspaceServiceInstance:WaitForChild("Enemies")
local MapFolderInWorkspaceObject = WorkspaceServiceInstance:WaitForChild("Map")

local RemoteEventsFolderInReplicatedStorage = ReplicatedStorageServiceInstance:WaitForChild("Remotes")
local CommunicationRemoteFunctionObject = RemoteEventsFolderInReplicatedStorage:WaitForChild("CommF_")

local NetworkModulesFolderInReplicatedStorage = ReplicatedStorageServiceInstance:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttackRemoteEventObject = NetworkModulesFolderInReplicatedStorage:WaitForChild("RE/RegisterAttack")
local RegisterHitRemoteEventObject = NetworkModulesFolderInReplicatedStorage:WaitForChild("RE/RegisterHit")

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 4: СИСТЕМА ПРЕДОТВРАЩЕНИЯ АВТОМАТИЧЕСКОГО КИКНУТИЯ (ANTI-AFK SYSTEM) ]]
-- ========================================================================================================================================

task.spawn(function()
    while task.wait(60) do
        pcall(function()
            VirtualUserServiceInstance:CaptureController()
            VirtualUserServiceInstance:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 5: ГЛОБАЛЬНЫЕ КОНФИГУРАЦИОННЫЕ ПАРАМЕТРЫ И КОНСТАНТЫ ]]
-- ========================================================================================================================================

local PIER_COORDINATES_FOR_BOAT_PURCHASE = Vector3.new(-16220, 25, 440)
local GLOBAL_BOAT_MOVEMENT_SPEED_VALUE = 475
local GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE = 300
local BOAT_DETECTION_MAXIMUM_RANGE = 800
local KILL_AURA_EFFECTIVE_RADIUS_DISTANCE = 300
local SKILL_USAGE_MAXIMUM_RADIUS_DISTANCE = 65
local MAXIMUM_ISLAND_STAY_DURATION_SECONDS = 390
local FIXED_FLIGHT_HEIGHT_LEVEL = 8
local MINIMUM_SAFETY_HEIGHT_THRESHOLD = 5
local ROCK_SAFE_FARMING_DISTANCE = 25 -- НОВЫЙ ПАРАМЕТР ДЛЯ СФЕРИЧЕСКОГО РАДИУСА БЕЗОПАСНОСТИ
local GOLEM_ATTACK_SPEED_INTERVAL = 0.025

local BOAT_LOST_MAXIMUM_DISTANCE_THRESHOLD = 1000
local BOAT_LOST_SCANNING_GRACE_PERIOD_SECONDS = 5

local ScriptGlobalConfiguration = {
    FullAutoEnabledStatus = true,
    CurrentBoatTypeSelection = "PirateBrigade",
    AutoHakiEnabledStatus = true,
    
    RelicManualActivationDelaySeconds = 90, 
    GolemHeightOffsetValue = 5,             
    GolemRelicShiftValue = 25               
}

local GlobalRuntimeStateParameters = {
    CurrentActiveTargetData = nil,
    PriorityTargetQueueTable = {},
    RelicActivationPositionVector = nil,
    
    CachedGolemTargetPositionVector = nil,
    LastGolemPositionUpdateTimestamp = 0,
    
    IsFarmingPermissionGrantedStatus = true, 
    RelicActivationEndTimeTick = 0,
    RelicWaitStartTimeTick = 0, 
    DangerLavaDeletionStatus = false,
    DragonEggPhaseStartedStatus = false,
    DragonEggPhaseStartTimeTick = 0,
    
    IslandPresenceStatusInLastFrame = false,
    
    SpawnPointSetInitialStatus = false,
    LastBoatPurchaseTimestamp = 0,
    
    ResetGraceTimerAccumulator = 0,
    ResetGraceThresholdMaximum = BOAT_LOST_SCANNING_GRACE_PERIOD_SECONDS,
    
    LastSkillXExecutionTimestamp = 0,
    LastSkillCExecutionTimestamp = 0,
    NextSkillSequenceToExecute = "C",
    DynamicSkillActivationCooldown = math.random(1, 3)
}

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 6: ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ БОЕВОЙ СИСТЕМЫ И ПЕРЕМЕЩЕНИЯ ]]
-- ========================================================================================================================================

local function ExecuteMeleeWeaponEquipmentSequence()
    if not PlayerCharacterModelObject then return end
    local CurrentHumanoidObject = PlayerCharacterModelObject:FindFirstChildOfClass("Humanoid")
    if not CurrentHumanoidObject or CurrentHumanoidObject.Health <= 0 then return end
    
    local CurrentEquippedToolObject = PlayerCharacterModelObject:FindFirstChildOfClass("Tool")
    if CurrentEquippedToolObject then
        if CurrentEquippedToolObject.ToolTip == "Melee" or CurrentEquippedToolObject:FindFirstChild("Combat") then
            return
        end
    end
    
    local PlayerBackpackFolderObject = LocalPlayerInstanceObject.Backpack
    local BackpackContentItemsList = PlayerBackpackFolderObject:GetChildren()
    
    for ItemIndex = 1, #BackpackContentItemsList do
        local ToolItemInstance = BackpackContentItemsList[ItemIndex]
        if ToolItemInstance:IsA("Tool") then
            if ToolItemInstance.ToolTip == "Melee" or ToolItemInstance:FindFirstChild("Combat") then
                CurrentHumanoidObject:EquipTool(ToolItemInstance)
                break
            end
        end
    end
end

local function ExecuteGlobalInterpolationMovement(TargetDestinationVector, MovementSpeedValue, DeltaTimeValue, TargetLookAtVector)
    if not PlayerHumanoidRootPartObject then return end
    
    local SafeTargetDestinationPosition = TargetDestinationVector
    if SafeTargetDestinationPosition.Y < MINIMUM_SAFETY_HEIGHT_THRESHOLD then
        SafeTargetDestinationPosition = Vector3.new(SafeTargetDestinationPosition.X, FIXED_FLIGHT_HEIGHT_LEVEL, SafeTargetDestinationPosition.Z)
    end

    PlayerHumanoidRootPartObject.Velocity = Vector3.new(0, 0, 0)
    PlayerHumanoidRootPartObject.RotVelocity = Vector3.new(0, 0, 0)
    
    local CharacterPartsDescendantsList = PlayerCharacterModelObject:GetDescendants()
    for PartIndex = 1, #CharacterPartsDescendantsList do
        local PhysicsBasePartObject = CharacterPartsDescendantsList[PartIndex]
        if PhysicsBasePartObject:IsA("BasePart") then 
            PhysicsBasePartObject.CanCollide = false 
        end
    end

    if PlayerHumanoidObject.SeatPart and PlayerHumanoidObject.SeatPart.Parent then
        local BoatPartsDescendantsList = PlayerHumanoidObject.SeatPart.Parent:GetDescendants()
        for BoatPartIndex = 1, #BoatPartsDescendantsList do
            local BoatPhysicsBasePartObject = BoatPartsDescendantsList[BoatPartIndex]
            if BoatPhysicsBasePartObject:IsA("BasePart") then 
                BoatPhysicsBasePartObject.CanCollide = false 
            end
        end
    end
    
    local CurrentCharacterGlobalPosition = PlayerHumanoidRootPartObject.Position
    local TotalDistanceToDestination = (SafeTargetDestinationPosition - CurrentCharacterGlobalPosition).Magnitude
    local SingleStepMovementMagnitude = MovementSpeedValue * DeltaTimeValue
    
    if TotalDistanceToDestination <= SingleStepMovementMagnitude then
        local FinalOrientationCFrame = TargetLookAtVector and CFrame.lookAt(SafeTargetDestinationPosition, Vector3.new(TargetLookAtVector.X, SafeTargetDestinationPosition.Y, TargetLookAtVector.Z)) or CFrame.new(SafeTargetDestinationPosition)
        PlayerHumanoidRootPartObject.CFrame = FinalOrientationCFrame
    else
        local MovementDirectionUnitVector = (SafeTargetDestinationPosition - CurrentCharacterGlobalPosition).Unit
        local NextIncrementalPositionStep = CurrentCharacterGlobalPosition + (MovementDirectionUnitVector * SingleStepMovementMagnitude)
        local FinalOrientationTarget = TargetLookAtVector or (NextIncrementalPositionStep + MovementDirectionUnitVector)
        PlayerHumanoidRootPartObject.CFrame = CFrame.lookAt(NextIncrementalPositionStep, Vector3.new(FinalOrientationTarget.X, NextIncrementalPositionStep.Y, FinalOrientationTarget.Z))
    end
end

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 7: ВЫСОКОПРОИЗВОДИТЕЛЬНАЯ БОЕВАЯ СИСТЕМА (KILL AURA & SKILL ENGINE) ]]
-- ========================================================================================================================================

task.spawn(function()
    while true do
        task.wait(GOLEM_ATTACK_SPEED_INTERVAL) 
        
        if ScriptGlobalConfiguration.FullAutoEnabledStatus and GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus and GlobalRuntimeStateParameters.CurrentActiveTargetData then
            pcall(function()
                local TargetDataReference = GlobalRuntimeStateParameters.CurrentActiveTargetData
                local TargetInstanceObject = TargetDataReference.Instance
                
                if not TargetInstanceObject or not TargetInstanceObject.Parent then 
                    GlobalRuntimeStateParameters.CurrentActiveTargetData = nil 
                    return 
                end

                local HitDetectionPartObject = (TargetDataReference.Type == "Golem") and TargetInstanceObject:FindFirstChild("HumanoidRootPart") or (TargetInstanceObject:FindFirstChild("volcanorock") or TargetInstanceObject.PrimaryPart)
                
                if HitDetectionPartObject then
                    local DistanceToCombatTarget = (PlayerHumanoidRootPartObject.Position - HitDetectionPartObject.Position).Magnitude
                    
                    if TargetDataReference.Type == "Golem" and DistanceToCombatTarget < KILL_AURA_EFFECTIVE_RADIUS_DISTANCE then
                        ExecuteMeleeWeaponEquipmentSequence()
                        RegisterAttackRemoteEventObject:FireServer(GOLEM_ATTACK_SPEED_INTERVAL)
                        RegisterHitRemoteEventObject:FireServer(HitDetectionPartObject, {})
                    end
                    
                    if TargetDataReference.Type == "Rock" then
                        -- [[ НОВАЯ МАТЕМАТИКА СФЕРИЧЕСКИХ КООРДИНАТ ДЛЯ БЕЗОПАСНОСТИ ]]
                        local PositionalDifferenceVector = PlayerHumanoidRootPartObject.Position - HitDetectionPartObject.Position
                        
                        -- Защита от деления на ноль, если персонаж ровно в центре
                        if PositionalDifferenceVector.Magnitude < 0.1 then
                            PositionalDifferenceVector = Vector3.new(0, 1, 0)
                        end
                        
                        local SafeDirectionUnitVector = PositionalDifferenceVector.Unit
                        local TargetRockSafePositionVector = HitDetectionPartObject.Position + (SafeDirectionUnitVector * ROCK_SAFE_FARMING_DISTANCE)
                        
                        local DistanceToRockSafePositionValue = (PlayerHumanoidRootPartObject.Position - TargetRockSafePositionVector).Magnitude
                        
                        -- Скиллы используются только когда мы долетели до вычисленной точки орбиты
                        if DistanceToRockSafePositionValue <= 5 then
                            ExecuteMeleeWeaponEquipmentSequence()
                            local CurrentGlobalSystemTimestamp = tick()
                            
                            -- [[ НОВЫЙ МЕТОД ПРИЦЕЛИВАНИЯ С ОГРАНИЧЕНИЕМ (LOOKAT СМЕЩЕНИЕ ВНИЗ) ]]
                            local RestrictedAimBasePositionVector = HitDetectionPartObject.Position - Vector3.new(0, 15, 0)
                            
                            if GlobalRuntimeStateParameters.NextSkillSequenceToExecute == "C" and CurrentGlobalSystemTimestamp - GlobalRuntimeStateParameters.LastSkillCExecutionTimestamp >= GlobalRuntimeStateParameters.DynamicSkillActivationCooldown then
                                if CurrentGameCameraObject then
                                    CurrentGameCameraObject.CFrame = CFrame.lookAt(CurrentGameCameraObject.CFrame.Position, RestrictedAimBasePositionVector)
                                end
                                VirtualInputManagerServiceInstance:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                                task.wait(0.01)
                                VirtualInputManagerServiceInstance:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                                GlobalRuntimeStateParameters.LastSkillCExecutionTimestamp = CurrentGlobalSystemTimestamp
                                GlobalRuntimeStateParameters.NextSkillSequenceToExecute = "X"
                                GlobalRuntimeStateParameters.DynamicSkillActivationCooldown = math.random(1, 6)
                                
                            elseif GlobalRuntimeStateParameters.NextSkillSequenceToExecute == "X" and CurrentGlobalSystemTimestamp - GlobalRuntimeStateParameters.LastSkillXExecutionTimestamp >= GlobalRuntimeStateParameters.DynamicSkillActivationCooldown then
                                if CurrentGameCameraObject then
                                    CurrentGameCameraObject.CFrame = CFrame.lookAt(CurrentGameCameraObject.CFrame.Position, RestrictedAimBasePositionVector)
                                end
                                VirtualInputManagerServiceInstance:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                                task.wait(0.01)
                                VirtualInputManagerServiceInstance:SendKeyEvent(false, Enum.KeyCode.X, false, game)
                                GlobalRuntimeStateParameters.LastSkillXExecutionTimestamp = CurrentGlobalSystemTimestamp
                                GlobalRuntimeStateParameters.NextSkillSequenceToExecute = "C"
                                GlobalRuntimeStateParameters.DynamicSkillActivationCooldown = math.random(1, 6)
                            end
                            RegisterAttackRemoteEventObject:FireServer(GOLEM_ATTACK_SPEED_INTERVAL)
                            RegisterHitRemoteEventObject:FireServer(HitDetectionPartObject, {})
                        end
                    end
                end
            end)
        end
    end
end)

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 8: ПОЛЬЗОВАТЕЛЬСКИЙ ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (UI CONSTRUCTION) ]]
-- ========================================================================================================================================

local function CreateSophisticatedUserInterface()
    local ExistingInterfaceObject = CoreGuiServiceInstance:FindFirstChild("DragonScriptPerformanceGui")
    if ExistingInterfaceObject then ExistingInterfaceObject:Destroy() end
    
    local MainScreenGuiInstance = Instance.new("ScreenGui")
    MainScreenGuiInstance.Name = "DragonScriptPerformanceGui"
    MainScreenGuiInstance.Parent = CoreGuiServiceInstance
    MainScreenGuiInstance.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainBackgroundFrame = Instance.new("Frame")
    MainBackgroundFrame.Name = "MainBackgroundFrame"
    MainBackgroundFrame.Parent = MainScreenGuiInstance
    MainBackgroundFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainBackgroundFrame.BorderSizePixel = 0
    MainBackgroundFrame.Position = UDim2.new(0.5, -300, 0.5, -150)
    MainBackgroundFrame.Size = UDim2.new(0, 600, 0, 300)
    MainBackgroundFrame.Active = true
    MainBackgroundFrame.Draggable = true
    
    local MainFrameCorner = Instance.new("UICorner")
    MainFrameCorner.CornerRadius = UDim.new(0, 12)
    MainFrameCorner.Parent = MainBackgroundFrame
    
    local HeaderTitleFrame = Instance.new("Frame")
    HeaderTitleFrame.Name = "HeaderTitleFrame"
    HeaderTitleFrame.Parent = MainBackgroundFrame
    HeaderTitleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HeaderTitleFrame.BorderSizePixel = 0
    HeaderTitleFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local HeaderFrameCorner = Instance.new("UICorner")
    HeaderFrameCorner.CornerRadius = UDim.new(0, 12)
    HeaderFrameCorner.Parent = HeaderTitleFrame
    
    local HeaderTitleLabel = Instance.new("TextLabel")
    HeaderTitleLabel.Name = "HeaderTitleLabel"
    HeaderTitleLabel.Parent = HeaderTitleFrame
    HeaderTitleLabel.BackgroundTransparency = 1
    HeaderTitleLabel.Position = UDim2.new(0, 20, 0, 0)
    HeaderTitleLabel.Size = UDim2.new(1, -40, 1, 0)
    HeaderTitleLabel.Font = Enum.Font.GothamBold
    HeaderTitleLabel.Text = "DRAGON SCRIPT V15.9.1 | ORBIT FARM FIX"
    HeaderTitleLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
    HeaderTitleLabel.TextSize = 18
    HeaderTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusInformationContainer = Instance.new("Frame")
    StatusInformationContainer.Name = "StatusInformationContainer"
    StatusInformationContainer.Parent = MainBackgroundFrame
    StatusInformationContainer.BackgroundTransparency = 1
    StatusInformationContainer.Position = UDim2.new(0, 20, 0, 70)
    StatusInformationContainer.Size = UDim2.new(0, 350, 0, 200)
    
    local IslandStatusTextLabel = Instance.new("TextLabel")
    IslandStatusTextLabel.Name = "IslandStatusTextLabel"
    IslandStatusTextLabel.Parent = StatusInformationContainer
    IslandStatusTextLabel.BackgroundTransparency = 1
    IslandStatusTextLabel.Size = UDim2.new(1, 0, 0, 30)
    IslandStatusTextLabel.Font = Enum.Font.GothamBold
    IslandStatusTextLabel.Text = "ОСТРОВ: ПОИСК..."
    IslandStatusTextLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    IslandStatusTextLabel.TextSize = 20
    IslandStatusTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ActionStatusTextLabel = Instance.new("TextLabel")
    ActionStatusTextLabel.Name = "ActionStatusTextLabel"
    ActionStatusTextLabel.Parent = StatusInformationContainer
    ActionStatusTextLabel.BackgroundTransparency = 1
    ActionStatusTextLabel.Position = UDim2.new(0, 0, 0, 40)
    ActionStatusTextLabel.Size = UDim2.new(1, 0, 0, 30)
    ActionStatusTextLabel.Font = Enum.Font.GothamBold
    ActionStatusTextLabel.Text = "Действие: ОЖИДАНИЕ"
    ActionStatusTextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    ActionStatusTextLabel.TextSize = 20
    ActionStatusTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local TimerStatusTextLabel = Instance.new("TextLabel")
    TimerStatusTextLabel.Name = "TimerStatusTextLabel"
    TimerStatusTextLabel.Parent = StatusInformationContainer
    TimerStatusTextLabel.BackgroundTransparency = 1
    TimerStatusTextLabel.Position = UDim2.new(0, 0, 0, 80)
    TimerStatusTextLabel.Size = UDim2.new(1, 0, 0, 30)
    TimerStatusTextLabel.Font = Enum.Font.GothamMedium
    TimerStatusTextLabel.Text = "ТАЙМЕР: 0 СЕКУНД"
    TimerStatusTextLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    TimerStatusTextLabel.TextSize = 16
    TimerStatusTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ControlToggleButton = Instance.new("TextButton")
    ControlToggleButton.Name = "ControlToggleButton"
    ControlToggleButton.Parent = MainBackgroundFrame
    ControlToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    ControlToggleButton.Position = UDim2.new(1, -220, 0, 70)
    ControlToggleButton.Size = UDim2.new(0, 200, 0, 50)
    ControlToggleButton.Font = Enum.Font.GothamBold
    ControlToggleButton.Text = "FULL AUTO: OFF"
    ControlToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ControlToggleButton.TextSize = 18
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ControlToggleButton
    
    local function UpdateButtonVisualRepresentation()
        if ScriptGlobalConfiguration.FullAutoEnabledStatus then
            ControlToggleButton.Text = "FULL AUTO: ON"
            ControlToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        else
            ControlToggleButton.Text = "FULL AUTO: OFF"
            ControlToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        end
    end
    
    ControlToggleButton.MouseButton1Click:Connect(function()
        ScriptGlobalConfiguration.FullAutoEnabledStatus = not ScriptGlobalConfiguration.FullAutoEnabledStatus
        UpdateButtonVisualRepresentation()
    end)
    
    return IslandStatusTextLabel, ActionStatusTextLabel, TimerStatusTextLabel
end

local IslandStatusLabel, ActionStatusLabel, TimerStatusLabel = CreateSophisticatedUserInterface()

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 9: ЛОГИКА УПРАВЛЕНИЯ ОЧЕРЕДЬЮ ЦЕЛЕЙ (TARGET QUEUE MANAGEMENT) ]]
-- ========================================================================================================================================

local function CheckIfTargetIsAlreadyPresentInQueue(TargetObjectInstance)
    if GlobalRuntimeStateParameters.CurrentActiveTargetData and GlobalRuntimeStateParameters.CurrentActiveTargetData.Instance == TargetObjectInstance then return true end
    for QueueIndex = 1, #GlobalRuntimeStateParameters.PriorityTargetQueueTable do
        if GlobalRuntimeStateParameters.PriorityTargetQueueTable[QueueIndex].Instance == TargetObjectInstance then return true end
    end
    return false
end

local function ExecuteTargetQueueUpdateSequence()
    if not GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus then return end
    
    local PrehistoricIslandModelObject = MapFolderInWorkspaceObject:FindFirstChild("PrehistoricIsland")
    if not PrehistoricIslandModelObject then return end
    
    local IslandCoreObject = PrehistoricIslandModelObject:FindFirstChild("Core")
    if not IslandCoreObject then return end

    local VolcanoRocksContainerFolder = IslandCoreObject:FindFirstChild("VolcanoRocks")
    if VolcanoRocksContainerFolder then
        local RocksCollectionList = VolcanoRocksContainerFolder:GetChildren()
        for RockIndex = 1, #RocksCollectionList do
            local RockInstanceObject = RocksCollectionList[RockIndex]
            local VisualEffectLayerObject = RockInstanceObject:FindFirstChild("VFXLayer")
            if VisualEffectLayerObject and VisualEffectLayerObject.At0.Glow.Enabled then
                if not CheckIfTargetIsAlreadyPresentInQueue(RockInstanceObject) then
                    table.insert(GlobalRuntimeStateParameters.PriorityTargetQueueTable, {Instance = RockInstanceObject, Type = "Rock"})
                end
            end
        end
    end

    local GlobalEnemiesList = EnemiesFolderInWorkspaceObject:GetChildren()
    for EnemyIndex = 1, #GlobalEnemiesList do
        local EnemyCharacterModel = GlobalEnemiesList[EnemyIndex]
        local EnemyHumanoidComponent = EnemyCharacterModel:FindFirstChild("Humanoid")
        if EnemyHumanoidComponent and EnemyHumanoidComponent.Health > 0 then
            local EnemyNameLowercase = EnemyCharacterModel.Name:lower()
            if EnemyNameLowercase:find("lava") or EnemyNameLowercase:find("golem") then
                if not CheckIfTargetIsAlreadyPresentInQueue(EnemyCharacterModel) then
                    table.insert(GlobalRuntimeStateParameters.PriorityTargetQueueTable, {Instance = EnemyCharacterModel, Type = "Golem"})
                end
            end
        end
    end
    
    if #GlobalRuntimeStateParameters.PriorityTargetQueueTable > 1 then
        table.sort(GlobalRuntimeStateParameters.PriorityTargetQueueTable, function(TargetA, TargetB)
            if GlobalRuntimeStateParameters.CurrentActiveTargetData and GlobalRuntimeStateParameters.CurrentActiveTargetData.Type == "Golem" then
                if TargetA.Type == "Golem" and TargetB.Type ~= "Golem" then return true
                elseif TargetA.Type ~= "Golem" and TargetB.Type == "Golem" then return false end
            end
            local PositionOfTargetA = TargetA.Instance:GetPivot().Position
            local PositionOfTargetB = TargetB.Instance:GetPivot().Position
            local CurrentLocalPlayerPosition = PlayerHumanoidRootPartObject.Position
            return (CurrentLocalPlayerPosition - PositionOfTargetA).Magnitude < (CurrentLocalPlayerPosition - PositionOfTargetB).Magnitude
        end)
    end
end

-- ========================================================================================================================================
-- [[ СЕКЦИЯ 10: ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ СОБЫТИЙ (HEARTBEAT EXECUTION LOOP) ]]
-- ========================================================================================================================================

RunServiceInstance.Heartbeat:Connect(function(DeltaTimeStepValue)
    if not ScriptGlobalConfiguration.FullAutoEnabledStatus or not PlayerHumanoidRootPartObject or PlayerHumanoidObject.Health <= 0 then return end
    
    local CurrentPrehistoricIslandInstance = MapFolderInWorkspaceObject:FindFirstChild("PrehistoricIsland")
    local CurrentIslandCoreInstance = CurrentPrehistoricIslandInstance and CurrentPrehistoricIslandInstance:FindFirstChild("Core")
    local PrehistoricRelicTargetObject = CurrentIslandCoreInstance and CurrentIslandCoreInstance:FindFirstChild("PrehistoricRelic")

    if GlobalRuntimeStateParameters.IslandPresenceStatusInLastFrame and not CurrentPrehistoricIslandInstance then
        GlobalRuntimeStateParameters.IslandPresenceStatusInLastFrame = false
        GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus = false
        GlobalRuntimeStateParameters.SpawnPointSetInitialStatus = false
        GlobalRuntimeStateParameters.RelicActivationEndTimeTick = 0
        GlobalRuntimeStateParameters.RelicWaitStartTimeTick = 0 
        GlobalRuntimeStateParameters.RelicActivationPositionVector = nil
        GlobalRuntimeStateParameters.DangerLavaDeletionStatus = false
        GlobalRuntimeStateParameters.DragonEggPhaseStartedStatus = false
        GlobalRuntimeStateParameters.CachedGolemTargetPositionVector = nil 
        ActionStatusLabel.Text = "Действие: ОСТРОВ ИСЧЕЗ - РЕСЕТ"
        PlayerHumanoidObject.Health = 0 
        return
    end

    if CurrentPrehistoricIslandInstance and CurrentIslandCoreInstance then
        GlobalRuntimeStateParameters.IslandPresenceStatusInLastFrame = true
        IslandStatusLabel.Text = "ОСТРОВ: НАЙДЕН"
        IslandStatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)

        if not GlobalRuntimeStateParameters.SpawnPointSetInitialStatus then
            task.spawn(function()
                CommunicationRemoteFunctionObject:InvokeServer("SetHome", "Prehistoric Island")
                CommunicationRemoteFunctionObject:InvokeServer("SetSpawnPoint")
            end)
            GlobalRuntimeStateParameters.SpawnPointSetInitialStatus = true
        end

        if PlayerHumanoidObject.SeatPart then
            PlayerHumanoidObject.Sit = false
            PlayerHumanoidObject.Jump = true
            return 
        end

        local RelicActivationPromptPart = CurrentIslandCoreInstance:FindFirstChild("ActivationPrompt")
        
        if RelicActivationPromptPart then
            if GlobalRuntimeStateParameters.RelicWaitStartTimeTick == 0 then GlobalRuntimeStateParameters.RelicWaitStartTimeTick = tick() end
            local TimeSpentWaiting = tick() - GlobalRuntimeStateParameters.RelicWaitStartTimeTick
            local TimeRemainingUntilActivation = ScriptGlobalConfiguration.RelicManualActivationDelaySeconds - TimeSpentWaiting
            GlobalRuntimeStateParameters.RelicActivationPositionVector = RelicActivationPromptPart.Position
            ExecuteGlobalInterpolationMovement(RelicActivationPromptPart.Position, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)

            if TimeRemainingUntilActivation > 0 then
                ActionStatusLabel.Text = "Фарм: ОЖИДАНИЕ РЕЛИКВИИ"
                TimerStatusLabel.Text = "АКТИВАЦИЯ ЧЕРЕЗ: " .. math.ceil(TimeRemainingUntilActivation) .. " СЕК"
            else
                ActionStatusLabel.Text = "Фарм: АКТИВАЦИЯ РЕЛИКВИИ"
                local ProximityPromptObject = RelicActivationPromptPart:FindFirstChildOfClass("ProximityPrompt")
                if ProximityPromptObject then fireproximityprompt(ProximityPromptObject) end
            end
            GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus = false
            return
        else
            GlobalRuntimeStateParameters.RelicWaitStartTimeTick = 0
        end

        if not GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus then
            if GlobalRuntimeStateParameters.RelicActivationEndTimeTick == 0 then GlobalRuntimeStateParameters.RelicActivationEndTimeTick = tick() end
            local SecondsElapsedSinceRelicActivation = tick() - GlobalRuntimeStateParameters.RelicActivationEndTimeTick
            local RemainingWaitTimeInSeconds = math.ceil(8 - SecondsElapsedSinceRelicActivation)
            local DisplayTimerValue = math.max(0, RemainingWaitTimeInSeconds)
            TimerStatusLabel.Text = "ПОДГОТОВКА: " .. DisplayTimerValue .. " СЕК"
            
            if DisplayTimerValue > 0 then
                ActionStatusLabel.Text = "Действие: ПОДГОТОВКА"
                if PrehistoricRelicTargetObject then
                    ExecuteGlobalInterpolationMovement(PrehistoricRelicTargetObject:GetPivot().Position, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
                else
                    ExecuteGlobalInterpolationMovement(CurrentIslandCoreInstance.Position + Vector3.new(0, 60, 0), GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
                end
                return
            else
                GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus = true
                if not GlobalRuntimeStateParameters.DangerLavaDeletionStatus then
                    local AllIslandDescendantsObjectsList = CurrentPrehistoricIslandInstance:GetDescendants()
                    for DescendantIndex = 1, #AllIslandDescendantsObjectsList do
                        local TargetObject = AllIslandDescendantsObjectsList[DescendantIndex]
                        if string.find(string.lower(TargetObject.Name), "lava") then TargetObject:Destroy() end
                    end
                    GlobalRuntimeStateParameters.DangerLavaDeletionStatus = true
                end
            end
        end

        if GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus then
            local DragonEggsFolderObject = CurrentIslandCoreInstance:FindFirstChild("SpawnedDragonEggs")
            local DragonEggsCollectionList = DragonEggsFolderObject and DragonEggsFolderObject:GetChildren() or {}
            
            if #DragonEggsCollectionList > 0 then
                if not GlobalRuntimeStateParameters.DragonEggPhaseStartedStatus then
                    GlobalRuntimeStateParameters.DragonEggPhaseStartedStatus = true
                    GlobalRuntimeStateParameters.DragonEggPhaseStartTimeTick = tick()
                end
                local ClosestEggInstanceObject = nil
                local MinimumDistanceToEggValue = math.huge
                for EggIndex = 1, #DragonEggsCollectionList do
                    local EggObjectInstance = DragonEggsCollectionList[EggIndex]
                    local MoltenEggPart = EggObjectInstance:FindFirstChild("Molten")
                    if MoltenEggPart then
                        local DistanceToTargetEgg = (PlayerHumanoidRootPartObject.Position - MoltenEggPart.Position).Magnitude
                        if DistanceToTargetEgg < MinimumDistanceToEggValue then 
                            MinimumDistanceToEggValue = DistanceToTargetEgg 
                            ClosestEggInstanceObject = EggObjectInstance 
                        end
                    end
                end
                if ClosestEggInstanceObject then
                    local TargetMoltenPart = ClosestEggInstanceObject.Molten
                    ActionStatusLabel.Text = "Фарм: ЯЙЦО ДРАКОНА"
                    ExecuteGlobalInterpolationMovement(TargetMoltenPart.Position, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
                    local EggProximityPrompt = TargetMoltenPart:FindFirstChild("ProximityPrompt")
                    if EggProximityPrompt then fireproximityprompt(EggProximityPrompt) end
                    return
                end
            else
                if GlobalRuntimeStateParameters.DragonEggPhaseStartedStatus then
                    local TimeElapsedInEggPhase = tick() - GlobalRuntimeStateParameters.DragonEggPhaseStartTimeTick
                    local RemainingTimeBeforeReset = math.ceil(50 - TimeElapsedInEggPhase)
                    local DisplayResetTimer = math.max(0, RemainingTimeBeforeReset)
                    TimerStatusLabel.Text = "РЕСЕТ ЧЕРЕЗ: " .. DisplayResetTimer .. " СЕК"
                    if DisplayResetTimer <= 0 then CurrentPrehistoricIslandInstance:Destroy() return end
                    ActionStatusLabel.Text = "Фарм: ЗАВЕРШЕНИЕ"
                    ExecuteGlobalInterpolationMovement(CurrentIslandCoreInstance.Position + Vector3.new(0, 80, 0), GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
                    return
                end
            end

            ExecuteTargetQueueUpdateSequence()
            
            if not GlobalRuntimeStateParameters.CurrentActiveTargetData and #GlobalRuntimeStateParameters.PriorityTargetQueueTable > 0 then
                GlobalRuntimeStateParameters.CurrentActiveTargetData = table.remove(GlobalRuntimeStateParameters.PriorityTargetQueueTable, 1)
                GlobalRuntimeStateParameters.CachedGolemTargetPositionVector = nil
            end

            if GlobalRuntimeStateParameters.CurrentActiveTargetData then
                local ActiveTargetDataPointer = GlobalRuntimeStateParameters.CurrentActiveTargetData
                local ActiveTargetInstanceObject = ActiveTargetDataPointer.Instance
                local TargetValidityStatus = true
                
                if not ActiveTargetInstanceObject or not ActiveTargetInstanceObject.Parent then TargetValidityStatus = false end
                if ActiveTargetDataPointer.Type == "Rock" then
                    local VisualEffectLayer = ActiveTargetInstanceObject:FindFirstChild("VFXLayer")
                    if not VisualEffectLayer or not VisualEffectLayer.At0.Glow.Enabled then TargetValidityStatus = false end
                elseif ActiveTargetDataPointer.Type == "Golem" then
                    local EnemyHumanoid = ActiveTargetInstanceObject:FindFirstChild("Humanoid")
                    if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then TargetValidityStatus = false end
                end

                if not TargetValidityStatus then
                    GlobalRuntimeStateParameters.CurrentActiveTargetData = nil
                    GlobalRuntimeStateParameters.CachedGolemTargetPositionVector = nil 
                else
                    if ActiveTargetDataPointer.Type == "Rock" then
                        ActionStatusLabel.Text = "Фарм: СГУСТОК МАГМЫ"
                        local ActualTargetRockPart = ActiveTargetInstanceObject:FindFirstChild("volcanorock") or ActiveTargetInstanceObject.PrimaryPart
                        if ActualTargetRockPart then
                            -- [[ ВЫЧИСЛЕНИЕ ДИНАМИЧЕСКОЙ СФЕРИЧЕСКОЙ ТОЧКИ ПОЛЕТА ]]
                            local PositionalDifferenceVector = PlayerHumanoidRootPartObject.Position - ActualTargetRockPart.Position
                            if PositionalDifferenceVector.Magnitude < 0.1 then PositionalDifferenceVector = Vector3.new(0, 1, 0) end
                            
                            local SafeDirectionUnitVector = PositionalDifferenceVector.Unit
                            local TargetRockSafePositionVector = ActualTargetRockPart.Position + (SafeDirectionUnitVector * ROCK_SAFE_FARMING_DISTANCE)
                            local RestrictedAimBasePositionVector = ActualTargetRockPart.Position - Vector3.new(0, 15, 0)
                            
                            -- Полет к вычисленной точке, взгляд направлен в пол под сгустком
                            ExecuteGlobalInterpolationMovement(TargetRockSafePositionVector, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue, RestrictedAimBasePositionVector)
                        end
                    elseif ActiveTargetDataPointer.Type == "Golem" then
                        ActionStatusLabel.Text = "Фарм: ГОЛЕМ (СТАТИЧНО)"
                        if not GlobalRuntimeStateParameters.CachedGolemTargetPositionVector then
                            local GolemGlobalPositionVector = ActiveTargetInstanceObject:GetPivot().Position
                            if PrehistoricRelicTargetObject then
                                local RelicGlobalPositionVector = PrehistoricRelicTargetObject:GetPivot().Position
                                local DirectionToRelicUnitVector = (RelicGlobalPositionVector - GolemGlobalPositionVector).Unit
                                GlobalRuntimeStateParameters.CachedGolemTargetPositionVector = GolemGlobalPositionVector + (DirectionToRelicUnitVector * ScriptGlobalConfiguration.GolemRelicShiftValue) + Vector3.new(0, ScriptGlobalConfiguration.GolemHeightOffsetValue, 0)
                            else
                                GlobalRuntimeStateParameters.CachedGolemTargetPositionVector = GolemGlobalPositionVector + Vector3.new(0, ScriptGlobalConfiguration.GolemHeightOffsetValue, 0)
                            end
                        end
                        ExecuteGlobalInterpolationMovement(GlobalRuntimeStateParameters.CachedGolemTargetPositionVector, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue, ActiveTargetInstanceObject:GetPivot().Position)
                    end
                end
            else
                ActionStatusLabel.Text = "Фарм: ОЖИДАНИЕ"
                if PrehistoricRelicTargetObject then
                    ExecuteGlobalInterpolationMovement(PrehistoricRelicTargetObject:GetPivot().Position, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
                else
                    ExecuteGlobalInterpolationMovement(CurrentIslandCoreInstance.Position + Vector3.new(0, 60, 0), GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
                end
            end
        end
    else
        GlobalRuntimeStateParameters.IslandPresenceStatusInLastFrame = false
        GlobalRuntimeStateParameters.IsFarmingPermissionGrantedStatus = false
        GlobalRuntimeStateParameters.SpawnPointSetInitialStatus = false
        GlobalRuntimeStateParameters.RelicActivationEndTimeTick = 0
        GlobalRuntimeStateParameters.RelicWaitStartTimeTick = 0
        GlobalRuntimeStateParameters.CachedGolemTargetPositionVector = nil 
        IslandStatusLabel.Text = "ОСТРОВ: ПОИСК..."
        IslandStatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        
        local CurrentlyOwnedBoatInstance = nil
        local ActiveBoatsCollectionList = BoatsFolderInWorkspaceObject:GetChildren()
        for BoatIndex = 1, #ActiveBoatsCollectionList do
            local BoatInstanceObject = ActiveBoatsCollectionList[BoatIndex]
            local OwnerValueObjectInstance = BoatInstanceObject:FindFirstChild("Owner")
            if OwnerValueObjectInstance and OwnerValueObjectInstance.Value == LocalPlayerInstanceObject then
                local BoatSeatObjectInstance = BoatInstanceObject:FindFirstChild("VehicleSeat") or BoatInstanceObject:FindFirstChildWhichIsA("VehicleSeat", true)
                if BoatSeatObjectInstance then
                    local DistanceToBoatSeat = (PlayerHumanoidRootPartObject.Position - BoatSeatObjectInstance.Position).Magnitude
                    if DistanceToBoatSeat < BOAT_LOST_MAXIMUM_DISTANCE_THRESHOLD then CurrentlyOwnedBoatInstance = BoatInstanceObject; break end
                end
            end
        end
        
        if not CurrentlyOwnedBoatInstance then
            local DistanceToBoatPurchasePier = (PlayerHumanoidRootPartObject.Position - PIER_COORDINATES_FOR_BOAT_PURCHASE).Magnitude
            if DistanceToBoatPurchasePier > BOAT_LOST_MAXIMUM_DISTANCE_THRESHOLD then 
                GlobalRuntimeStateParameters.ResetGraceTimerAccumulator = GlobalRuntimeStateParameters.ResetGraceTimerAccumulator + DeltaTimeStepValue
                local RemainingGraceTime = math.ceil(GlobalRuntimeStateParameters.ResetGraceThresholdMaximum - GlobalRuntimeStateParameters.ResetGraceTimerAccumulator)
                ActionStatusLabel.Text = "СКАН ЛОДКИ: " .. math.max(0, RemainingGraceTime) .. " СЕК"
                if GlobalRuntimeStateParameters.ResetGraceTimerAccumulator >= GlobalRuntimeStateParameters.ResetGraceThresholdMaximum then
                    PlayerHumanoidObject.Health = 0 
                    GlobalRuntimeStateParameters.ResetGraceTimerAccumulator = 0 
                end
            else 
                ActionStatusLabel.Text = "Действие: ПУТЬ К ПИРСУ"
                GlobalRuntimeStateParameters.ResetGraceTimerAccumulator = 0
                ExecuteGlobalInterpolationMovement(PIER_COORDINATES_FOR_BOAT_PURCHASE, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue) 
            end
            if DistanceToBoatPurchasePier < 60 and tick() - GlobalRuntimeStateParameters.LastBoatPurchaseTimestamp > 10 then
                GlobalRuntimeStateParameters.LastBoatPurchaseTimestamp = tick()
                CommunicationRemoteFunctionObject:InvokeServer("BuyBoat", ScriptGlobalConfiguration.CurrentBoatTypeSelection)
            end
        else
            GlobalRuntimeStateParameters.ResetGraceTimerAccumulator = 0 
            local VehicleSeatPartObject = CurrentlyOwnedBoatInstance:FindFirstChild("VehicleSeat") or CurrentlyOwnedBoatInstance:FindFirstChildWhichIsA("VehicleSeat", true)
            if not PlayerHumanoidObject.SeatPart then
                ActionStatusLabel.Text = "Действие: ПОСАДКА В ЛОДКУ"
                ExecuteGlobalInterpolationMovement(VehicleSeatPartObject.Position, GLOBAL_CHARACTER_FLIGHT_SPEED_VALUE, DeltaTimeStepValue)
            else
                local CurrentCharacterCoordinatesVector = PlayerHumanoidRootPartObject.Position
                ActionStatusLabel.Text = "Действие: ПОИСК ОСТРОВА (+Z)"
                ExecuteGlobalInterpolationMovement(Vector3.new(CurrentCharacterCoordinatesVector.X, FIXED_FLIGHT_HEIGHT_LEVEL, CurrentCharacterCoordinatesVector.Z + 1000), GLOBAL_BOAT_MOVEMENT_SPEED_VALUE, DeltaTimeStepValue)
            end
        end
    end
end)
