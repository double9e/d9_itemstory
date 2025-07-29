ESX = exports["es_extended"]:getSharedObject()
local ResourceName = GetCurrentResourceName()

GetName = function(a, b)
	return string.format("%s:%s:%s", ResourceName, a, b)
end

RegisEvent = function(n, h)
	return RegisterNetEvent(n), AddEventHandler(n, h)
end

ispressed = function(input, key)
	return IsControlPressed(input, key) or IsDisabledControlPressed(input, key)
end

Eventnui = function(event, data)
	SendNUIMessage({
		event = event,
		data = data,
	})
end


Citizen.CreateThread(function()
	while NetworkIsPlayerActive(PlayerId()) ~= 1 do
		Citizen.Wait(0)
	end
	Citizen.Wait(1000)
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	ESX.PlayerData = ESX.GetPlayerData()
	model:init()
end)

function model:init()
	AddEventHandler("esx:onPlayerDeath", function(data)
		self.IsDead = true
	end)

	AddEventHandler("playerSpawned", function()
		self.IsDead = false
	end)

	RegisEvent(GetName('cl', 'Painkiller'), function(item)
		log('Painkiller used: ' .. item)
		local PlayerPed = PlayerPedId()
		if not Config.Painkiller[item] then
			log("Painkiller item not found: " .. item)
		end

		local xData = Config.Painkiller[item]

		if xData.InVehicle and IsPedInAnyVehicle(PlayerPed, true) then
			return
		end

		if self.status.painkiller then
			log("Already using painkiller")
			return
		end

		if not model:CheckJob(xData.Job) then
			log("Job not allowed to use painkiller")
			return
		end

		if xData.Remove then
			TriggerServerEvent(GetName('sv','removeItem'), item)
		end

		self.caches.painkiller = xData
		self.status.painkiller = true
		if xData.Anim then
			model:PlayerAnim(xData.Anim.Dict, xData.Anim.Name, xData.Anim.Flag)
		end
		Citizen.Wait(xData.Time)
		if not self.status.aed and xData.Anim then
			StopAnimTask(PlayerPed, xData.Anim.Dict, xData.Anim.Name, 6.0)
		end
		if not self.IsDead then
			SetEntityHealth(Ped, GetEntityHealth(PlayerPedId()) + xData.Health)
			self.status.painkiller = false
			self.caches.painkiller = {}
		end

	end)

	RegisEvent(GetName('cl', 'Armor'), function(item)
		log('Armor used: ' .. item)
		local PlayerPed = PlayerPedId()
		if not Config.Armor[item] then
			log("Armor item not found: " .. item)
		end

		local xData = Config.Armor[item]

		if xData.InVehicle and IsPedInAnyVehicle(PlayerPed, true) then
			return
		end

		if self.status.armor then
			log("Already using Armor")
			return
		end

		if not model:CheckJob(xData.Job) then
			log("Job not allowed to use Armor")
			return
		end

		if xData.Remove then
			TriggerServerEvent(GetName('sv','removeItem'), item)
		end

		self.caches.armor = xData
		self.status.armor = true
		if xData.Anim then
			model:PlayerAnim(xData.Anim.Dict, xData.Anim.Name, xData.Anim.Flag)
		end
		Citizen.Wait(xData.Time)
		if not self.status.aed and xData.Anim then
			StopAnimTask(PlayerPed, xData.Anim.Dict, xData.Anim.Name, 6.0)
		end
		if not self.IsDead then
			AddArmourToPed(PlayerPedId(), xData.Armor)
			self.status.armor = false
			self.caches.armor = {}
		end

	end)

	RegisEvent(GetName('cl', 'Aed'), function(item)
		log("Aed used: " .. item)

		if self.Cooldown.aed then
			log("Aed is on cooldown")
			return
		end

		local PlayerPed = PlayerPedId()
		if not Config.Aed[item] then
			log("Aed item not found: " .. item)
		end

		local xData = Config.Aed[item]

		if xData.InVehicle and IsPedInAnyVehicle(PlayerPed, true) then
			return
		end

		if self.status.aed then
			log("Already using Aed")
			return
		end

		if not model:CheckJob(xData.Job) then
			log("Job not allowed to use Aed")
			return
		end


		local sid, isDead, closestPlayer = model:GetNearbyPlayer(2.0)
		if not isDead or closestPlayer == -1 then
			return
		end

		
		self.caches.aed = xData
		self.status.aed = true
		self.Cooldown.aed = true

		if xData.Marker then
			local closestPlayerPed = GetPlayerPed(closestPlayer)
			Citizen.CreateThread(function()
				while self.status.aed do
					local coords = GetEntityCoords(closestPlayerPed)
					DrawMarker(
						xData.Marker.Type, coords.x, coords.y, coords.z + 0.5,
						0.0, 0.0, 0.0,
						xData.Marker.rot.x, xData.Marker.rot.y, xData.Marker.rot.z,
						xData.Marker.Scale.x, xData.Marker.Scale.y, xData.Marker.Scale.z,
						xData.Marker.Color.r, xData.Marker.Color.g, xData.Marker.Color.b, xData.Marker.Color.a,
						false, true, 2, false, nil, nil, false
					)
					Citizen.Wait(1)
				end
			end)
		end


		if xData.Anim then
			local cancle = false

			TriggerEvent("mythic_progbar:client:progress", {
				name = 'AED',
				duration = xData.Time,
				label = 'AED',
				useWhileDead = false,
				canCancel = true,
				controlDisables = {
					disableMovement = false,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},
			}, function(status)
				if not status and not IsEntityDead(PlayerPedId()) then 
					ClearPedTasks(PlayerPed)
					log('status:', status, 'for AED')
					if not self.status.aed then
						log("AED already cancelled")
						return
					end
					if IsPedInAnyVehicle(PlayerPed, true) then
						log("AED animation started")
						return
					end
					if xData.Remove then
						TriggerServerEvent(GetName("sv", "removeItem"), item)
					end
					TriggerServerEvent(GetName('sv', 'ReviveTarget'), item, sid)
					log("AED animation completed")
					self.status.aed = false
					self.caches.aed = {}
				else
					cancle = true
					self.status.aed = false
					self.caches.aed = {}
					-- ClearPedTasks(PlayerPed)
					StopAnimTask(PlayerPed, xData.Anim.Dict, xData.Anim.Name, 6.0)

				end
				self.status.aed = false
				self.caches.aed = {}
				SetTimeout(500, function()
					self.Cooldown.aed = false
				end)
			end)
			model:PlayerAnim(xData.Anim.Dict, xData.Anim.Name, xData.Anim.Flag)
			for i = 1, xData.Time/1000, 0.9 do
				log('AED animation loop:', i)
				if cancle then
					StopAnimTask(PlayerPed, xData.Anim.Dict, xData.Anim.Name, 6.0)
					ClearPedTasks(PlayerPed)
					break
				end
				Citizen.Wait(900)
				if not cancle then
					TaskPlayAnim(PlayerPedId(), xData.Anim.Dict, xData.Anim.Name, 8.0, -8.0, -1, 0, 0, false, false, false)
				end
			end
		end


	end)
end