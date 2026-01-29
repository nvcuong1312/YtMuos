local Config = require("config")
local Thread = require("thread")

local uChn = Thread.GetPlayUrl()
local dChn = Thread.GetPlayDone()

while true do
    local uObj = uChn:pop()
    if uObj then
        local url = uObj.url

        if uObj.isOnline then
            local command = string.format(Config.PLAY_FFPLAY_CMD, url)
            os.execute(command)
            dChn:push(true)
        else
            local command = string.format(Config.PLAY_FFPLAY_OFFLINE_CMD, url)
            os.execute(command)
            dChn:push(true)
        end
    end
end
