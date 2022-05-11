Brick = Class{}

--colors shit
    paletteColors = {
    -- blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
    }

function Brick:init(x, y)
    -- used for coloring and score calculation
    self.locked = false

    self.color = 1
    self.tier = 0
    
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16


    
    -- used to determine whether this brick should be rendered
    self.inPlay = true

    -- particle system belonging to the brick, emitted on hit
        self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

        -- various behavior-determining functions for the particle system
        -- https://love2d.org/wiki/ParticleSystem

        -- lasts between 0.5-1 seconds seconds
        self.psystem:setParticleLifetime(0.5, 1)

        -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
        -- gives generally downward 
        self.psystem:setLinearAcceleration(-15, 0, 15, 80)

        -- spread of particles; normal looks more natural than uniform, which is clumpy; numbers
        -- are amount of standard deviation away in X and Y axis
        self.psystem:setAreaSpread('normal', 10, 10)
end

--check whether the brick got hit, play a sound, pretend it does not exist ann more
function Brick:hit()
     -- set the particle system to interpolate between two colors; in this case, we give
    -- it our self.color but with varying alpha; brighter for higher tiers, fading to 0
    -- over the particle's lifetime (the second color)
    self.psystem:setColors(
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        55 * (self.tier + 1) / 255,
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        0
    )
    self.psystem:emit(64)
    
    -- sound on hit
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    -- if we're at a higher tier than the base, we need to go down a tier
    -- if we're already at the lowest color, else just go down a color
    if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
        -- if we're in the first tier and the base color, remove brick from play
        if self.color == 1 then
            self.inPlay = false
            table.insert(gStateMachine.current.powerupsAvatarsTable, Powerup(self.x + (self.width/2-8), self.y, math.random(1, 6)))
        else
            self.color = self.color - 1
        end
    end

    -- play a second layer sound if the brick is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
    love.graphics.setFont(gFontsTable['large'])
    love.graphics.printf('unnnn', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
end

function Brick:render()
    if self.inPlay then
        if self.locked == true then
            love.graphics.draw(gTextures['main'], gFrames['bricks'][24], self.x, self.y)
        else
            love.graphics.draw(gTextures['main'], 
            -- multiply color by 4 (-1) to get our color offset, then add tier to that
            -- to draw the correct tier and color brick onto the screen
            gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
            self.x, self.y)
        end
    end
end

function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end