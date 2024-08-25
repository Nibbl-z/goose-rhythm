local editor = {}
require("modules.conductor")

require("yan")

local utils = require("yan.utils")
local settings = require("modules.settings")
local pause = require("modules.pause")

editor.Enabled = false

local scrollOffset = 0
local quadrant = -1
local xOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 60
local snap = 0.5
local beatQuadrant = {}

local chart = {}
local chartPath = ""
local lines = {}
local pixelsPerBeat = 300

local snapIndex = 2
local snaps = {1, 1/2, 1/3, 1/4, 1/6, 1/8, 1/16}
local playing = false

local minVisibleBeat = 0
local maxVisibleBeat = 6

local unsavedChanges = false

local dragging = false
local dragStartNote = -1
local dragEndNote = -1
local dragStartBeat = -1
local dragEndBeat = -1

local sprites = {
    Bread = love.graphics.newImage("/img/bread.png"),
    Crust = love.graphics.newImage("/img/crust.png")
}

local sfx = {
    Select = love.audio.newSource("/sfx/select.wav", "static")
}

local BGSprite
local message = ""
local messageResetTime = 0

local clipboard = {}

function editor:LoadChart(c)
    unsavedChanges = false
    chartPath = c
    local chartData = love.filesystem.read(c.."/chart.lua")
    chart = loadstring(chartData)()

    local metadata = love.filesystem.read(c.."/metadata.lua")
    loadedMetadata = loadstring(metadata)()
    
    loadedSong = love.audio.newSource(c.."/song.ogg", "static")
    conductor.BPM = loadedMetadata.BPM
    loadedSong:setVolume(settings:GetMusicVolume())
    local bgfileExt = ".png"

    if love.filesystem.getInfo(c.."/assets/bg.jpg") ~= nil then
        bgfileExt = ".jpg"
    elseif love.filesystem.getInfo(c.."/assets/bg.jpeg") ~= nil then
        bgfileExt = ".jpeg"
    elseif love.filesystem.getInfo(c.."/assets/bg.bmp") ~= nil then
        bgfileExt = ".bmp"
    end

    BGSprite = love.graphics.newImage(c.."/assets/bg"..bgfileExt)
end

function PlaceNote()
    if beatQuadrant.b == nil then return end
    unsavedChanges = true
    table.insert(chart, {B = beatQuadrant.b, N = quadrant})
end

function DeleteNote()
    for i, v in ipairs(chart) do
        if v.B == beatQuadrant.b and v.N == quadrant then
            table.remove(chart,i)
            unsavedChanges = true
        end
    end

    
end

function Export()
    local result = "return {"
    
    for i, note in ipairs(chart) do
        result = result.."{B = "..note.B..", N = "..note.N
        if note.D ~= nil then
            result = result..", D = "..note.D
        end
        if i == #chart then
            result = result.."}"
        else
            result = result.."},"
        end
    end

    result = result.."}"
    
    love.filesystem.write(chartPath.."/chart.lua", result)

    unsavedChanges = false
end

