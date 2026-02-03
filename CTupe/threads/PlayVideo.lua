local Config = require("config")
local Thread = require("thread")

local uChn = Thread.GetPlayUrl()
local dChn = Thread.GetPlayDone()

while true do
    local uObj = uChn:pop()
    if uObj then
        local url = uObj.url
        local res = "res:"..(uObj.resolution or "720")
        
        if uObj.isOnline then
            local command = string.format(Config.PLAY_CMD, url, res)
            os.execute(command)
            dChn:push(true)
        else
            local command = string.format(Config.PLAY_OFFLINE_CMD, url)
            os.execute(command)
            dChn:push(true)
        end
    end
end
