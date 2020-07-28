local ClosestWeeds = {}
local ClosestWeedPlant = nil

local isMenuOpen = false

SpawnedObjects = {}

Citizen.CreateThread(function()
	RequestModel(Globals.WeedObjectHash)
	TriggerServerEvent('weed:server:debug:requestUpdate')
	while true do
		ClosestWeedPlant = nil

		for i=1, #ClosestWeeds, 1 do
			local closestWeedObject = ClosestWeeds[i]

			if SpawnedObjects[tostring(closestWeedObject.plant_key)] == nil then
				SpawnedObjects[tostring(closestWeedObject.plant_key)] = {}
			end
			if not DoesEntityExist(SpawnedObjects[tostring(closestWeedObject.plant_key)].object) then
				local zOffset = CalculatePlantHeight(closestWeedObject.progress)
				SpawnedObjects[tostring(closestWeedObject.plant_key)].lastHeight = zOffset
				SpawnedObjects[tostring(closestWeedObject.plant_key)].object = CreateObject(Globals.WeedObjectHash, closestWeedObject.position.x, closestWeedObject.position.y, closestWeedObject.position.z+(zOffset), false, true, false)
			else
				local zOffset = CalculatePlantHeight(closestWeedObject.progress)
				if zOffset ~= SpawnedObjects[tostring(closestWeedObject.plant_key)].lastHeight then
					if DoesEntityExist(SpawnedObjects[tostring(closestWeedObject.plant_key)].object) then
						SetEntityCoords(SpawnedObjects[tostring(closestWeedObject.plant_key)].object, closestWeedObject.position.x, closestWeedObject.position.y, closestWeedObject.position.z+(zOffset), false, false, false, false)
					end
				end
			end

			if GetDistanceBetweenCoords(Globals.CurrentLocalPedCoords, closestWeedObject.position.x, closestWeedObject.position.y, closestWeedObject.position.z+1.5, true) <= 1.0 then
				ClosestWeedPlant = closestWeedObject
			end
		end
		Citizen.Wait(300)
	end
end)

Citizen.CreateThread(function()
	while true do
		if ClosestWeedPlant ~= nil and isDoingAction == false then
			if not isMenuOpen then
				SetTextComponentFormat('STRING')
				AddTextComponentString('Naciśnij ~INPUT_CONTEXT~ aby, pielęgnować roślinę')
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				isMenuOpen = true
			end

			if IsControlJustReleased(0, 51) then
				OpenMenu(ClosestWeedPlant)
			end
		else
			if isMenuOpen then
				isMenuOpen = false
			end
			Citizen.Wait(200)
		end
		Citizen.Wait(10)
	end
end)

Citizen.CreateThread(function()
	local closestPlants = {}
	while true do
		CleanupNoCloseObject(ClosestWeeds)
		closestPlants = {}
		for i=1, #WeedPlant, 1 do
			local weedObject = WeedPlant[i]

			if GetDistanceBetweenCoords(Globals.CurrentLocalPedCoords, weedObject.position.x, weedObject.position.y, weedObject.position.z+1, true) < 60.0 then
				table.insert(closestPlants, weedObject)
			end
		end
		ClosestWeeds = closestPlants
		Citizen.Wait(2000)
	end
end)