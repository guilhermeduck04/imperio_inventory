local Tunnel <const>        = module("vrp","lib/Tunnel")
local RESOURCE_NAME <const> = GetCurrentResourceName()
local Proxy <const>         = module("vrp","lib/Proxy")
local currentMugshot = nil

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

-- BLOQUEIO DE TECLAS NUMÉRICAS (1-5) PARA ARMAS
CreateThread(function()
    while true do
        local time = 100
        -- Bloqueia troca de arma nativa (1, 2, 3, 4, 5)
        DisableControlAction(0, 157, true) 
        DisableControlAction(0, 158, true) 
        DisableControlAction(0, 160, true) 
        DisableControlAction(0, 164, true) 
        DisableControlAction(0, 165, true) 
        
        -- Verifica se deve cancelar ação com X (Tecla 73)
        if API.isUsingItem and API.isUsingItem() then
            time = 5
            if IsControlJustPressed(0, 73) then 
                API.cancelItem()
            end
        end
        Wait(time)
    end
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
    
    -- Gera a foto antes de abrir
    local mugshotTxd = API.CreatePedMugshot()
    
    -- Envia a NUI com a foto
    SendNUIMessage({ 
        route = "OPEN_INVENTORY",
        payload = {
            mugshot = mugshotTxd -- Envia a textura da foto
        }
    })
    SetNuiFocus(true,true)
end)

CreateThread(function() 
    RegisterKeyMapping("abrirmochilanikito","Abrir a mochila","keyboard","OEM_3")
    RegisterKeyMapping("openchest","Trunkchest Open","keyboard","PAGEUP")

    for i = 1, 5 do
        RegisterCommand("+inventory:hotkey" .. i, function()
            TriggerServerEvent("imperio_inventory:useItemFromHotkey", tostring(i))
        end, false)
        RegisterCommand("-inventory:hotkey" .. i, function() end, false)
        RegisterKeyMapping("+inventory:hotkey" .. i, "Atalho do Inventário " .. i, "keyboard", tostring(i))
    end
end)

RegisterNetEvent("inventory:update")
AddEventHandler("inventory:update", function()
    if IsNuiFocused() then
        SendNUIMessage({route = "FORCE_UPDATE_INVENTORY"})
    end
end)

-- Função para registrar o Headshot
function API.CreatePedMugshot()
    local ped = PlayerPedId()
    local handle = RegisterPedheadshot(ped)
    
    local timeout = 2000
    while not IsPedheadshotReady(handle) and timeout > 0 do
        Wait(10)
        timeout = timeout - 10
    end

    if IsPedheadshotReady(handle) then
        local txd = GetPedheadshotTxdString(handle)
        currentMugshot = handle
        return txd
    end
    
    return nil
end

-- Função para limpar o Headshot (Chamar ao fechar inventário)
function API.ReleasePedMugshot()
    if currentMugshot then
        UnregisterPedheadshot(currentMugshot)
        currentMugshot = nil
    end
end

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
    API.ReleasePedMugshot() -- Limpa a foto da memória
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

exports("setinsafe", function(status)
	insafezone = status
end)

function API.checkSafezone()
	return insafezone
end