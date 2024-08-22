require("modules.conductor")
require("yan")
local editor = require("modules.editor")
local menu = require("modules.menu")
local uimgr = require("yan.uimanager")
local settings = require("modules.settings")
local transitions = require("modules.transitions")
local results = require("modules.results")
local pause = require("modules.pause")

local started = false
local startedSong = false
local startDelay = 0

local fading = false
local fadingDelay = 0

local sprites = {
    GooseFace = "goose_face.png",
    GooseHonk = "goose_honking.png",
    GooseAngry = "goose_angry.png",
    Bread = "bread.png",
    Crust = "crust.png",
    CrustPressed = "crust_pressed.png"
}

local BGSprite = nil
local GooseSprite = nil
local GooseMissSprite = nil

local bread = 0
local combo = 0
local misses = 0
local notesHit = 0

local loadedMetadata
local chartPath

function Reset()
    bread = 0
    combo = 0
    misses = 0
    notesHit = 0

    if loadedSong ~= nil then
        loadedSong:stop()
    end
end

function StartSong(chart)
    Reset()
    chartPath = chart
    local chartData = love.filesystem.read(chart.."/chart.lua")
    local loadedChart = loadstring(chartData)()

    local metadata = love.filesystem.read(chart.."/metadata.lua")
    loadedMetadata = loadstring(metadata)()
    
    loadedSong = love.audio.newSource(chart.."/song.ogg", "stream")
    conductor.BPM = loadedMetadata.BPM
   
    
    BGSprite = love.graphics.newImage(chart.."/assets/bg.png")
    GooseSprite = love.graphics.newImage(chart.."/assets/goose.png")
    GooseMissSprite = love.graphics.newImage(chart.."/assets/goose_miss.png")
    goose:SetLoadedSprite(GooseSprite)
    
    if loadedMetadata.GooseSize ~= nil then
        goose.Size = Vector2.new(loadedMetadata.GooseSize, loadedMetadata.GooseSize)
    else
        goose.Size = Vector2.new(2,2)
    end
    
    metronome = love.audio.newSource("/select.wav", "static")
    loadedSong:setVolume(settings:GetMusicVolume())
    
    startedSong = false
    conductor:Init()
    conductor:LoadChart(loadedChart)
    startTime = love.timer.getTime()
    started = true
end

function menu.playsong(chart)
    menu.Enabled = false
    hud.Enabled = true
    StartSong(chart)
end

function ReturnToMenu()
    transitions:FadeIn(0.3)
    fading = true
    fadingDelay = love.timer.getTime() + 0.5
end

function editor.ReturnToMenu()
    transitions:FadeIn(0.3)
    fading = true
    fadingDelay = love.timer.getTime() + 0.5
end

function pause.ReturnToMenu()
    transitions:FadeIn(0.3)
    fading = true
    fadingDelay = love.timer.getTime() + 0.5
end

function pause.Unpause()
    loadedSong:play()
end

