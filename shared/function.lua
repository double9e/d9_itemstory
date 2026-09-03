shared = shared or {}

local ResourceName = GetCurrentResourceName()

function GetName(side, action)
	return ("%s:%s:%s"):format(ResourceName, side, action)
end

function RegisEvent(name, handler)
	RegisterNetEvent(name)
	return AddEventHandler(name, handler)
end

function log(...)
	if Config.Debug then
		print(...)
	end
end

---@param serverId number
---@return boolean
function CheckPlayerDead(serverId)
	if type(serverId) ~= "number" or serverId <= 0 then
		return false
	end

	local player = Player(serverId)
	if player and player.state.isdead then
		return true
	end

	local playerIdx = GetPlayerFromServerId(serverId)
	if playerIdx == -1 then
		return false
	end

	return IsEntityDead(GetPlayerPed(playerIdx))
end

function IsLocalPlayerDead()
	if LocalPlayer.state.isdead then
		return true
	end
	if core and core.player and core.player.isDead then
		return core.player.isDead
	end
	return IsEntityDead(PlayerPedId())
end
