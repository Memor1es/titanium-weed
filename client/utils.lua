WeedPlant = {}
isDoingAction = false

local isDataPreLoaded = false

RegisterNetEvent('weed:client:plantCreated')
AddEventHandler('weed:client:plantCreated', function(weedObject)
    if isDataPreLoaded then
        table.insert(WeedPlant, weedObject)
    end
end)

RegisterNetEvent('weed:client:plantDeleted')
AddEventHandler('weed:client:plantDeleted', function(_plant_key)
    if isDataPreLoaded then
        local weedObject = nil

        for i=1, #WeedPlant, 1 do
            if WeedPlant[i].plant_key == _plant_key then               
                weedObject = WeedPlant[i]
                weedObject.tableID = i
                break
            end
        end

        if (weedObject ~= nil) then
            table.remove(WeedPlant, weedObject.tableID)
        end
    end
end)
RegisterNetEvent('weed:client:updatePlants')
AddEventHandler('weed:client:updatePlants', function(plants, isForced)
    if not isDataPreLoaded and isForced then
        isDataPreLoaded = true
    end
    if isDataPreLoaded then
        WeedPlant = plants
    end
end)

local offsetCoords, testRay, _, hit, hitLocation, surfaceNormal, material, _ = nil, nil, nil, nil, nil, nil, nil, nil
RegisterNetEvent('weed:client:sowWeed')
AddEventHandler('weed:client:sowWeed', function(seedType)
    if not isDataPreLoaded then
        return
    end

    offsetCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -2.0)
    testRay = StartShapeTestRay(GetEntityCoords(PlayerPedId()), offsetCoords, 17, PlayerPedId(), 7) 
    _, hit, hitLocation, surfaceNormal, material, _ = GetShapeTestResultEx(testRay)

    if hit == 1 then
        if Globals.GroundsAllowed[material] then
            if SurfaceCheck(surfaceNormal) then
                if not CheckClosePlants(offsetCoords) then
                    isDoingAction = true
                    --INVI.ShowNotification('info', 'Trwa sadzenie marihuany!', 2000)
                    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                    Citizen.Wait(10000)
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('weed:server:sowWeed', offsetCoords, seedType)
                    isDoingAction = false
                else
                    --INVI.ShowNotification('info', 'Sadzisz zbyt blisko innej rośliny!', 2000)
                end
            else
                --INVI.ShowNotification('info', 'Zbyt strome podłoże!', 2000)
            end
        else
           --INVI.ShowNotification('info', 'Gleba nie nadaje się do uprawy!', 2000)
        end
    else
        --INVI.ShowNotification('info', 'Nie znaleziono podłoża!', 2000)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    TriggerServerEvent('weed:server:debug:requestUpdate')
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        WeedPlant = nil
        for k,v in pairs(SpawnedObjects) do
            ForceDeleteObject(SpawnedObjects[k].object)
        end
	end
end)

RegisterNUICallback('NUIFocusOFF', function()
    SetNuiFocus(false, false)
    isDoingAction = false
end)
RegisterNUICallback('showMessage', function(data)
    --INVI.ShowNotification('info', data.msg, 2000)
end)
RegisterNUICallback('plant_use_water', function(data)
    isDoingAction = true   
    TaskTurnPedToFaceEntity(PlayerPedId(), SpawnedObjects[data._plant_key].object, -1)
    Citizen.Wait(1500)
    TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_KNEEL", 0, false)
    Citizen.Wait(5000)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('weed:server:actionOnPlant', 1, data._plant_key)
    isDoingAction = false
end)
RegisterNUICallback('plant_use_fertilizer', function(data)
    isDoingAction = true
    TaskTurnPedToFaceEntity(PlayerPedId(), SpawnedObjects[data._plant_key].object, -1)
    Citizen.Wait(1500)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, false)
    Citizen.Wait(5000)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('weed:server:actionOnPlant', 2, data._plant_key)
    isDoingAction = false
