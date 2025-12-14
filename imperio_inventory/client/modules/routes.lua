local ts = tostring
local tn = tonumber
local PENDING_CB <const> = {}
local COOLDOWN = GetGameTimer()

Routes = {
    ["CLOSE_INVENTORY"] = function(data)
        if data.right then 
            Remote._emitCloseListeners()
        end
        SetNuiFocus()
        API.isInVehicleChest()
    end,

    ["PLAY_SOUND"] = function(data)
        if data.sound == 'success' then
            PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
        elseif data.sound == 'error' then
            PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
        end
    end,

    ["SHOP_ACTION"] = function(data)
        return Remote.shopAction(data.store_name, data.item, data.amount, data.slot)
    end,
    
    ["TAKE_CHEST_ITEM"] = function(data)
        return Remote.takeChestItem(data.item, data.amount,ts(data.slot), ts(data.playerslot))
    end,
    ["STORE_CHEST_ITEM"] = function(data)
        return Remote.storeChestItem(ts(data.slot), data.amount, ts(data.to_slot))
    end,

    ["GET_WEAPONS"] = function()
        return vRP.getWeapons()
    end,
    ["MANAGE_WEAPONS"] = function(data)
        if (COOLDOWN - GetGameTimer()) > 0 then return end
        COOLDOWN = (GetGameTimer() + 3000)
        return Remote.storeWeapons(data.weapons)
    end,
    
    ["GET_INVENTORY"] = function(data)
        return Remote.getInventory()
    end,

    ["SWAP_SLOT"] = function(data)
        return Remote.swapSlot(ts(data.from_slot), tn(data.from_amount), ts(data.to_slot))
    end,

    ["SEND_ITEM"] = function(data)
        return Remote.sendItem(ts(data.slot), tn(data.amount))
    end,
    
    ["USE_ITEM"] = function(data)
        return Remote.useItem(ts(data.slot), tn(data.amount))
    end,

    ["DROP_ITEM"] = function(data)
        return Remote.dropItem(ts(data.slot), tn(data.amount))
    end,

    ["PICKUP_ITEM"] = function(data)
        return Remote.pegarItem(data.id)
    end,

    ["TAKE_INSPECT_ITEM"] = function(data)
        return Remote.takeInspectItem(ts(data.from_slot), ts(data.to_slot), tn(data.amount))
    end,

    ["PUT_INSPECT_ITEM"] = function(data)
        return Remote.putInspectItem(ts(data.from_slot), ts(data.to_slot), tn(data.amount))
    end,

    ["REQUEST_ITEMS_CONFIG"] = function(data)
        local config = Remote.getItems() 
        for k,v in pairs(config) do 
            if v.func then 
                config[k].func = nil
            end
        end
        return config
    end,
}

local NoWait = {
    ["USE_ITEM"] = true
}
CreateThread(function()
    for k,v in pairs(Routes) do
        RegisterNUICallback(k, function(data, cb)
            if not PENDING_CB[k] or NoWait[k] then 
                PENDING_CB[k] = true
                local result = v(data)
                PENDING_CB[k] = nil
                if cb then
                    cb(result)
                end
            else 
                cb(false)
            end
        end)
    end
end)

