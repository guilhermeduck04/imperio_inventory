local NEAR_SHOP = false

local function ParseItems(items) 
    local response = {}
    local count = 0
    for k,v in pairs(items) do
        count += 1 
        response[tostring(count)] = {
            price = items[k],
            item = k,
            slot = tostring(count)
        }
    end
    return response
end
CreateThread(function() 
    for k,v in pairs(Shops) do 
        Shops[k].items = ParseItems(v.items)
    end
    SearchShopThread()
end)

function SearchShopThread()
    CreateThread(function() 
        while not NEAR_SHOP do 
            local sleep = 1002
            local ply       = PlayerPedId()
            local plyCds    = GetEntityCoords(ply)
            for k,v in pairs(Shops) do
                for i = 1, #v.coords do
                    local distance = #(plyCds - v.coords[i])
                    if distance < 7.0 then
                        NEAR_SHOP = true
                        NearShopThread(k, i)
                    end
                end
            end
            Wait(sleep)
        end
    end)
end


function NearShopThread(store, coordIndex)
    CreateThread(function()
        while NEAR_SHOP do
            local sleep = 4
            local ply = PlayerPedId()
            local plyCds = GetEntityCoords(ply)
            local distance = #(plyCds - Shops[store].coords[coordIndex])
            if distance > 7.0 or vRP.getHealth() <= 101 then
                NEAR_SHOP = false
                SearchShopThread()
                break
            end
            DrawText3D(Shops[store].coords[coordIndex].x,Shops[store].coords[coordIndex].y,Shops[store].coords[coordIndex].z,"~g~E~w~   ABRIR")
            DrawMarker(29,Shops[store].coords[coordIndex].x,Shops[store].coords[coordIndex].y,Shops[store].coords[coordIndex].z-0.6,0,0,0,180.0,0,0,0.55,0.55,0.55,13, 13, 251, 50,0,0,0,20)
            if distance <= 1.3 then
                if IsControlJustPressed(0, 38) then
                    -- print("near shop!")
                    if (not Shops[store].perm or Remote.checkPermission(Shops[store].perm)) then 
                        SendNUIMessage({
                            route = "OPEN_SHOP",
                            payload = {
                                mode = Shops[store].mode, -- buy|sell
                                store_name = store, -- buy|sell
                                inventory = Shops[store].items, -- [item: string] = price;
                            }
                        })
                        SetNuiFocus(true,true)
                    end  
                end
            end
            Wait(sleep)
        end
    end)
end
