ESX = nil
WeedTable = {}
WeedTableLoaded = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RetrieveDatabase = function()
	local _WeedTable = {}
	if #WeedTable == 0 then
		local dbResult = MySQL.Sync.fetchAll('SELECT * FROM `weeds`', {})

		for i=1, #dbResult, 1 do
			local weedObject = CreateWeedObject()
			weedObject.setPosition(json.decode(dbResult[i].position))
			weedObject.setSeedType(dbResult[i].automatic)
			weedObject.setStatus(json.decode(dbResult[i].status))
			weedObject.setPlantKey(dbResult[i].plant_key)

			table.insert(_WeedTable, weedObject)
			Citizen.Wait(100)
		end
		WeedTable = _WeedTable
		WeedTableLoaded = true
		print('[TITANIUM-WEED] - Recreated plants from database!')
	end
end

CalculateSun = function()
	local time = exports["vSync"]:getServerTimeClock()
	local weather = exports["vSync"]:getServerWeather()

	local points = Globals.Scoreboard["time"][time.h]

	return tonumber(( points*Globals.Scoreboard["weather"][weather:upper()] ) * 1.0) 
end

CreatePlantWithParams = function(_position, _automatic)
	local weedObject = CreateWeedObject()

	weedObject.setPlantKey(Globals.DailyNumber..'-'..math.random(1000,9999))
	weedObject.setPosition(_position)
	weedObject.setSeedType(_automatic)

	weedObject.createPlant(function()
		table.insert(WeedTable, weedObject)
		TriggerClientEvent('weed:client:plantCreated', -1, weedObject)
	end)
end

DeletePlantByPlantKey = function(_key)
	local weedObject = nil

	for i=1, #WeedTable, 1 do
		if WeedTable[i].plant_key == _key then
			WeedTable[i].tableID = i
			weedObject = WeedTable[i]
			break
		end
	end

	if weedObject ~= nil then
		MySQL.Async.execute('DELETE FROM `weeds` WHERE `plant_key`=@plant_key', {
			["@plant_key"] = weedObject.plant_key
		}, function()
			table.remove(WeedTable, weedObject.tableID)
			TriggerClientEvent('weed:client:plantDeleted', -1, weedObject.plant_key)
		end)
	end
end

SendUpdateMessage = function(who, force)
	local publicWeeds = {}

	for i=1, #WeedTable, 1 do
		table.insert(publicWeeds, {
			plant_key = WeedTable[i].plant_key,
			position = WeedTable[i].position,
			progress = WeedTable[i].progress,
			water = WeedTable[i].water,
			fertilizer = WeedTable[i].fertilizer,
			sun = WeedTable[i].sun
		})
	end

	TriggerClientEvent('weed:client:updatePlants', who, publicWeeds, force)
end

RegisterServerEvent('weed:server:sowWeed')
AddEventHandler('weed:server:sowWeed', function(_position, _automatic)
	local xPlayer = ESX.GetPlayerFromId(source)

	CreatePlantWithParams(_position, _automatic)

	if (_automatic == 1) then
		xPlayer.removeInventoryItem('weed_seed_automatic', 1)
	elseif (_automatic == 0) then
		xPlayer.removeInventoryItem('weed_seed_season', 1)
	end
end)

RegisterServerEvent('weed:server:actionOnPlant')
AddEventHandler('weed:server:actionOnPlant', function(_action, _key)
	local xPlayer = ESX.GetPlayerFromId(source)
	local weedObject = nil

	for i=1, #WeedTable, 1 do
		if WeedTable[i].plant_key == _key then
			weedObject = WeedTable[i]
			break
		end
	end

	if weedObject ~= nil then
		if (_action == 1) then
			if xPlayer.getInventoryItem('water').count > 0 then
				xPlayer.removeInventoryItem('water', 1)
				weedObject.runAction(_action, xPlayer.source)
			end
		elseif (_action == 2) then
			if xPlayer.getInventoryItem('ferti').count > 0 then
				xPlayer.removeInventoryItem('ferti', 1)
				weedObject.runAction(_action, xPlayer.source)
			end
		elseif (_action == 3) then
			weedObject.runAction(_action, xPlayer.source, function(reward)
				local xItem = xPlayer.getInventoryItem('weed')
				if ((xItem.count+reward)>xItem.limit) then
					xPlayer.setInventoryItem('weed', xItem.limit)
				else
					xPlayer.addInventoryItem('weed', reward)
				end
			end)
		end
	end
end)

RegisterServerEvent('weed:server:debug:requestUpdate')
AddEventHandler('weed:server:debug:requestUpdate', function()
	local _source = source
	while not (WeedTableLoaded) do
		Citizen.Wait(500)
	end
	SendUpdateMessage(_source, true)
end)

ESX.RegisterUsableItem('weed_seed_automatic', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('weed:client:sowWeed', xPlayer.source, 1)
end)
ESX.RegisterUsableItem('weed_seed_season', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('weed:client:sowWeed', xPlayer.source, 0)
end)