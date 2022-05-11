megaball = Class{__includes = BasePowerUp}


function  megaball:start() 

    gStateMachine.current.ball.size = math.min( gStateMachine.current.ball.size + 1, 4)
    gStateMachine.current.ball.width = 8 * gStateMachine.current.ball.size
    gStateMachine.current.ball.height = 8 * gStateMachine.current.ball.size

end


function megaball:disable() end
function megaball:update(dt) end
    

function megaball:render() end