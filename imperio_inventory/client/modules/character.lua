-- imperio_inventory/client/modules/character.lua

local isPedVisible = false
local clonedPed = nil
local heading = 282.6

function API.showCharacter()
    if isPedVisible then return end

    isPedVisible = true
    local playerPed = PlayerPedId()

    -- Ativa o menu de fundo para renderização
    ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_EMPTY_NO_BACKGROUND"), true, -1)
    
    -- Clona o ped do jogador
    clonedPed = ClonePed(playerPed, heading, true, false)
    FreezeEntityPosition(clonedPed, true)
    SetEntityInvincible(clonedPed, true)
    SetEntityCollision(clonedPed, false, false)

    -- Define a posição do ped clonado
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    local fov = 50.0
    local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.5, 0.5)
    SetCamActive(cam, true)
    RenderScriptCams(1, 0, 0, 1, 1)
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    PointCamAtCoord(cam, x, y, z + 0.5)
    SetCamFov(cam, fov)
    
    -- Posiciona o ped clonado na frente da câmera de forma que ele fique visível no menu
    local ped_coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
    SetEntityCoords(clonedPed, ped_coords.x, ped_coords.y, ped_coords.z - 1.0, 0.0, 0.0, 0.0, false)
    SetEntityHeading(clonedPed, GetEntityHeading(PlayerPedId()) - 180.0)
    
    -- Iluminação específica para o ped no menu
    SetPauseMenuPedLighting(true)
    SetPauseMenuPedRgb(1.0, 1.0, 1.0)
end

function API.hideCharacter()
    if not isPedVisible then return end

    isPedVisible = false
    
    -- Desativa o menu de fundo
    ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_EMPTY_NO_BACKGROUND"), false, -1)
    
    -- Deleta o ped clonado
    if DoesEntityExist(clonedPed) then
        DeleteEntity(clonedPed)
    end
    clonedPed = nil

    -- Limpa a câmera
    RenderScriptCams(0, 1, 500, 1, 1)
    DestroyAllCams(true)
    
    -- Reseta a iluminação
    SetPauseMenuPedLighting(false)
end

-- Rotação do personagem
CreateThread(function()
    while true do
        if isPedVisible then
            if IsControlPressed(0, 11) then -- Botão esquerdo do mouse
                heading = heading + 2.0
                SetEntityHeading(clonedPed, heading)
            end
        end
        Wait(5)
    end
end)