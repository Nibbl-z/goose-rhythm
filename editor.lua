local editor = {}
require("conductor")

local frame = require("yan.instance.ui.frame")
local btn = require("yan.instance.ui.textbutton")
local screen = require("yan.instance.ui.screen")
local Color = require("yan.datatypes.color")
local UIVector2 = require("yan.datatypes.uivector2")
local Vector2 = require("yan.datatypes.vector2")

editor.Enabled = true

local scrollOffset = 0
local quadrant = -1
local totalYOffset = 100
local xOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
local snap = 0.25
local beats = 8
local beatQuadrant = {}

local chart = {}

local notePlaceLines = {}
local pixelsPerBeat = 300

function PlaceNote()
    if beatQuadrant.b == nil then return end
    table.insert(chart, {B = beatQuadrant.b, N = quadrant, Y = beatQuadrant.y1})
    
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
    noteDetector = screen:New()
    noteDetector.Enabled = true
    
    noteColumns = {}
    
    placerContainer = frame:New(noteDetector)
    placerContainer.Size = UIVector2.new(0,70 * 4,1,0)
    placerContainer.Position = UIVector2.new(0.5,0,0,0)
    placerContainer.AnchorPoint = Vector2.new(0.5,0)
    placerContainer.Color = Color.new(1,1,1,0)
    
    for i = 1, 4 do
        local noteDetector = btn:New(noteDetector, "", 20, "center", "center")
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

        noteDetector.MouseDown = function ()
            PlaceNote()
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

function editor:Update()
    local mX, mY = love.mouse.getPosition()

    lines = {}
    beatQuadrant = {}
    local beat = 0
    for i = 0, -1000, -snap do
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
        
        beat = beat + snap
    end

    
end

function editor:WheelMoved(x, y)
    scrollOffset = scrollOffset + y * 20
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
            love.graphics.setColor(1,1,1,1)
        else
            love.graphics.setColor(0.5,0.5,0.5,1)
        end
        love.graphics.print(l.b, xOffset - 30, l.y1 + scrollOffset)
        love.graphics.line(l.x1, l.y1 + scrollOffset, l.x2, l.y2 + scrollOffset)
    end
    
    love.graphics.setColor(1,1,1,1)
end

return editor