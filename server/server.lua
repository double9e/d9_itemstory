local ResourceName = GetCurrentResourceName()
ESX = exports["es_extended"]:getSharedObject()

GetName = function(a, b)
    return string.format("%s:%s:%s", ResourceName, a, b)
end

RegisEvent = function(n, h)
    return RegisterNetEvent(n), AddEventHandler(n, h)
end

Citizen.CreateThread(function()
    model:Init()
end)

function model:Init()
    for k, v in pairs(Config.Painkiller) do
        ESX.RegisterUsableItem(k, function(source)
            TriggerClientEvent(GetName('cl','Painkiller'), source, k)
        end)
    end

    for k, v in pairs(Config.Armor) do
        ESX.RegisterUsableItem(k, function(source)
            TriggerClientEvent(GetName('cl','Armor'), source, k)
        end)
    end

    for k, v in pairs(Config.Aed) do
        ESX.RegisterUsableItem(k, function(source)
            TriggerClientEvent(GetName('cl','Aed'), source, k)
        end)
    end

    RegisEvent(GetName('sv', 'removeItem'), function(item)
        if not item then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        xPlayer.removeInventoryItem(item, 1)
    end)

    RegisEvent(GetName('sv', 'ReviveTarget'), function(item, Target)
        log("ReviveTarget", item, Target)
        if not item or not Target then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        local xData = Config.Aed[item]
        if not xData then
            print(("Aed item not found: %s"):format(item))
            return
        end
        xData.ReviveFunction(Target)
    end)

end