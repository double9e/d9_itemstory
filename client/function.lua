model = {
	IsDead = false,
	onRevive = false,
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
}

function model:GetStatus(value)
	return self.status[value] or false
end

exports("GetStatus", function(value)
	return model:GetStatus(value)
end)

function model:Notify(kind, text, title)
	if Config.Function and Config.Function.Notify then
		Config.Function.Notify(kind, text, title)
	end
end

function model:CheckJob(jobs)
	if jobs == nil then
		return true
	end

	local job = core.player and core.player.job
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

function model:HasItem(itemName, count)
	count = tonumber(count) or 1
	if core.player and core.player.hasItem then
		return core.player.hasItem(itemName, count)
	end
	return false
end

function model:IsInVehicle(ped)
	ped = ped or core.player and core.player.ped or PlayerPedId()
	return IsPedInAnyVehicle(ped, false)
end

function model:GetAedTarget(distance)
	local ped = core.player and core.player.ped or PlayerPedId()
	local coords = GetEntityCoords(ped)
	local targetPlayer = lib.getClosestPlayer(coords, distance or 2.0, false)
	if not targetPlayer then
		return nil, nil, nil
	end

	local targetPed = GetPlayerPed(targetPlayer)
	local targetSid = GetPlayerServerId(targetPlayer)
	return targetSid, targetPed, targetPlayer
end

function model:CanReviveTarget(targetPed, targetSid)
	if not targetPed or not targetSid then
		return false, "ไม่พบผู้เล่นใกล้ตัว"
	end

	if not CheckPlayerDead(targetSid) then
		return false, "ผู้เล่นยังมีชีวิตอยู่"
	end

	local dragSource = GetEntityAttachedTo(targetPed)
	if dragSource ~= 0 and IsPedInAnyVehicle(dragSource, false) then
		return false, "ไม่สามารถชุบผู้เล่นที่ถูกลากบนยานพาหนะได้"
	end

	return true
end

function model:ClearUse(kind)
	self.status[kind] = false
	self.caches[kind] = {}
	if kind == "aed" then
		self.onRevive = false
	end
end

function model:CanUseItem(item, configTable)
	return type(item) == "string" and configTable[item] ~= nil
end

function model:RequestRemoveItem(item, kind)
	return lib.callback.await(GetName("callback", "removeItem"), false, item, kind) == true
end

function model:PlayHeldProp(ped, propModel)
	if not propModel then
		return nil
	end

	lib.requestModel(propModel)
	local coords = GetEntityCoords(ped)
	local prop = CreateObject(joaat(propModel), coords.x, coords.y, coords.z, true, true, true)
	local boneIndex = GetPedBoneIndex(ped, 36029)
	AttachEntityToEntity(prop, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0, true, true, false, true, 1, true)
	return prop
end

function model:RunTimedHeal(kind, item, xData, applyEffect)
	if self.status[kind] then
		return false
	end

	local playerPed = core.player and core.player.ped or PlayerPedId()
	if xData.InVehicle and self:IsInVehicle(playerPed) then
		self:Notify("warning", "ไม่สามารถใช้งานในรถได้")
		return false
	end

	if not self:CheckJob(xData.Job) then
		self:Notify("warning", "อาชีพของคุณไม่สามารถใช้ไอเทมนี้ได้")
		return false
	end

	if not self:HasItem(item, 1) then
		self:Notify("warning", "คุณไม่มีไอเทมนี้")
		return false
	end

	if xData.Remove ~= false and not self:RequestRemoveItem(item, kind) then
		return false
	end

	self.status[kind] = true
	self.caches[kind] = xData

	CreateThread(function()
		local anim = xData.Anim
		local prop = nil
		local animFlag = Config.Function.GetAnimFlag(anim, 0)

		ClearPedSecondaryTask(playerPed)

		if anim and anim.Dict and anim.Name then
			lib.requestAnimDict(anim.Dict)
			TaskPlayAnim(playerPed, anim.Dict, anim.Name, 8.0, -8.0, -1, animFlag, 0.0, false, false, false)
		end

		local propModel = Config.Function.GetHeldPropModel(xData, kind)
		if propModel then
			prop = self:PlayHeldProp(playerPed, propModel)
		end

		local duration = tonumber(xData.Time) or 3000
		local startedAt = GetGameTimer()
		while GetGameTimer() - startedAt <= duration do
			Wait(0)
		end

		if prop and DoesEntityExist(prop) then
			DeleteEntity(prop)
		end

		if not self.IsDead and not IsLocalPlayerDead() then
			applyEffect(playerPed, xData)
		end

		if anim and anim.Dict then
			ClearPedSecondaryTask(playerPed)
			RemoveAnimDict(anim.Dict)
			StopAnimTask(playerPed, anim.Dict, anim.Name, 6.0)
		end

		self:ClearUse(kind)
	end)

	return true
