Config.Function = Config.Function or {}

Config.Function.ProgressBar = function(name, time)
	TriggerEvent("mythic_progbar:client:progress", {
		name = name,
		duration = time,
		label = name,
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = false,
		},
	}, function(status)
		log("ProgressBar status:", status, "for", name)
		if not status and not IsEntityDead(PlayerPedId()) then
			return true
		else
			return false
		end
	end)
end
