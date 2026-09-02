ESX = exports["es_extended"]:getSharedObject()

CreateThread(function()
    model:Init()
end)

function model:Init()
    -- self:RegisterUsableItems(Config.Painkiller, GetName("client", "painkiller"), "painkiller", true)
    -- self:RegisterUsableItems(Config.Armor, GetName("client", "armor"), "armor", true)
    -- self:RegisterUsableItems(Config.Aed, GetName("client", "aed"), "aed_use", false)

    RegisEvent(GetName("server", "reviveTarget"), function(item, target)
        local source = source
        if source <= 0 or source == 65535 then
            return
        end
        if self:IsThrottled(source, "aed_revive", 1000) then
            return
        end

        if type(item) ~= "string" or item == "" or #item > 64 then
            return
        end

        target = tonumber(target)
        if not target or target ~= target then
            return
        end

        target = math.floor(target)
        if target <= 0 or target == source then
            return
        end
        if not GetPlayerName(target) then
            return
        end

        local xData = Config.Aed[item]
        if not xData then
            return
        end

        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            return
        end
        if not self:HasJob(xPlayer, xData.Job) then
            return
        end
        if not self:HasItem(xPlayer, item) then
            return
        end
        if not self:DistanceOk(source, target, 3.0) then
            return
        end

        if xData.Remove then
            xPlayer.removeInventoryItem(item, 1)
        end

        log("ReviveTarget", item, target)
        if xData.ReviveFunction then
            xData.ReviveFunction(target)
        end
    end)
end
