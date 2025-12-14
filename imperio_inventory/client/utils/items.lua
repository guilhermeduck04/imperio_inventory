-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE USAR BANDAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
local bandagem = false
local tempoBandagem = 0
local oldHealth = 0

function API.useBandagem()
	bandagem = true
	tempoBandagem = 60
	oldHealth = GetEntityHealth(PlayerPedId())
end

CreateThread(function()
	while true do
		local time = 1000
		if bandagem then
			if GetEntityHealth(PlayerPedId()) > 300 then
				tempoBandagem = 0
				bandagem = false
				TriggerEvent("Notify", "negado", "<b>Você Não Pode Utilizar a [BANDAGEM]</b> Pois Sua Vida Está Cheia.", 5000)
			end

			tempoBandagem = tempoBandagem - 1

			if tempoBandagem <= 0 then
				tempoBandagem = 0
				bandagem = false
				TriggerEvent("Notify", "negado", "<b>Sua Bandagem acabou</b>", 5000)
			end

			if oldHealth > GetEntityHealth(PlayerPedId()) and bandagem then
				tempoBandagem = 0
				bandagem = false
				TriggerEvent("Notify", "negado", "<b>A [BANDAGEM]</b> Foi Cancelada Pois Você sofreu algum dano.", 5000)
			end

			if GetEntityHealth(PlayerPedId()) <= 101 and bandagem then
				tempoBandagem = 0
				bandagem = false
				TriggerEvent("Notify", "negado", "A Bandagem Foi Cancelada pois Você morreu.", 5000)
			end

			if GetEntityHealth(PlayerPedId()) > 102 and bandagem and GetEntityHealth(PlayerPedId()) < 250 then
				SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 2)
			end

			if GetEntityHealth(PlayerPedId()) >= 300 and bandagem then
				tempoBandagem = 0
				bandagem = false
				SetEntityHealth(PlayerPedId(), 300)
				TriggerEvent("Notify", "negado", "<b>A Bandagem Foi Cancelada pois sua Vida já está cheia.", 5000)
			end

			if GetEntityHealth(PlayerPedId()) < 300 and bandagem then
				if oldHealth > GetEntityHealth(PlayerPedId()) then
					tempoBandagem = 0
					bandagem = false
					TriggerEvent("Notify", "negado", "A Bandagem Foi Cancelada pois Você sofreu algum dano.", 5000)
				elseif GetEntityHealth(PlayerPedId()) >= 300 then
					tempoBandagem = 0
					bandagem = false
					SetEntityHealth(PlayerPedId(), 300)
					TriggerEvent("Notify", "negado", "<b>[BANDAGEM]</b> acabou a bandagem..", 5000)
				elseif GetEntityHealth(PlayerPedId()) < 300 then
					SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 2)
				end
			end
		end
		Wait(time)
	end
end)

CreateThread(function()
	while true do
		local time = 5000
		if bandagem then
			oldHealth = GetEntityHealth(PlayerPedId())
		end
		Wait(time)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPAIRVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("repairVehicle")
AddEventHandler("repairVehicle",function(index,status)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			local fuel = GetVehicleFuelLevel(v)
			if status then
				SetVehicleFixed(v)
				SetVehicleDeformationFixed(v)
			end
			SetVehicleBodyHealth(v,1000.0)
			SetVehicleEngineHealth(v,1000.0)
			SetVehiclePetrolTankHealth(v,1000.0)
			SetVehicleFuelLevel(v,fuel)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCKPICKVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_inventory:lockpickVehicle")
AddEventHandler("vrp_inventory:lockpickVehicle",function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			SetEntityAsMissionEntity(v,true,true)
			if GetVehicleDoorsLockedForPlayer(v,PlayerId()) == 1 then
				SetVehicleDoorsLocked(v,false)
				SetVehicleDoorsLockedForAllPlayers(v,false)
			else
				SetVehicleDoorsLocked(v,true)
				SetVehicleDoorsLockedForAllPlayers(v,true)
			end
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
			Wait(200)
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOCKBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
local blockButtons = false
function API.blockButtons(status)
	blockButtons = status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local timeDistance = 500
		if blockButtons then
			timeDistance = 4
			DisableControlAction(1,73,true)
			DisableControlAction(1,75,true)
			DisableControlAction(1,29,true)
			DisableControlAction(1,47,true)
			DisableControlAction(1,105,true)
			DisableControlAction(1,187,true)
			DisableControlAction(1,189,true)
			DisableControlAction(1,190,true)
			DisableControlAction(1,188,true)
			DisableControlAction(1,311,true)
			DisableControlAction(1,245,true)
			DisableControlAction(1,257,true)
			DisableControlAction(1,288,true)
			DisableControlAction(1,37,true)
			DisablePlayerFiring(PlayerPedId(),true)
		end
		Wait(timeDistance)
	end
end)


CreateThread(function()
    while true do
        Wait(0)
        local playerPed = GetPlayerPed(-1)
        if IsEntityDead(playerPed) and not IsPedInAnyVehicle(playerPed, true) then
            SetPedDropsWeaponsWhenDead(playerPed, false)
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ENERGETICO
-----------------------------------------------------------------------------------------------------------------------------------------
local energetico = false

function API.setEnergetico(status)
	if status then
		SetRunSprintMultiplierForPlayer(PlayerId(),1.30)
		energetico = true
	else
		SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
		RestorePlayerStamina(PlayerId(),1.0)
		energetico = false
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('reparar')
AddEventHandler('reparar',function(vehicle)
	TriggerServerEvent("tryreparar",VehToNet(vehicle))
end)

RegisterNetEvent('syncreparar')
AddEventHandler('syncreparar',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local fuel = GetVehicleFuelLevel(v)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				SetVehicleFixed(v)
				SetVehicleDirtLevel(v,0.0)
				SetVehicleUndriveable(v,false)
				SetEntityAsMissionEntity(v,true,true)
				SetVehicleOnGroundProperly(v)
				SetVehicleFuelLevel(v,fuel)
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR PNEUS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('repararpneus')
AddEventHandler('repararpneus',function(vehicle)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("tryrepararpneus",VehToNet(vehicle))
	end
end)

RegisterNetEvent('syncrepararpneus')
AddEventHandler('syncrepararpneus',function(index)
	if NetworkDoesNetworkIdExist(index) then
        local v = NetToEnt(index)
        if DoesEntityExist(v) then
            for i = 0,8 do
                SetVehicleTyreFixed(v,i)
            end
        end
    end
end)