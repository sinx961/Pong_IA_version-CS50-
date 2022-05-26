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

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    self.difficulty = params.difficulty
end

function ServeState:init()
    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(42, 32)
    player2 = Paddle(VIRTUAL_WIDTH - 42, VIRTUAL_HEIGHT - 158)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2)
end

function ServeState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
      gStateMachine:change('play', {
            difficulty = self.difficulty
        })

    end

    -- before switching to play, initialize ball's velocity based
    -- on player who last scored

end

function ServeState:render()
    love.graphics.setFont(smallFont)
    love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- show the score before ball is rendered so it can move over the text
    displayScore()
    
    player1:render()
    player2:render()
    ball:render()
end

function ServeState:exit()
    -- nothing
end