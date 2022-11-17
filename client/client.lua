local QBCore = exports['qb-core']:GetCoreObject()
local display = false
pickupZoneName = nil
pickupBlip = nil

-- For Animation
local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local tabletAnim = "base"
local tabletProp = 'prop_cs_tablet'
local tabletBone = 60309
local tabletOffset = vector3(0.03, 0.002, -0.0)
local tabletRot = vector3(10.0, 160.0, 0.0)

function doAnimation()
    if not display then return end
    -- Animation
    RequestAnimDict(tabletDict)
    while not HasAnimDictLoaded(tabletDict) do Citizen.Wait(100) end
    -- Model
    RequestModel(tabletProp)
    while not HasModelLoaded(tabletProp) do Citizen.Wait(100) end

    local plyPed = PlayerPedId()

    local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)

    local tabletBoneIndex = GetPedBoneIndex(plyPed, tabletBone)

    AttachEntityToEntity(tabletObj, plyPed, tabletBoneIndex, tabletOffset.x,
                         tabletOffset.y, tabletOffset.z, tabletRot.x,
                         tabletRot.y, tabletRot.z, true, false, false, false, 2,
                         true)
    SetModelAsNoLongerNeeded(tabletProp)

    CreateThread(function()
        while display do
            Wait(0)
            if not IsEntityPlayingAnim(plyPed, tabletDict, tabletAnim, 3) then
                TaskPlayAnim(plyPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49,
                             0, 0, 0, 0)
            end
        end
        ClearPedSecondaryTask(plyPed)
        Wait(250)
        DetachEntity(tabletObj, true, false)
        DeleteEntity(tabletObj)
    end)
end

RegisterNUICallback('items', function(_, cb)

    local itemList = {}
    for k, v in pairs(Config.Items) do
        itemList[#itemList + 1] = {
            name = v.name,
            description = v.description,
            price = v.price,
            image = Config.Inventory .. "/html/images/" ..
                QBCore.Shared.Items[k].image,
            item = k
        }
    end

    cb(itemList)

end)

function createPickupBlipRoute(coords)

    if pickupBlip ~= nil then RemoveBlip(pickupBlip) end

    pickupBlip = AddBlipForCoord(coords)
    SetBlipRoute(pickupBlip, true)
    SetBlipRouteColour(pickupBlip, 43)
    SetBlipSprite(pickupBlip, 514)
    SetBlipAsShortRange(pickupBlip, true)
    SetBlipScale(pickupBlip, 0.8)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Pickup Location')
    EndTextCommandSetBlipName(pickupBlip)
end

function StartPickup(coords)
    SetTimeout(Config.EmailSendTime, function()
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Anonymous Sender',
            subject = 'Your Item is Ready for Pickup',
            message = 'I have added a waypoint to your GPS, please make your way over there to retrieve your item.',
            button = {}
        })
        Wait(1000)
        createPickupBlipRoute(coords)
    end)
end

function createPickupZone(item)
    local pickupZoneInfo = Config.PickupLocations[math.random(1,
                                                              #Config.PickupLocations)]
    pickupZoneName = pickupZoneInfo.name
    QBCore.Functions.Notify(
        'Purchase Successful, you will recieve an email shortly with your pickup location!',
        'success', 7500)
    StartPickup(pickupZoneInfo.coords)

    exports['qb-target']:AddBoxZone(pickupZoneInfo.name, pickupZoneInfo.coords,
                                    pickupZoneInfo.length, pickupZoneInfo.width,
                                    {
        name = pickupZoneInfo.name,
        debugPoly = Config.Debug,
        heading = pickupZoneInfo.heading,
        minZ = pickupZoneInfo.minZ,
        maxZ = pickupZoneInfo.maxZ
    }, {
        options = {
            {
                type = "client",
                action = function()
                    TriggerEvent("qw-darkmarket:client:pickupItem", item)
                end,
                icon = "fas fa-hand",
                label = "Pickup Items"
            }
        },
        distance = 2.0
    })

end

RegisterNetEvent('qw-darkmarket:client:pickupItem', function(item)
    TriggerServerEvent('qw-darkmarket:server:pickupItem', item)
    exports['qb-target']:RemoveZone(pickupZoneName)
    RemoveBlip(pickupBlip)
    pickupZoneName = nil
    pickupBlip = nil
end)

RegisterNUICallback('buyitems', function(data)

    SetDisplay(false)

    QBCore.Functions.TriggerCallback('qw-darkmarket:server:buyItem', function(hasEnough)

        if hasEnough then
            createPickupZone(data.item)
        else
            QBCore.Functions.Notify(
                'You do not have enough money to purchase this item!', 'error',
                7500)
        end

    end, tonumber(data.price))

end)

RegisterNUICallback("exit", function(data) SetDisplay(false) end)

RegisterNUICallback('error', function(data)
    print(data.error)
    SetDisplay(false)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({type = "ui", status = bool})
    doAnimation()
end

RegisterNetEvent('qw-darkmarket:client:openTablet', function()
    local ped = PlayerPedId()

    SetDisplay(not display)
end)

CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)
