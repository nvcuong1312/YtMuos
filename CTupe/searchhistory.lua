local love = require("love")
local Font = require("font")
local Text = require("text")

local SearchHistory = {}

function SearchHistory.Draw(tableSearchHistory, idx)
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Font.Normal())
    for i, text in ipairs(tableSearchHistory) do
        local color = {1, 1, 1}
        if i == idx then
            color = {1, 1, 0}
        end
        love.graphics.setColor(color)
        Text.DrawLeftText(50, 50 + (i - 1) * 30, text)
    end
end

function SearchHistory.keypressed(key, callback)
    if key == "r1" then
        callback("close")
        return
    end

    if key == "a" then
        callback("select")
        return
    end

    if key == "x" then
        callback("delete")
        return
    end

    if key == "up" then
        callback("up")
        return
    end

    if key == "down" then
        callback("down")
        return
    end
end

return SearchHistory