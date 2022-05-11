ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricksTable = params.bricksTable
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores

    -- init new ball (random color for fun)
    self.ball = Ball()
    self.ball.skin = math.random(7)
end

function ServeState:update(dt)
    -- we can ONLY move the paddle
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - self.ball.width /2
    self.ball.y = self.paddle.y - self.ball.width

    if love.keyboard.wasPressedLastFrame('e') then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricksTable = self.bricksTable,
            health = self.health,
            score = self.score,
            ball = self.ball,
            level = self.level,
            highScores = self.highScores

        })
    end

    if love.keyboard.wasPressedLastFrame('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    for k, brick in pairs(self.bricksTable) do
        brick:render()
    end

        
    renderScore(self.score)
    renderHealth(self.health)


    love.graphics.setFont(gFontsTable['medium'])
    love.graphics.printf('Press E to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end