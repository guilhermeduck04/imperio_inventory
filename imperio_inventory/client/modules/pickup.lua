local droplist = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE DROPAR ITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function API.updateDrops(id,marker)
	droplist[id] = marker
end

function API.removeDrop(id)
	if droplist[id] ~= nil then
		droplist[id] = nil
	end
end

CreateThread(function()
    while true do
        local time = 1000
        local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		for k,v in pairs(droplist) do
			local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
			local distance = #(coords - vector3(v.x,v.y,cdz))
			if distance <= 10 and GetEntityHealth(ped) > 101 and not vRP.isHandcuffed() then
				time = 2
				DrawMarker(22,v.x,v.y,cdz+0.2, 0,0,0,180.0,0,0,0.3,0.3,0.3,13, 13, 251, 50,0,0,0,20)
                if distance < 2.0 then 
                    DrawText3D(v.x, v.y, v.z - 0.4, "Pressione ~b~[E] ~w~para pegar~b~ " .. v.count .. "x " .. v.item)

                    if IsControlJustPressed(0, 38) then 
                        Remote.pegarItem(k)
                        Wait(1000)
                    end
                end
			end
		end

        Wait(time)
    end
end)

