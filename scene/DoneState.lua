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

DoneState = Class{__includes = BaseState}

function DoneState:init()
    -- nothing
end

function DoneState:enter(params)
    self.winningPlayer = params.winningPlayer
end

function DoneState:update(dt)
    if love.keyboard.wasPressed('1') or love.keyboard.wasPressed('return') then
        gStateMachine:change('title')
    end
end

function DoneState:render()
    love.graphics.setFont(largeFont)
    love.graphics.printf('Player ' .. tostring(self.winningPlayer) .. ' wins!',
        0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
end

function DoneState:exit()
    -- nothing
end