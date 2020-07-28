local function ServerTick()
	local tickSunPoints = CalculateSun()

	for i=1, #WeedTable, 1 do
		local weedObject = WeedTable[i]

		if (weedObject ~= nil) then
			weedObject.runTick(tickSunPoints)

			if not weedObject.isFlaggedToDelete then
				weedObject.savePlant()
			else
				DeletePlantByPlantKey(weedObject.plant_key)
			end
		end
		Citizen.Wait(100)
	end

	SendUpdateMessage(-1, false)
	SetTimeout(Globals.Main_Interval*1000, ServerTick)
end

MySQL.ready(function ()
	RetrieveDatabase()
	ServerTick()
end)