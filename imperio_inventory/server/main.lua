Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
Tools = module("vrp","lib/Tools")
Resource = GetCurrentResourceName()
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
RegisterTunnel = {}
Tunnel.bindInterface(Resource, RegisterTunnel)

local arena = Tunnel.getInterface("imperio_arena")
local func = exports["vrp"]

vTunnel = Tunnel.getInterface(Resource)

local idgens = Tools.newIDGenerator()

local vehList = {}

local OpennedVehicle = {}

local OpennedOrg = {}

local OpennedChestUser = {}

local OpennedHouse = {}

dataVehicle = {}

dataHouseChest = {}

dataOrgChest = {}

local classWeapons = {
	["WEAPON_SNSPISTOL_MK2"] = "PISTOLAS",
	["WEAPON_PISTOL_MK2"] = "PISTOLAS",
	["WEAPON_COMBATPISTOL"] = "PISTOLAS",
	["WEAPON_HEAVYPISTOL"] = "PISTOLAS",
	["WEAPON_PISTOL50"] = "PISTOLAS",
	["WEAPON_GUSENBERG"] = "SEMI-RIFLE",
	["WEAPON_MACHINEPISTOL"] = "SEMI-RIFLE",
	["WEAPON_SMG_MK2"] = "SEMI-RIFLE",
	["WEAPON_SMG"] = "SEMI-RIFLE",
	["WEAPON_ASSAULTSMG"] = "SEMI-RIFLE",
	["WEAPON_COMBATPDW"] = "SEMI-RIFLE",
	["WEAPON_SAWNOFFSHOTGUN"] = "SHOTGUN",
	["WEAPON_PUMPSHOTGUN_MK2"] = "SHOTGUN",
	["WEAPON_ASSAULTRIFLE"] = "RIFLE",
	["WEAPON_COMBATMG_MK2"] = "RIFLE",
	["WEAPON_ASSAULTRIFLE_MK2"] = "RIFLE",
	["WEAPON_SPECIALCARBINE_MK2"] = "RIFLE",
	["WEAPON_CARBINERIFLE"] = "RIFLE",
	["WEAPON_SPECIALCARBINE"] = "RIFLE",
	["WEAPON_STUNGUN"] = "STUNGUN",
    ["WEAPON_FNFAL"] = "RIFLE",
}

RegisterTunnel.getInventory = function()
    local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)

	if user_id then
		local inv = vRP.getInventory(user_id)
		local amountMoc = vRP.getMochilaAmount(user_id)
		if inv then
			local inventory = {}

			for k, v in pairs(inv) do
				if Items[v.item] then
					if (parseInt(v["amount"]) <= 0 or Items[v.item] == nil) then
						vRP.removeInventoryItem(user_id, v.item, parseInt(v["amount"]))
					else
						v["amount"] = parseInt(v["amount"])
						v["name"] = Items[v["item"]].name
						v["peso"] = Items[v["item"]].weight
						v["index"] = v["item"]
						v["key"] = v["item"]
						v["slot"] = k
						inventory[k] = v
					end
				end
			end

			return {inventory = inventory, weight = vRP.computeInvWeight(user_id), max_weight = vRP.getInventoryMaxWeight(user_id)}
		end
	end
end

ConfigServer = {
typeItens = {
    usar = "usar", -- Type dos itens normais
    recarregar = "recarregar", -- Type das munições
    equipar = "equipar", -- Type das armas
},
listaDeItens = {
["bombaadesiva"] = { index = "bombaadesiva", nome = "Bomba Adesiva", filtro = "box", type = "usar", funcao = false, descricao = "Bomba com cola, com grande quantidade de polvora!" },	
["serra"] = { index = "serra", nome = "Serra", filtro = "box", type = "usar", funcao = false, descricao = "Serra nova, geralmente utilizada para serrar grandes ferros/aços" },		
["furadeira"] = { index = "furadeira", nome = "Furadeira", filtro = "box", type = "usar", funcao = false, descricao = "Furadeira nova, geralmente utilizada para furar pequenos ferros/aços" },	
["bombaadesiva"] = { index = "bombaadesiva", nome = "Bomba Adesiva", filtro = "box", type = "usar", funcao = false, descricao = "Bomba com cola, com grande quantidade de polvora!" },	
["notebook"] = { index = "notebook", nome = "Notebook", filtro = "box", type = "usar", funcao = false, descricao = "Notebook novo ainda na garantia." },
["notebookroubado"] = { index = "notebookroubado", nome = "Notebook Roubado", filtro = "box", type = "usar", funcao = false, descricao = "Notebook Desbloqueado" },
["cartao"] = { index = "cartao", nome = "Cartão Limpo", filtro = "box", type = "usar", funcao = false, descricao = "Cartão Liso, sem identificação!" },
["cartao1"] = { index = "cartao1", nome = "Cartão Classic Clonado", filtro = "box", type = "usar", funcao = false, descricao = "Cartão Classic do Banco do Brasil, identificação desconhecida" },
["cartao2"] = { index = "cartao2", nome = "Cartão Gold Clonado", filtro = "box", type = "usar", funcao = false, descricao = "Cartão Gold do Banco do Brasil, identificação desconhecida" },
["cartao3"] = { index = "cartao3", nome = "Cartão Platinium Clonado", filtro = "box", type = "usar", funcao = false, descricao = "Cartão Platinium do Banco do Brasil, identificação desconhecida" },
["cartao4"] = { index = "cartao4", nome = "Cartão Black Clonado", filtro = "box", type = "usar", funcao = false, descricao = "Cartão Black do Banco do Brasil, identificação desconhecida" },


["suspensaoar"] = { index = "suspensaoar", nome = "Suspensão a Ar",filtro = "box", type = "usar", funcao = false, descricao = "Peça de suspensão a ar, aplicável em qualquer veículo!" },
["moduloxenon"] = { index = "moduloxenon", nome = "Módulo de Xenon",filtro = "box", type = "usar", funcao = false, descricao = "Módulo de Xenon, aplicável em qualquer veículo!" },
["moduloneon"] = { index = "moduloneon", nome = "Módulo de Neon",filtro = "box", type = "usar", funcao = false, descricao = "Módulo RGB de Neon, aplicável em qualquer veículo!" },
}
}

RegisterTunnel.getWeapons = function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        return vRPclient.getWeapons(source)
    end
end

function getWeaponMuni(weapon)
    for k,v in pairs(weapon_ammos) do
		for l,w in pairs(v) do
            if w == weapon then
                return k
	        end
		end
    end
end

RegisterTunnel.storeWeapons = function(weapon)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if not vRP.checkPatrulhamento(user_id) then
            local weapons = vRPclient.getWeapons(source)
            local mensagem = ''
            for k, v in pairs(weapon) do
                if weapons[v] then
                    if v == "WEAPON_STUNGUN" or v == "WEAPON_PETROLCAN" then
                        return { error = "Não é possivel guardar " .. vRP.getItemName(v) .. " na mochila.." }
                    else
                        vRP.giveInventoryItem(user_id, v, 1, true)
                        if weapons[v].ammo > 0 then
                            local ammo = string.gsub(v, "WEAPON_", "AMMO_")
                            vRP.giveInventoryItem(user_id, ammo, weapons[v].ammo, true)
                        end
                        if weapons[v].ammo > 0 then
                            mensagem = mensagem .. "(Arma: " .. v .. " Municao: " .. weapons[v].ammo .. "x) - "
                        else
                            mensagem = mensagem .. "(Arma: " .. v .. " Municao: 0x) - "
                        end
                        weapons[v] = nil
                    end
                else
                    return { error = "Você não possui essa arma." }
                end
            end
            vRPclient.replaceWeapons(source, weapons)
            vRP.sendLog("GARMAS", "O ID " .. user_id .. " guardou  [ " .. mensagem .. " ] ")
            return { success = "Você guardou seu armamento na mochila." }
        else
            return { error = "Você não pode guardar armas em patrulhamento." }
        end
    end
