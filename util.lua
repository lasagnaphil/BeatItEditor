function drawFPS()
    -- draw the fps
    love.graphics.setColor(255,255,255)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, love.window.getHeight()-20)
end