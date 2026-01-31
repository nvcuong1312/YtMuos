local love = require("love")
local Font = require("font")
local Text = require("text")

local Loading = {}

function Loading.Draw(text)
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    local time = love.timer.getTime()
    local angle = (time * 6) % (2 * math.pi)
    local centerX = 320
    local centerY = 240
    local radius = 30
    local ringWidth = 6
    local segments = 12
    for i = 0, segments - 1 do
        local segmentAngle = angle + (i * (2 * math.pi / segments))
        local x = centerX + math.cos(segmentAngle) * radius
        local y = centerY + math.sin(segmentAngle) * radius
        local alpha = (i + 1) / segments
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.circle("fill", x, y, ringWidth / 2)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Font.Normal())
    Text.DrawLeftText(0, 450, text)
end

return Loading