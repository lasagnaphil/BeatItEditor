local class = require 'middleclass'

local Note = require 'note'
local IO = require 'IO'

local Score = class('Score')

function Score:initialize()
    self.songname = "Test Song"
    self.artist = "Test Artist"
    
    self.notes = {}
    self.checkpoint = 0
    self.isLoaded = false
    self.isPaused = true
    self.bpm = 0
    self.position = 0
    
    self.target = { x = 600, y = 200 }
    self.bounds = { l = 50, r = 1150 }
    self.boundLength = self.bounds.r - self.bounds.l
    self.boundSeconds = 8 -- (how many seconds of notes shown in the screen)
    self.barNumber = 4
    
    self.io = IO:new()
end

function Score:loadMusic(filename)
    self.musicName = filename
    self.music = love.audio.newSource(filename)
    local soundData = love.sound.newSoundData(love.sound.newDecoder(filename, 1024*1024*5))
    self.duration = soundData:getDuration()
    self.isLoaded = true
end

function Score:setBPM(bpm)
    if bpm then
        self.bpm = bpm
        self.quantizedTime = 60 / bpm
        return true
    else
        return false
    end
end

function Score:addNote(pos)
    local quantizedPosition = self.quantizedTime * math.floor(self.position / self.quantizedTime + 0.5)
    local foundDuplicate = false
    for _,note in ipairs(self.notes) do
        if note.position == quantizedPosition then
            foundDuplicate = true
        end
    end
    if not foundDuplicate then table.insert(self.notes, Note:new((pos or quantizedPosition), "default")) end
end

function Score:updateNotePosition()
    for _,note in ipairs(self.notes) do
        note:updateX(self)
    end
end
function Score:addCheckpoint()
    self.checkpoint = self.position
end

function Score:update(dt)
    self.position = self.music:tell("seconds")
    for _,note in ipairs(self.notes) do
        note:update(dt, self)
        if note.toDestroy then
            table.remove(self.notes,_)
        end
    end 
end

function Score:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.line(self.bounds.l,self.target.y,self.bounds.r,self.target.y)
    love.graphics.line(self.target.x,self.target.y-50,self.target.x,self.target.y+50)
    for _,note in ipairs(self.notes) do
        note:draw(self)
    end
    -- draw the lines that separate the bars
    love.graphics.setColor(255,255,255)
    local barSeconds = (self.barNumber * (self.quantizedTime or 0.5))
    local barPos = math.floor((self.position-self.boundSeconds/2)/barSeconds)* barSeconds
    while barPos < self.position + self.boundSeconds/2 do
        function convertPosToX(pos)
            return (pos-self.position)*self.boundLength / self.boundSeconds
        end
        local barX = convertPosToX(barPos)
        love.graphics.line(self.target.x - barX,self.target.y-20,self.target.x - barX,self.target.y+20)
        for i=1,3 do
            barPos = barPos + barSeconds/4
            barX = convertPosToX(barPos)
            love.graphics.line(self.target.x - barX,self.target.y-10,self.target.x - barX,self.target.y+10)
        end
        barPos = barPos + barSeconds/4
    end
    love.graphics.setColor(100,100,100)
    --love.graphics.rectangle("fill",0,self.target.y-50,self.bounds.l,self.target.y+50)
    --slove.graphics.rectangle("fill",self.bounds.r,self.target.y-50,love.window.getWidth(),self.target.y+50)
end

function Score:mousepressed(x, y, button)
    for _,note in ipairs(self.notes) do
        note:checkMousePressed(x-self.target.x, y-self.target.y, button)
    end
end

function Score:mousereleased(x, y, button)
    for _,note in ipairs(self.notes) do
        note:mousereleased(x-self.target.x, y-self.target.y, button, self)
    end
end

function Score:import()
    self.io:import(self)
end
function Score:export()
    self.io:export(self)
end

return Score