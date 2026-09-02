model = {
    Throttle = {},
}

function model:IsThrottled(source, key, limit)
    local now = GetGameTimer()
    local t = self.Throttle[source]
    if not t then
        t = {}
        self.Throttle[source] = t
    end
    if now - (t[key] or 0) < limit then
        return true
    end
    t[key] = now
    return false
end

function model:HasJob(xPlayer, jobs)
    if jobs == nil then
        return true
    end
    local jobName = xPlayer.job and xPlayer.job.name
    if not jobName then
        return false
    end
    for _, name in pairs(jobs) do
        if jobName == name then
            return true
        end
    end
    return false
end

function model:HasItem(xPlayer, itemName)
    local item = xPlayer.getInventoryItem(itemName)
    return item and item.count and item.count >= 1
end

function model:InBlockedVehicle(source, blockInVehicle)
    if not blockInVehicle then
        return false
    end
    local ped = GetPlayerPed(source)
    return ped ~= 0 and GetVehiclePedIsIn(ped, false) ~= 0
end

function model:DistanceOk(source, target, maxDist)
    local srcPed = GetPlayerPed(source)
    local tgtPed = GetPlayerPed(target)
    if srcPed == 0 or tgtPed == 0 then
        return false
    end
    return #(GetEntityCoords(srcPed) - GetEntityCoords(tgtPed)) <= maxDist
end

---@param configTable table
---@param clientEvent string
---@param throttleKey string
---@param removeOnUse boolean
function model:RegisterUsableItems(configTable, clientEvent, throttleKey, removeOnUse)
    for itemName, xData in pairs(configTable) do
        ESX.RegisterUsableItem(itemName, function(source)
            if source <= 0 or source == 65535 then
                return
            end
            if self:IsThrottled(source, throttleKey, 500) then
                return
            end

            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then
                return
            end
            if not self:HasJob(xPlayer, xData.Job) then
                return
            end
            if not self:HasItem(xPlayer, itemName) then
                return
            end
            if self:InBlockedVehicle(source, xData.InVehicle) then
                return
            end

            if removeOnUse and xData.Remove then
                xPlayer.removeInventoryItem(itemName, 1)
            end

            TriggerClientEvent(clientEvent, source, itemName)
        end)
    end
end

AddEventHandler("playerDropped", function()
    model.Throttle[source] = nil
end)
