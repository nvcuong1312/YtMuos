local Config = require("config")
local Thread = require("thread")

local uChn = Thread.GetPlayUrl()
local dChn = Thread.GetPlayDone()

while true do
    local uObj = uChn:pop()
    if uObj then
        local command = string.format(Config.PLAY_FFPLAY_CMD, uObj)
        os.execute(command)
        dChn:push(true)
    end
end
