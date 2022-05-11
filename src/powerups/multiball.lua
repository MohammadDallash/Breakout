multiball = Class{__includes = BasePowerUp}

function multiball:init()
    
    self.BallsTable = {} 

end



function multiball:start(params) 
     
    play = gStateMachine.current
    local dx = math.random(-400, 400)
    local dy = math.random(-100, -120)
     
    table.insert(self.BallsTable, Ball(1, params.x, params.y, dx, dy))
    
    
    table.insert(self.BallsTable, Ball(1, params.x,params.y, 100*dx/math.random(85, 120), 100*dy /math.random(85, 120)) )
end


function multiball:disable() end
function multiball:update(dt)
    for k, iterratingBall in pairs(self.BallsTable) do
        if iterratingBall:collides(play.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            iterratingBall.y = play.paddle.y - iterratingBall.height
            iterratingBall.dy = -iterratingBall.dy
    
            --
            -- tweak angle of bounce based on where it hits the paddle
            --
    
            -- if we hit the paddle on its left side while moving left...
            if iterratingBall.x < play.paddle.x + (play.paddle.width / 2) and play.paddle.dx < 0 then
                iterratingBall.dx = -50 + -(8 * (play.paddle.x + play.paddle.width / 2 - iterratingBall.x))
            
                -- else if we hit the paddle on its right side while moving right...
            elseif iterratingBall.x > play.paddle.x + (play.paddle.width / 2) and play.paddle.dx > 0 then
                iterratingBall.dx = 50 + (8 * math.abs(play.paddle.x + play.paddle.width / 2 - iterratingBall.x))
            end
            
            gSounds['paddle-hit']:play()
        end

        for k, iterratingBrick in pairs(play.bricksTable) do
            --manage ball reflections
            if iterratingBrick.inPlay and iterratingBall:collides(iterratingBrick) then
                -- trigger the brick's hit function, which removes it from play
                iterratingBrick:hit()
    
    
                play.score = play.score + (iterratingBrick.tier * 200 + iterratingBrick.color * 25)
                play.deltascore = play.deltascore +  (iterratingBrick.tier * 200 + iterratingBrick.color * 25)
                if play.deltascore > 1000 then
                    play.deltascore = play.deltascore - 1000
                    play.paddle.size = math.max(play.paddle.size + 1, 4)
                    play.paddle.width = play.paddle.size * 32
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
                if iterratingBall.x + 2 < iterratingBrick.x and iterratingBall.dx > 0 then
                    
                    -- flip x velocity and reset position outside of iterratingBrick
                    iterratingBall.dx = -iterratingBall.dx
                    iterratingBall.x = iterratingBrick.x - iterratingBall.width
                
                -- right edge; only check if we're moving left
                elseif iterratingBall.x + 6 > iterratingBrick.x + iterratingBrick.width and iterratingBall.dx < 0 then
                    
                    -- flip x velocity and reset position outside of iterratingBrick
                    iterratingBall.dx = -iterratingBall.dx
                    iterratingBall.x = iterratingBrick.x - iterratingBall.width + iterratingBrick.width
                
                -- top edge if no X collisions, always check
                elseif iterratingBall.y < iterratingBrick.y then
                    
                    -- flip y velocity and reset position outside of iterratingBrick
                    iterratingBall.dy = -iterratingBall.dy
                    iterratingBall.y = iterratingBrick.y - iterratingBall.height
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of iterratingBrick
                    iterratingBall.dy = -iterratingBall.dy
                    iterratingBall.y = iterratingBrick.y + iterratingBrick.height
                end
    
                -- slightly scale the y velocity to speed up the game
                iterratingBall.dy = iterratingBall.dy * 1.02
                
                -- only allow colliding with one iterratingBrick, for corners
                break
            end
        
            if iterratingBall.y >= WINDOW_HEIGHT then 
                table.remove(self.BallsTable, iterratingBall)
            end
        end
    
    
    
        iterratingBall:update(dt)
    end

end

function multiball:render() 
    for k, iterratingBall in pairs(self.BallsTable) do
        iterratingBall:render()
    end
end