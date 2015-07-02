local gui = require "Quickie"

local Score = require 'score'
local Renderer = require 'renderer'
local Exporter = require 'exporter'

local mousePressed = false
local mouseReleaseTrigger = false
local isLoaded = false
local fileInput = {text = "music.mp3"}
local bpmInput = {text = ""}
local musicSlider = {value = .5}

function love.load()
    score = Score:new()
    renderer = Renderer:new()
    exporter = Exporter:new()
end

function love.update(dt)
    
    --
    -- the top row of objects
    --

    gui.group.push{grow = "right", pos = {5,5}}
    
    -- Load input and button
    gui.Input{info = fileInput, size = {100}}
    if gui.Button{id = "Load", text = "Load"} then
        score:loadMusic(fileInput.text)
        isLoaded = true
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
        score.bpm = tostring(bpmInput.text)
        if not score.bpm then
            love.window.showMessageBox("Error", "BPM must be a number", "info")
        end
    end
    
    gui.group.pop{}
    
    --
    -- the editor
    --
    
    gui.group.push{grow = "right", pos = {5,305}}

    -- Pause Button
    if gui.Button{id = "Pause", text = "Pause"} then
        score.music:pause()
        score.isPaused = true
    end
    
    -- Play Button
    if gui.Button{id = "Play", text = "Play"} then
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
    if isLoaded then
        if not mousePressed then
            musicSlider.value = score.music:tell("seconds") / score.duration
        else
            if not score.isPaused then score.music:pause() end
            score.music:seek(musicSlider.value * score.duration)
        end
        if mouseReleaseTrigger then
            score.music:play()
        end 
    end
    gui.Slider{info = musicSlider, size = {250}}
    
    
    gui.group.pop{}
    
    -- update mouse events
    updateMouseEvents()
end

function updateMouseEvents() mouseReleaseTrigger = false end

function love.draw()
    gui.core.draw()
end

function love.keypressed(key, code)
    gui.keyboard.pressed(key)
end

function love.mousepressed(x, y, button)
    if button == "l" then
        mousePressed = true
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
        mousePressed = false
        mouseReleaseTrigger = true
    end
end

function love.textinput(str)
    gui.keyboard.textinput(str)
end