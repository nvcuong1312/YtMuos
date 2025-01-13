local Config = require("config")
local Thread = require("thread")

local keyChn = Thread.GetSearchVideoKeywordChannel()
local reChn = Thread.GetSearchVideoResultChannel()

while true do
    local searchData = keyChn:pop()
    if searchData then
        local command = ""
        if searchData.type == "1" then
            local searchCmd =
            [[
                wget "https://www.youtube.com/results?search_query=%s&sp=EgIQAQ%3D%3D" -O data/searchDataFull.txt &
                    grep -oP 'var ytInitialData = \K.*?(?=;</script>)' data/searchDataFull.txt > result_cr.json
            ]]

            command = string.format(searchCmd, searchData.search)
        else
            local searchCmd = string.format(Config.SEARCH_URL, searchData.search, Config.SEARCH_MAX_RESULT, searchData.key)
            command = "wget \"" .. searchCmd .."\" -O " .. Config.SEARCH_RESUTL_JSON
        end

        os.execute(command)

        reChn:push(true)
    end
end
