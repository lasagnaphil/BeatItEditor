local class = require 'middleclass'

local Note = class('Note')

function Note:initialize(pos, noteType)
    self.x, self.y = 0, 0
    self.size = 20
    self.width, self.height = 20, 20
    self.dragging = {active = false, diffX = 0, diffY = 0}
    self.speed = 100
    self.toDestroy = false
    self.position, self.type = pos, noteType
end

function Note:update(dt, score)
    if score.isPaused then
        if self.dragging.active then
            self.x = love.mouse.getX() - score.target.x - self.dragging.diffX
        end
    else
        self:updateX(score)
    end
end

function Note:updateX(score)
    self.x = ((self.position - score.position) / score.boundSeconds) * (-score.boundLength)
end

function Note:updatePositionByX(score)
    self.position = score.position - self.x * score.boundSeconds / score.boundLength
end

function Note:quantize(score)
    local quantizedPosition = score.quantizedTime * math.floor(self.position / score.quantizedTime + 0.5)
    self.position = quantizedPosition
end

function Note:draw(score)
    if self.x < score.boundLength then
        love.graphics.setColor(255, 30, 0)
        love.graphics.rectangle("fill", self.x + score.target.x - self.size/2, self.y + score.target.y - self.size/2, self.size, self.size)
        if self.dragging.active then
            love.graphics.setColor(0,255,0)
        else
            love.graphics.setColor(255,255,255)
        end
        love.graphics.rectangle("line", self.x + score.target.x - self.size/2, self.y + score.target.y - self.size/2, self.size, self.size)
    end
end

function Note:checkMousePressed(x, y, button)
    if x > self.x - self.width/2 and x < self.x + self.width/2 and y > self.y - self.height/2 and y < self.y + self.height/2 then
        self:mousepressed(x, y, button)
    end
end

function Note:mousepressed(x, y, button)
    if button == "l" then
        self.dragging.active = true
        self.dragging.diffX = x - self.x
        self.dragging.diffY = y - self.y

    elseif button == "r" then
        -- right click; do nothing yet
    end
end


function Note:mousereleased(x, y, button, score)
    if button == "l" then
        self.dragging.active = false
        self:updatePositionByX(score)
        self:quantize(score)
        self:updateX(score)
    end
end

return Note