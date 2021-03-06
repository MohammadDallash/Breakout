require  'src/Dependencies'




function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')


    math.randomseed(os.time())


    love.window.setTitle('Breakout')

    -- initialize our nice-looking retro text fonts
        gFontsTable = {
            ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
            ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
            ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
        }
        love.graphics.setFont(gFontsTable['small'])

    -- load up the graphics we'll be using throughout our states
        gTextures = {
            ['background'] = love.graphics.newImage('graphics/background.png'),
            ['main'] = love.graphics.newImage('graphics/breakout.png'),
            ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
            ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
            ['particle'] = love.graphics.newImage('graphics/particle.png')
        }

    
        
    -- init ialize our virtual resolution, which will be rendered ewithin our actual window no matter its dimensions
        push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
            vsync = true,
            fullscreen = false,
            resizable = true
        })

    -- set up our sound effects; later, we can just index this table andcall each entry's `play` method
        gSounds = {
            ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
            ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
            ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
            ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
            ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
            ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
            ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
            ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
            ['powerup'] = love.audio.newSource('sounds/powerup.wav', 'static'),
            ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
            ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
            ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
            ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
            ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

            ['music'] = love.audio.newSource('sounds/music.wav', 'static')
        }
        gSounds['music']:setLooping(true)
        --gSounds['music']:play()

    
    
    gStateMachine
     = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['high-scoeres'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end
    }
    gStateMachine:change('start', {highScores = loadHighScores()})

    -- Quads we will be generated for all of our textures; Quads allow us to show only part of a texture and not the entire thing
        gFrames = {
            ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
            ['balls'] = GenerateQuadsBalls(gTextures['main']),
            ['bricks'] = GenerateQuadsBricks(gTextures['main']),
            ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
            ['power-ups'] = GenerateQuadsPoweUps(gTextures['main'])
        }
    
        love.keyboard.keysHavePressed = {}

end

function love.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysHavePressed = {}
end

function love.draw()
    push:apply('start')

    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'], 0, 0, 0,
        -- scale factors on X and Y axis so it fills the screen
    VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))
    

    gStateMachine:render()

    displayFPS()
         
    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(gFontsTable['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end
function love.keypressed(key)
    love.keyboard.keysHavePressed[key] = true
end
function love.keyboard.wasPressedLastFrame(key)
    if love.keyboard.keysHavePressed[key] then 
        return true
    else
        return false
    end
end
function love.resize(w, h)
    push:resize(w, h)
end

function renderHealth(health)
    -- start of our health rendering
    local healthX = VIRTUAL_WIDTH - 100
    
    -- render health left
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

 
function renderScore(score)
    love.graphics.setFont(gFontsTable['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function loadHighScores()
    love.filesystem.setIdentity('breakout')

    -- if the file doesn't exist, initialize it with some default scores
    if not love.filesystem.exists('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'zzz\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    -- flag for whether we're reading a name or not
    local name = true
    local currentName = nil
    local counter = 1

    -- initialize scores table with at least 10 blank entries
    local scores = {}

    for i = 1, 10 do
        -- blank table; each will hold a name and a score
        scores[i] = {
            name = nil,
            score = nil
        }
    end
     -- iterate over each line in the file, filling in names and scores
     for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        -- flip the name flag to jumping between odd or even lines
        name = not name
    end

    return scores
end


