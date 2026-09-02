model = {
    IsDead = false,
    status = {
        painkiller = false,
        aed = false,
        armor = false,
    },
    caches = {
        painkiller = {},
        aed = {},
        armor = {},
    },
    Cooldown = {
        painkiller = false,
        aed = false,
        armor = false,
    },
}

function model:GetStatus(value)
    return self.status[value] or false
end

exports("GetStatus", function(value)
    return model:GetStatus(value)
end)

function model:LoadAnim(dict)
    if HasAnimDictLoaded(dict) then
        return true
    end
    RequestAnimDict(dict)
    local startTime = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        Wait(10)
        if GetGameTimer() - startTime > 2000 then
            print(("LoadAnim timeout: '%s'"):format(dict))
            return false
        end
    end
    return true
end

function model:PlayerAnim(dict, anim, flag)
    if not self:LoadAnim(dict) then
        return
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, flag or 0, 0.0, false, false, false)
end

function model:CheckJob(jobs)
    if jobs == nil then
        return true
    end

    local job = core.player.job
    local jobName = job and job.name
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

function model:GetNearbyPlayer(distance)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or not distance or closestDistance > distance then
        return nil, false, -1
    end

    local sid = GetPlayerServerId(closestPlayer)
    local target = GetPlayerPed(closestPlayer)
    return sid, IsEntityDead(target), closestPlayer
end

function model:ClearUse(kind)
    self.status[kind] = false
    self.caches[kind] = {}
end

function model:CanUseItem(item, configTable)
    if type(item) ~= "string" then
        return false
    end

    return configTable[item] ~= nil
end

--- ลงทะเบียนผ่าน core.registerUseItem(item, handler) — โหมดใหม่ของ d9_lib useitem
function model:RegisterCoreUseItems()
    for itemName in pairs(Config.Painkiller) do
        core.registerUseItem(itemName, function(item, ...)
            return self:UsePainkiller(item, ...)
        end)
    end

    for itemName in pairs(Config.Armor) do
        core.registerUseItem(itemName, function(item, ...)
            return self:UseArmor(item, ...)
        end)
    end

    for itemName in pairs(Config.Aed) do
        core.registerUseItem(itemName, function(item, ...)
            return self:UseAed(item, ...)
        end)
    end
end

function model:BindServerUseEvents()
    RegisEvent(GetName("client", "painkiller"), function(item)
        core.useItem(item)
    end)

    RegisEvent(GetName("client", "armor"), function(item)
        core.useItem(item)
    end)

    RegisEvent(GetName("client", "aed"), function(item)
        core.useItem(item)
    end)
end
