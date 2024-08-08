require("conductor")
local editor = require("editor")
local song = "/kk_intermission.ogg"

local testDraw = true

function love.load()
    love.window.setMode(800,600,{resizable=true})
    
    if editor.Enabled == true then
        
    else
        loadedSong = love.audio.newSource(song, "stream")
        metronome = love.audio.newSource("/select.wav", "static")
        loadedSong:setVolume(0.2)
        
        love.graphics.setFont(love.graphics.newFont(32))

        conductor:LoadChart()

        loadedSong:play()
    end
end

function love.update(dt)
    if editor.Enabled == true then
        editor:Update()
    else
        conductor:Update(dt)
    end
    
    --conductor:GetHitAccuracy()
end

function conductor.Metronome()
    testDraw = not testDraw
    
end

local status = ""

function love.mousepressed()

end

function love.keypressed(key)
    if editor.Enabled == true then
    
    else
        local result = conductor:GetHitAccuracy(key)
        if result == nil then return end
        
        if result <= 0.05 then
            status = "Perfect"
        elseif result <= 0.2 then
            status = "Okay"
        elseif result > 0.3 then
            status = "Miss"
        end
    end
end

function love.draw()
    if editor.Enabled == true then
        editor:Draw()
    else
        local circleXOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
        
        for i = 1, 4 do
            love.graphics.circle("line", i * 70 + circleXOffset, 500, 30)
        end
        
        for _, v in ipairs(conductor.Chart) do
            if v.H ~= true then
                for _, n in ipairs(v.N) do
                    love.graphics.circle("fill", n * 70 + circleXOffset, (v.B - conductor.SongPositionInBeats) * -300 + 500, 30)
                end
            end
        end
        
        love.graphics.print(status)
        
        if testDraw then
            love.graphics.rectangle("fill", 10, 10, 20, 20)
        end
    end
end