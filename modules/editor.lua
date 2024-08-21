local editor = {}
require("modules.conductor")

local frame = require("yan.instance.ui.frame")
local btn = require("yan.instance.ui.textbutton")
local screen = require("yan.instance.ui.screen")
local Color = require("yan.datatypes.color")
local UIVector2 = require("yan.datatypes.uivector2")
local Vector2 = require("yan.datatypes.vector2")
local utils = require("yan.utils")

local textinput = require("yan.instance.ui.textinput")

editor.Enabled = false

local scrollOffset = 0
local quadrant = -1
local totalYOffset = 100
local xOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
local snap = 0.5
local beats = 8
local beatQuadrant = {}

local chart = {{B = 0, N = 1, Y = 500},{B = 0.5, N = 2, Y = 350},{B = 1, N = 3, Y = 200},{B = 1.5, N = 2, Y = 50},{B = 2, N = 1, Y = -100},{B = 2.5, N = 4, Y = -250},{B = 3, N = 2, Y = -400},{B = 3, N = 3, Y = -400},{B = 4, N = 2, Y = -700},{B = 4.5, N = 3, Y = -850},{B = 5, N = 4, Y = -1000},{B = 5.5, N = 2, Y = -1150},{B = 6, N = 4, Y = -1300},{B = 6.5, N = 3, Y = -1450},{B = 7, N = 3, Y = -1600},{B = 7.5, N = 4, Y = -1750},{B = 8, N = 1, Y = -1900},{B = 8.5, N = 2, Y = -2050},{B = 9, N = 3, Y = -2200},{B = 9.5, N = 2, Y = -2350},{B = 10, N = 1, Y = -2500},{B = 10.5, N = 3, Y = -2650},{B = 11, N = 2, Y = -2800},{B = 11, N = 1, Y = -2800},{B = 12, N = 1, Y = -3100},{B = 12.5, N = 2, Y = -3250},{B = 13, N = 3, Y = -3400},{B = 13.5, N = 3, Y = -3550},{B = 14, N = 4, Y = -3700},{B = 14.5, N = 3, Y = -3850},{B = 14.5, N = 4, Y = -3850},{B = 15, N = 2, Y = -4000},{B = 15.5, N = 1, Y = -4150},{B = 16, N = 4, Y = -4300, D = 2},{B = 16, N = 1, Y = -4300},{B = 16.5, N = 2, Y = -4450},{B = 17, N = 3, Y = -4600},{B = 17.5, N = 2, Y = -4750},{B = 18, N = 3, Y = -4900, D = 2},{B = 18, N = 1, Y = -4900},{B = 18.5, N = 4, Y = -5050},{B = 19, N = 1, Y = -5200},{B = 20, N = 2, Y = -5500, D = 2},{B = 20, N = 1, Y = -5500},{B = 20.5, N = 3, Y = -5650},{B = 21.5, N = 3, Y = -5950},{B = 22, N = 4, Y = -6100},{B = 21, N = 1, Y = -5800},{B = 22, N = 1, Y = -6100, D = 2},{B = 22.5, N = 3, Y = -6250},{B = 23, N = 3, Y = -6400},{B = 23.5, N = 4, Y = -6550},{B = 24, N = 2, Y = -6700, D = 2},{B = 24, N = 3, Y = -6700},{B = 24.5, N = 1, Y = -6850},{B = 25, N = 4, Y = -7000},{B = 25.5, N = 3, Y = -7150},{B = 26, N = 3, Y = -7300, D = 2},{B = 26, N = 1, Y = -7300},{B = 26.5, N = 2, Y = -7450},{B = 27, N = 1, Y = -7600},{B = 28, N = 4, Y = -7900, D = 2},{B = 28, N = 1, Y = -7900},{B = 28.5, N = 2, Y = -8050},{B = 29, N = 3, Y = -8200},{B = 29.5, N = 3, Y = -8350},{B = 29.5, N = 2, Y = -8350},{B = 30, N = 1, Y = -8500},{B = 30, N = 2, Y = -8500},{B = 30.5, N = 3, Y = -8650},{B = 30.5, N = 4, Y = -8650},{B = 31, N = 3, Y = -8800},{B = 31, N = 2, Y = -8800},{B = 31.5, N = 1, Y = -8950},{B = 31.5, N = 4, Y = -8950},{B = 32, N = 2, Y = -9100},{B = 32.5, N = 4, Y = -9250},{B = 32.5, N = 3, Y = -9250},{B = 33.5, N = 3, Y = -9550},{B = 33.5, N = 4, Y = -9550},{B = 34, N = 2, Y = -9700},{B = 34.5, N = 1, Y = -9850},{B = 36, N = 1, Y = -10300},{B = 36.5, N = 2, Y = -10450},{B = 35.5, N = 1, Y = -10150},{B = 36, N = 3, Y = -10300},{B = 38, N = 3, Y = -10900},{B = 37, N = 4, Y = -10600},{B = 38, N = 4, Y = -10900},{B = 38.5, N = 2, Y = -11050},{B = 38.5, N = 1, Y = -11050},{B = 39.5, N = 1, Y = -11350},{B = 40, N = 1, Y = -11500},{B = 40.5, N = 3, Y = -11650},{B = 40.5, N = 4, Y = -11650},{B = 41.5, N = 3, Y = -11950},{B = 41.5, N = 4, Y = -11950},{B = 42, N = 3, Y = -12100},{B = 42, N = 4, Y = -12100},{B = 42.5, N = 1, Y = -12250},{B = 43.5, N = 2, Y = -12550},{B = 44, N = 3, Y = -12700},{B = 44.5, N = 2, Y = -12850},{B = 44.5, N = 4, Y = -12850},{B = 45.5, N = 2, Y = -13150},{B = 45, N = 1, Y = -13000},{B = 46, N = 3, Y = -13300},{B = 46.5, N = 4, Y = -13450},{B = 47, N = 3, Y = -13600},{B = 47.5, N = 2, Y = -13750}}

