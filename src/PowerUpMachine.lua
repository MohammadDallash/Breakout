PowerUpMachine = Class{}

function PowerUpMachine:init(powerups)
	self.empty = {
        start = function() end,
        render = function() end,
		update = function() end,
        disable = function() end
	}
	self.powerupsTable = powerups or {} -- [name] -> [function that returns powerups]
	self.currentpowerups = {self.empty}
end



function PowerUpMachine:apply(powerupN ,params)
	assert(self.powerupsTable[powerupN]) -- powerup must exist!
	
	for k, iterratingPowerUp in pairs(self.currentpowerups) do
		if iterratingPowerUp.readytobestopped == true then
			iterratingPowerUp:disable()
			table.remove(self.currentpowerups, iterratingPowerUp)
		end
	end
	
	self.temp = self.powerupsTable[powerupN]()
	
	--self.current:disable()
	table.insert(self.currentpowerups, self.temp)
	self.temp:start(params)
end

function PowerUpMachine:update(dt)
	for k, iterratingPowerUp in pairs(self.currentpowerups) do
		iterratingPowerUp:update(dt)
	end
end

function PowerUpMachine:render()
	for k, iterratingPowerUp in pairs(self.currentpowerups) do
	iterratingPowerUp:render()
	end
end
