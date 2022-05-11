PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.HasAkey = false
    
    self.LPowerUpMachine
     = PowerUpMachine {
        function() return getalife() end,
        function() return growpaddle() end,
        function() return shrinkpaddle() end,
        function() return megaball() end,
        function() return multiball() end,
        function() return key() end
    }
    
end


function PlayState:enter(params)
  
        self.paddle = params.paddle
        self.bricksTable = params.bricksTable
        self.health = params.health
        self.score = params.score
        self.ball = params.ball
        self.ball.dx = math.random(-400, 400)
        self.ball.dy = math.random(-100, -120)
       
        self.paused = false
        self.level = params.level
        self.highScores = params.highScores
        self.deltascore = 0
        self.powerupsAvatarsTable = {}

end


function PlayState:update(dt)
    
    if self.paused then
        if love.keyboard.wasPressedLastFrame('space') then
            self.paused = false
            gSounds['music']:play()
            gSounds['pause']:play()
        else
            return -----7lwaaaaaaaa fassshhhhhhhhhhhhhh
        end
    elseif love.keyboard.wasPressedLastFrame('space') then
        self.paused = true
        gSounds['pause']:play()
        gSounds['music']:pause()
        return
    end

    if self.ball:collides(self.paddle) then
       -- raise ball above paddle in case it goes below it, then reverse dy
       self.ball.y = self.paddle.y - self.ball.height
       self.ball.dy = -self.ball.dy

       --
       -- tweak angle of bounce based on where it hits the paddle
       --

       -- if we hit the paddle on its left side while moving left...
       if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
           self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
       
           -- else if we hit the paddle on its right side while moving right...
       elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
           self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
       end
       
       gSounds['paddle-hit']:play()
    end

    for k, iterratingBrick in pairs(self.bricksTable) do
        --manage ball reflections
        if iterratingBrick.inPlay and self.ball:collides(iterratingBrick) then
            -- trigger the brick's hit function, which removes it from play
            if not iterratingBrick.locked  then
                iterratingBrick:hit()


                self.score = self.score + (iterratingBrick.tier * 200 + iterratingBrick.color * 25)
                self.deltascore = self.deltascore +  (iterratingBrick.tier * 200 + iterratingBrick.color * 25)
                if self.deltascore > 1000 then
                    self.deltascore = self.deltascore - 1000
                    self.paddle.size = math.max(self.paddle.size + 1, 4)
                    gSounds['powerup']:pause()
                    gSounds['powerup']:play()
                    self.paddle.width = self.paddle.size * 32

                end

            elseif self.HasAkey then
                self.score = self.score + 1500
                gSounds['brick-hit-2']:stop()
                gSounds['brick-hit-2']:play()
                iterratingBrick.inPlay = false
            else
                gSounds['brick-hit-1']:stop()
                gSounds['brick-hit-1']:play()
            end


            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right
            if self.ball.x + 2 < iterratingBrick.x and self.ball.dx > 0 then
                
                -- flip x velocity and reset position outside of iterratingBrick
                self.ball.dx = -self.ball.dx
                self.ball.x = iterratingBrick.x - self.ball.width
            
            -- right edge; only check if we're moving left
            elseif self.ball.x + 6 > iterratingBrick.x + iterratingBrick.width and self.ball.dx < 0 then
                
                -- flip x velocity and reset position outside of iterratingBrick
                self.ball.dx = -self.ball.dx
                self.ball.x = iterratingBrick.x - self.ball.width + iterratingBrick.width
            
            -- top edge if no X collisions, always check
            elseif self.ball.y < iterratingBrick.y then
                
                -- flip y velocity and reset position outside of iterratingBrick
                self.ball.dy = -self.ball.dy
                self.ball.y = iterratingBrick.y - self.ball.height
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of iterratingBrick
                self.ball.dy = -self.ball.dy
                self.ball.y = iterratingBrick.y + iterratingBrick.height
            end

            -- slightly scale the y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02
            
            -- only allow colliding with one iterratingBrick, for corners
            break
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()
        self.paddle.size = math.max(self.paddle.size - 1, 1)
        self.paddle.width = 32 * self.paddle.size

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricksTable = self.bricksTable,
                health = self.health,
                score = self.score,
                level = self.level,
                highScores = self.highScores
            })
        end
    end


    
    if self:checkVictory() then
        gSounds['victory']:play()
        gStateMachine:change('victory', {
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            ball = self.ball,
            level = self.level,
            highScores = self.highScores

        })
    end
    -- update positions based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)
    self.LPowerUpMachine:update(dt)
    
    --particals sys 
    for k, iterratingPowerUp in pairs(self.powerupsAvatarsTable) do
        if iterratingPowerUp:collides(self.paddle) and iterratingPowerUp.rendering then
            gSounds['powerup']:pause()
            gSounds['powerup']:play()
            self.LPowerUpMachine:apply(iterratingPowerUp.type, {x = iterratingPowerUp.x ,y = iterratingPowerUp.y})
            iterratingPowerUp.rendering = false
            
            
            --table.remove(self.powerupsAvatarsTable, k)
        elseif iterratingPowerUp.y >= VIRTUAL_HEIGHT then
            table.remove(self.powerupsAvatarsTable, k)
        end
    end

    for k, iterratingBrick in pairs(self.bricksTable) do
        iterratingBrick:update(dt)
    end
    
    for k, iterratingPowerUp in pairs(self.powerupsAvatarsTable) do
        iterratingPowerUp:update(dt)
    end


    
    if love.keyboard.wasPressedLastFrame('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()

    

    
    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFontsTable['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

        
    renderScore(self.score)
    renderHealth(self.health)
    self.LPowerUpMachine:render()

    for k, iterratingBrick in pairs(self.bricksTable) do
        iterratingBrick:render()
    end

    


    if self.HasAkey then
        love.graphics.draw(gTextures['main'], gFrames['power-ups'][6], VIRTUAL_WIDTH - 118, 0)
    end

    for k, iterratingBrick in pairs(self.bricksTable) do
        iterratingBrick:renderParticles()
    end
    
    for k, iterratingPowerUp in pairs(self.powerupsAvatarsTable) do
        iterratingPowerUp:render()
    end

end

function PlayState:checkVictory()
    for k, iterratingBrick in pairs(self.bricksTable) do
        if iterratingBrick.inPlay then
            return false
        end 
    end

    return true
end



    