local notePlaceLines = {}
local lines = {}
local pixelsPerBeat = 300

local snapIndex = 2
local snaps = {1, 1/2, 1/3, 1/4, 1/6, 1/8, 1/16}
local song = "/charts/bluegoose/song.ogg"
local playing = false

local minVisibleBeat = 0
local maxVisibleBeat = 6

function PlaceNote()
    if beatQuadrant.b == nil then return end
    table.insert(chart, {B = beatQuadrant.b, N = quadrant, Y = beatQuadrant.y1})
    
    Export()
end

function DeleteNote()
    for i, v in ipairs(chart) do
        if v.B == beatQuadrant.b and v.N == quadrant then
            table.remove(chart,i)
        end
    end
    
    Export()
end

function Export()
    local result = "{"
    
    for i, note in ipairs(chart) do
        result = result.."{B = "..note.B..", N = "..note.N..", Y = "..note.Y
        if note.D ~= nil then
            result = result..", D = "..note.D
        end
        if i == #chart then
            result = result.."}}"
        else
            result = result.."},"
        end
    end
    
    love.system.setClipboardText(result)
end

function editor:Init()
    loadedSong = love.audio.newSource(song, "static")
    loadedSong:setVolume(0.7)

    mainBeatFont = love.graphics.newFont(25)
    smallBeatFont = love.graphics.newFont(15)

    self.Screen = screen:New()
    self.Screen.Enabled = true
    
    noteColumns = {}
    
    placerContainer = frame:New(self.Screen)
    placerContainer.Size = UIVector2.new(0,70 * 4,1,0)
    placerContainer.Position = UIVector2.new(0.5,0,0,0)
    placerContainer.AnchorPoint = Vector2.new(0.5,0)
    placerContainer.Color = Color.new(1,1,1,0)
    
    for i = 1, 4 do
        local noteDetector = btn:New(self.Screen, "", 20, "center", "center")
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
    
    snapInput = textinput:New(self.Screen, "0.5", 16, "left", "center")
    snapInput.Position = UIVector2.new(0, 10, 0, 10)
    snapInput.Size = UIVector2.new(0.1,0,0.05,0)
    snapInput.TextColor = Color.new(0,0,0,1)
    snapInput.MouseDown = function () 
    
    end 
    
    snapInput.OnEnter = function ()
        if tonumber(snapInput.Text) ~= nil then
            if tonumber(snapInput.Text) > 0 then
                snap = tonumber(snapInput.Text)
            end
        end
    end
    --[[beatDetector = screen:New()
    beatDetector.Enabled = true
    
    beatRows = {}
    
    beatDetectorContainer = frame:New(noteDetector)
    beatDetectorContainer.Size = UIVector2.new(0,70 * 4,0,530)
    beatDetectorContainer.Position = UIVector2.new(0.5,0,0,0)
    beatDetectorContainer.AnchorPoint = Vector2.new(0.5,0)
    beatDetectorContainer.Color = Color.new(1,1,1,0.5)
    
    for i = 1, beats do
        local beatDetector = btn:New(beatDetector, "", 1, "center", "center")
        beatDetector.Position = UIVector2.new(0, 0, 0.125 * (i - 1), 0)
        beatDetector.Size = UIVector2.new(1,0,0.125,0)
        beatDetector:SetParent(beatDetectorContainer)
        beatDetector.Color = Color.new(i * 0.25, 1, 1, 0.5)
        
        beatDetector.MouseEnter = function ()
            beatQuadrant = i
        end
        
        beatDetector.MouseLeave = function ()
            beatQuadrant = -1
        end
    end]]
end

function editor:MousePressed(x, y, button)
    if quadrant ~= -1 then
        if button == 1 then PlaceNote() end
        if button == 2 then DeleteNote() end
    end
end

function editor:Update(dt)
    local mX, mY = love.mouse.getPosition()
    local csb = math.floor(scrollOffset / pixelsPerBeat)
    
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
end

function StartPlayback()
    conductor.BPM = 120
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
    if key == "escape" then
        self.ReturnToMenu()
    end
    if key == "space" then
        if playing == false then
            StartPlayback()
        else
            StopPlayback()
        end
    end
end

function editor:WheelMoved(x, y)
    if love.keyboard.isDown("lctrl") then
        snapIndex = utils:Clamp(snapIndex + y, 1, #snaps)
        snap = snaps[snapIndex]
        return
    end

    if love.keyboard.isDown("lshift") then
        for i, v in ipairs(chart) do
            if v.B == beatQuadrant.b and v.N == quadrant then
                
                if chart[i].D == nil then
                    chart[i].D = 0
                end

                chart[i].D = chart[i].D + snap * y

                if chart[i].D < 0 then
                    chart[i].D = nil
                end

                print(chart[i].D, snap * y)
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
    if quadrant ~= -1 and beatQuadrant.y1 ~= nil then
        love.graphics.circle("line", (quadrant) * 70 + xOffset, beatQuadrant.y1 + scrollOffset, 30)
    end
    
    for i = 1, 4 do
        love.graphics.circle("line", i * 70 + xOffset, 500, 30)
    end
    
    for _, note in ipairs(chart) do
        love.graphics.circle("fill", (note.N) * 70 + xOffset, note.Y + scrollOffset, 30)
        if note.D ~= nil then
            love.graphics.rectangle("fill", (note.N) * 70 + xOffset - 10, note.Y + scrollOffset - note.D * 300, 20, note.D * 300, 10, 10)
        end                  
    end

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
    
    love.graphics.setColor(1,1,1,1)
end

return editor