function API.addChest(name, chest)
    Chests[name] = chest
end

function API.loadChests(data)
    Chests = data
end

local vehicleChest = false
function API.openVehicleChest()
	local vehicle = vRP.getNearestVehicle(7)
    if vehicle then
        if IsEntityAVehicle(vehicle) then
            TriggerServerEvent("trytrunk",VehToNet(vehicle), GetClosestPlayers(25.0))
        end
        vehicleChest = true
    end
end

function API.isInVehicleChest()
    if vehicleChest then
        local vehicle = vRP.getNearestVehicle(7)
        ClearPedTasks(PlayerPedId())
		TriggerServerEvent("trytrunk",VehToNet(vehicle), GetClosestPlayers(25.0))
        vehicleChest = false
    end
end

function API.SearchChest(hasRobbery) 
    local ply = PlayerPedId()
    local plyCds = GetEntityCoords(ply)
    local vehicle   = getClosestVeh()
    local args = {}
    if vRP.isHandcuffed() or vRP.getHealth() <= 101 then
        TriggerEvent('Notify', 'negado', 'Você está morto e nao consegue abrir o porta malas morto.', 5000)
        return
    end
    if vehicle and GetVehicleDoorLockStatus(vehicle) == 1 then 
        -- print("veiculo encontrado!")
        args = {"VEHICLE", VehToNet(vehicle), _, hasRobbery}
        openChest = { coords = GetEntityCoords(vehicle) }
        
    else
        for k,v in pairs(Chests) do 
            if #(v.coords - plyCds) <= 2.0 then 
                args = {"GROUP", false, k}
                -- print("ID DO BAU "..k)
                openChest = v
            end
        end
    end
    if #args == 0 then 
        return
    end
    local response = Remote.requireChest(args)
    if response then 
        response.chest_type = args[1]
        SendNUIMessage({route = "OPEN_CHEST", payload = response})
        SetNuiFocus(true,true)
    end
end

RegisterNetEvent("Nikito:myHouseChest",function(id,houseid, maxBau)
    -- print(id, maxBau)
    local response = Remote.requireChest("HOUSE",maxBau,id)
    if vRP.getHealth() <= 101 then
        TriggerEvent('Notify', 'negado', 'Você não pode acessar o seu inventário agora.', 5000)
        return
    end
    if response then 
        response.chest_type = "HOUSE"
        SendNUIMessage({route = "OPEN_CHEST",payload = response})
        SetNuiFocus(true,true)
    end
end)

local LAST_COMMAND_EXECUTION = GetGameTimer()
RegisterCommand("openchest",function() 
    if GetGameTimer() - LAST_COMMAND_EXECUTION < 2000 then 
        TriggerEvent("Notify","negado","Espere um pouco para executar este comando novamente.", 5000)
        return
    end
    API.SearchChest()
end)

CreateThread(function() 
    SetNuiFocus(false,false)
    while true do 
        local msec = 3000
        local ply = PlayerPedId()
        local plyCoords = GetEntityCoords(ply)
        for k,v in pairs(Chests) do 
            local distance = #(v.coords - plyCoords)
            if distance < 10.0 then
                msec = 4
                DrawMarker(20, v.coords - vec3(0.0,0.0,0.4), 0, 0, 0, 0, 180.0, 0, 0.7, 0.7, 0.7, 13, 13, 251, 50, 1, 0, 0, 1)
                if distance < 1.3 and IsControlJustPressed(0,38) then 
                    ExecuteCommand('openchest')
                    Wait(1000)
                end
            end
        end
        Wait(msec)
    end
end)

CreateThread(function()
    RegisterKeyMapping("openchest", "Abrir baú ~", "keyboard", "PAGEUP")
end)


---
-- Helper functions
---
function getClosestVeh()
	local plyPed = PlayerPedId()
    local actualVeh = GetVehiclePedIsIn(plyPed, false)
    if actualVeh > 0 then return actualVeh end
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.0, 0.0)
	local radius = 0.8
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, radius, 10, plyPed, 7)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)

	return vehicle
end

function GetClosestPlayers(range)
    local peds = GetGamePool("CPed")
    local ped = PlayerPedId()
    local plys = {}
    for i=1, #peds do
        local ply = peds[i]
        local distance = #(GetEntityCoords(ped) - GetEntityCoords(ply))
        if IsPedAPlayer(ply) and distance < range then
            plys[#plys + 1] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ply))
        end
    end
    return plys
end