end


RegisterTunnel.swapSlot = function(slot, amount, targetslot)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local inv = vRP.getInventory(user_id)
        if inv[targetslot] then
            if inv[targetslot].item ~= inv[slot].item then
                if vRP.tryGetInventoryItem(user_id, inv[targetslot].item, inv[targetslot].amount, false, targetslot) then
                    if vRP.tryGetInventoryItem(user_id, inv[slot].item, inv[slot].amount, false, slot) then
                        vRP.giveInventoryItem(user_id, inv[targetslot].item, inv[targetslot].amount, false, slot)
                        vRP.giveInventoryItem(user_id, inv[slot].item, inv[slot].amount, false, targetslot)
                        return { error = "Item Com sucesso." }
                    end
                end
            else
                if vRP.tryGetInventoryItem(user_id, inv[slot].item, amount, false, slot) then
                    vRP.giveInventoryItem(user_id, inv[slot].item, amount, false, targetslot)
                    return { error = "Item Com sucesso." }
                end
            end
        else
            if vRP.tryGetInventoryItem(user_id, inv[slot].item, amount, false, slot) then
                vRP.giveInventoryItem(user_id, inv[slot].item, amount, false, targetslot)
                return { error = "Item Com sucesso." }
            end
        end
        return false
	end
end

RegisterTunnel.sendItem = function(slot, amount)
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local inv = vRP.getInventory(user_id)
        local nplayer = vRPclient.getNearestPlayer(source, 3)
        if not inv[slot] then return end
        if nplayer then
            local item = inv[slot].item
            local nuser_id = vRP.getUserId(nplayer)
            if vRP.computeInvWeight(nuser_id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(nuser_id) then
                if item == "money" or item == "dinheirosujo" then
                    if amount >= 15000000 then
                        vRP.setBanned(user_id, true)
                        DropPlayer(source, "Você foi banido do nosso servidor por enviar 15 milhões de dinheiro ou dinheirosujo ")
                        vRP.sendLog("ENVIAR","@everyone | O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .." na quantidade de " .. amount .. "x para o id " .. nuser_id .. " (SUSPEITO HACK)")
                    elseif amount >= 500000 then
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 4)
							vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Wait(3000)
							vRPclient._DeletarObjeto(source)
							vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","@everyone | O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    else
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 4)
                            vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Wait(3000)
							vRPclient._DeletarObjeto(source)
                            vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    end


                elseif item == "WEAPON_PISTOL_MK2" or item == "WEAPON_SPECIALCARBINE_MK2" or item == "WEAPON_ASSAULTRIFLE_MK2" then
                    if amount >= 9 then
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 4)
                            vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Wait(3000)
							vRPclient._DeletarObjeto(source)
                            vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","@everyone | O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    else
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 4)
                            vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Wait(3000)
							vRPclient._DeletarObjeto(source)
                            vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    end


                elseif vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                    func:setBlockCommand(user_id, 4)
                    vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
					Wait(3000)
					vRPclient._DeletarObjeto(source)
                    vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                   vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                    vRP.sendLog("ENVIAR","O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " .. nuser_id .. ".")
                    return { success = "Você enviou com sucesso" }
                end
            else
                return { error = "Mochila do jogador cheia." }
            end
        else
            return { error = "Nenhum jogador próximo." }
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE UTILIZAÇÃO DE ITENS INVENTÁRIO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function play_drink(source, tipo, segundos)
	local prop = ""
	-- BEBIDAS
	if tipo == "energetico" then
		prop = "prop_energy_drink"

	-- BEBIDAS ALCOLICAS
	elseif tipo == "cerveja" then
		prop = "prop_amb_beer_bottle"
	elseif tipo == "whisky" then
		prop = "prop_drink_whisky"
	elseif tipo == "vodka" then
		prop = "p_whiskey_notop" 
	elseif tipo == "pinga" then
		prop = "p_whiskey_notop" 
	elseif tipo == "corote" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "absinto" then
		prop = "prop_drink_whisky"
	elseif tipo == "skolb" then
		prop = "ng_proc_sodacan_01b"
	else
		prop = "prop_ld_flow_bottle"
	end
	
	vRPclient._CarregarObjeto(source,"mp_player_intdrink","loop_bottle",prop,49,60309)
    SetTimeout(segundos*1000, function() 
        vRPclient._DeletarObjeto(source)
        vRPclient._stopAnim(source, false)
    end)
end