function editor:Init()
    mainBeatFont = love.graphics.newFont(25)
    smallBeatFont = love.graphics.newFont(15)
    
    self.Screen = yan:Screen()
    self.Screen.Enabled = true
    
    noteColumns = {}
    
    placerContainer = yan:Frame(self.Screen)
    placerContainer.Size = UIVector2.new(0,70 * 4,1,0)
    placerContainer.Position = UIVector2.new(0.5,0,0,0)
    placerContainer.AnchorPoint = Vector2.new(0.5,0)
    placerContainer.Color = Color.new(1,1,1,0)
    
    for i = 1, 4 do
        local noteDetector = yan:TextButton(self.Screen, "", 20, "center", "center")
        noteDetector.Position = UIVector2.new(0.25 * (i - 1), 0, 0, 0)
        noteDetector.Size = UIVector2.new(0.25,0,1,0)
        noteDetector:SetParent(placerContainer)
        noteDetector.Color = Color.new(i * 0.25, 1, i * 0.25, 0)
        
        noteDetector.MouseEnter = function ()
            quadrant = i
        end

        noteDetector.MouseLeave = function ()
            quadrant = -1
        end
    end
    
    messageLabel = yan:Label(self.Screen, message, 32, "left", "bottom", "/ComicNeue.ttf")
    messageLabel.Position = UIVector2.new(0,5,1,5)
    messageLabel.AnchorPoint = Vector2.new(0,1)
    messageLabel.Size = UIVector2.new(1,0,0.1,0)
    messageLabel.TextColor = Color.new(1,1,1,1)
    
    snapInput = yan:TextInputter(self.Screen, "0.5", 16, "left", "center", "/ComicNeue.ttf")
    snapInput.Position = UIVector2.new(1, -10, 0, 10)
    snapInput.Size = UIVector2.new(0.1,0,0.05,0)
    snapInput.AnchorPoint = Vector2.new(1,0)
    snapInput.TextColor = Color.new(0,0,0,1)
    snapInput.MouseEnter = function () snapInput.Color = Color.new(0.7,0.7,0.7,1) end 
    snapInput.MouseLeave = function () snapInput.Color = Color.new(1,1,1,1) end 
    snapInput.MouseDown = function () sfx.Select:play() end 
    snapInput.CornerRoundness = 8
    snapInput.OnEnter = function ()
        if tonumber(snapInput.Text) ~= nil then
            if tonumber(snapInput.Text) > 0 then
                sfx.Select:play()
                snap = tonumber(snapInput.Text)
            end
        end
    end

    snapLabel = yan:Label(self.Screen, "Snap", 16, "right", "center", "/ComicNeue.ttf")
    snapLabel:SetParent(snapInput)
    snapLabel.AnchorPoint = Vector2.new(1,0)
    snapLabel.Position = UIVector2.new(0,-5,0,0)
    snapLabel.Size = UIVector2.new(1,0,1,0)
    snapLabel.TextColor = Color.new(1,1,1,1)
    
    beatInput = yan:TextInputter(self.Screen, "0", 16, "left", "center", "/ComicNeue.ttf")
    beatInput.Position = UIVector2.new(1, -10, 0.05, 15)
    beatInput.Size = UIVector2.new(0.1,0,0.05,0)
    beatInput.AnchorPoint = Vector2.new(1,0)
    beatInput.TextColor = Color.new(0,0,0,1)
    beatInput.MouseEnter = function () beatInput.Color = Color.new(0.7,0.7,0.7,1) end 
    beatInput.MouseLeave = function () beatInput.Color = Color.new(1,1,1,1) end 
    beatInput.MouseDown = function () sfx.Select:play() end 
    beatInput.CornerRoundness = 8
    beatInput.OnEnter = function ()
        if tonumber(beatInput.Text) ~= nil then
            if tonumber(beatInput.Text) >= 0 then
                sfx.Select:play()
                scrollOffset = tonumber(beatInput.Text) * 300
            end
        end
    end

    tobeatLabel = yan:Label(self.Screen, "Jump to Beat", 16, "right", "center", "/ComicNeue.ttf")
    tobeatLabel:SetParent(beatInput)
    tobeatLabel.AnchorPoint = Vector2.new(1,0)
    tobeatLabel.Position = UIVector2.new(0,-5,0,0)
    tobeatLabel.Size = UIVector2.new(1,0,1,0)
    tobeatLabel.TextColor = Color.new(1,1,1,1)
    
    saveBtn = yan:ImageButton(self.Screen, "/img/save.png")
    saveBtn.Size = UIVector2.new(0,40,0,40)
    saveBtn.Position = UIVector2.new(0,5,0,5)
    
    saveBtn.MouseEnter = function () saveBtn.Color = Color.new(0.7,0.7,0.7,1) end
    saveBtn.MouseLeave = function () saveBtn.Color = Color.new(1,1,1,1) end
    saveBtn.MouseDown = function ()
        sfx.Select:play()
        Export()
        message = "Chart saved successfully!"
        messageResetTime = love.timer.getTime() + 3
    end
end

function editor:MousePressed(x, y, button)
    if love.keyboard.isDown("lctrl") then
        if quadrant ~= -1 and beatQuadrant.b ~= nil then
            dragging = true
            dragStartNote = quadrant
            dragStartBeat = beatQuadrant.b
        end

        return
    end
    if quadrant ~= -1 then
        if button == 1 then PlaceNote() end
        if button == 2 then DeleteNote() end
    end
end

function editor:MouseReleased(x, y, button)
    if dragging then
        dragging = false
        
        local minBeat, maxBeat = dragStartBeat, dragEndBeat
        local minNote, maxNote = dragStartNote, dragEndNote
        
        if dragStartBeat >= dragEndBeat then
            minBeat = dragEndBeat
            maxBeat = dragStartBeat
        end
        if dragStartNote >= dragEndNote then
            minNote = dragEndNote
            maxNote = dragStartNote
        end

        for _, v in ipairs(chart) do
            if v.B >= minBeat and v.B <= maxBeat and v.N >= minNote and v.N <= maxNote then
                v.S = true
            end
        end
    end
end

