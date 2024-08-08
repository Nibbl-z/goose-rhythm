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

end

function love.keypressed(key)
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

function love.draw()
    for i = 1, 4 do
        love.graphics.circle("line", i * 70 + 200, 500, 30)
    end
    
    for _, v in ipairs(conductor.Chart) do
        if v.H ~= true then
            love.graphics.circle("fill", v.N * 70 + 200, (v.B - conductor.SongPositionInBeats) * -300 + 500, 30)
        end
        
    end

    love.graphics.print(status)

    --[[if testDraw then
        love.graphics.rectangle("fill", 100, 100, 100, 100)
    end]]
end