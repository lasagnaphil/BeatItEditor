local class = require 'middleclass'
JSON = (loadfile "JSON.lua")()

local IO = class('IO')

function IO:initialize()

end

function IO:import(score)
--    self.data = JSON:decode(
end

function IO:export(score)
    
    self.data = {
        name = score.songname,
        author = score.author,
        bpm = score.bpm,
        length = score.duration,
        notes = {}
    }
    
    for _, note in ipairs(score.notes) do
        table.insert(self.data.notes, note.position*1000)
    end
    
    local jsonData = JSON:encode_pretty(self.data)
    local file = io.open(score.songname .. "_data.json", "w")
    file:write(jsonData)
    file:close()
end

return IO
