local Config = require("config")
local Thread = require("thread")

-- baseSavePath, url, id, thumbnail
local uChn = Thread.GetDownloadVideoUrlChannel()

-- true/false
local dChn = Thread.GetSearchVideoResultChannel()

while true do
    local uObj = uChn:pop()
    if uObj then
        local baseSavePath = uObj.baseSavePath
        local url = uObj.url
        local id = uObj.id
        local thumbnail = uObj.thumbnail
        print( baseSavePath .. "/" .. id .. "/MediaData")

        local command = "youtube-dl -f \"bestvideo[width<=640][height<=480]+bestaudio\" -o - \"" .. url .."\" > " .. baseSavePath .. "/" .. id .. "/MediaData"
        os.execute(command)

        dChn:push(true)
    end
end