end)
RegisterNUICallback('plant_use_scissors', function(data)
    if SpawnedObjects[data._plant_key] == nil or not DoesEntityExist(SpawnedObjects[data._plant_key].object) then
        return
    end

    isDoingAction = true
    SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
    TaskTurnPedToFaceEntity(PlayerPedId(), SpawnedObjects[data._plant_key].object, -1)
    Citizen.Wait(1500)
    RequestAnimDict("oddjobs@shop_robbery@rob_till")
	while not HasAnimDictLoaded("oddjobs@shop_robbery@rob_till") do
		Citizen.Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), "oddjobs@shop_robbery@rob_till", "loop", 1.0, -0.8, -1, 1, 0, false, false, false)
    SetEntityAnimSpeed(PlayerPedId(), "oddjobs@shop_robbery@rob_till", "loop", 0.2)
    Citizen.Wait(10000)
    SetEntityAnimSpeed(PlayerPedId(), "oddjobs@shop_robbery@rob_till", "loop", 1.0)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('weed:server:actionOnPlant', 3, data._plant_key)
    isDoingAction = false
end)

ForceDeleteObject = function(objhandle)
    DeleteObject(objhandle)

    if DoesEntityExist(objhandle) then
        NetworkRequestControlOfEntity(objhandle)
        while not NetworkHasControlOfEntity(objhandle) do
            Citizen.Wait(0)
        end
        
        DetachEntity(objhandle, 0, false)
        SetEntityCollision(objhandle, false, false)
        SetEntityAlpha(objhandle, 0.0, true)
        SetEntityAsMissionEntity(objhandle, true, true)
        SetEntityAsNoLongerNeeded(objhandle)
        DeleteObject(objhandle)
    end
end

Citizen.CreateThread(function()
	while true do
		if isDoingAction then
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
		Citizen.Wait(10)
	end
end)

Citizen.CreateThread(function()
	while true do
		Globals.CurrentLocalPedCoords = GetEntityCoords(PlayerPedId())
		Citizen.Wait(500)
	end
end)

SurfaceCheck = function(surfaceNormal)
    local x = math.abs(surfaceNormal.x)
    local y = math.abs(surfaceNormal.y)
    local z = math.abs(surfaceNormal.z)
    return (x <= 0.7 and y <= 0.7 and z >= 1.0 - 0.7)
end

CalculatePlantHeight = function(level)
    local height = 0

    if (level < 20.0) then
        height = -0.5
    elseif (level >= 20.0 and level < 30.0) then
        height = -0.25
    elseif (level >= 30.0 and level < 40.0) then
        height = -0.05
    elseif (level >= 40.0 and level < 50.0) then
        height = 0.0
    elseif (level >= 50.0 and level < 70.0) then
        height = 0.25
    elseif (level >= 70.0 and level < 90.0) then
        height = 0.5
    elseif (level >= 90) then
        height = 1.0
    end

    return height
end

CleanupNoCloseObject = function(currentList)
    for k,v in pairs(SpawnedObjects) do
        if not IsClosestObject(k, currentList) then
            ForceDeleteObject(SpawnedObjects[k].object)
            SpawnedObjects[k] = nil
        end
    end
end

IsClosestObject = function(plant_key, list)
    for i=1, #list, 1 do
        if list[i].plant_key == plant_key then
            return true
        end
    end
    return false
end

OpenMenu = function(weedObject)
    isDoingAction = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        water = weedObject.water,
        fertilizer = weedObject.fertilizer,
        sun = (weedObject.sun/2)*100,
        level = weedObject.progress,
        plant_key = weedObject.plant_key
    })
end

CheckClosePlants = function(coords)
    local found = false

    for i=1, #WeedPlant, 1 do
        if GetDistanceBetweenCoords(coords, WeedPlant[i].position.x, WeedPlant[i].position.y, WeedPlant[i].position.z+1.5, true) <= 2.0 then
            found = true
            break
        end
    end
    return found
end
