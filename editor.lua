local editor = {}
require("conductor")

local frame = require("yan.instance.ui.frame")
local btn = require("yan.instance.ui.textbutton")
local screen = require("yan.instance.ui.screen")
local Color = require("yan.datatypes.color")
local UIVector2 = require("yan.datatypes.uivector2")
local Vector2 = require("yan.datatypes.vector2")
local utils = require("yan.utils")

local textinput = require("yan.instance.ui.textinput")

editor.Enabled = true

local scrollOffset = 0
local quadrant = -1
local totalYOffset = 100
local xOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
local snap = 0.5
local beats = 8
local beatQuadrant = {}

local chart = {}

local notePlaceLines = {}
local pixelsPerBeat = 300

local snapIndex = 2
local snaps = {1, 1/2, 1/3, 1/4, 1/6, 1/8, 1/16, 0}
local song = "/kk_intermission.ogg"
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
        result = result.."{B = "..note.B..", N = "..note.N
        
        if i == #chart then
            result = result.."}}"
        else
            result = result.."},"
        end
    end
    
    print(result)
end

function editor:Init()
    loadedSong = love.audio.newSource(song, "static")
    loadedSong:setVolume(0.2)

    mainBeatFont = love.graphics.newFont(25)
    smallBeatFont = love.graphics.newFont(15)

    editorui = screen:New()
    editorui.Enabled = true
    
    noteColumns = {}
    
    placerContainer = frame:New(editorui)
    placerContainer.Size = UIVector2.new(0,70 * 4,1,0)
    placerContainer.Position = UIVector2.new(0.5,0,0,0)
    placerContainer.AnchorPoint = Vector2.new(0.5,0)
    placerContainer.Color = Color.new(1,1,1,0)
    
    for i = 1, 4 do
        local noteDetector = btn:New(editorui, "", 20, "center", "center")
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
    
    snapInput = textinput:New(editorui, "0.5", 16, "left", "center")
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
    playing = true
    conductor.SongPositionInBeats = scrollOffset / pixelsPerBeat
    conductor.SongPosition = scrollOffset / pixelsPerBeat * conductor.SecondsPerBeat
    loadedSong:play()
    print(scrollOffset / pixelsPerBeat * conductor.SecondsPerBeat)
    loadedSong:seek(scrollOffset / pixelsPerBeat * conductor.SecondsPerBeat, "seconds")
end

function StopPlayback()
    playing = false
    loadedSong:stop()
    
    --scrollOffset = math.ceil(scrollOffset / pixelsPerBeat / snap) * pixelsPerBeat * snap
end

function editor:KeyPressed(key)
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