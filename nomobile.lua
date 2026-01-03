-- Главная таблица для всего кода
_G.AntiMobileInject = {}

-- Функция проверки платформы
_G.AntiMobileInject.CheckPlatform = function()
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Проверка на мобильную платформу
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then
        -- Кикаем игрока
        LocalPlayer:Kick("скрипт для компьютеров\\script for pc")
        return true
    end
    
    -- Дополнительные проверки
    if UserInputService:GetPlatform() == Enum.Platform.IOS or 
       UserInputService:GetPlatform() == Enum.Platform.Android then
        LocalPlayer:Kick("скрипт для компьютеров\\script for pc")
        return true
    end
    
    return false
end

-- Функция защиты от изменений
_G.AntiMobileInject.ProtectScript = function()
    -- Защищаем функции от перезаписи
    local mt = {
        __newindex = function(self, key, value)
            if key == "CheckPlatform" or key == "ProtectScript" then
                error("Изменение защищенных функций запрещено")
            else
                rawset(self, key, value)
            end
        end
    }
    
    setmetatable(_G.AntiMobileInject, mt)
end

-- Проверка при загрузке
_G.AntiMobileInject.CheckPlatform()

-- Периодическая проверка
_G.AntiMobileInject.Monitor = function()
    while true do
        wait(5)
        _G.AntiMobileInject.CheckPlatform()
    end
end

-- Запуск мониторинга
_G.AntiMobileInject.MonitorThread = coroutine.create(_G.AntiMobileInject.Monitor)
coroutine.resume(_G.AntiMobileInject.MonitorThread)

-- Защищаем скрипт
_G.AntiMobileInject.ProtectScript()