function editor:Update(dt)
    local mX, mY = love.mouse.getPosition()
    local csb = math.floor(scrollOffset / pixelsPerBeat)
    if quadrant ~= -1 and dragging then
        dragEndNote = quadrant
    end

    if dragging and beatQuadrant.b ~= nil then
        dragEndBeat = beatQuadrant.b
    end 
    
    minVisibleBeat = csb - 2
    maxVisibleBeat = csb + 4
    lines = {}
    beatQuadrant = {}
    local beat = 0
    for i = 0, -1000, -snap do
        if beat >= minVisibleBeat and beat <= maxVisibleBeat then
            local line = {x1 = xOffset, x2 = love.graphics.getWidth() - xOffset, y1 = i * pixelsPerBeat + 500, y2 = i * pixelsPerBeat + 500, b = beat}
            
            line.b = tonumber(string.format('%.3f', line.b))

            if math.floor(line.b) ~= line.b then
                line.partial = true
            else
                line.partial = false
            end
            
            table.insert(lines, line)
        
            if math.abs((i * pixelsPerBeat + 500 + scrollOffset) - (mY)) < 20 then
                beatQuadrant = line
            end
            
            
        end
        beat = beat + snap
    end
    
    if playing then
        conductor:Update(dt)

        scrollOffset = conductor.SongPositionInBeats * pixelsPerBeat
    end
    messageLabel.Text = message
    if messageResetTime < love.timer.getTime() then
        message = ""
    end
end

function StartPlayback()
    conductor:Init()
    playing = true
    conductor.SongPositionInBeats = scrollOffset / pixelsPerBeat
    conductor.SongPosition = scrollOffset / pixelsPerBeat * conductor.SecondsPerBeat
    loadedSong:play()
    --print(scrollOffset / pixelsPerBeat * conductor.SecondsPerBeat)
    loadedSong:seek(scrollOffset / pixelsPerBeat * conductor.SecondsPerBeat, "seconds")
end

function StopPlayback()
    playing = false
    loadedSong:stop()
    
    --scrollOffset = math.ceil(scrollOffset / pixelsPerBeat / snap) * pixelsPerBeat * snap
end

function editor:KeyPressed(key)
    if (key == "d" and love.keyboard.isDown("lctrl")) or (key == "lctrl" and love.keyboard.isDown("d")) then
        for _, v in ipairs(chart) do
            v.S = nil
        end
    end

    if (key == "s" and love.keyboard.isDown("lctrl")) or (key == "lctrl" and love.keyboard.isDown("s")) then
        Export()
        message = "Chart saved successfully!"
        messageResetTime = love.timer.getTime() + 3
    end
    
    if (key == "c" and love.keyboard.isDown("lctrl")) or (key == "lctrl" and love.keyboard.isDown("c")) then
        clipboard = {}
        
        for _, v in ipairs(chart) do
            if v.S == true then
                table.insert(clipboard, v)
            end
        end
    end

    if (key == "x" and love.keyboard.isDown("lctrl")) or (key == "lctrl" and love.keyboard.isDown("x")) then
        clipboard = {}
        
        for _, v in ipairs(chart) do
            if v.S == true then
                table.insert(clipboard, v)
            end
        end
        
        local i = 1
        
        while i <= #chart do
            if chart[i].S == true then
                table.remove(chart, i)
            else
                i = i + 1
            end
        end
    end
    
    if (key == "v" and love.keyboard.isDown("lctrl")) or (key == "lctrl" and love.keyboard.isDown("v")) then
        local lowestBeat = math.huge
        
        for _, v in ipairs(clipboard) do
            if v.B < lowestBeat then
                lowestBeat = v.B
            end
        end
        
        local beatSnap = math.floor((scrollOffset / 300) / snap + 0.5) * snap
        
        for _, v in ipairs(clipboard) do
            table.insert(chart, {B = v.B - lowestBeat + beatSnap, N = v.N, D = v.D, S = true})
        end
    end

    if (key == "delete") then
        local i = 1
        
        while i <= #chart do
            if chart[i].S == true then
                table.remove(chart, i)
            else
                i = i + 1
            end
        end
    end
    
    if (key == "up") then
        for _, v in ipairs(chart) do
            if v.S == true then
                v.B = v.B + snap
            end
        end
    end
    
    if (key == "down") then
        for _, v in ipairs(chart) do
            if v.S == true then
                v.B = v.B - snap
                if v.B <= 0 then
                    v.B = 0
                end
            end
        end
    end
    
    if key == "escape" then
        pause.Type = "editor"
        pause.Paused = not pause.Paused
        pause.Screen.Enabled = not pause.Screen.Enabled
    end
    if key == "space" then
        if playing == false then
            StartPlayback()
        else
            StopPlayback()
        end
    end
end

function pause.HasSaved()
    return unsavedChanges
end

