local love = require("love")
local Font = require("font")
local Text = require("text")

local Loading = {}

function Loading.Update(dt)

end

function Loading.Draw()
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Font.Big())
    Text.DrawCenteredText(0, 200, 640, "Loading...")
end

return Loading