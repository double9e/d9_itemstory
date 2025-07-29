--- 
-- Model table for storing status flags.
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
    }
}

---
-- Get the status value for a given key.
-- @param value string ชื่อของสถานะที่ต้องการดึงค่า ('painkiller', 'aed', หรือ 'armor')
-- @return boolean ค่าสถานะ (true/false) หรือ false หากไม่พบ
function model:GetStatus(value)
    return self.status[value] and self.status[value] or false
end

---
-- Exported function to get a status value.
-- @param value string ชื่อของสถานะที่ต้องการดึงค่า
-- @return boolean ค่าสถานะ (true/false) หรือ false หากไม่พบ
exports('GetStatus', function(value)
    return model:GetStatus(value)
end)

function model:LoadAnim(dict)
	local startTime = GetGameTimer()
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
		if GetGameTimer() - startTime > 2000 then
			print(("LoadAnim timeout: failed to load anim dict '%s' within 3 seconds."):format(dict))
			break
		end
	end
end

function model:PlayerAnim(dict, anim, Flag)
	self:LoadAnim(dict)
	TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, Flag or 0, 0, false, false, false)
end

function model:CheckJob(data)
	if data == nil then
		return true
	end
	for k, v in pairs(data) do
		if ESX.GetPlayerData().job.name == v then
			return true
		end
	end
	return false
end

function model:GetNearbyPlayer(distance)
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 then
		if distance and closestDistance <= distance then
			local sid = GetPlayerServerId(closestPlayer)
			local target = GetPlayerPed(closestPlayer)
			local isDead = IsEntityDead(target)
			return sid, isDead, closestPlayer
		end
		return false
	else
		return false
	end
end
