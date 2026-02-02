local Config = require("config")
local Thread = require("thread")

local uChn = Thread.GetPlayUrl()
local dChn = Thread.GetPlayDone()

while true do
    local uObj = uChn:pop()
    if uObj then
        local url = uObj.url
        local res = "res:"..(uObj.resolution or "720")

        local cmdOnline = Config.PLAY_MPV_CMD
        local cmdOffline = Config.PLAY_MPV_OFFLINE_CMD

        local isFFplay = false
        if isFFplay then
            cmdOnline = Config.PLAY_FFPLAY_CMD
            cmdOffline = Config.PLAY_FFPLAY_OFFLINE_CMD
        end

        if uObj.isOnline then
            local command = string.format(cmdOnline, url, res)
            os.execute(command)
            dChn:push(true)
        else
            local command = string.format(cmdOffline, url)
            os.execute(command)
            dChn:push(true)
        end
    end
end
