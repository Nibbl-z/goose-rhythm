local editor = {}
require("conductor")

local frame = require("yan.instance.ui.frame")
local btn = require("yan.instance.ui.textbutton")
local screen = require("yan.instance.ui.screen")
local Color = require("yan.datatypes.color")
local UIVector2 = require("yan.datatypes.uivector2")
local Vector2 = require("yan.datatypes.vector2")

editor.Enabled = true

local offset = 0
local quadrant = -1
local totalYOffset = 100
local xOffset = (love.graphics.getWidth() - 4 * 70) / 2 - 35
local snap = 1
local beats = 8
local beatQuadrant = 1

local chart = {}

function PlaceNote()
    print( math.abs(beatQuadrant - 8), quadrant)
    table.insert(chart, {B = math.abs(beatQuadrant - 8), N = quadrant})
end

function editor:Init()
    noteDetector = screen:New()
    noteDetector.Enabled = true
    
    noteColumns = {}
    
    placerContainer = frame:New(noteDetector)
    placerContainer.Size = UIVector2.new(0,70 * 4,1,0)
    placerContainer.Position = UIVector2.new(0.5,0,0,0)
    placerContainer.AnchorPoint = Vector2.new(0.5,0)
    placerContainer.Color = Color.new(1,1,1,0.5)
    
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
    
    beatDetector = screen:New()
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
    end
end

function editor:Update()
    local mx, my = love.mouse.getPosition()
end

function editor:Draw()
    if quadrant ~= -1 then
        love.graphics.circle("line", (quadrant) * 70 + xOffset, beatQuadrant * (530 / 8) - 30, 30)
    end
    
    for i = 1, 4 do
        love.graphics.circle("line", i * 70 + xOffset, 500, 30)
    end
    
    for _, note in ipairs(chart) do
        love.graphics.circle("fill", (note.N) * 70 + xOffset, (-(note.B - 8) * (530 / 8)) - 30, 30)
    end
end

return editor