local class = require 'middleclass'

local Note = require 'note'

local Score = class('Score')

function Score:initialize()
    self.notes = {}
    self.checkpoint = 0
    self.isLoaded = false
    self.isPaused = true
    self.bpm = 0
    self.position = 0
    
    self.target = { x = 100, y = 200 }
    self.bounds = { l = 50, r = 750 }
    self.boundLength = self.bounds.r - self.target.x
    self.boundSeconds = 8 -- (how many seconds of notes shown in the screen
end

function Score:loadMusic(filename)
    self.musicName = filename
    self.music = love.audio.newSource(filename)
    local soundData = love.sound.newSoundData(love.sound.newDecoder(filename, 1024*1024*5))
    self.duration = soundData:getDuration()
    self.isLoaded = true
end

function Score:addNote(pos, noteType)
    table.insert(self.notes, Note:new((pos or self.position), (noteType or "default")))
end

function Score:addCheckpoint()
    self.checkpoint = self.position
end

function Score:update(dt)
    self.position = self.music:tell("seconds")
    for _,note in ipairs(self.notes) do
        note:update(dt, self)
    end 
end

function Score:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.line(self.bounds.l,self.target.y,self.bounds.r,self.target.y)
    love.graphics.line(self.target.x,self.target.y-50,self.target.x,self.target.y+50)
    for _,note in ipairs(self.notes) do
        note:draw(self)
    end
end

return Score