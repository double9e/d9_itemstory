core.loaded.AwaitPlayerLoaded(function()
	model:init()
end, CreateThread)

function model:UsePainkiller(item)
	if not self:CanUseItem(item, Config.Painkiller) then
		return false
	end

	local xData = Config.Painkiller[item]
	return self:RunTimedHeal("painkiller", item, xData, function(playerPed, data)
		if data.Health then
			SetEntityHealth(playerPed, GetEntityHealth(playerPed) + data.Health)
		end
		log("Painkiller used:", item)
	end)
end

function model:UseArmor(item)
	if not self:CanUseItem(item, Config.Armor) then
		return false
	end

	local xData = Config.Armor[item]
	return self:RunTimedHeal("armor", item, xData, function(playerPed, data)
		if data.Armor then
			AddArmourToPed(playerPed, data.Armor)
		end
		log("Armor used:", item)
	end)
end

function model:UseAed(item)
	if not self:CanUseItem(item, Config.Aed) then
		return false
	end

	if IsLocalPlayerDead() or self.onRevive or self.status.aed then
		return false
	end

	local xData = Config.Aed[item]
	local ped = PlayerPedId()

	if xData.InVehicle and self:IsInVehicle(ped) then
		self:Notify("warning", "ไม่สามารถชุบบนยานพาหนะได้")
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

	local targetSid, targetPed = self:GetAedTarget(Config.Function.GetClientReviveDistance(xData))
	local canRevive, reason = self:CanReviveTarget(targetPed, targetSid)
	if not canRevive then
		self:Notify("warning", reason or "ไม่สามารถชุบผู้เล่นนี้ได้")
		return false
	end

	log("Aed used:", item, targetSid)
	self.caches.aed = xData
	self.status.aed = true
	self.onRevive = true
	self:Notify("info", "กำลังชุบผู้เล่น")

	return self:RunAedProgress(xData, targetSid, targetPed, item)
end

function model:init()
	self:RegisterCoreUseItems()

	AddEventHandler("esx:onPlayerDeath", function()
		self.IsDead = true
		core.disableUseItem()
		if core.progressIsDoingAction and core.progressIsDoingAction() then
			core.progressCancel()
		end
	end)

	AddEventHandler("esx:onPlayerSpawn", function()
		self.IsDead = false
		core.enableUseItem()
	end)
end
