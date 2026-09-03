Config = Config or {}

Config.Debug = false

--- ค่าเริ่มต้นเมื่อ config ไม่ได้กำหนด (รองรับ config เก่า)
Config.Defaults = {
	AedHealth = 150,
	AedClientDistance = 2.0,
	AedServerDistance = 3.0,
	PainkillerProp = "prop_ld_health_pack",
}

Config.Painkiller = {
	Painkiller = {
		Time = 3000,
		-- Job = {},
		Health = 40,
		Remove = true,
		InVehicle = false,
		Anim = {
			Dict = "anim@heists@narcotics@funding@gang_idle",
			Name = "gang_chatting_idle01",
		},
	},
}

Config.Aed = {
	AED = {
		Time = 12000,
		-- Job = {},
		Remove = true,
		Anim = {
			Dict = "mini@cpr@char_a@cpr_str",
			Name = "cpr_pumpchest",
			Flag = 0,
		},
		ReviveFunction = function(target)
			log("Reviving with AED for target: " .. tostring(target))
			TriggerClientEvent("esx_ambulancejob:revive", target)
		end,
		Marker = {
			Type = 20,
			Color = { r = 37, g = 135, b = 222, a = 170 },
			Scale = { x = 0.5, y = 0.5, z = 0.5 },
			rot = { x = 0.0, y = 0.0, z = 0.0 },
		},
	},
}

Config.Armor = {
	armor = {
		Time = 4000,
		Armor = 100,
		-- Job = {},
		Remove = true,
		InVehicle = false,
		Anim = {
			Dict = "clothingshirt",
			Name = "try_shirt_positive_d",
			Flag = 48,
		},
	},
}
