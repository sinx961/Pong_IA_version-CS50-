--[[
    GD50 2018
    Pong Remake

    -- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a ball which will bounce back and forth between paddles
    and walls until it passes a left or right boundary of the screen,
    scoring a point for the opponent.
]]

Boost = Class{}

function Boost:init(x, y, width, height)
    self.view = true
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 0
    self.dx = 0
end

--[[
    Expects a paddle as an argument and returns true or false, depending
    on whether their rectangles overlap.
]]
function Boost:collides(ball)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > ball.x + ball.width or ball.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > ball.y + ball.height or ball.y > self.y + self.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]


function Boost:update()
    if (self.view) then
      self.x = self.x + math.random(0,100)
      self.y = self.y + math.random(0,100)
    end
end

function Boost:render()
  if self.view then
    love.graphics.rectangle('line', self.x , self.y, self.width, self.height)
  end
end
