key = Class{__includes = BasePowerUp}


local timer = 0 

function key:start() 
    play = gStateMachine.current
    play.HasAkey = true
end

function key:disable()
end


function key:update(dt)
    if play.HasAkey then
        timer = timer + dt
        if timer > 8 then
            play.HasAkey = false
            timer = 0
        end
    end
end


function key:render() 
    if play.HasAkey then
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 118, 16, 16 - timer * 2, 2)
    end
end


