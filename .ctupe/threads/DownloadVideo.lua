local Config = require("config")
local Thread = require("thread")
local json = require("json")

-- baseSavePath
-- data
    -- id = item.videoRenderer.videoId,
    -- time = time,
    -- title = title,
    -- description = "",
    -- thumbnail = thumbnail,
    -- channelTitle = channelTitle
--CT.GenerateMediaFile(string.format(Config.YT_PLAY_URL, searchData[cIdx].id), searchData[cIdx].id, searchData[cIdx].thumbnail)
local uChn = Thread.GetDownloadVideoUrlChannel()

-- true/false
local dChn = Thread.GetSearchVideoResultChannel()

local function save_file(filename, content)
    local file, err = io.open(filename, "w")
    if not file then
        print("Error opening file:", err)
        return false
    end

    file:write(content)
    file:close()
    print("File saved:", filename)
    return true
end

while true do
    local uObj = uChn:pop()
    if uObj then
        local url = string.format(Config.YT_PLAY_URL, uObj.data.id)

        local dirPath = uObj.baseSavePath .. "/" .. uObj.data.id
        local dataPath = dirPath .. "/MediaData"
        local infoPath = dirPath .. "/InfoData"

        os.execute("mkdir -p " .. dirPath)

        local command = "youtube-dl -S \"res:640\" -o - \"" .. url .."\" > " .. dataPath

        print(command)
        os.execute(command)

        local jsonData = json.encode(uObj.data)
        save_file(infoPath, jsonData)

        dChn:push(true)
    end
end
