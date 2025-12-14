local Tunnel <const>        = module("vrp","lib/Tunnel")
local RESOURCE_NAME <const> = GetCurrentResourceName()
local Proxy <const>         = module("vrp","lib/Proxy")

---@alias vector3 table

vRP = Proxy.getInterface("vRP")
vRPs = Tunnel.getInterface("vRP")

if not IsDuplicityVersion() and not _G["API"] then 
    _G["API"] = {}
    Tunnel.bindInterface(RESOURCE_NAME,API)
end

Remote = Tunnel.getInterface(RESOURCE_NAME)
local InventoryBlocked = 0
function API.SetInventoryBlocked(time)
    SendNUIMessage({route = "CLOSE_INVENTORY"})
    SetNuiFocus(false, false)
    InventoryBlocked = GetGameTimer() + (time * 1000)
end

local in_arena = false
RegisterNetEvent("imperio_survival:updateArena", function(boolean)
    in_arena = boolean
end)

RegisterCommand("abrirmochilanikito",function()
    local ped = PlayerPedId()
    
    if in_arena then
        TriggerEvent("Notify","negado","Você não pode acessar seu inventario agora.",5000)
        return 
    end 

    if IsPauseMenuActive() then
        return 
    end

    if GetGameTimer() < InventoryBlocked or vRP.isHandcuffed() then
        TriggerEvent("Notify","negado","Você não pode acessar seu inventario agora.",5000)
        return 
    end

    if GetEntityHealth(ped) <= 101 or in_arena == true then 
        TriggerEvent("Notify", "negado", "Você não pode acessar seu inventario agora.",5000)
    return
    end
    
    SendNUIMessage({route = "OPEN_INVENTORY",})
    SetNuiFocus(true,true)
end)

CreateThread(function() 
    RegisterKeyMapping("abrirmochilanikito","Abrir a mochila","keyboard","OEM_3")
    RegisterKeyMapping("openchest","Trunkchest Open","keyboard","PAGEUP")

    -- Atalhos do inventário (Versão Corrigida)
    for i = 1, 5 do
        RegisterCommand("+inventory:hotkey" .. i, function()
            -- Apenas informa ao servidor que a tecla foi pressionada
            TriggerServerEvent("imperio_inventory:useItemFromHotkey", tostring(i))
        end, false)
        RegisterCommand("-inventory:hotkey" .. i, function() end, false)
        RegisterKeyMapping("+inventory:hotkey" .. i, "Atalho do Inventário " .. i, "keyboard", tostring(i))
    end
end)

-- Este evento é chamado pelo servidor para forçar a atualização da UI
RegisterNetEvent("inventory:update")
AddEventHandler("inventory:update", function()
    if IsNuiFocused() then
        SendNUIMessage({route = "FORCE_UPDATE_INVENTORY"})
    end
end)




function API.getActivePlayers()
    local response = {}
    local players = GetActivePlayers()
    for i = 1,#players do 
        response[#response + 1] = GetPlayerServerId(players[i])
    end
    return response
end

function API.inVehicle()
    return IsPedInAnyVehicle(PlayerPedId())
end


AddEventHandler(GetCurrentResourceName()..":emitNuiEvent",function(ev)
    if IsNuiFocused() and not IsNuiFocusKeepingInput() then 
        SendNUIMessage(ev)
    end
end)

RegisterNetEvent('closeInventory')
AddEventHandler('closeInventory',function()
    SendNUIMessage({ route = "CLOSE_INVENTORY" })
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end



function API.rechargeCheck(ammoType)
	local ped = PlayerPedId()
	if weapon_ammos[ammoType] then
		for k,v in pairs(weapon_ammos[ammoType]) do
			if HasPedGotWeapon(ped,v) then
				return v
			end
		end
	end
	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SAFEZONE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("setinsafe", function(status)
	insafezone = status
end)

function API.checkSafezone()
	return insafezone
end