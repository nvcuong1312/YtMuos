local Config = require("config")
local Thread = require("thread")
local timer = require("love.timer")

local uChn = Thread.GetPlayUrl()
local dChn = Thread.GetPlayDone()

while true do
    local uObj = uChn:pop()
    if uObj then
        local url = uObj.url
        local res = "res:"..(uObj.resolution or "720")
        
        local command = ""
        if uObj.isOnline then command = string.format(Config.PLAY_CMD, url, res)
        else command = string.format(Config.PLAY_OFFLINE_CMD, url) end
        os.execute(command)
        
        timer.sleep(0.5)
        dChn:push(true)
    end
end
