require("conductor")
local editor = require("editor")
local uimgr = require("yan.uimanager")
local song = "/kk_intermission.ogg"

local testDraw = true


local started = false

function love.load()
    conductor:Init()
    startTime = love.timer.getTime() + 1
    
    if editor.Enabled == true then
        editor:Init()
    else
        loadedSong = love.audio.newSource(song, "static")
        metronome = love.audio.newSource("/select.wav", "static")
        loadedSong:setVolume(0.2)
        
        love.graphics.setFont(love.graphics.newFont(32))

        conductor:LoadChart()
    end
end

function love.update(dt)
    
    if editor.Enabled == true then
        editor:Update(dt)
        uimgr:Update()
    else
        if love.timer.getTime() > startTime and not started then
            loadedSong:play()
            conductor:Update(dt)
            started = true
        end

        if started then
            conductor:Update(dt)
        end
        
    end
    
    --conductor:GetHitAccuracy()
end

function conductor.Metronome()
    testDraw = not testDraw
    --metronome:play()
end

local status = ""

function love.mousepressed(x, y, button)
    editor:MousePressed(x, y, button)
end

function love.wheelmoved(x, y)
    editor:WheelMoved(x, y)
end

function love.keypressed(key, scancode, rep)
    uimgr:KeyPressed(key, scancode, rep)
    if editor.Enabled == true then
        editor:KeyPressed(key)
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

function love.textinput(t)
    uimgr:TextInput(t)
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
                    love.graphics.circle("fill", n * 70 + circleXOffset, (v.B - conductor.SongPositionInBeats) * -300 + 470, 30)
                end
            end
        end
        
        love.graphics.print(status)
        
        if testDraw then
            love.graphics.rectangle("fill", 10, 10, 20, 20)
        end
    end

    uimgr:Draw()
end