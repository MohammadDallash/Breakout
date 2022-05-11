getalife = Class{__includes = BasePowerUp}

function  getalife:start() 

    gStateMachine.current.health = math.min(gStateMachine.current.health + 1, 3)

end


function getalife:disable() end
function getalife:update(dt) end
function getalife:render() end