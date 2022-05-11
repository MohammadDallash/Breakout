shrinkpaddle = Class{__includes = BasePowerUp}

function  shrinkpaddle:start() 

    gStateMachine.current.paddle.size =  math.max(gStateMachine.current.paddle.size - 1, 1)

end



function shrinkpaddle:disable() end
function shrinkpaddle:update(dt) end
function shrinkpaddle:render() end