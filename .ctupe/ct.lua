local love = require("love")
local Config = require("config")
local json = require("json")
local Thread = require("thread")

local CT = {}

local API_KEY = ""

-- 1: crawl
-- 2: v3
local searchType = "1"

function CT.LoadSearchType()
    local typeFile = io.open(Config.SEARCH_TYPE, "r")
    if typeFile then
        searchType = typeFile:read("*all")
    else
        searchType = "2"
    end
end

function CT.LoadSearchData()
    local resultData = {}

    if searchType == "1" then
        local file = io.open(Config.SEARCH_RESUTL_CR_JSON, "r")
        if not file then
            return resultData
        end

        local dataResultJs = file:read("*all")
        file:close()

        local rsObj = json.decode(dataResultJs)
        if   rsObj.contents ~= nil
         and rsObj.contents.twoColumnSearchResultsRenderer ~= nil
         and rsObj.contents.twoColumnSearchResultsRenderer.primaryContents ~= nil
         and rsObj.contents.twoColumnSearchResultsRenderer.primaryContents.sectionListRenderer ~= nil
         and rsObj.contents.twoColumnSearchResultsRenderer.primaryContents.sectionListRenderer.contents ~= nil
        then
            local contents = rsObj.contents.twoColumnSearchResultsRenderer.primaryContents.sectionListRenderer.contents
            if table.getn(contents) > 0 then
                for _, itemContent in pairs(contents) do
                    if   itemContent.itemSectionRenderer ~= nil
                     and itemContent.itemSectionRenderer.contents ~= nil
                    then
                        local items = itemContent.itemSectionRenderer.contents
                        if items ~= nil and table.getn(items) > 0 then
                            for _, item in pairs(items) do
                                if item.videoRenderer then
                                    local time = ""
                                    if item.videoRenderer.publishedTimeText ~= nil then
                                        time = item.videoRenderer.publishedTimeText.simpleText
                                    end

                                    local title = "Title"
                                    if item.videoRenderer.title ~= nil
                                       and item.videoRenderer.title.runs ~= nil
                                       and table.getn(item.videoRenderer.title.runs) > 0 then
                                        title = item.videoRenderer.title.runs[1].text
                                    end

                                    local thumbnail = {}
                                    if item.videoRenderer.thumbnail ~= nil
                                     and item.videoRenderer.thumbnail.thumbnails ~= nil
                                     and table.getn(item.videoRenderer.thumbnail.thumbnails) > 0 then
                                        thumbnail = item.videoRenderer.thumbnail.thumbnails[1]
                                    end

                                    local channelTitle = ""
                                    if item.videoRenderer.ownerText ~= nil
                                     and item.videoRenderer.ownerText.runs ~= nil
                                     and table.getn(item.videoRenderer.ownerText.runs) > 0 then
                                        channelTitle = item.videoRenderer.ownerText.runs[1].text
                                    end

                                    table.insert(resultData,
                                    {
                                        id = item.videoRenderer.videoId,
                                        time = time,
                                        title = title,
                                        description = "",
                                        thumbnail = thumbnail,
                                        channelTitle = channelTitle
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end

        return resultData
    end

    local file = io.open(Config.SEARCH_RESUTL_JSON, "r")

    if not file then
        return resultData
    end

    local dataResultJs = file:read("*all")
    file:close()
    local rsObj = json.decode(dataResultJs)
    local items = rsObj.items

    if items ~= nil and table.getn(items) > 0 then
        for idx, item in pairs(items) do
            table.insert(
                resultData,
                {
                    id = item.id.videoId,
                    time = string.sub(item.snippet.publishedAt, 1, 10),
                    title = item.snippet.title,
                    description = item.snippet.description,
                    thumbnail = item.snippet.thumbnails.default.url,
                    thumbnailMed = item.snippet.thumbnails.medium.url,
                    channelTitle = item.snippet.channelTitle
                })
        end
    end

    return resultData
end

function CT.LoadAPIKEY()
    local file = io.open(Config.API_KEY_PATH, "r")
    API_KEY = file:read("*all")
    file:close()

    return API_KEY
end

function CT.Search(search)
    -- if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") ~= "1" then
    --     local searchCmd = string.format(Config.SEARCH_URL, searchKey, Config.SEARCH_MAX_RESULT, API_KEY)
    --     local command = "wget \"" .. searchCmd .."\" -O " .. Config.SEARCH_RESUTL_JSON
    --     os.execute(command)
    -- end

    Thread.GetSearchVideoKeywordChannel():push({type = searchType, search = search, key = API_KEY})
end

function CT.GenerateMediaFile(url)
    local command = "youtube-dl -f \"bestvideo[width<=640][height<=480]+bestaudio\" -o - \"" .. url .."\" > " .. Config.MEDIA_PATH
    os.execute(command)
end

function CT.Play(url)
    Thread.GetPlayUrl():push(url)
end

return CT