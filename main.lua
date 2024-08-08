require("conductor")

local song = "/kk_intermission.ogg"

local testDraw = true

function love.load()
    loadedSong = love.audio.newSource(song, "stream")
    metronome = love.audio.newSource("/select.wav", "static")
    
    loadedSong:play()
    loadedSong:setVolume(0.2)
    love.graphics.setFont(love.graphics.newFont(32))

    conductor:LoadChart()
end

function love.update(dt)
    conductor:Update(dt)
    --conductor:GetHitAccuracy()
end

function conductor.Metronome()
    testDraw = not testDraw
    
end

local status = ""

function love.mousepressed()
    if conductor:GetHitAccuracy() <= 0.05 then
        status = "Perfect"
    elseif conductor:GetHitAccuracy() <= 0.2 then
        status = "Okay"
    elseif conductor:GetHitAccuracy() > 0.3 then
        status = "Miss"
    end
    --metronome:play()
end

function love.draw()
    love.graphics.rectangle("fill", 200, 400, 2, 200)
    for _, v in ipairs(conductor.Chart) do
        love.graphics.rectangle("fill", (v.B - conductor.SongPositionInBeats) * 300 + 200, 500, 10, 10)
    end

    love.graphics.print(status)

    --[[if testDraw then
        love.graphics.rectangle("fill", 100, 100, 100, 100)
    end]]
end