local gui = require "Quickie"
require 'util'

local Score = require 'score'

local mousePressed = false
local mouseReleaseTrigger = false
local isLoaded = false
local fileInput = {text = "music.mp3"}
local bpmInput = {text = ""}
local zoomSlider = {value = .5}
local musicSlider = {value = .5}

function love.load()
    love.window.setMode(1024, 768)
    score = Score:new()
end

function love.update(dt)
    if score.isLoaded then score:update(dt) end
    guiUpdate(dt)
end

function guiUpdate(dt)
    
    --
    -- the top row of objects
    --

    gui.group.push{grow = "right", pos = {5,5}}
    
    -- Load input and button
    gui.Input{info = fileInput, size = {100}}
    if gui.Button{id = "Load", text = "Load"} then
        score:loadMusic(fileInput.text)
    end
        
    -- Close button
    if gui.Button{id = "Close", text = "Close"} then
        
    end
    
    -- BPM text input
    gui.Label{text = "", size = {50}}
    gui.Label{text = "BPM", size = {40}}
    gui.Input{info = bpmInput, size = {100}}
    if gui.Button{id = "SetBPM", text = "Set"} then
        -- set the score object's bpm to the input
        if not score:setBPM(tonumber(bpmInput.text)) then
            love.window.showMessageBox("Error", "BPM must be a number", "info")
        end
    end
    
    gui.Label{text = "", size = {50}}
    if gui.Button{id = "Import", text = "Import"} then
        score:import()
    end
    if gui.Button{id = "Export", text = "Export"} then
        score:export()
    end
    
    gui.group.pop{}
    
    --
    -- navigate editor
    --
    
    gui.group.push{grow = "right", pos = {5,55}}
    
    gui.Label{text = "Zoom:", size = {50}}
    if gui.Slider{info = zoomSlider, size = {100}} then
        score.boundSeconds = zoomSlider.value * 8
        score:updateNotePosition()
    end
    
    gui.group.pop{}
    
    --
    -- music player
    --
    
    gui.group.push{grow = "right", pos = {5,305}}

    -- Pause Button
    if gui.Button{id = "Pause", text = "Pause"} then
        score.music:pause()
        score.isPaused = true
    end
    
    -- Play Button
    if gui.Button{id = "Play", text = "Play"} then
        if score.bpm == 0 then
            love.window.showMessageBox("Error", "Set BPM First", "info")
        end
        if score.isPaused then score.music:resume() else score.music:play() end
        score.isPaused = false
    end
    
    -- Rewind Button
    if gui.Button{id = "Rewind", text = "Rewind"} then
        score.music:rewind()
        score.isPaused = true
    end
    
    -- Slider (to change position of song)
    gui.Label{text = "", size = {50}}
    if score.isLoaded then
        if not mousePressed then
            musicSlider.value = score.position / score.duration
        end
    end
    if gui.Slider{info = musicSlider, size = {250}} then
        score.isPaused = true
        score:updateNotePosition()
        score.music:pause()
        score.music:seek(musicSlider.value * score.duration)
    end
    
    gui.group.pop{}
    
    --
    -- the checkpoint buttons
    --
    
    gui.group.push{grow = "right", pos = {5,355}}
    
    if gui.Button{id = "Create Checkpoint", text = "Create Checkpoint", size = {120}} then
        score:addCheckpoint()
    end
    
    if gui.Button{id = "Goto Checkpoint", text = "Goto Checkpoint", size = {120}} then
        score.music:seek(score.checkpoint)
    end
    
    gui.group.pop{}
    
    -- update mouse events
    updateMouseEvents()
end

function updateMouseEvents() mouseReleaseTrigger = false end

function love.draw()
    gui.core.draw()
    score:draw()
    drawFPS()
end

function love.keypressed(key, code)
    gui.keyboard.pressed(key)
    if key == " " then
        if not score.isPaused then
            score:addNote()
        end
    end
end

function love.mousepressed(x, y, button)
    score:mousepressed(x, y, button)
    if button == "l" then
        mousePressed = true
    end
end

function love.mousereleased(x, y, button)
    score:mousereleased(x, y, button)
    if button == "l" then
        mousePressed = false
        mouseReleaseTrigger = true
    end
end

function love.textinput(str)
    gui.keyboard.textinput(str)
end