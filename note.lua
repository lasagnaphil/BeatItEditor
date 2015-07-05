local class = require 'middleclass'

local Note = class('Note')

function Note:initialize(pos, noteType)
    self.x, self.y = 0, 0
    self.size = 20
    self.speed = 100
    self.toDestroy = false
    self.position, self.type = pos, noteType
end

function Note:update(dt, score)
    self.x = ((self.position - score.position) / score.boundSeconds) * (-score.boundLength)
end

function Note:draw(score)
    if self.x < score.boundLength then
        love.graphics.setColor(255, 30, 0)
        love.graphics.rectangle("fill", self.x + score.target.x - self.size/2, self.y + score.target.y - self.size/2, self.size, self.size)
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle("line", self.x + score.target.x - self.size/2, self.y + score.target.y - self.size/2, self.size, self.size)
    end
end

return Note