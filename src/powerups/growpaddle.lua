growpaddle = Class{__includes = BasePowerUp}

function  growpaddle:start() 

    gStateMachine.current.paddle.size = math.min(gStateMachine.current.paddle.size + 1, 4)

end


function growpaddle:disable() end
function growpaddle:update(dt) end
function growpaddle:render() end