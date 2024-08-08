local editor = {}
require("conductor")

editor.Enabled = true

local offset = 0
local quadrant = -1
local totalYOffset = 100
local xOffset = 70 * 4 - 30

function editor:Update()
    local mx, my = love.mouse.getPosition()
    
    if mx <= xOffset or mx > xOffset + 70 * 4 then
        quadrant = -1
    elseif mx <= xOffset + 70 then
        quadrant = 1
    elseif mx <= xOffset + 70 * 2 then
        quadrant = 2
    elseif mx <= xOffset + 70 * 3 then
        quadrant = 3
    elseif mx <= xOffset + 70 * 4 then
        quadrant = 4
    end

    print(quadrant)
end

function editor:Draw()
    if quadrant ~= -1 then
        love.graphics.circle("line", xOffset + 70 * (quadrant - 1), 400, 30)
    end
    
    
    for i = 1, 4 do
        love.graphics.line(xOffset, offset + i * 100 + totalYOffset, love.graphics.getWidth() - xOffset, offset + i * 100 + totalYOffset)
    end
    
end

return editor