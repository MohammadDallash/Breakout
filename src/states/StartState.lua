StartState = Class{__includes = BaseState}

local highlighted = 1 

function StartState:enter(params)
    self.highScores = params.highScores
end


function StartState:update(dt)
    if love.keyboard.wasPressedLastFrame('up') or love.keyboard.wasPressedLastFrame('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end

    if love.keyboard.wasPressedLastFrame('escape') then
        love.event.quit()
    end
    if love.keyboard.wasPressedLastFrame('e') then
        if highlighted == 1 then
            gSounds['confirm']:play()
            gStateMachine:change('serve',
            {
                paddle = Paddle(1),
                bricksTable = LevelMaker.createMap(1),
                health = 3,
                score = 0,
                level = 1,
                highScores = self.highScores 
            }
            )
        else
            gStateMachine:change('high-scores', {
                highScores = self.highScores
            })
        end
       
    end
end


function StartState:render()

    love.graphics.setFont(gFontsTable['large'])
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    
    love.graphics.setFont(gFontsTable['medium'])

    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(0.4, 1, 1, 1)
    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)

    -- render option 2 blue if we're highlighting that one
    if highlighted == 2 then
        love.graphics.setColor(0.4, 1, 1, 1)
    end
    love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)
end


