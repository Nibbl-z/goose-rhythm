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
end

function conductor.Metronome()
    testDraw = not testDraw
    metronome:play()
end

function love.draw()
    if testDraw then
        love.graphics.rectangle("fill", 100, 100, 100, 100)
    end
end