function editor:WheelMoved(x, y)
    if love.keyboard.isDown("lctrl") and not dragging then
        snapIndex = utils:Clamp(snapIndex + y, 1, #snaps)
        snap = snaps[snapIndex]
        snapInput.Text = tostring(math.floor(snap * 1000) / 1000)
        return
    end

    if love.keyboard.isDown("lshift") then
        for i, v in ipairs(chart) do
            if v.B == beatQuadrant.b and v.N == quadrant then
                
                if chart[i].D == nil then
                    chart[i].D = 0
                end
                
                chart[i].D = chart[i].D + snap * y

                if chart[i].D <= 0 then
                    chart[i].D = nil
                end
                
                print(chart[i].D, snap * y)
            else
                if v.D ~= nil then
                    if v.D ~= nil then
                        local pX, pY, sX, sY = (v.N) * 70 + xOffset + 20, (-v.B * pixelsPerBeat + 500) + scrollOffset - v.D * 300, 20, v.D * 300
                        if utils:CheckCollision(love.mouse.getX(), love.mouse.getY(), 1, 1, pX, pY, sX, sY) then
                            chart[i].D = chart[i].D + snap * y
                            
                            if chart[i].D <= 0 then
                                chart[i].D = nil
                            end
                        end
                    end 
                end
            end
        end

        return
    end
    
    scrollOffset = scrollOffset + y * 20
    if scrollOffset < 0 then
        scrollOffset = 0
    end
end

function editor:Draw()
    if BGSprite ~= nil then
        love.graphics.setColor(0.5,0.5,0.5,1)
        love.graphics.draw(BGSprite, 0, 0, 0, 800 / BGSprite:getPixelWidth(), 600 / BGSprite:getPixelHeight())
    end
    love.graphics.setColor(1,1,1,1)
    
    for _, l in ipairs(lines) do
        if l.partial == false then
            love.graphics.setFont(mainBeatFont)
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(l.b, xOffset - 80, l.y1 + scrollOffset - (mainBeatFont:getHeight() / 2))
            
        else
            love.graphics.setFont(smallBeatFont)
            love.graphics.setColor(0.5,0.5,0.5,1)
            love.graphics.print(l.b, xOffset - 80, l.y1 + scrollOffset - (smallBeatFont:getHeight() / 2))
        end
        
        love.graphics.line(l.x1, l.y1 + scrollOffset, l.x2, l.y2 + scrollOffset)
    end

    if quadrant ~= -1 and beatQuadrant.y1 ~= nil and not playing and not dragging then
        for i, v in ipairs(chart) do
            if v.B == beatQuadrant.b and v.N == quadrant then
                love.graphics.draw(sprites.Crust, (quadrant) * 70 + xOffset, beatQuadrant.y1 + scrollOffset - 30, 0, 1.2, 1.2, 5, 5)
            end
        end
        
        love.graphics.draw(sprites.Crust, (quadrant) * 70 + xOffset, beatQuadrant.y1 + scrollOffset - 30)
    end
    
    for i = 1, 4 do
        love.graphics.draw(sprites.Crust, i * 70 + xOffset, 470)
    end
    
    for _, note in ipairs(chart) do
        if note.D ~= nil then
            if note.S == true then
                love.graphics.setColor(0,1,0)
            else
                love.graphics.setColor(1, 183/255, 135/255)
            end
            love.graphics.rectangle("fill", (note.N) * 70 + xOffset + 20, (-note.B * pixelsPerBeat + 500) + scrollOffset - note.D * 300, 20, note.D * 300, 10, 10)
        end   

        if note.S == true then
            love.graphics.setColor(0,1,0)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.draw(sprites.Bread, (note.N) * 70 + xOffset, (-note.B * pixelsPerBeat + 470) + scrollOffset)
    end
    
    if dragging then
        local startNote, startBeat, endNote, endBeat = dragStartNote, dragStartBeat, dragEndNote, dragEndBeat
        
        if dragStartNote >= dragEndNote then
            startNote = dragEndNote
            endNote = dragStartNote
        end
        
        print(startNote)
        local sizeY = ((-dragEndBeat * pixelsPerBeat + 470) + scrollOffset) - ((-dragStartBeat * pixelsPerBeat + 470) + scrollOffset)
        local posYAdder = 0
        if sizeY == 0 then 
            sizeY = 20 
            posYAdder = -10
        end
        
        

        love.graphics.setColor(0.5,0.5,1, 0.5)
        love.graphics.rectangle("fill", 
        (startNote) * 70 + xOffset, 
        (-dragStartBeat * pixelsPerBeat + 500) + scrollOffset + posYAdder, 
        (endNote - startNote + 1) * 70,
        sizeY
    )
    end
    
    love.graphics.setColor(1,1,1,1)
end

return editor