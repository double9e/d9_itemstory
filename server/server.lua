ESX = exports["es_extended"]:getSharedObject()

CreateThread(function()
	model:Init()
end)

function model:Init()
	lib.callback.register(GetName("callback", "removeItem"), function(source, item, kind)
		return model:RemoveItem(source, item, kind)
	end)

	RegisEvent(GetName("server", "removeItem"), function(item)
		local source = source
		model:RemoveItem(source, item, "aed")
	end)

	RegisEvent(GetName("server", "revivePlayer"), function(target, health, item)
		local source = source
		if source <= 0 or source == 65535 then
			return
		end
		if self:IsThrottled(source, "aed_revive", 1000) then
			return
		end

		target = tonumber(target)
		health = tonumber(health) or Config.Function.GetReviveHealth(xData)
		if not target or target <= 0 or target == source then
			return
		end
		if not GetPlayerName(target) then
			return
		end

		if type(item) ~= "string" or item == "" or #item > 64 then
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
		if not self:DistanceOk(source, target, Config.Function.GetServerReviveDistance(xData)) then
			return
		end

		log("RevivePlayer", item, target, health)
		Config.Function.CallReviveFunction(xData, target, health)
	end)
end