end

function model:RunAedProgress(xData, targetSid, targetPed, item)
	local ped = core.player and core.player.ped or PlayerPedId()
	local anim = xData.Anim
	local animDict = anim and anim.Dict or "mini@cpr@char_a@cpr_str"
	local animName = anim and anim.Name or "cpr_pumpchest"
	local animFlag = Config.Function.GetAnimFlag(anim, 1)
	local lastPlayAnim = GetGameTimer()
	local reviveHealth = Config.Function.GetReviveHealth(xData)

	lib.requestAnimDict(animDict)
	TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, animFlag, 0.0, false, false, false)

	self:StartAedMarker(xData, targetPed)

	local action = {
		name = "d9_itemstory_aed",
		duration = tonumber(xData.Time) or 12000,
		label = "กำลังชุบผู้เล่น...",
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = false,
		},
	}

	local started = core.progressWithStartAndTick(action, function()
		lastPlayAnim = GetGameTimer()
		TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, animFlag, 0.0, false, false, false)
		log('play anim 1')
	end, function()
		if GetGameTimer() - lastPlayAnim > 900 then
			lastPlayAnim = GetGameTimer()
			TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, animFlag, 0.0, false, false, false)
			log('play anim loop')
		end
	end, function(cancelled)
		self.onRevive = false
		self:ClearUse("aed")

		if not IsPedRunningRagdollTask(ped) then
			ClearPedTasks(ped)
		end

		StopAnimTask(ped, animDict, animName, 6.0)

		if cancelled or self.IsDead or IsLocalPlayerDead() or self:IsInVehicle(ped) then
			return
		end

		if not CheckPlayerDead(targetSid) then
			self:Notify("warning", "ผู้เล่นยังมีชีวิตอยู่")
			return
		end

		TriggerServerEvent(GetName("server", "revivePlayer"), targetSid, reviveHealth, item)

		if xData.Remove ~= false then
			TriggerServerEvent(GetName("server", "removeItem"), item)
		end
	end)

	if not started then
		self.onRevive = false
		self:ClearUse("aed")
		RemoveAnimDict(animDict)
		return false
	end

	return true
end

function model:RegisterCoreUseItems()
	for itemName in pairs(Config.Painkiller) do
		core.registerUseItem(itemName, function(item)
			self:UsePainkiller(item)
		end)
	end

	for itemName in pairs(Config.Armor) do
		core.registerUseItem(itemName, function(item)
			self:UseArmor(item)
		end)
	end

	for itemName in pairs(Config.Aed) do
		core.registerUseItem(itemName, function(item)
			self:UseAed(item)
		end)
	end
end

function model:StartAedMarker(xData, targetPed)
	if not xData.Marker or not targetPed then
		return
	end

	local marker = xData.Marker
	CreateThread(function()
		while self.status.aed do
			if DoesEntityExist(targetPed) then
				local coords = GetEntityCoords(targetPed)
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
