
Items = {}

weapon_ammos = {
	["WEAPON_PISTOL_AMMO"] = {
		"WEAPON_PISTOL",
		"WEAPON_PISTOL_MK2",
		"WEAPON_APPISTOL",
		"WEAPON_HEAVYPISTOL",
		"WEAPON_SNSPISTOL",
		"WEAPON_SNSPISTOL_MK2",
		"WEAPON_VINTAGEPISTOL",
		"WEAPON_PISTOL50",
		"WEAPON_REVOLVER",
		"WEAPON_COMBATPISTOL",
	},
	["WEAPON_SMG_AMMO"] = {
		"WEAPON_COMPACTRIFLE",
		"WEAPON_MICROSMG",
		"WEAPON_MINISMG",
		"WEAPON_SMG",
		"WEAPON_ASSAULTSMG",
		"WEAPON_GUSENBERG",
		"WEAPON_MACHINEPISTOL",
		"WEAPON_COMBATPDW"
	},
	["WEAPON_RIFLE_AMMO"] = {
		"WEAPON_CARBINERIFLE",
		"WEAPON_ASSAULTRIFLE",
		"WEAPON_SPECIALCARBINE",
		"WEAPON_ASSAULTRIFLE_MK2",
		"WEAPON_CARBINERIFLE_MK2",
        "WEAPON_SPECIALCARBINE_MK2",
		"WEAPON_FNFAL",
		"WEAPON_M6IC",
		"WEAPON_PARAFAL"
	},
	["WEAPON_SHOTGUN_AMMO"] = {
		"WEAPON_PUMPSHOTGUN",
		"WEAPON_SAWNOFFSHOTGUN",
	},
	["WEAPON_PETROLCAN_AMMO"] = {
		"WEAPON_PETROLCAN",
	}
}

if IsDuplicityVersion() then 
    RegisterCommand('rscuba', function(source,args)
        local user_id = vRP.getUserId(source)
        if user_id then
            local ok = vRP.request(source, "Você deseja retirar a sua scuba?", 30)
            if ok and (GetEntityHealth(GetPlayerPed(source)) > 102) then
                if Remote.checkScuba(source) then
                    Remote._setScuba(source, false)
                    TriggerClientEvent("Notify",source,"negado","Você retirou sua scuba, não conseguimos recuperar ela houve um vazamento.", 5000)
                else
                    TriggerClientEvent("Notify",source,"negado","Você não possui scuba equipada.", 5000)
                end
            end
        end
    end)
end

function itemBodyList(item)
	if Items[item] then
		return Items[item]
	end
end

function itemIndexList(item)
	if Items[item] then
		return Items[item].index
	end
end

function itemImageList(item)
	if Items[item] then
        if Items[item].png then
            return Items[item].png
        end
        return Items[item].index
    end
end

function itemList(item)
	if Items[item] then
		return Items[item].name
	end
	return "Deleted"
end

function itemTypeList(item)
	if Items[item] then
		return Items[item].type
	end
end

function itemAmmoList(item)
	if Items[item] then
		return Items[item].ammo
	end
end

function itemWeightList(item)
	if Items[item] then
		return Items[item].weight
	end
	return 0
end
