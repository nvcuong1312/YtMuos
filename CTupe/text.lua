local love = require("love")
local Text = {}

function Text.DrawCenteredText(rectX, rectY, rectWidth, text)
    local font       = love.graphics.getFont()
	local textWidth  = font:getWidth(text)
	love.graphics.print(text, rectX + rectWidth / 2 - textWidth / 2, rectY)
end

function Text.DrawLeftText(rectX, rectY, text)
    love.graphics.print(text, rectX, rectY, 0, 1, 1)
end

return Text