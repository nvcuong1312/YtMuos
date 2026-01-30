local love = require("love")
local Config = require("config")

local Font = {}

local Big
function Font.Big()
    return Big
end

local Normal
function Font.Normal()
    return Normal
end

local Small
function Font.Small()
    return Small
end

function Font.Load()
    Big = love.graphics.newFont(Config.FONT_PATH, 17)
    Normal = love.graphics.newFont(Config.FONT_PATH, 14)
    Small = love.graphics.newFont(Config.FONT_PATH, 12)
end

return Font