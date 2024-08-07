local bpm = 128
local song = "/kk_intermission.ogg"
local beat = 0

local lastBeat = 0
local time = 0.0
local testDraw = true

function love.load()
    loadedSong = love.audio.newSource(song, "stream")
    metronome = love.audio.newSource("/select.wav", "static")
    timePerBeat = 60 / bpm
    
    loadedSong:play()
    loadedSong:setVolume(0.2)
    love.graphics.setFont(love.graphics.newFont(32))
end

function love.update(dt)
    time = time + dt
    
    if time > lastBeat + timePerBeat then
        metronome:play()
        beat = beat + 1
        lastBeat = lastBeat + timePerBeat
        testDraw = not testDraw
    end
end

function love.draw()
    --love.graphics.print(time)
    love.graphics.print(beat, 0, 0)

    if testDraw then
        love.graphics.rectangle("fill", 100, 100, 100, 100)
    end
    
end