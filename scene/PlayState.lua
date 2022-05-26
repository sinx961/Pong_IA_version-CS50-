--[[
    GD50 2018
    Match-3 Remake

    -- BaseState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Used as the base class for all of our states, so we don't have to
    define empty methods in each of them. StateMachine requires each
    State have a set of four "interface" methods that it can reliably call,
    so by inheriting from this base state, our State classes will all have
    at least empty versions of these methods even if we don't define them
    ourselves in the actual classes.
]]

--[[
    TitleScreenState Class
    
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The TitleScreenState is the starting screen of the game, shown on startup. It should
    display "Press Enter" and also our highest score.
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.difficulty = params.difficulty
end

function PlayState:init()

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

end

function PlayState:update(dt)

    -- detect ball collision with paddles, reversing dx if true and
    -- slightly increasing it, then altering the dy based on the position
    -- at which it collided, then playing a sound effect
    if ball:collides(player1) then
        ball.dx = -ball.dx

        -- keep velocity going in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        sounds['paddle_hit']:play()
    end
    if ball:collides(player2) then
        ball.dx = -ball.dx

        -- keep velocity going in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        sounds['paddle_hit']:play()
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
        if player2Score == MAX_SCORE then
            winningPlayer = 2
            gStateMachine:change('done', {
                winningPlayer = winningPlayer
            })
        else
            gStateMachine:change('serve', {
            difficulty = self.difficulty
        })
            
            -- places the ball in the middle of the screen, no velocity
            ball:reset()
        end
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        sounds['score']:play()

        if player1Score == MAX_SCORE then
            winningPlayer = 1
            gStateMachine:change('done',{
            winningPlayer = winningPlayer
        })
        else
            gStateMachine:change('serve', {
            difficulty = self.difficulty
        })
            ball:reset()
        end
    end

    ball:update(dt)

    
    if love.keyboard.isDown('up') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 bot
    if ball.dx > 0 then
      if ball.y > player2.y+DIFFICULT then
        player2.dy = PADDLE_SPEED
      elseif ball.y < player2.y-DIFFICULT then
          player2.dy = -PADDLE_SPEED
      else
          player2.dy = 0
      end
    else
      player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
end

function PlayState:render()

    -- show the score before ball is rendered so it can move over the text
    displayScore()

    player1:render()
    player2:render()
    ball:render()
end

function PlayState:exit()
    -- nothing
end