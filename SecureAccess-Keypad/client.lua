-- main.lua
local correctPassword
local propModel = `vw_prop_casino_keypad_02`
local QBCore = exports['qb-core']:GetCoreObject()

-- Ensure the Config table is available before trying to use it
Config = Config or {}

local createdProps = {}

function GetClosestKeypadProp(playerPed, radius)
    local playerCoords = GetEntityCoords(playerPed)
    local handle, prop = FindFirstObject()
    local success
    local rprop = nil
    local distance = radius

    repeat
        local propCoords = GetEntityCoords(prop)
        if #(playerCoords - propCoords) < distance and GetEntityModel(prop) == propModel then
            distance = #(playerCoords - propCoords)
            rprop = prop
        end
        success, prop = FindNextObject(handle)
    until not success

    EndFindObject(handle)
    return rprop
end

function PlayFobClickAnimation(callback)
    local playerPed = PlayerPedId()
    local animDict = "anim@mp_player_intmenu@key_fob@"
    local animName = "fob_click"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 50, 0, false, false, false)

    Wait(2000)

    ClearPedTasks(playerPed)
    callback()
end

function OpenKeypadUI(propEntity, callback)
    if propEntity then
        PlayFobClickAnimation(function()
            local propPos = GetEntityCoords(propEntity)
            local camOffset = vector3(0.0, -0.5, 0.0)
            local camCoords = GetOffsetFromEntityInWorldCoords(propEntity, camOffset.x, camOffset.y, camOffset.z)
            local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
            PointCamAtCoord(cam, propPos.x, propPos.y, propPos.z - 0.0)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 3000, true, false, false)

            Wait(1000)

            local screenX, screenY = GetScreenCoordFromWorldCoord(propPos.x, propPos.y, propPos.z)

            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openKeypad',
                screenX = screenX,
                screenY = screenY
            })
        end)
    else
        print('No keypad prop found')
    end

    RegisterNUICallback('submitPassword', function(data, cb)
        local enteredPassword = data.password
        if enteredPassword == correctPassword then
            print("Password correct!")
            cb('ok')
            callback(true)
        else
            print("Password incorrect!")
            cb('error')
            callback(false)
        end
    end)
end

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    DestroyCam(cam, false)
    RenderScriptCams(false, false, 0, true, false)
    cb('ok')
end)

RegisterCommand('useKeypad', function()
    local playerPed = PlayerPedId()
    local propEntity = GetClosestKeypadProp(playerPed, 2.0)
    OpenKeypadUI(propEntity, function(result)
        print("Password result: ", result)
    end)
end)

function CreateKeypadProp(coords)
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(1)
    end

    local prop = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(prop, coords.w)
    SetModelAsNoLongerNeeded(propModel)

    table.insert(createdProps, prop)

    return prop
end

function SpawnKeypads()
    for _, coords in ipairs(Config.KeypadLocations) do
        CreateKeypadProp(coords)
    end
end

function DeleteKeypads()
    for _, prop in ipairs(createdProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    createdProps = {}
end

exports('useKeypad', function(password, callback)
    correctPassword = password
    local playerPed = PlayerPedId()
    local propEntity = GetClosestKeypadProp(playerPed, 2.0)
    OpenKeypadUI(propEntity, callback)
end)

RegisterCommand('useExternalKeypad', function()
    local password = "5555"
    exports["SecureAccess-Keypad"]:useKeypad(password, function(result)
        if result then
            QBCore.Functions.Notify("Password correct!", "success")
        else
            QBCore.Functions.Notify("Password incorrect!", "error")
        end
    end)
end, false)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnKeypads()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteKeypads()
    end
end)
