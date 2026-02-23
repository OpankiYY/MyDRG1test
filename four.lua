-- ========================================================================================================================================
-- [[ DRAGON SYSTEM: PERMANENT VISUAL SHIELD (V4.0 - PLAYERGUI EDITION) ]]
-- ========================================================================================================================================
-- ПРЕДНАЗНАЧЕНИЕ: ПОЛНОЕ СКРЫТИЕ ИГРОВОГО ПРОЦЕССА БЕЛЫМ ЭКРАНОМ.
-- ТЕХНИЧЕСКИЕ ОСОБЕННОСТИ:
-- 1. НЕУЯЗВИМОСТЬ: АВТОМАТИЧЕСКОЕ ВОССТАНОВЛЕНИЕ ПРИ УДАЛЕНИИ ЧЕРЕЗ DEX ИЛИ СКРИПТЫ.
-- 2. СОВМЕСТИМОСТЬ: НЕ ПЕРЕКРЫВАЕТ СИСТЕМНЫЕ ОКНА ROBLOX (СООБЩЕНИЯ О ВЫЛЕТЕ/КИКЕ).
-- 3. ОПТИМИЗАЦИЯ: ПОЛНОЕ ОТКЛЮЧЕНИЕ 3D-РЕНДЕРА ДЛЯ СНИЖЕНИЯ НАГРУЗКИ НА ТЕЛЕФОН.
-- ========================================================================================================================================

-- [[ РАЗДЕЛ 1: СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ ]]
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local PlayersServiceInstance = game:GetService("Players")
local RunServiceInstance = game:GetService("RunService")

local LocalPlayerInstanceObject = PlayersServiceInstance.LocalPlayer
-- Ожидаем загрузки контейнера интерфейса игрока
local PlayerGuiInstanceObject = LocalPlayerInstanceObject:WaitForChild("PlayerGui")

-- [[ РАЗДЕЛ 2: ПАРАМЕТРЫ КОНФИГУРАЦИИ ]]
local ShieldConfigurationParameters = {
    ShieldName = "DragonVisualShield_System",
    BackgroundColor = Color3.fromRGB(255, 255, 255), -- Чисто белый
    -- DisplayOrder = 0 позволяет перекрыть игру, но оставить системные окна Roblox (в CoreGui) видимыми
    DisplayOrderPriority = 0,
    Disable3DRendering = true
}

-- [[ РАЗДЕЛ 3: ФУНКЦИЯ СОЗДАНИЯ ЗАЩИТНОГО СЛОЯ ]]
local function ExecuteVisualShieldCreation()
    -- Проверка на дубликаты перед созданием
    local ExistingShieldObject = PlayerGuiInstanceObject:FindFirstChild(ShieldConfigurationParameters.ShieldName)
    if ExistingShieldObject then
        ExistingShieldObject:Destroy()
    end

    -- Создание ScreenGui
    local ShieldScreenGuiObject = Instance.new("ScreenGui")
    ShieldScreenGuiObject.Name = ShieldConfigurationParameters.ShieldName
    -- Родитель — PlayerGui (это гарантирует, что системные кики будут ПОВЕРХ белого экрана)
    ShieldScreenGuiObject.Parent = PlayerGuiInstanceObject
    ShieldScreenGuiObject.DisplayOrder = ShieldConfigurationParameters.DisplayOrderPriority
    ShieldScreenGuiObject.IgnoreGuiInset = true -- Растягиваем на весь экран, включая полоску сверху
    ShieldScreenGuiObject.ResetOnSpawn = false -- Экран не исчезнет после смерти персонажа

    -- Создание фоновой рамки
    local VisualBlockerFrameObject = Instance.new("Frame")
    VisualBlockerFrameObject.Name = "VisualBlocker"
    VisualBlockerFrameObject.Size = UDim2.new(1, 0, 1, 0)
    VisualBlockerFrameObject.Position = UDim2.new(0, 0, 0, 0)
    VisualBlockerFrameObject.BackgroundColor3 = ShieldConfigurationParameters.BackgroundColor
    VisualBlockerFrameObject.BorderSizePixel = 0
    -- Active = false позволяет кликам проходить сквозь белый экран к другим вашим меню или кнопкам
    VisualBlockerFrameObject.Active = false 
    VisualBlockerFrameObject.ZIndex = 1
    VisualBlockerFrameObject.Parent = ShieldScreenGuiObject

    return ShieldScreenGuiObject
end

-- [[ РАЗДЕЛ 4: СИСТЕМА МОНИТОРИНГА И АВТОРЕГЕНЕРАЦИИ ]]

-- Первичный запуск
local CurrentActiveShieldInstance = ExecuteVisualShieldCreation()

-- Цикл проверки на удаление (Защита от Dex Explorer)
task.spawn(function()
    while true do
        task.wait(0.5) -- Проверка дважды в секунду
        
        -- Ищем объект в PlayerGui
        local IntegrityCheckInstance = PlayerGuiInstanceObject:FindFirstChild(ShieldConfigurationParameters.ShieldName)
        
        if not IntegrityCheckInstance then
            -- Если щит был удален — немедленно восстанавливаем
            warn("[DRAGON-SHIELD] ОБНАРУЖЕНО УДАЛЕНИЕ ЩИТА. ВОССТАНОВЛЕНИЕ...")
            CurrentActiveShieldInstance = ExecuteVisualShieldCreation()
        else
            -- Если GUI на месте, проверяем наличие самой белой заливки внутри
            local FrameCheckInstance = IntegrityCheckInstance:FindFirstChild("VisualBlocker")
            if not FrameCheckInstance then
                -- Если кто-то удалил только Frame внутри GUI
                local RestoredFrameObject = Instance.new("Frame")
                RestoredFrameObject.Name = "VisualBlocker"
                RestoredFrameObject.Size = UDim2.new(1, 0, 1, 0)
                RestoredFrameObject.BackgroundColor3 = ShieldConfigurationParameters.BackgroundColor
                RestoredFrameObject.BorderSizePixel = 0
                RestoredFrameObject.Active = false
                RestoredFrameObject.Parent = IntegrityCheckInstance
            end
        end
    end
end)

-- [[ РАЗДЕЛ 5: ОПТИМИЗАЦИЯ ДЛЯ ТЕЛЕФОНОВ ]]
if ShieldConfigurationParameters.Disable3DRendering then
    -- Этот метод полностью выключает отрисовку 3D мира. 
    -- Процессор и видеочип телефона перестают греться, так как рисуется только белый GUI.
    RunServiceInstance:Set3dRenderingEnabled(false)
end

print("[DRAGON-SYSTEM] БЕЛЫЙ ЭКРАН АКТИВИРОВАН. СИСТЕМНЫЕ УВЕДОМЛЕНИЯ ОСТАЛИСЬ ДОСТУПНЫ.")

-- ========================================================================================================================================
-- [[ КОНЕЦ ЗАЩИТНОГО СКРИПТА ]]
-- ========================================================================================================================================