RegisterTunnel.useItem = function(slot, amount)
    local source = source
	local user_id = vRP.getUserId(source)

	if user_id then
		local inv = vRP.getInventory(user_id)
		if inv then
			if not inv[tostring(slot)] or inv[tostring(slot)].item == nil then
				return
			end

			local item = inv[tostring(slot)].item
			local itemType = Items[item].tipo
            print("NKT", item, itemType)
			if itemType then
                if amount == nil or amount <= 0 then
                    amount = vRP.getInventoryItemAmount(user_id, item)
                end
                
                if itemType == "usar" then
                    if item == "mochila" then
                        local maxMochila = {}
                        maxMochila[user_id] = 3

                        if tonumber(maxMochila[user_id]) > tonumber(vRP.getMochilaAmount(user_id)) then
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.addMochila(user_id)
                                TriggerClientEvent("Notify", source, "aviso","Você equipou sua mochila.",5000)
                                TriggerClientEvent('closeInventory', source)
                                return { success = "Você equipou sua mochila." }
                            end
                        else
                            return { error = "Você já equipou o máximo de mochilas." }
                        end

                    elseif item == "colete" then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            func:setBlockCommand(user_id, 4)
                            vTunnel.blockButtons(source, true)
                            vRPclient._playAnim(source, true,{ { "oddjobs@basejump@ig_15","puton_parachute"}},false)
                            TriggerClientEvent('closeInventory', source)
                            TriggerClientEvent("progress", source, 4000)
                            SetTimeout(4000,function()
                                vTunnel.blockButtons(source, false)
                                vRPclient._stopAnim(source, true)
                                SetPedArmour(source,100)
                                TriggerClientEvent("Notify", source, "sucesso", "Você equipou seu colete com sucesso.",5000)
                            end)
                            return { success = "Colete colocado com sucesso." }
                        end

                    elseif item == "radio" then
                        if vRP.tryGetInventoryItem(user_id, item, 0, false, slot) then
                            TriggerClientEvent('closeInventory', source)
                            TriggerClientEvent('Nikito:OpenRadio', source)
                        return { success = "Você utilizou sua radio com sucesso." }
                    end

                    elseif item == "attachs" then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('closeInventory', source)
                            TriggerClientEvent("Weapon:Attachs", source)
                        end

                    elseif item == "capuz" then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            func:setBlockCommand(user_id, 6)
                            local nplayer = vRPclient.getNearestPlayer(source, 3)
                            if nplayer then
                                local nuser_id = vRP.getUserId(nplayer)

                                if vRPclient.isCapuz(nplayer) then
                                    vRPclient._setCapuz(nplayer, false)
                                    TriggerClientEvent("Notify", source, "sucesso","Você retirou o capuz desse jogador.", 6000)
                                else
                                    vRPclient._setCapuz(nplayer, true)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você colocou o capuz nesse jogador, para retirar use o item novamente.",6000)
                                end

                                vRP.sendLog("CAPUZ", "O USER_ID: " .. user_id .. " Usou o Capuz no USER_ID: " .. nuser_id)
                            else
                                TriggerClientEvent("Notify", source, "negado", "Nenhum jogador proximo.", 6000)
                                TriggerClientEvent('closeInventory', source)
                            end
                        end

                    elseif item == "maconha" or item == "cocaina" or item == "lsd" or item == "heroina" or item == "metanfetamina" or item == "lancaperfume" or item == "balinha" then
                        local fome, sede = vRP.itemFood(item)
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('closeInventory', source)
                            func:setBlockCommand(user_id, 15)
                            vTunnel.blockButtons(source, true)
                            vRPclient._playAnim(source, true, { { "anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3" } }, true)
                            TriggerClientEvent("progress", source, 15000)
                            SetTimeout(15000, function()vRP.varyThirst(user_id, tonumber(sede))
                                vTunnel._setEnergetico(source, true)
                                vRPclient._DeletarObjeto(source)
                                vRPclient._stopAnim(source, false)
                                vTunnel.blockButtons(source, false)
                                TriggerClientEvent("Notify", source, "sucesso", "Você usou uma droga, tome cuidado.", 5000)
                                SetTimeout(45000, function()
                                    vTunnel._setEnergetico(source, false)
                                    TriggerClientEvent("Notify", source, "successo", "Seu corpo voltou ao normal após o uso da droga. Tome cuidado da próxima vez.", 5000)
                                end)
                            end)
                        else
                            return { error = "Você não possui essa droga." }
                        end
                    

                    elseif item == "lockpick" then
                        local plate,mName,mNet,mPortaMalas,mPrice,mLock,mModel = vRPclient.ModelName(source, 7)
                        local plateUser = vRP.getUserByRegistration(plate)
                        local plyCoords = GetEntityCoords(GetPlayerPed(source))
                        local x,y,z = plyCoords[1],plyCoords[2],plyCoords[3]
                        if plateUser then
                            if mLock then
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    TriggerClientEvent('closeInventory', source)
                                    Wait(500)
                                    vTunnel._startAnimHotwired(source)
                                    
                                    vTunnel.blockButtons(source, true)
                                    local finished = vRPclient.taskBar(source, 2500, math.random(7, 15))
                                    if finished then
                                        local finished = vRPclient.taskBar(source, 1500, math.random(7, 15))
                                        if finished then
                                            local finished = vRPclient.taskBar(source, 1000, math.random(7, 15))
                                            if finished then
                                                local entity = NetworkGetEntityFromNetworkId(mNet)
                                                if entity then
                                                    SetVehicleDoorsLocked(entity,1)
                                                end
                                                TriggerClientEvent("vrp_sounds:source", source, "lock", 0.4)
                                                TriggerClientEvent( "Notify", source, "negado", "Você destrancou o veiculo, cuidado a policia foi acionada.", 6000 )
                                                vTunnel.blockButtons(source, false)
                                                vRP.sendLog("LOCKPICK", "**SUCESSO** O [ID: " .. user_id .. "] Roubou o veiculo " .. mModel .. "(ID:" .. plateUser .. ") nas nas cordenadas: " .. x .. "," .. y .. "," .. z )
                                            end
                                        end
                                    end

                                    exports['vrp']:alertPolice({x = x,y = y,z = z,blipID = 161,blipColor = 63,blipScale = 0.5,time = 20,code = "911",title = "Veiculo Roubado (" .. mModel .. ")",name = "Um novo registro de tentativa de roubo de veiculo, Modelo: " ..	mModel .. " Placa: " .. plate .. ". "})
                                    vRPclient._stopAnim(source, true)
                                    vTunnel._updateInventory(source, "updateMochila")
                                end
                            else
                                TriggerClientEvent('closeInventory', source)
                                TriggerClientEvent("Notify", source, "negado", "Este veiculo já está destracando.",6000)
                            end
                        else
                            TriggerClientEvent('closeInventory', source)
                            TriggerClientEvent("Notify", source, "negado", "Este veiculo não pode ser roubado.",6000)
                        end


                    elseif item == "repairkit" then
                        if not vRPclient.isInVehicle(source) then
                            local vehicle = vRPclient.getNearestVehicle(source, 3)
                            if vehicle then
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) or vRP.hasPermission(user_id, "perm.mecanica") then
                                    func:setBlockCommand(user_id, 30)
                                    vTunnel.blockButtons(source, true)
                                    vRPclient._playAnim(source, false, { { "mini@repair", "fixing_a_player" } }, true)
                                    TriggerClientEvent("progress", source, 30000)
                                    SetTimeout(30000, function()
                                        TriggerClientEvent("reparar", source, vehicle)
                                        vTunnel.blockButtons(source, false)
                                        TriggerClientEvent("Notify", source, "sucesso", "Você reparou o veiculo.", 5000)
                                        vRPclient._stopAnim(source, false) 
                                    end)
                                    return { success = "Veiculo reparado com sucesso." }
                                end
                            else
                                return { error = "Você precisa estar perto do veículo." }
                            end
                        else
                            return { error = "fique fora do veiculo para reparar." }
                        end


                    elseif item == "pneus" then
                        if not vRPclient.isInVehicle(source) then
                            local vehicle = vRPclient.getNearestVehicle(source, 3)
                            if vehicle then
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    func:setBlockCommand(user_id, 15)
                                    vTunnel.blockButtons(source, true)
                                    vRPclient._playAnim(source, false, { { "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer" } }, true)
                                    TriggerClientEvent("progress", source, 20000)
                                    SetTimeout(20000, function()
                                        TriggerClientEvent('repararpneus', source, vehicle)
                                        vTunnel.blockButtons(source, false)
                                        vRPclient._stopAnim(source, false)
                                        TriggerClientEvent("Notify", source, "sucesso", "Você reparou o pneu do veiculo.",6000)
                                        TriggerClientEvent('closeInventory', source)
                                    end)
                                end
                            else
                                return { error = "Chegue mais perto do veículo para trocar os pneus." }
                            end
                        end
                        return { success = "Você trocou o pneu do veículo" }
                    end
                end

                    if itemType == "beber" then
                        local fome, sede = vRP.itemFood(item)
                        if item == "energetico" then
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                TriggerClientEvent('closeInventory', source)
                                vTunnel.SetInventoryBlocked(source, 500000)
                                func:setBlockCommand(user_id, 10)
                                vTunnel.blockButtons(source, true)
                                play_drink(source, item, 10000 * amount)
                                TriggerClientEvent("progress", source, 10000)
                                SetTimeout(10000, function()vRP.varyThirst(user_id, tonumber(sede))
                                    vTunnel._setEnergetico(source, true)
                                    vTunnel.blockButtons(source, false)
                                    vRPclient._DeletarObjeto(source)
                                    vRPclient._stopAnim(source, false)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você tomou um energético.", 5000)
                                    vTunnel.SetInventoryBlocked(source, 0)
                                    SetTimeout(25000, function()
                                        vTunnel._setEnergetico(source, false)
                                        TriggerClientEvent("Notify", source, "negado", "O efeito do energético acabou.", 5000)
                                    end)
                                end)
                            end
                        end
                    end
            
                    if itemType == "comer" then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            local fome, sede = vRP.itemFood(item)
                            TriggerClientEvent('closeInventory', source)
                            vTunnel.SetInventoryBlocked(source, 5000000) --
                            func:setBlockCommand(user_id, 10)
                            vTunnel.blockButtons(source, true)
                            play_eat(source, item, 10000)
                        TriggerClientEvent("progress", source, 10000)
                            SetTimeout((10000), function()vRP.varyHunger(user_id, tonumber(fome) * 1)
                                vTunnel.blockButtons(source, false)
                                vTunnel.SetInventoryBlocked(source, 0) --
                                vRPclient._DeletarObjeto(source)
                                vRPclient._stopAnim(source, false)
                            end)
                            return { success = "Você comeu a comida." }
                        end
                    end
            
                    if itemType == "bebera" then
                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        vTunnel.SetInventoryBlocked(source, 5000000) --
                        play_drink(source, item, 10000 * amount)
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            SetTimeout(9500, function()
                                Tunnel.blockButtons(source, false)
                                vTunnel.SetInventoryBlocked(source, 0) --
                                vRPclient._DeletarObjeto(source)
                                vRPclient._stopAnim(source, false)
                            end)
                        end
                    end

                    if itemType == "remedio" then
                        if item == "bandagem" then
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                TriggerClientEvent('closeInventory', source)
                                vTunnel.SetInventoryBlocked(source, 50000000) --
                                func:setBlockCommand(user_id, 15)
                                vTunnel.blockButtons(source, true)
                                vRPclient._CarregarObjeto(source, "amb@world_human_clipboard@male@idle_a", "idle_c","v_ret_ta_firstaid", 49, 60309)
                                TriggerClientEvent("progress", source, 15000)
                                SetTimeout(15000, function()
                                    vTunnel.blockButtons(source, false)
                                    vTunnel.SetInventoryBlocked(source, 0) --
                                    vRPclient._DeletarObjeto(source)
                                    vTunnel._useBandagem(source)
                                    TriggerClientEvent("Notify", source, "aviso","Você utilizou a bandagem, não tome nenhum tipo de dano para não ser cancelada.",6000)
                                end)
                                return { success = "Você usou a bandagem." }
                            end
                        end
                    end

                if itemType == "usarVIP" then
                    if item == "alterarrg" then
                        TriggerClientEvent('closeInventory', source)
                        local numero = vRP.prompt(source, "Digite o numero: (MAX 6) (EXEMPLO: NIKITO)", "")
                        if numero ~= nil and numero ~= "" and numero and string.len(numero) == 6 then
                            if checkRG(numero) then
                                if vRP.request(source, "Tem certeza que deseja alterar seu rg para " .. numero .. " ?", 30) then
                                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                        vRP.execute("vRP/update_registro", { user_id = user_id, registro = numero })
                                        vRP.updateIdentity(user_id)
                                        TriggerClientEvent("Notify", source, "sucesso","Você trocou o seu rg para " ..numero .. ".", 15000)
                                    end
                                end
                            else
                                TriggerClientEvent("Notify", source, "negado", "Você não pode utilizar esse rg, pois ele já existe.", 5000)
                            end
                        else
                            TriggerClientEvent("Notify", source, "negado", "Você precisa Digitar o rg correto. (EXEMPLO: N1K1T0)", 5000)
                        end

                    elseif item == "cirurgia" then
                        if vRPclient.getHealth(source) <= 101 or vRPclient.isHandcuffed(source) or vTunnel.inVehicle(source) then
                            TriggerClientEvent('closeInventory', source)
                            TriggerClientEvent("Notify", source, "negado", "Você não pode fazer sua cirurgia agora.", 5000)
                        else
                            TriggerClientEvent('closeInventory', source)
                            local request = vRP.request(source, "Você deseja realizar a cirurgia agora?", 30)
                            if request then
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    TriggerClientEvent('closeInventory', source)
                                    TriggerEvent("Nikito:cirurgia", source)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você realizou sua cirurgia com sucesso.", 10000)
                                    return { success = "Você realizou sua cirurgia com sucesso." }
                                else
                                    TriggerClientEvent("Notify", source, "negado", "Você não possui o item cirurgia.", 10000)
                                end
                            else
                                TriggerClientEvent("Notify", source, "negado", "Você recusou fazer a cirurgia.", 10000)
                            end
                        end
                        
                    elseif item == "alterartelefone" then
                        TriggerClientEvent('closeInventory', source)
                        local numero = vRP.prompt(source, "Digite o numero: (MAX 6) (EXEMPLO: 123-456)", "")
                        if tonumber(numero) ~= nil and numero ~= "" and tonumber(numero) and string.len(numero) == 6 then
                            numero = formatNumber(numero)
                            if checkNumber(numero) then
                                if vRP.request(source, "Tem certeza que deseja alterar o numero de telefone para " .. numero .. " ?", 30) then
                                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                        vRP.execute("vRP/update_number", { user_id = user_id, telefone = numero })
                                        vRP.updateIdentity(user_id)
                                        TriggerClientEvent("Notify", source, "sucesso","Você trocou o numero de telefone para " ..numero .. ".", 15000)
                                    end
                                end
                            else
                                TriggerClientEvent("Notify", source, "negado", "Este numero de telefone ja existe.", 5000)
                                TriggerClientEvent('closeInventory', source)
                            end
                        else
                            TriggerClientEvent("Notify", source, "negado","Digite o numero de telefone correto. (EXEMPLO: 123456)", 5000)
                            TriggerClientEvent('closeInventory', source)
                        end
                    end
                end

                if itemType == "equipar" then

                    local data = vRP.getUserDataTable(user_id)
                    local myWeapons = data.weapons
                    local blockWeapons = {}
                    local bloqueado = false

                    for k, v in pairs(myWeapons) do
                        local categoria = classWeapons[k]
                        if categoria ~= nil then
                            blockWeapons[categoria] = true
                        end

                        local categoria2 = classWeapons[item]
                        if categoria2 ~= nil then
                            if blockWeapons[categoria2] ~= nil then
                                bloqueado = true
                            end
                        end
                    end

                    if not bloqueado then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then

                            local weapons = {}
                            weapons[item] = { ammo = 0 }
                            vRPclient._giveWeapons(source, weapons)

                            vRP.sendLog("EQUIPAR", "O ID " .. user_id .." equipou a arma " .. vRP.getItemName(item) .. ".")
                            return { success = "Arma equipada com sucesso", used_amount = 1 }
                        end
                    else
                        return { error = "Você já possui uma arma dessa classe equipada!"}
                    end
                end

            
                if itemType == "recarregar" then

                    local weapon = string.gsub(item, "AMMO_", "WEAPON_")
                    local municao = vRPclient.getAmmo(source, weapon)
                    local maxMunicao = 250
                    if vRPclient.checkWeapon(source, weapon) then
                        if municao < 250 then
                            if maxMunicao <= amount then
                                maxMunicao = maxMunicao - municao
                                amount = maxMunicao
                            else
                                maxMunicao = maxMunicao - municao
                                if amount > maxMunicao then
                                amount = maxMunicao
                                end
                            end

                            if vRP.tryGetInventoryItem(user_id, item, amount, true, slot) then
                                local weapons = {}
                                weapons[weapon] = { ammo = amount }
                                vRPclient._giveWeapons(source, weapons, false)
                                vRP.sendLog("EQUIPAR","O ID " ..user_id .." recarregou a municao " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. " x.")
                                return { success = "Munição equipada com sucesso", used_amount = amount}
                            end
                        else
                            return { error =  "Sua " .. vRP.getItemName(weapon) .. " já está com seu maximo de munição" }
                        end
                    else
                        return { error = "Você precisa estar com a " ..vRP.getItemName(weapon) .. " na mão para recarregar." }
                    end
                end
                return { error = "Item não utilizável." }
			end
		end
    end
