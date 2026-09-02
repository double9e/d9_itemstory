shared = shared or {}

local ResourceName = GetCurrentResourceName()

function GetName(side, action)
    return ("%s:%s:%s"):format(ResourceName, side, action)
end

function RegisEvent(name, handler)
    RegisterNetEvent(name)
    return AddEventHandler(name, handler)
end

function log(...)
    if Config.Debug then
        print(...)
    end
end
