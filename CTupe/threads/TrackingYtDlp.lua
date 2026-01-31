local Thread = require("thread")
local timer = require("love.timer")

local uChn = Thread.GetTrackingYtDlp()

-- true/false
local dChn = Thread.GetTrackingYtDlpResultChannel()

local logPath = "/tmp/yt-dlp.log"
while true do
    local uObj = uChn:pop()
    if uObj then
        timer.sleep(1)  -- wait for yt-dlp to start logging
        local f = io.open(logPath, "r")
        if f then
            f:seek("end")
            local lastLine = nil
            while true do
                local line = f:read("*l")
                if line then
                    if string.find(line, "%[hlsnative%]") 
                    or string.find(line, "%[info%]") 
                    or string.find(line, "%[Destination%]") then
                        dChn:push("done")
                        break
                    else
                        dChn:push(line)
                    end
                else
                    timer.sleep(0.01)
                end
            end
        end
    end
end