function love.load()
    love.window.setTitle("Goose Rhythm")
    love.window.setIcon(love.image.newImageData("/img/icon.png"))
    
    settings:Load()
    pause:Init()
    menu:Init()
    results:Init()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end

    conductor:Init()
    editor:Init()
    startTime = love.timer.getTime()
    
    
    
    goose = yan:Instance("Goose")
    goose.Position = Vector2.new(650,500)
    goose.Offset = Vector2.new(25, 50)

    goose.Size = Vector2.new(2,2)
    
    gooseBopTween = yan:NewTween(goose, yan:TweenInfo(0.2, EasingStyle.Linear), {Size = Vector2.new(2,2)})
    doBop = false
    
    hud = yan:Screen()
    
    breadLabel = yan:Label(hud, "Bread: 0", 24, "center", "center", "/ComicNeue.ttf")
    breadLabel.Position = UIVector2.new(0.75,0,1,0)
    breadLabel.Size = UIVector2.new(0.25,0,0.1,0)
    breadLabel.AnchorPoint = Vector2.new(0,1)
    breadLabel.TextColor = Color.new(1,1,1,1)
    
    comboLabel = yan:Label(hud, "Combo: 0 (Full Combo)", 24, "center", "center", "/ComicNeue.ttf")
    comboLabel.Position = UIVector2.new(0.25,0,1,0)
    comboLabel.Size = UIVector2.new(0.5,0,0.1,0)
    comboLabel.AnchorPoint = Vector2.new(0,1)
    comboLabel.TextColor = Color.new(1,1,1,1)
    
    missesLabel = yan:Label(hud, "Misses: 0", 24, "center", "center", "/ComicNeue.ttf")
    missesLabel.Position = UIVector2.new(0,0,1,0)
    missesLabel.Size = UIVector2.new(0.25,0,0.1,0)
    missesLabel.AnchorPoint = Vector2.new(0,1)
    missesLabel.TextColor = Color.new(1,1,1,1)
    
   -- love.graphics.setFont(love.graphics.newFont(32))
end

function love.update(dt)
    yan:Update(dt)
    results:Update()
    
    if fading then
        if love.timer.getTime() > fadingDelay then
            menu.Enabled = true
            editor.Enabled = false
            results.Screen.Enabled = false
            hud.Enabled = false
            Reset()
            menu:Reset()
            fading = false
            editor.Screen.Enabled = false

            
            pause.Paused = false
            pause.Screen.Enabled = false
            transitions:FadeOut(0.3)
        end
    end

    if editor.Enabled == true then
        editor:Update(dt)
        hud.Enabled = false
    elseif menu.Enabled == true then
        menu.Screen.Enabled = true
        hud.Enabled = false
        editor.Screen.Enabled = false
        menu:Update(dt)
    else
        conductor.SongPosition = loadedSong:tell("seconds")
        editor.Screen.Enabled = false
        menu.Screen.Enabled = false
        if started then
            if love.timer.getTime() >= startTime and not startedSong then
                loadedSong:play()
                startedSong = true
            end
            conductor:Update(dt)
        end
        
        if doBop then
            doBop = false
        end
        
        breadLabel.Text = "Bread: "..bread
        missesLabel.Text = "Misses: "..misses
        
        if misses == 0 then
            comboLabel.Text = "Combo: "..combo.." (Full Combo)"
        else
            comboLabel.Text = "Combo: "..combo
        end
    end
    
    --conductor:GetHitAccuracy()
end

function conductor.Metronome()
    if loadedMetadata ~= nil then
        goose.Size = Vector2.new(loadedMetadata.GooseSize * 1.25, loadedMetadata.GooseSize * 0.75)
        yan:NewTween(goose, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = Vector2.new(loadedMetadata.GooseSize, loadedMetadata.GooseSize)}):Play()
    end
   
   -- gooseBopTween:Play()
    
    if menu.Enabled == true then
        menu:Metronome()
    end
end

function conductor.OnChartFinish()
    results:Open(bread, notesHit, loadedMetadata, chartPath)
end

function results.ReturnToMenu()
    ReturnToMenu()
end

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
    elseif menu.Enabled == true then
        menu:KeyPressed(key)
    else
        if key == "escape" then
            pause.Paused = not pause.Paused
            pause.Screen.Enabled = not pause.Screen.Enabled

            if pause.Paused then
                loadedSong:pause()
            else
                loadedSong:play()
            end
        end
        if pause.Paused then return end
        local result = conductor:GetHitAccuracy(key)
        
        if result == nil then 
            return 
        end
        
        if result <= 0.05 then
            combo = combo + 1
            notesHit = notesHit + 1
            goose:SetLoadedSprite(GooseSprite)
        elseif result <= 0.3 then
            combo = combo + 1
            notesHit = notesHit + 1
            goose:SetLoadedSprite(GooseSprite)
        elseif result > 0.3 then
            goose:SetLoadedSprite(GooseMissSprite)
            
            misses = misses + 1
            combo = 0
        end
        local addedBread = (10 - math.floor(result * 10))
        if addedBread <= 0 then addedBread = 0 end
        bread = bread + addedBread
    end
