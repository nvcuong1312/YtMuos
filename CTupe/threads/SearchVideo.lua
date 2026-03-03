local Config = require("config")
local Thread = require("thread")

local keyChn = Thread.GetSearchVideoKeywordChannel()
local reChn = Thread.GetSearchVideoResultChannel()

while true do
    local searchData = keyChn:pop()
    if searchData then
        local command = ""
        if searchData.type == "1" then
            local searchCmd = "wget \"https://www.youtube.com/results?search_query=".. searchData.search .. "&sp=EgIQAQ%3D%3D\" -O data/searchDataFull.txt"
            os.execute(searchCmd)
            local jsCmd = "tr '\\n' ' ' < data/searchDataFull.txt | sed 's/.*var ytInitialData = //' | sed 's/\"targetId\":\"search-page\"}.*/\"targetId\":\"search-page\"}/' > data/result_cr.json"
            os.execute(jsCmd)
        else
            local searchCmd = string.format(Config.SEARCH_URL, searchData.search, Config.SEARCH_MAX_RESULT, searchData.key)
            command = "wget \"" .. searchCmd .."\" -O " .. Config.SEARCH_RESUTL_JSON
            os.execute(command)
        end

        reChn:push(true)
    end
end