end


local droplist = {}

function RegisterTunnel.dropItem(slot, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then

        local inv = vRP.getInventory(user_id)
        if inv then
            if not inv[tostring(slot)] or inv[tostring(slot)].item == nil then
                return
            end

            local itemName = inv[tostring(slot)].item
            if vRP.tryGetInventoryItem(user_id, itemName, parseInt(amount), true, slot) then
                vRPclient._playAnim(source, true, { { "pickup_object", "pickup_low" } }, false)
                createDropItem(itemName, parseInt(amount), source)

                vRP.sendLog("DROPAR","O ID " .. user_id .." dropou o item " .. vRP.getItemName(itemName) .. " na quantidade de " .. amount .. "x.")
                return { success = "Você dropou o item com sucesso." }
            end
        end
	end
end

function RegisterTunnel.pegarItem(id)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local amount = droplist[id].count
		vRPclient._playAnim(source, true, { { "pickup_object", "pickup_low" } }, false)
        
        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(droplist[id].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
            dropCache = droplist[id]

            if (droplist[id].count - amount) >= 1 then
                vTunnel._removeDrop(-1, id)

                local newamount = droplist[id].count - amount
                createDropItem(droplist[id].item, newamount, source)
                droplist[id] = nil
                idgens:free(id)
            else
                vTunnel._removeDrop(-1, id)
                droplist[id] = nil
                idgens:free(id)
            end

            if tostring(dropCache.item) == "money" then
                vRP.giveInventoryItem(user_id, tostring(dropCache.item), parseInt(amount), true)
            else
                vRP.giveInventoryItem(user_id, tostring(dropCache.item), parseInt(amount), true)
            end

            vRP.sendLog("PEGAR","O ID " .. user_id .. " pegou o item " ..dropCache.item .. " do chão na quantidade de " .. amount .."x.")
            return { success = "Você pegou o item com sucesso." }
        else
            TriggerClientEvent("Notify", source, "negado", "Mochila cheia.", 5000)
            return { error = "Mochila cheia." }
        end
	end
end


function createDropItem(item, count, source)
	local id = idgens:gen()
	local coords = GetEntityCoords(GetPlayerPed(source))

	droplist[id] = {
		item = item,
		count = count,
		x = coords[1],
		y = coords[2],
		z = coords[3],
		name = vRP.getItemName(item),
		key = item,
		index = vRP.getItemType(item),
		peso = vRP.getItemWeight(item)
	}
	vTunnel._updateDrops(source, id, droplist[id])

	local nplayers = vRPclient.getNearestPlayers(source, 100)
	for k in pairs(nplayers) do
		vTunnel._updateDrops(k, id, droplist[id])
	end
end

RegisterTunnel.shopAction = function(id, item, amount, slot)
    amount = parseInt(amount)

	if amount == nil or amount <= 0 then
		amount = 1
	end

	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if Shops[id] then
			local items = Shops[id].items
			if items[item] ~= nil then
                if Shops[id].mode == "buy" then
                    if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                        if parseInt(items[item]) == 0 or vRP.tryFullPayment(user_id, parseInt(items[item]) * amount) then
                            vRP.giveInventoryItem(user_id, item, amount, true, slot)

                            if parseInt(items[item]) * amount > 0 then
                                return { success = "Você pagou R$ " .. vRP.format(parseInt(items[item]) * amount) .. "." }
                            end
                        else
                            return { error = "Você não possui dinheiro suficiente" }
                        end
                    else
                        return { error = "Mochila cheia" }
                    end
                else
                    local items = Shops[id].items
                    if item and items[item] ~= nil then
                        if vRP.tryGetInventoryItem(user_id, item, amount, slot) then
                            vRP.giveBankMoney(user_id,items[item]*amount, true)
                            return { success = "Você comprou o item com sucesso." }
                        else
                            return { error = "Você não possui dinheiro." }
                        end
                    end
                end
			end
		end
	end
end

RegisterTunnel.requireChest = function(data, maxbau, id)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if data[1] == "VEHICLE" then
            local plate = GetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(data[2]))
            local name = vehList[GetEntityModel(NetworkGetEntityFromNetworkId(data[2]))].model
            if OpennedVehicle[plate .. ":" .. name] then return false end
            -- ExecuteCommand("honra")
            vRPclient._playAnim(source, true, { { "amb@prop_human_parking_meter@female@idle_a","idle_a_female"} }, true)
            if dataVehicle[plate .. ":" .. name] == nil then
                local nuser_id = vRP.getUserByRegistration(plate)
                if nuser_id then
                    local rows = vRP.query("vRP/get_portaMalas",{ user_id = parseInt(nuser_id), veiculo = string.lower(name) }) or {}
                    if #rows > 0 then
                        local malas = json.decode(rows[1].portamalas) or {}
                        dataVehicle[plate .. ":" .. name] = { malas, name, plate, false }
                    else
                        local rows = vRP.getSData("tmpChest:" .. name .. "_" .. plate)
                        dataVehicle[plate .. ":" .. name] = { json.decode(rows) or {}, name, plate, true }
                    end
                else
                    local rows = vRP.getSData("tmpChest:" .. name .. "_" .. plate)
                    dataVehicle[plate .. ":" .. name] = { json.decode(rows) or {}, name, plate, true }
                end
            end

            local myVehicle = {}
            local weight = 0.0
            if dataVehicle[plate .. ":" .. name] then
                for k, v in pairs(dataVehicle[plate .. ":" .. name][1]) do
                    if Items[v.item] then
                        v["amount"] = parseInt(v["amount"])
						v["name"] = Items[v["item"]].name
						v["peso"] = Items[v["item"]].weight
						v["index"] = v["item"]
						v["key"] = v["item"]
						v["slot"] = k
                        myVehicle[k] = v
                        weight = weight + (Items[v.item].weight * parseInt(v.amount))
                    end
                end
            end
            OpennedVehicle[plate .. ":" .. name] = user_id
            OpennedChestUser[user_id] = { tipo = "VEHICLE", name = plate .. ":" .. name, vehname = name }
            return { inventory = myVehicle, weight = weight, max_weight = vRP.getVehicleTrunk(name)  }
        elseif data[1] == "GROUP" then
            if OpennedOrg[data[3]] then return end
            vRPclient._playAnim(source, true, { { "amb@prop_human_parking_meter@female@idle_a","idle_a_female"} }, false)
            if (Chests[data[3]] and Chests[data[3]].permission ~= nil and vRP.hasPermission(user_id, Chests[data[3]].permission)) or (Chests[data[3]] and Chests[data[3]].permission == true) then
                if dataOrgChest[data[3]] == nil then
                    local rows = vRP.getSData("orgChest:" .. data[3])
                    dataOrgChest[data[3]] = { json.decode(rows) or {} }
                end

                local myOrgChest = {}
                local weight = 0.0
                for k, v in pairs(dataOrgChest[data[3]][1]) do
                    if Items[v.item] then
                        v["amount"] = parseInt(v["amount"])
						v["name"] = Items[v["item"]].name
						v["peso"] = Items[v["item"]].weight
						v["index"] = v["item"]
						v["key"] = v["item"]
						v["slot"] = k
                        myOrgChest[k] = v
                        weight = weight + (Items[v.item].weight * parseInt(v["amount"]))
                    end
                end
                OpennedChestUser[user_id] = { tipo = "GROUP", name = data[3] }
                OpennedOrg[data[3]] = user_id
                return { inventory = myOrgChest, weight = weight, max_weight = Chests[data[3]].weight }
            else
                TriggerClientEvent("Notify", source, "negado", "Você não tem permissão para acessar esse bau!", 5000)
            end
        elseif data == "HOUSE" then
            if OpennedHouse[id] then return end
             vRPclient._playAnim(source, true, { { "amb@prop_human_parking_meter@female@idle_a","idle_a_female"} }, false)
            if dataHouseChest[id] == nil then
				local rows = vRP.query("imperio/allInfoHome", { id = id })
				dataHouseChest[id] = { json.decode(rows[1].bau) or {}, houseID, maxbau }
			end

			local myHouseChest = {}
			local weight = 0.0
			for k, v in pairs(dataHouseChest[id][1]) do
				if Items[v.item] then
                    if Items[v.item] then
                        v["amount"] = parseInt(v["amount"])
						v["name"] = Items[v["item"]].name
						v["peso"] = Items[v["item"]].weight
						v["index"] = v["item"]
						v["key"] = v["item"]
						v["slot"] = k
                        myHouseChest[k] = v
                        weight = weight + (Items[v.item].weight * parseInt(v["amount"]))
                    end
				end
			end
            OpennedChestUser[user_id] = { tipo = "HOUSE", name = id }
            OpennedHouse[id] = user_id
            return { inventory = myHouseChest, weight = weight, max_weight = maxbau }
        end
    end
end


RegisterTunnel.storeChestItem = function(playerslot, amount, targetslot)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if GetPlayerPing(source) > 0 then
            local inv = vRP.getInventory(user_id)
			if inv[playerslot].item == "money" then
				return { error = { "Você não pode fazer isso com esse item." } }
			end
            if OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "VEHICLE" then
                local bau = OpennedChestUser[user_id].name
                if OpennedVehicle[bau] and OpennedVehicle[bau] == user_id and dataVehicle[bau][1] ~= nil then
                    if vRP.computeItemsWeight(dataVehicle[bau][1]) + vRP.getItemWeight(inv[playerslot].item) * parseInt(amount) <= vRP.getVehicleTrunk(OpennedChestUser[user_id].vehname) then
                        if vRP.tryGetInventoryItem(user_id, inv[playerslot].item, amount, true, playerslot) then
                            if dataVehicle[bau][1][tostring(targetslot)] then
                                dataVehicle[bau][1][tostring(targetslot)].amount = dataVehicle[bau][1][tostring(targetslot)] + amount
                            else
                                dataVehicle[bau][1][tostring(targetslot)] = { amount = amount, item = inv[playerslot].item }
                            end
                        end
                    else
                        return { error = "Porta malas cheio."}
                    end
                else
                    return { error = "Você não está com esse bau aberto" }
                end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "GROUP" then
                local bau = OpennedChestUser[user_id].name
                if OpennedOrg[bau] and OpennedOrg[bau] == user_id and dataOrgChest[bau][1] ~= nil then
                    if vRP.computeItemsWeight(dataOrgChest[bau][1]) + vRP.getItemWeight(inv[playerslot].item) * parseInt(amount) <= Chests[bau].weight then
                        if vRP.tryGetInventoryItem(user_id, inv[playerslot].item, amount, true, playerslot) then
                            if dataOrgChest[bau][1][tostring(targetslot)] then
                                dataOrgChest[bau][1][tostring(targetslot)].amount = dataOrgChest[bau][1][tostring(targetslot)].amount + amount
                            else
                                dataOrgChest[bau][1][tostring(targetslot)] = { amount = amount, item = inv[playerslot].item }
                            end
                        end
                    else
                        return { error = "Bau cheio."}
                    end
                else
                    return { error = "Você não está com esse bau aberto" }
                end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "HOUSE" then
                local bau = OpennedChestUser[user_id].name
                if OpennedHouse[bau] and OpennedHouse[bau] == user_id and dataHouseChest[bau][1] ~= nil then
                    if vRP.computeItemsWeight(dataHouseChest[bau][1]) + vRP.getItemWeight(inv[playerslot].item) * parseInt(amount) <= parseInt(dataHouseChest[bau][3]) then
                        if vRP.tryGetInventoryItem(user_id, inv[playerslot].item, amount, true, playerslot) then
                            if dataHouseChest[bau][1][tostring(targetslot)] then
                                dataHouseChest[bau][1][tostring(targetslot)].amount = dataHouseChest[bau][1][tostring(targetslot)].amount + amount
                            else
                                dataHouseChest[bau][1][tostring(targetslot)] = { amount = amount, item = inv[playerslot].item }
                            end
                        end
                    else
                        return { error = "Bau cheio."}
                    end
                else
                    return { error = "Você não está com esse bau aberto" }
                end
            end
		end
	end
end

RegisterTunnel.takeChestItem = function(item, amount, playerslot, slot)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if GetPlayerPing(source) > 0 then
			if OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "VEHICLE" then
                local bau = OpennedChestUser[user_id].name
				if OpennedVehicle[bau] and dataVehicle[bau] and OpennedVehicle[bau] == user_id and dataVehicle[bau][1][tostring(slot)] and dataVehicle[bau][1][tostring(slot)].item ~= nil then
                    if dataVehicle[bau][1][tostring(slot)].amount >= amount then
                        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(dataVehicle[bau][1][tostring(slot)].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                            vRP.giveInventoryItem(user_id, dataVehicle[bau][1][tostring(slot)].item,amount, true, playerslot)
                            dataVehicle[bau][1][tostring(slot)].amount = dataVehicle[bau]
                                [1][tostring(slot)].amount - amount
                            if dataVehicle[bau][1][tostring(slot)].amount <= 0 then
                                dataVehicle[bau][1][tostring(slot)] = nil
                            end
                            return { success = "Item retirado com sucesso" }
                        else
                            return { error = "Mochila cheia." }
                        end
                    else
                        return { error = "Você está tentando dumpar itens." }
                    end
				else
					return { error = "Você não está com esse bau aberto." }
				end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "GROUP" then
                local bau = OpennedChestUser[user_id].name
				if OpennedOrg[bau] and dataOrgChest[bau] and OpennedOrg[bau] == user_id and dataOrgChest[bau][1][tostring(slot)] and dataOrgChest[bau][1][tostring(slot)].item ~= nil then
                    if dataOrgChest[bau][1][tostring(slot)].amount >= amount then
                        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(dataOrgChest[bau][1][tostring(slot)].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                            vRP.giveInventoryItem(user_id, dataOrgChest[bau][1][tostring(slot)].item,amount, true, playerslot)
                            dataOrgChest[bau][1][tostring(slot)].amount = dataOrgChest[bau][1][tostring(slot)].amount - amount
                            if dataOrgChest[bau][1][tostring(slot)].amount <= 0 then
                                dataOrgChest[bau][1][tostring(slot)] = nil
                            end
                            return { success = "Item retirado com sucesso" }
                        else
                            return { error = "Mochila cheia." }
                        end
                    else
                        return { error = "Você está tentando dumpar itens." }
                    end
				else
					return { error = "Você não está com esse bau aberto." }
				end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "HOUSE" then
                
                local bau = OpennedChestUser[user_id].name
				if OpennedHouse[bau] and dataHouseChest[bau] and OpennedHouse[bau] == user_id and dataHouseChest[bau][1][tostring(slot)] and dataHouseChest[bau][1][tostring(slot)].item ~= nil then
                    if dataHouseChest[bau][1][tostring(slot)].amount >= amount then
                    
                        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(dataHouseChest[bau][1][tostring(slot)].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                            vRP.giveInventoryItem(user_id, dataHouseChest[bau][1][tostring(slot)].item,amount, true, playerslot)
                            dataHouseChest[bau][1][tostring(slot)].amount = dataHouseChest[bau][1][tostring(slot)].amount - amount
                            if dataHouseChest[bau][1][tostring(slot)].amount <= 0 then
                                dataHouseChest[bau][1][tostring(slot)] = nil
                            end
                            return { success = "Item retirado com sucesso" }
                        else
                            return { error = "Mochila cheia." }
                        end
                    else
                        return { error = "Você está tentando dumpar itens." }
                    end
				else
					return { error = "Você não está com esse bau aberto." }
				end
			end
		end
	end
end

local openedRevistar = {}

RegisterCommand('revistar', function(source, args)
    local source = source
    local user_id = vRP.getUserId(source)
    local nplayer = vRPclient.getNearestPlayer(source, 3)
    local nuser_id = vRP.getUserId(nplayer)

    if vRPclient.getHealth(source) <= 101 then
        TriggerClientEvent("Notify", source, "negado", "Você não pode revistar alguem estando morto .", 6000)
        return
    end
   
    if vRPclient.isHandcuffed(source) then
        TriggerClientEvent("Notify", source, "negado", "Você não pode revistar estando algemado.", 6000)
        return
    end

    if arena.inArena(source) then
        TriggerClientEvent("Notify", source, "negado", "Você não pode revistar dentro da arena.", 6000)
        return
    end

    if vTunnel.inVehicle(source) then
        TriggerClientEvent("Notify", source, "negado", "Você não pode revistar dentro do veículo.", 6000)
        return
    end

    if vTunnel.checkSafezone(source) then
        TriggerClientEvent("Notify", source, "negado", "Você não pode revistar alguém dentro de uma safe-zone.", 6000)
        return
    end
    
    if not nuser_id then
        TriggerClientEvent("Notify", source, "negado", "Nenhum jogador próximo.", 5000)
        return
    end
    
    local request = false

    if vRPclient.getHealth(nplayer) <= 101 then
        request = true
        vRPclient._playAnim(source, false, { { "amb@medic@standing@tendtodead@idle_a", "idle_a" } }, true)
        TriggerClientEvent("Notify", nplayer, "negado", "Você está sendo revistado.", 5000)
    else
        request = vRP.request(nplayer, "Você deseja aceitar ser revistado?", 15)
    end

    if request then
        local identity = vRP.getUserIdentity(nuser_id)
        local name = identity.nome .. " " .. identity.sobrenome
        local inv = vRP.getInventory(user_id)
        local myInventory = {}
        local myweight = 0.0

        if inv then
            for k, v in pairs(inv) do
                if Items[v["item"]] then
                    v["amount"] = parseInt(v["amount"])
                    v["name"] = Items[v["item"]].name
                    v["peso"] = Items[v["item"]].weight
                    v["index"] = v["item"]
                    v["key"] = v["item"]
                    v["slot"] = k

                    myInventory[k] = v
                    myweight = myweight + (Items[v["item"]].weight * parseInt(v["amount"]))
                end
            end
        end

        local weapons = vRPclient.replaceWeapons(nplayer, {})

        for k, v in pairs(weapons) do
            vRP.giveInventoryItem(nuser_id, k, 1, true)

            if v.ammo > 0 then
                local weapon = string.gsub(k, "WEAPON_", "AMMO_")
                vRP.giveInventoryItem(nuser_id, weapon, v.ammo, true)
            end
        end

        local inv2 = vRP.getInventory(nuser_id)
        local myHouseChest = {}
        local weight = 0.0

        for k, v in pairs(inv2) do
            if Items[v["item"]] then
                v["amount"] = parseInt(v["amount"])
                v["name"] = Items[v["item"]].name
                v["peso"] = Items[v["item"]].weight
                v["index"] = v["item"]
                v["key"] = v["item"]
                v["slot"] = k
                myHouseChest[k] = v
                weight = weight + (Items[v["item"]].weight * parseInt(v["amount"]))
            end
        end

        openedRevistar[user_id] = nuser_id
        vTunnel.openInspect(source,{ source = { inventory = myInventory, weight = myweight, max_weight = vRP.getInventoryMaxWeight(user_id) },target = { inventory = myHouseChest, weight = weight, max_weight = vRP.getInventoryMaxWeight(nuser_id),target_name = name } })
        vTunnel.SetInventoryBlocked(nplayer, 500000000000)
        func:setBlockCommand(nuser_id, 100000000000)
        func:setBlockCommand(source, 100000000000)
        TriggerClientEvent("Notify", source, "sucesso", "Você está revistando.", 5000)
        TriggerClientEvent("Notify", nplayer, "negado", "Você está sendo revistado.", 5000)
        vRPclient._playAnim(source, false, { { "misscarsteal4@director_grip", "end_loop_grip" } }, true)
        vRPclient._playAnim(nplayer, false, { { "random@mugging3", "handsup_standing_base" } }, true)
    else
        TriggerClientEvent("Notify", source, "negado", "O jogador recusou seu pedido de revistar.", 5000)
    end
end)

RegisterServerEvent("imperio_inventory:useItemFromHotkey")
AddEventHandler("imperio_inventory:useItemFromHotkey", function(slot)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local inv = vRP.getInventory(user_id)
    if not inv or not inv[slot] then
        vRPclient.notify(source, "~r~Não há item no slot " .. slot .. ".")
        return
    end

    -- Chama a função de usar item que já existe
    -- Usamos 1 como a quantidade padrão para o atalho
    local result = RegisterTunnel.useItem(slot, 1)

    -- A função useItem retorna uma tabela com 'error' ou 'success'
    if result then
        if result.error then
            vRPclient.notify(source, "~r~" .. result.error)
        elseif result.success then
            vRPclient.notify(source, "~g~" .. result.success)
            -- Informa ao cliente para atualizar o inventário na tela
            TriggerClientEvent("inventory:update", source)
        end
    else
        -- Notificação genérica caso a função não retorne nada
        vRPclient.notify(source, "~r~Não foi possível usar o item.")
    end
end)


RegisterTunnel.emitCloseListeners = function()
    local source = source
    local nplayer = vRPclient.getNearestPlayer(source, 5)
    local nuser_id = vRP.getUserId(nplayer)
    local user_id = vRP.getUserId(source)
    if user_id then
        if OpennedChestUser[user_id] then
            if OpennedChestUser[user_id].tipo == "HOUSE" then
                OpennedHouse[OpennedChestUser[user_id].name] = nil
                vRPclient._stopAnim(source, false)
            elseif OpennedChestUser[user_id].tipo == "VEHICLE" then
                OpennedVehicle[OpennedChestUser[user_id].name] = nil
                vRPclient._stopAnim(source, false)
            elseif OpennedChestUser[user_id].tipo == "GROUP" then
                OpennedOrg[OpennedChestUser[user_id].name] = nil
                vRPclient._stopAnim(source, false)
            end
        end
        if openedRevistar[user_id] then
            vTunnel.SetInventoryBlocked(nplayer, 0)
            openedRevistar[user_id] = nil
            func:setBlockCommand(nuser_id, 0)
            func:setBlockCommand(source, 0)
            vRPclient._stopAnim(source, false)
            vRPclient._stopAnim(nplayer, false)
        end
    end
end

local itensblock = {
	["algemas"] = true,
	["chave_algemas"] = true,
	["c4"] = true,
	["masterpick"] = true,
	["pendrive"] = true,
	["furadeira"] = true,
	["lockpick"] = true,
	["m-aco"] = true,
	["m-capa_colete"] = true,
	["m-corpo_ak47_mk2"] = true,
	["m-corpo_g3"] = true,
	["m-corpo_machinepistol"] = true,
	["m-corpo_pistol_mk2"] = true,
	["m-corpo_shotgun"] = true,
	["m-corpo_smg_mk2"] = true,
	["m-corpo_snspistol_mk2"] = true,
	["m-gatilho"] = true,
	["capsulas"] = true,
	["polvora"] = true,
	["pecadearma"] = true,
	["metal"] = true,
	["molas"] = true,
	["gatilho"] = true,
	["m-malha"] = true,
	["m-placametal"] = true,
	["m-tecido"] = true,
	["c-cobre"] = true,
	["c-ferro"] = true,
	["c-fio"] = true,
	["c-polvora"] = true,
	["l-alvejante"] = true,
	["folhamaconha"] = true,
	["maconha"] = true,
	["pastabase"] = true,
	["cocaina"] = true,
	["acidolsd"] = true,
	["colete"] = true,
	["capuz"] = true,
	["dinheirosujo"] = true,
	["scubagear"] = true,
	["relogioroubado"] = true,
	["colarroubado"] = true,
	["anelroubado"] = true,
	["brincoroubado"] = true,
	["pulseiraroubada"] = true,
	["carnedepuma"] = true,
	["carnedelobo"] = true,
	["carnedejavali"] = true,
	["lsd"] = true,
	["morfina"] = true,
	["heroina"] = true,
	["anfetamina"] = true,
	["metanfetamina"] = true,
	["tartaruga"] = true,
	["WEAPON_SNSPISTOL_MK2"] = true,
	["WEAPON_COMBATMG_MK2"] = true,
	["AMMO_SNSPISTOL_MK2"] = true,
	["WEAPON_PISTOL_MK2"] = true,
	["WEAPON_GUSENBERG"] = true,
	["WEAPON_PISTOL50"] = true,
	["WEAPON_HEAVYPISTOL"] = true,
	["WEAPON_HATCHET"] = true,
	["AMMO_PISTOL_MK2"] = true,
	["WEAPON_COMBATPISTOL"] = true,
	["WEAPON_COMBATPDW"] = true,
	["AMMO_COMBATPISTOL"] = true,
	["WEAPON_MACHINEPISTOL"] = true,
	["AMMO_MACHINEPISTOL"] = true,
	["WEAPON_SMG_MK2"] = true,
	["AMMO_SMG_MK2"] = true,
	["WEAPON_SMG"] = true,
	["AMMO_SMG"] = true,
	["WEAPON_ASSAULTSMG"] = true,
	["AMMO_ASSAULTSMG"] = true,
	["WEAPON_SAWNOFFSHOTGUN"] = true,
	["AMMO_SAWNOFFSHOTGUN"] = true,
	["WEAPON_PUMPSHOTGUN_MK2"] = true,
	["AMMO_PUMPSHOTGUN_MK2"] = true,
	["WEAPON_ASSAULTRIFLE_MK2"] = true,
	["AMMO_ASSAULTRIFLE_MK2"] = true,
	["WEAPON_SPECIALCARBINE_MK2"] = true,
	["AMMO_SPECIALCARBINE_MK2"] = true,
	["WEAPON_CARBINERIFLE"] = true,
	["AMMO_CARBINERIFLE"] = true,
	["WEAPON_SPECIALCARBINE"] = true,
	["AMMO_SPECIALCARBINE"] = true,
	["WEAPON_STUNGUN"] = true,
	["WEAPON_PETROLCAN"] = true,
	["AMMO_PETROLCAN"] = true,
    ["WEAPON_FNFAL"] = true,
    ["WEAPON_M6IC"] = true,
    ["WEAPON_PARAFAL"] = true,
}


RegisterTunnel.takeInspectItem = function(target, slot, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        if openedRevistar[user_id] then
            local id = parseInt(openedRevistar[user_id])
            local nplayer = vRP.getUserSource(id)
            if nplayer then
                local inv = vRP.getInventory(id)
                if not inv then return end
                local item = inv[target].item
                if vRP.hasPermission(user_id, "perm.policia") then
                    if itensblock[item] ~= nil then
                        return { error = "Você não pode pegar esse item de bandidos." }
                    end
                end
    
                if item == "WEAPON_STUNGUN" then
                    return { error = "Você não pode pegar esse item." }
                end
    
                if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                    if vRP.tryGetInventoryItem(id, item, amount, true, target) then
                        vRP.giveInventoryItem(user_id, item, amount, true, slot)
                        vRP.sendLog("SAQUEAR","O ID "..user_id .."saqueou o item ".. vRP.getItemName(item) .. "na quantidade ".. amount .. "x do ID "..id .. ".")
                            return { success = "Você pegou o item com sucesso." }
                    end
                else
                    return { error = "Mochila cheia." }
                end
            end
        end
	end
end


RegisterTunnel.putInspectItem = function(target, slot, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        if openedRevistar[user_id] then
            local id = parseInt(openedRevistar[user_id])
            local nplayer = vRP.getUserSource(id)
            if nplayer then
                local inv = vRP.getInventory(user_id)
                if not inv then return end
                local item = inv[target].item
                if vRP.computeInvWeight(id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(id) then
                    if vRP.tryGetInventoryItem(user_id, item, amount, true, target) then
                        vRP.giveInventoryItem(id, item, amount, true, slot)
                        vRP.sendLog("SAQUEAR","O ID " ..user_id .." colocou o item " .. vRP.getItemName(item) .. " na quantidade " .. amount .. "x do ID " ..id .. " no ID "..id..".")
                        return { success = "Você colocou o item com sucesso." }
                    end
                else
                    return { error = "Mochila cheia." }
                end
            end
        end
	end
end

function save_vehicles_chest()
	local count = 0

	for k in pairs(dataVehicle) do
		local nuser_id = vRP.getUserByRegistration(dataVehicle[k][3])
		if nuser_id then
			if not dataVehicle[k][4] then
				if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
					vRP.execute("vRP/update_portaMalas",
						{ user_id = nuser_id, veiculo = dataVehicle[k][2], portamalas = json.encode(dataVehicle[k][1]) })
					dataVehicle[k] = nil
					count = count + 1
				end
			else
				if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
					vRP.setSData("tmpChest:" .. dataVehicle[k][2] .. "_" .. dataVehicle[k][3],
						json.encode(dataVehicle[k][1]))
					dataVehicle[k] = nil
					count = count + 1
				end
			end
		else
			if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
				vRP.setSData("tmpChest:" .. dataVehicle[k][2] .. "_" .. dataVehicle[k][3], json.encode(dataVehicle[k][1]))
				dataVehicle[k] = nil
				count = count + 1
			end
		end
	end


	if count > 0 then
		print("^1[INVENTÁRIO] ^0Total de porta malas salvo(s): ^1"..count)
	end

	SetTimeout(10 * 1000, save_vehicles_chest)
end


function save_org_chest()
    local count = 0
	for k in pairs(dataOrgChest) do
		if OpennedOrg[k] == nil then
            count = count + 1
			vRP.setSData("orgChest:" .. k, json.encode(dataOrgChest[k][1]))
			dataOrgChest[k] = nil
		end
	end

    if count > 0 then
		print("^1[INVENTÁRIO] ^0Total de baus de facção salvo(s): ^1"..count)
	end
	SetTimeout(10 * 1000, save_org_chest)
end


function checkRG(numero)
	local rows = vRP.query("vRP/getRegistro", {registro = numero} ) or nil
	if not rows[1] then
		return true
	end
end

function checkNumber(numero)
	local rows = vRP.query("vRP/getNumber", {telefone = numero} ) or nil
	if not rows[1] then
		return true
	end
end

function formatNumber(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1-'):reverse())..right
end


function save_house_chest()
	local count = 0
	for k in pairs(dataHouseChest) do
		if OpennedHouse[k] == nil then
            count = count + 1
			vRP.execute("imperio/updateBau", { id = k, bau = json.encode(dataHouseChest[k][1]) })
			dataHouseChest[k] = nil
		end
	end

    if count > 0 then
		print("^1[INVENTÁRIO] ^0Total de bau de casa salvo(s): ^1"..count)
	end
	SetTimeout(10 * 1000, save_house_chest)
end

CreateThread(function()
	save_org_chest()
	save_vehicles_chest()
	save_house_chest()
    Items = vRP.getAllItens()
end)

RegisterTunnel.getItems = function()
    return Items
end

RegisterServerEvent("updateVehList")
AddEventHandler("updateVehList", function(list) 
    vehList = list
end)




-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryreparar")
AddEventHandler("tryreparar",function(nveh)
	TriggerClientEvent("syncreparar",-1,nveh)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR PNEUS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryrepararpneus")
AddEventHandler("tryrepararpneus",function(nveh)
	TriggerClientEvent("syncrepararpneus",-1,nveh)
end)

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -- BVIDA
-- ----------------------------------------------r--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RegisterCommand('bvida',function(source,args)
--     local user_id = vRP.getUserId(source)
--     if exports["vrp"]:checkCommand(user_id) and GetEntityHealth(GetPlayerPed(source)) > 102 then
--         local status,time = exports['vrp']:getCooldown(user_id, "bvida")
-- 		if vTunnel.inVehicle(source) then
-- 			TriggerClientEvent("Notify",source,"negado","Você não consegue utilizar esse comando dentro de um veiculo.", 5000)
-- 			return
-- 		end
-- 		if status then 
-- 			if not vRP.checkFarda(user_id) then
-- 				exports['vrp']:setCooldown(user_id, "bvida", 60)
-- 				vRPclient.setCustomization(source, vRP.getUserApparence(user_id).clothes)
-- 			else
-- 				TriggerClientEvent("Notify",source,"negado","Você não pode utilizar esse comando fardado.", 5000)
-- 			end
-- 		else
-- 			TriggerClientEvent("Notify",source,"negado","Você so pode utilizar esse comando em  ".. time .. " segundo(s)", 5000)
-- 		end
--     end
-- end)