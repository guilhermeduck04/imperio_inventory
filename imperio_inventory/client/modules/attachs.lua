-- imperio_inventory/client/modules/attachs.lua

local inAttachMode = false
local weaponObject = nil
local cam = nil
local weaponHeading = 90.0

-- Coordenadas "estúdio" (longe do mapa ou embaixo dele para não ter interferência)
local studioCoords = vector3(1000.0, 1000.0, -200.0) 

function API.enterAttachMode(weaponName)
    if inAttachMode then return end
    inAttachMode = true
    
    -- Congela o jogador e esconde HUD
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    DisplayRadar(false)

    -- Cria o objeto da arma
    local weaponHash = GetHashKey(weaponName)
    RequestModel(weaponHash)
    while not HasModelLoaded(weaponHash) do Wait(10) end

    -- Spawna a arma flutuando
    weaponObject = CreateObject(weaponHash, studioCoords.x, studioCoords.y, studioCoords.z, false, false, false)
    SetEntityHeading(weaponObject, weaponHeading)
    FreezeEntityPosition(weaponObject, true)
    SetModelAsNoLongerNeeded(weaponHash)

    -- Configura a Câmera focada na arma
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, studioCoords.x - 0.8, studioCoords.y, studioCoords.z + 0.2) -- Ajuste de posição (lado)
    PointCamAtEntity(cam, weaponObject, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)

    -- Iluminação extra na arma (opcional, ajuda ver detalhes)
    -- CreateLight... (pode ser adicionado depois)
end

function API.exitAttachMode()
    if not inAttachMode then return end
    inAttachMode = false

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    DisplayRadar(true)

    -- Limpa a câmera
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    cam = nil

    -- Deleta a arma
    if DoesEntityExist(weaponObject) then
        DeleteEntity(weaponObject)
    end
    weaponObject = nil
end

function API.rotateWeapon(moveX)
    if weaponObject and DoesEntityExist(weaponObject) then
        weaponHeading = weaponHeading + (moveX * 0.5) -- Sensibilidade
        SetEntityHeading(weaponObject, weaponHeading)
    end
end

-- Rota para receber movimento do mouse do JS
RegisterNUICallback("ROTATE_WEAPON", function(data, cb)
    API.rotateWeapon(data.x)
    cb("ok")
end)

-- Rota para aplicar o attach (arrastar item para a arma)
RegisterNUICallback("APPLY_ATTACHMENT", function(data, cb)
    local item = data.item
    local currentWeapon = data.weapon -- A arma que está sendo editada
    
    -- Aqui você precisa da lógica para verificar se o item é compatível
    -- Exemplo simplificado:
    TriggerServerEvent("imperio_inventory:applyAttach", item, currentWeapon)
    
    -- Atualiza visualmente components na arma 3D
    -- (Necessário mapear qual componente é qual modelo)
    -- GiveWeaponComponentToWeaponObject(weaponObject, componentHash)
    
    cb("ok")
end)