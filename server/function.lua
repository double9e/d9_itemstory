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

function model:GetItemConfig(item, kind)
	if kind == "painkiller" then
		return Config.Painkiller[item]
	end
	if kind == "armor" then
		return Config.Armor[item]
	end
	if kind == "aed" then
		return Config.Aed[item]
	end
	return nil
end

---@param source number
---@param item string
---@param kind? "painkiller"|"armor"|"aed"
---@return boolean
function model:RemoveItem(source, item, kind)
	if source <= 0 or source == 65535 then
		return false
	end
	if self:IsThrottled(source, "remove_" .. (kind or item), 500) then
		return false
	end

	if type(item) ~= "string" or item == "" or #item > 64 then
		return false
	end

	local xData = kind and self:GetItemConfig(item, kind) or Config.Aed[item]
	if not xData then
		return false
	end

	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return false
	end
	if not self:HasJob(xPlayer, xData.Job) then
		return false
	end
	if not self:HasItem(xPlayer, item) then
		return false
	end
	if self:InBlockedVehicle(source, xData.InVehicle) then
		return false
	end

	if xData.Remove == false then
		return true
	end

	xPlayer.removeInventoryItem(item, 1)
	log("RemoveItem", item, source)
	return true
end

AddEventHandler("playerDropped", function()
	model.Throttle[source] = nil
end)