end

function love.keyreleased(key)
    local result = conductor:ReleaseHeldNote(key)
        if result == nil then return end
        
        --[[if result <= 0.1 then
            goose:SetLoadedSprite(GooseSprite)
        elseif result <= 0.4 then
            goose:SetLoadedSprite(GooseSprite)
        elseif result > 0.4 then
            goose:SetLoadedSprite(GooseMissSprite)
        end]]
        
        bread = bread + (10 - math.floor(result * 10))
end

function love.textinput(t)
    uimgr:TextInput(t)
end

function love.mousemoved(x, y, dx, dy)
    if menu.Enabled == true then
        menu:MouseMoved(x,y, dx, dy)
    end
end

function love.draw()
    if editor.Enabled == true then
        editor:Draw()
    elseif menu.Enabled == true then
        menu:Draw()
    else
        if BGSprite ~= nil then
            love.graphics.draw(BGSprite)
        end

        goose:Draw()

        local circleXOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", circleXOffset + 35, 0, 70 * 4, love.graphics.getHeight())
        
        love.graphics.setColor(1,1,1,1)
        for i = 1, 4 do
            --love.graphics.setColor(colors[i][1],colors[i][2],colors[i][3],1)
            --love.graphics.circle("fill", i * 70 + circleXOffset, 500, 30)
            --love.graphics.setColor(1,1,1,1)
            
            
            if love.keyboard.isDown(settings.Keybinds[i]) and pause.Paused == false then
                love.graphics.draw(sprites.CrustPressed, i * 70 + circleXOffset - 30, 440)
            else
                love.graphics.draw(sprites.Crust, i * 70 + circleXOffset - 30, 440)
            end
        end
        
        for _, v in ipairs(conductor.Chart) do
            if (v.B - conductor.SongPositionInBeats) > -10 and (v.B - conductor.SongPositionInBeats) < 10 then
                for _, n in ipairs(v.N) do
                    if v.H[tostring(n)] ~= true and v.M ~= true then
                    
                        love.graphics.draw(sprites.Bread, n * 70 + circleXOffset - 30, (v.B - conductor.SongPositionInBeats) * -settings.NoteSpeed + 440)
                       --love.graphics.circle("fill", n * 70 + circleXOffset, (v.B - conductor.SongPositionInBeats) * -300 + 470, 30)
                        
                       
                        if (v.B - conductor.SongPositionInBeats) * -settings.NoteSpeed + 440 > 600 then
                            v.M = true
                            
                            goose:SetLoadedSprite(GooseMissSprite)
        
                            misses = misses + #v.N
                            combo = 0
                            status = "Miss"
                        end
                    end
                end
                
                if v.D ~= nil then
                    for _, n in ipairs(v.N) do
                        if v.D[tostring(n)] ~= nil then
                            love.graphics.stencil(function ()
                                love.graphics.rectangle("fill", 0,0,800,500)
                            end, "replace", 1)
                            love.graphics.setStencilTest("greater", 0)
                            love.graphics.setColor(1, 183/255, 135/255)
                            love.graphics.rectangle("fill",
                            n * 70 + circleXOffset - 10, 
                            (v.B - conductor.SongPositionInBeats) * -settings.NoteSpeed + 440 - v.D[tostring(n)] * settings.NoteSpeed,
                            20,
                            v.D[tostring(n)] * settings.NoteSpeed, 10, 10)
                            love.graphics.setColor(1,1,1,1)
                        end
                       
                        love.graphics.setStencilTest()
                    end
                end
            end
        end
    end
    
    yan:Draw()
end

function love.textinput(t)
    yan:TextInput(t)
end