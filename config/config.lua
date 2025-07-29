Config = Config or {}

Config.Debug = false

Config.Painkiller = {
    Painkiller = {
        Time = 3000,
        -- Job = {},
        Health = 40,
        Remove = true,
        InVehicle = false,
        Anim = {
            Dict = "anim@heists@narcotics@funding@gang_idle",
            Name = "gang_chatting_idle01"
        }
    }
}

Config.Aed = {
    AED = {
        Time = 12000,
        -- Job = {},
        Remove = true,
        Anim = {
            Dict = "mini@cpr@char_a@cpr_str",
            Name = "cpr_pumpchest",
            Flag = 1
        },
        ReviveFunction = function(Target)
            log('Reviving with AED for target: ' .. tostring(Target))
            TriggerClientEvent('esx_ambulancejob:revive', Target)
        end,
        Marker = {
            Type = 20,
            Color = { r = 37, g = 135, b = 222, a = 170 },
            Scale = { x = 0.5, y = 0.5, z = 0.5 },
            rot = { x = 0.0, y = 0.0, z = 0.0 }
        }
    }
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
            Flag = 48
        },
    }
}