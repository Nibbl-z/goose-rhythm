require("conductor")
require("yan")
local editor = require("editor")
local uimgr = require("yan.uimanager")
local song = "/kk_intermission.ogg"
local settings = require("settings")

local testDraw = true


local started = false

local sprites = {
    BG = "bg.png",
    GooseFace = "goose_face.png",
    GooseHonk = "goose_honking.png",
    GooseAngry = "goose_angry.png",
    Bread = "bread.png",
    Crust = "crust.png",
    CrustPressed = "crust_pressed.png"
}

local colors = {
    {1, 80/255, 0},
    {72/255, 0, 1},
    {0, 38/255, 1},
    {1,1,1}
}



function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end

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
    
    goose = yan:Instance("Goose")
    goose:SetSprite("/img/greengoose.png")
    goose.Position = Vector2.new(650,500)
    goose.Offset = Vector2.new(25, 50)
    goose.Size = Vector2.new(2,2)
    
    gooseBopTween = yan:NewTween(goose, yan:TweenInfo(0.3, EasingStyle.QuadOut), {Size = Vector2.new(2,2)})
    doBop = false
end

function love.update(dt)
    yan:Update(dt)
    if editor.Enabled == true then
        editor:Update(dt)
    else
        if love.timer.getTime() > startTime and not started then
            loadedSong:play()
            conductor:Update(dt)
            started = true
        end

        if started then
            conductor:Update(dt)
        end
        
        if doBop then
            doBop = false
           
        end
    end
    
    --conductor:GetHitAccuracy()
end

function conductor.Metronome()
    testDraw = not testDraw
    --metronome:play()
    
    goose.Size = Vector2.new(2.5, 1.5)
    gooseBopTween:Play()
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
    love.graphics.draw(sprites.BG)
    goose:Draw()
    if editor.Enabled == true then
        editor:Draw()
    else
        local circleXOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
        
        for i = 1, 4 do
            --love.graphics.setColor(colors[i][1],colors[i][2],colors[i][3],1)
            --love.graphics.circle("fill", i * 70 + circleXOffset, 500, 30)
            --love.graphics.setColor(1,1,1,1)
            
            
            if love.keyboard.isDown(settings.Keybinds[i]) then
                love.graphics.draw(sprites.CrustPressed, i * 70 + circleXOffset - 30, 470)
            else
                love.graphics.draw(sprites.Crust, i * 70 + circleXOffset - 30, 470)
            end
        end
        
        love.graphics.setColor(1,1,1,1)
        
        for _, v in ipairs(conductor.Chart) do
            if v.H ~= true then
                for _, n in ipairs(v.N) do
                    love.graphics.draw(sprites.Bread, n * 70 + circleXOffset - 30, (v.B - conductor.SongPositionInBeats) * -300 + 440)
                   --love.graphics.circle("fill", n * 70 + circleXOffset, (v.B - conductor.SongPositionInBeats) * -300 + 470, 30)
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