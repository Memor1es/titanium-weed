CreateWeedObject = function()
	local self = {}

	self.plant_key = nil
	self.position = {x = 0.0, y = 0.0, z = 0.0}

	self.automatic = 1
	self.isFlaggedToDelete = false

	self.progress = 0.0
	self.water = 30.0
	self.fertilizer = 30.0
	self.sun = 0.0

	self.isAutomatic = function()
		return self.automatic
	end
	self.getStatus = function()
		return {water = self.water, fertilizer = self.fertilizer, progress = self.progress}
	end
	self.calculateNeeds = function(sun)
		local currentScoreboard = Globals.Scoreboard
		local score = 0

		if (self.fertilizer >= 20.0 and self.fertilizer < 50.0) then
			score = score+Globals.Scoreboard["fertilizer"]["bad"]
		elseif (self.fertilizer >= 50.0 and self.fertilizer < 75.0) then
			score = score+Globals.Scoreboard["fertilizer"]["good"]
		elseif (self.fertilizer >= 75) then
			score = score+Globals.Scoreboard["fertilizer"]["best"]
		end

		if (self.water < 20.0) then
			score = -1
		elseif (self.water >= 20.0 and self.water < 40.0) then
			score = score+Globals.Scoreboard["water"]["bad"]
		elseif (self.water >= 40.0 and self.water < 60.0) then
			score = score+Globals.Scoreboard["water"]["good"]
		elseif (self.water >= 60.0 and self.water < 95.0) then
			score = score+Globals.Scoreboard["water"]["best"]
		elseif (self.water >= 95) then
			score = -1
		end

		if (score == -1) then
			score = (self.progress*-1) + (-1)
		else
			if (self.automatic == 1) then
				score = score/2
			elseif (self.automatic == 0) then
				score = score/4
			end

			if (self.automatic == 1) then
				score = (score * sun/2) * Globals.Main_Scale
			elseif (self.automatic == 0) then
				score = (score * sun/2) * 1.5
			end

			if (self.progress + score) >= 100.0 then
				score = 100.0-self.progress
			end
		end
		return score
	end
	
	self.setPosition = function(_coords)
		self.position = {x = _coords.x, y = _coords.y, z = _coords.z}
	end
	self.setSeedType = function(_automatic)
		self.automatic = _automatic
	end
	self.setStatus = function(_status)
		self.progress = _status.p
		self.water = _status.w
		self.fertilizer = _status.f
	end
	self.setPlantKey = function(_key)
		self.plant_key = _key
	end


	self.savePlant = function()
		MySQL.Async.execute('UPDATE `weeds` SET `status`=@status WHERE `plant_key`=@plant_key', {
			["@plant_key"] = self.plant_key,
			["@status"] = json.encode({ w = self.water, f = self.fertilizer, p = self.progress })
		})
	end
	self.createPlant = function(cb)
		MySQL.Async.execute('INSERT INTO `weeds` (`plant_key`,`position`,`status`,`automatic`) VALUES (@plant_key, @position, @status, @automatic)', {
			["@plant_key"] = self.plant_key,
			["@position"] = json.encode(self.position),			
			["@status"] = json.encode({ w = self.water, f = self.fertilizer, p = self.progress }),
			["@automatic"] = self.automatic
		}, function(onRowChanged)
			if onRowChanged then
				cb()
				print('[TITANIUM-WEED] - Created plant ['..self.plant_key..']!')
			end		
		end)
	end
	

	self.runTick = function(sun)
		if (self.progress ~= -1) then
			if (self.progress < 100.0) then
				self.water = self.water-Globals.Minus_Hydration
				if (self.water < 0.0) then
					self.water = 0.0
				end

				self.fertilizer = self.fertilizer-Globals.Minus_Fertilizer
				if (self.fertilizer < 0.0) then
					self.fertilizer = 0.0
				end

				self.sun = sun

				self.progress = (self.progress + self.calculateNeeds(sun))
			end
		else
			self.isFlaggedToDelete = true
		end
	end
	

	self.runAction = function(actionType, calledBy, callback)
		if (actionType == 1) then
			if (self.water + Globals.Plus_Hydration >= 100.0) then
				self.water = 100.0
			else
				self.water = self.water+Globals.Plus_Hydration
			end
			SendUpdateMessage(-1, false)

			if (callback) then
				callback(false)
			end
		elseif (actionType == 2) then
			if (self.fertilizer + Globals.Plus_Fertilizer >= 100.0) then
				self.fertilizer = 100.0
			else
				self.fertilizer = self.fertilizer+Globals.Plus_Fertilizer
			end
			SendUpdateMessage(-1, false)
			
			if (callback) then
				callback(false)
			end
		elseif (actionType == 3) then
			if (self.progress >= 95.0) then
				if (callback) then
					DeletePlantByPlantKey(self.plant_key)
					callback(math.random(Globals.Scoreboard["reward"][self.automatic].min, Globals.Scoreboard["reward"][self.automatic].max))
				end
			else
				DeletePlantByPlantKey(self.plant_key)
			end
		end	
	end
	return self
end