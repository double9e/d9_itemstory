Config.Function = Config.Function or {}

local defaults = Config.Defaults or {}

---@param kind "info"|"success"|"warning"|"error"
---@param text string
---@param title string?
function Config.Function.Notify(kind, text, title)
	if not core or not core.notifyAlert then
		return
	end

	local notifyType = "info"
	if kind == "success" then
		notifyType = "success"
	elseif kind == "warning" or kind == "error" then
		notifyType = "warning"
	end

	core.notifyAlert({
		type = notifyType,
		title = title or "ITEM",
		text = text or "",
		position = "top-right",
		duration = 3500,
	})
end

---@param xData table
---@return number
function Config.Function.GetReviveHealth(xData)
	local health = xData and tonumber(xData.Health)
	if health and health > 0 then
		return health
	end
	return tonumber(defaults.AedHealth) or 150
end

---@param xData table
---@return number
function Config.Function.GetClientReviveDistance(xData)
	local distance = xData and tonumber(xData.Distance)
	if distance and distance > 0 then
		return distance
	end
	return tonumber(defaults.AedClientDistance) or 2.0
end

---@param xData table
---@return number
function Config.Function.GetServerReviveDistance(xData)
	local distance = xData and tonumber(xData.Distance)
	if distance and distance > 0 then
		return distance
	end
	return tonumber(defaults.AedServerDistance) or 3.0
end

---@param anim table|nil
---@param fallback number?
---@return number
function Config.Function.GetAnimFlag(anim, fallback)
	if type(anim) == "table" and anim.Flag ~= nil then
		return anim.Flag
	end
	return fallback or 0
end

---@param xData table
---@param kind "painkiller"|"armor"
---@return string|nil
function Config.Function.GetHeldPropModel(xData, kind)
	if type(xData) ~= "table" or xData.Prop == false then
		return nil
	end

	if type(xData.PropModel) == "string" and xData.PropModel ~= "" then
		return xData.PropModel
	end

	if xData.UseProp == true then
		return defaults.PainkillerProp or "prop_ld_health_pack"
	end

	return nil
end

--- รองรับ ReviveFunction แบบเก่า (target) และแบบใหม่ (target, health)
---@param xData table
---@param target number
---@param health number
function Config.Function.CallReviveFunction(xData, target, health)
	local reviveFn = xData and xData.ReviveFunction
	if type(reviveFn) ~= "function" then
		TriggerClientEvent("esx_ambulancejob:revive", target, health)
		return
	end

	local ok = pcall(reviveFn, target, health)
	if not ok then
		pcall(reviveFn, target)
	end
end

return Config.Function
