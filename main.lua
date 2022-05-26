--[[
    -- Main Program --

    Author: Simone Di Saverio
    sinx961@gmail.com

    The software is an "improved" version of the game presented 
    by Colton Ogden in the CS50 game development course 

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'lib/push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib/class'


-- import state machine abstract class
require 'lib/StateMachine'
-- import different state (scene) of game from folder scene
require 'scene/TitleScreenState'
require 'scene/ServeState'
require 'scene/PlayState'
require 'scene/DoneState'


-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

require 'Boost'

-- size of our actual window
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 800
VIRTUAL_HEIGHT = 600

-- paddle movement speed
PADDLE_SPEED = 200
DIFFICULT = 5

MAX_SCORE = 2


--Background image for set playground
local background = love.graphics.newImage('resources/fancy-court.png')

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())
    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 26)
    largeFont = love.graphics.newFont('font.ttf', 50)
    scoreFont = love.graphics.newFont('font.ttf', 45)
    love.graphics.setFont(smallFont)

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['serve'] = function() return ServeState() end,
        ['play'] = function() return PlayState() end,
        ['done'] = function() return DoneState() end
    }
    gStateMachine:change('title')


    -- initialize input table
    love.keyboard.keysPressed = {}

    --Boost for ball
    boost = Boost(math.random(50,400), math.random(40,300), 7, 7)

    -- initialize score variables
    player1Score = 0
    player2Score = 0

    player1ScoreOld = player1Score
    player2ScoreOld = player2Score

    time = love.timer.getTime( )
    timeOld = time

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- player who won the game; not set to a proper value until we reach
    -- that state in the game
    winningPlayer = 0
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)

    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end

end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end


--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]
function love.update(dt)
    time= love.timer.getTime()
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position
        -- at which it collided, then playing a sound effect
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if boost:collides(ball) then
          ball.vel = true
          boost.view = false
          timeOld = love.timer.getTime()
        end

        --Control boost effects
        if (time - timeOld) > 30 then
          ball.vel = false
          boost.view = true
          timeOld = love.timer.getTime()
        end

        --Control spown Boost
        if (time -timeOld) > 150 then
          boost:update()
        end

        -- detect upper and lower screen boundary collision, playing a sound
        -- effect and reversing dy if true
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- if we reach the left or right edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}

end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    --push:start()

    love.graphics.draw(background, 0, 0)
    player1:render()
    player2:render()
    ball:render()
    boost:render()

    gStateMachine:render()

    --push:finish()
end

--[[
    Simple function for rendering the scores.
]]
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end