require("conductor")

local song = "/kk_intermission.ogg"

local testDraw = true

function love.load()
    loadedSong = love.audio.newSource(song, "stream")
    metronome = love.audio.newSource("/select.wav", "static")
    
    loadedSong:play()
    loadedSong:setVolume(0.2)
    love.graphics.setFont(love.graphics.newFont(32))
end

function love.update(dt)
    conductor:Update(dt)
    conductor:GetHitAccuracy()
end

function conductor.Metronome()
    testDraw = not testDraw
    --metronome:play()
end

function love.mousepressed()
    if conductor:GetHitAccuracy() <= 0.05 then
        print("PERFECT!")
    elseif conductor:GetHitAccuracy() <= 0.1 then
        print("Okay")
    elseif conductor:GetHitAccuracy() <= 0.2 then
        print("doinked")
    end
end

function love.draw()
    if testDraw then
        love.graphics.rectangle("fill", 100, 100, 100, 100)
    end
end