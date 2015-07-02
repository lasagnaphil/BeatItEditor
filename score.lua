local class = require 'middleclass'

local Score = class('Score')

function Score:initialize()
    self.beats = {}
    self.isPaused = false
    self.bpm = 0
end

function Score:loadMusic(filename)
    self.musicName = filename
    self.music = love.audio.newSource(filename)
    local soundData = love.sound.newSoundData(love.sound.newDecoder(filename, 1024*1024*5))
    self.duration = soundData:getDuration() -- the code does not work (hmm)
end

function Score:addBeat(pos, beatType)
    table.insert(self.beats, {pos = pos, beatType = beatType})
end

function Score:update(dt)
    
end


return Score