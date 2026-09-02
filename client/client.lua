ESX = exports["es_extended"]:getSharedObject()

core.loaded.AwaitPlayerLoaded(function()
    model:init()
end, CreateThread)

function model:UsePainkiller(item)
    if not self:CanUseItem(item, Config.Painkiller) then
        return false
    end

    local xData = Config.Painkiller[item]

    local playerPed = PlayerPedId()
    if xData.InVehicle and IsPedInAnyVehicle(playerPed, true) then
        return false
    end
    if self.status.painkiller then
        return false
    end
    if not self:CheckJob(xData.Job) then
        return false
    end

    log("Painkiller used:", item)
    self.caches.painkiller = xData
    self.status.painkiller = true

    if xData.Anim then
        self:PlayerAnim(xData.Anim.Dict, xData.Anim.Name, xData.Anim.Flag)
    end

    Wait(xData.Time)

    playerPed = PlayerPedId()
    if not self.status.aed and xData.Anim then
        StopAnimTask(playerPed, xData.Anim.Dict, xData.Anim.Name, 6.0)
    end

    if not self.IsDead and xData.Health then
        SetEntityHealth(playerPed, GetEntityHealth(playerPed) + xData.Health)
    end

    self:ClearUse("painkiller")
    return true
end

function model:UseArmor(item)
    if not self:CanUseItem(item, Config.Armor) then
        return false
    end

    local xData = Config.Armor[item]

    local playerPed = PlayerPedId()
    if xData.InVehicle and IsPedInAnyVehicle(playerPed, true) then
        return false
    end
    if self.status.armor then
        return false
    end
    if not self:CheckJob(xData.Job) then
        return false
    end

    log("Armor used:", item)
    self.caches.armor = xData
    self.status.armor = true

    if xData.Anim then
        self:PlayerAnim(xData.Anim.Dict, xData.Anim.Name, xData.Anim.Flag)
    end

    Wait(xData.Time)

    playerPed = PlayerPedId()
    if not self.status.aed and xData.Anim then
        StopAnimTask(playerPed, xData.Anim.Dict, xData.Anim.Name, 6.0)
    end

    if not self.IsDead and xData.Armor then
        AddArmourToPed(playerPed, xData.Armor)
    end

    self:ClearUse("armor")
    return true
end

function model:UseAed(item)
    if not self:CanUseItem(item, Config.Aed) then
        return false
    end

    if self.Cooldown.aed or self.status.aed then
        return false
    end

    local xData = Config.Aed[item]

    local playerPed = PlayerPedId()
    if xData.InVehicle and IsPedInAnyVehicle(playerPed, true) then
        return false
    end
    if not self:CheckJob(xData.Job) then
        return false
    end

    local sid, isDead, closestPlayer = self:GetNearbyPlayer(2.0)
    if not isDead or closestPlayer == -1 or not sid then
        return false
    end

    log("Aed used:", item)
    self.caches.aed = xData
    self.status.aed = true
    self.Cooldown.aed = true

    if xData.Marker then
        local closestPlayerPed = GetPlayerPed(closestPlayer)
        local marker = xData.Marker
        CreateThread(function()
            while self.status.aed do
                if DoesEntityExist(closestPlayerPed) then
                    local coords = GetEntityCoords(closestPlayerPed)
                    DrawMarker(
                        marker.Type,
                        coords.x,
                        coords.y,
                        coords.z + 0.5,
                        0.0,
                        0.0,
                        0.0,
                        marker.rot.x,
                        marker.rot.y,
                        marker.rot.z,
                        marker.Scale.x,
                        marker.Scale.y,
                        marker.Scale.z,
                        marker.Color.r,
                        marker.Color.g,
                        marker.Color.b,
                        marker.Color.a,
                        false,
                        true,
                        2,
                        false,
                        nil,
                        nil,
                        false
                    )
                end
                Wait(0)
            end
        end)
    end

    local anim = xData.Anim
    local completed = lib.progressBar({
        duration = xData.Time,
        label = "AED",
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            combat = false,
        },
        anim = anim and {
            dict = anim.Dict,
            clip = anim.Name,
            flag = anim.Flag or 1,
        } or nil,
    })

    playerPed = PlayerPedId()
    local ok = false
    if completed and not IsEntityDead(playerPed) and self.status.aed then
        if not IsPedInAnyVehicle(playerPed, true) then
            TriggerServerEvent(GetName("server", "reviveTarget"), item, sid)
            log("AED completed")
            ok = true
        end
    elseif anim then
        StopAnimTask(playerPed, anim.Dict, anim.Name, 6.0)
        ClearPedTasks(playerPed)
    end

    self:ClearUse("aed")
    SetTimeout(500, function()
        self.Cooldown.aed = false
    end)
    return ok
end

function model:init()
    self:RegisterCoreUseItems()
    self:BindServerUseEvents()

    AddEventHandler("esx:onPlayerDeath", function()
        self.IsDead = true
        core.disableUseItem()
    end)

    AddEventHandler("esx:onPlayerSpawn", function()
        self.IsDead = false
        core.enableUseItem()
    end)
end
