local love = require("love")
local Config = require("config")
local CT = require("ct")
local Font = require("font")
local Keyboard = require("keyboard")
local Thread = require("thread")
local Loading = require("loading")
local Text = require("text")
local Color = require("color")
local Icon = require("icon")

local msg = "DEVELOPMENT STAGE"
local hasAPIKEY = false

local searchData = {}
local imgDataList = {}
local cPage = 1
local cIdx = 1

local isKeyboarFocus = false
local keyboardText = ""

local isLoading = false

function love.load()
    Font.Load()
    Keyboard:create()
    Thread.Create()

    CT.LoadSearchType()
    CT.LoadAPIKEY()

    searchData = CT.LoadSearchData()
    LoadImgData()

    hasAPIKEY = true
end

function love.draw()
    love.graphics.setBackgroundColor(Color.BG)
    HeaderUI()
    BodyUI()
    BottomUI()
    GuideUI()

    love.graphics.setFont(Font.Small())

    Keyboard:draw(isKeyboarFocus)

    if isLoading then
        Loading.Draw()
    end

    if not hasAPIKEY then return end
end

function love.update(dt)
    local imgDownloaded = Thread.GetDownloadResutlChannel():pop()
    if imgDownloaded then
        table.insert(imgDataList, imgDownloaded)
    end

    local searchResult = Thread.GetSearchVideoResultChannel():pop()
    if searchResult then
        searchData = CT.LoadSearchData()
        LoadImgData()
        isLoading = false
        cPage = 1
        cIdx = 1
    end

    local playDone = Thread.GetPlayDone():pop()
    if playDone then
        isLoading = false
    end

    if isLoading then
        Loading.Update(dt)
    end
end

-- Header
function HeaderUI()
    local xPos = 0
    local yPos = 0

    love.graphics.setColor(Color.HEADER_BG)
    love.graphics.rectangle("fill", xPos, yPos, 640, 30)

    love.graphics.setColor(Color.HEADER_TEXT)
    love.graphics.setFont(Font.Big())
    Text.DrawCenteredText(xPos, yPos + 3, 640, "CTupe")

    Now = os.date('*t')
    local formatted_time = string.format("%02d:%02d", tonumber(Now.hour), tonumber(Now.min))
    love.graphics.setColor(Color.HEADER_TIME)
    Text.DrawLeftText(xPos, yPos + 3, formatted_time)

    love.graphics.setFont(Font.Normal())
end

function BodyUI()
    local xPos = 0
    local yPos = 30
    local widthItem = 400
    local heightItem = 83
    local widthImgItem = 83
    local heigthImgItem = 63

    local widthImgMain = 239
    local heightImgMain = 145

    local total = table.getn(searchData)
    local idxStart = cPage * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = cPage * Config.GRID_PAGE_ITEM
    local iPos = 0

    local imgSelected = nil
    local imgSelectedScale = {}

    for i = idxStart, idxEnd do
        if i > total then break end

        local h = heightItem * (iPos) + iPos + 1
        love.graphics.setColor(Color.BODY_ITEM_BG)
        love.graphics.rectangle("fill", xPos, yPos + h , widthItem, heightItem)

        for _,imgData in pairs(imgDataList) do
            pcall(function ()
                if imgData.id == searchData[i].id and imgData.type == "thumbnail" then
                    local img = love.graphics.newImage(imgData.imgData)
                    love.graphics.setColor(Color.WHITE)
                    local scale = ScaleFactorImg(img:getWidth(), img:getHeight(), widthImgItem, heigthImgItem)
                    love.graphics.draw(img, xPos, yPos + h, 0, scale.scaleW, scale.scaleH, 0 , 0)
                end

                if cIdx == iPos + 1 then
                    if imgData.id == searchData[i].id and imgData.type == "thumbnail" then
                        imgSelectedScale = ScaleFactorImg(imgData.width, imgData.height, widthImgMain, heightImgMain)
                        imgSelected = love.graphics.newImage(imgData.imgData)
                    end
                end
            end)
        end

        love.graphics.setColor(Color.BODY_TITLE_ITEM)
        love.graphics.setFont(Font.Normal())
        love.graphics.printf(searchData[i].title, xPos + widthImgItem + 1, yPos + h, 320)

        love.graphics.setColor(Color.BODY_CHANNEL_ITEM)
        love.graphics.setFont(Font.Small())
        love.graphics.print(searchData[i].channelTitle, xPos, yPos + h + 63)
        love.graphics.print(searchData[i].time, xPos + widthImgItem + 240, yPos + h + 63)

        if cIdx == iPos + 1 then
            love.graphics.setColor(Color.BODY_ITEM_SEL_BG)
            love.graphics.rectangle("fill", xPos, yPos + h, widthItem, heightItem, 4)
        end

        iPos = iPos + 1
    end

    love.graphics.setColor(Color.BODY_IMG_DEF)
    if imgSelected then
        love.graphics.setColor(Color.WHITE)
        love.graphics.draw(imgSelected, xPos + widthItem + 1, yPos, 0, imgSelectedScale.scaleW, imgSelectedScale.scaleH, 0 , 0)
    else
        love.graphics.rectangle("fill", xPos + widthItem + 1, yPos, widthImgMain, heightImgMain)
    end
end

function BottomUI()
    local xPos = 0
    local yPos = 480 - 30 + 1
    love.graphics.setColor(Color.BOTTOM_BG)
    love.graphics.rectangle("fill", xPos, yPos, 640, 29)

    love.graphics.setColor(1,1,1)
    Text.DrawLeftText(xPos + 5, 450 + 5, msg)
end

function GuideUI()
    local xPos = 401
    local yPos = 30 + 240
    local width = 265
    local height = 180
    local heightTextBlock = 30

    love.graphics.setColor(Color.GUIDE_BG)
    love.graphics.rectangle("fill", xPos, yPos, width, height, 3,3)

    love.graphics.setColor(Color.GUIDE_TB_BG)
    love.graphics.rectangle("fill", xPos + 2, yPos + 2, width - 30, heightTextBlock, 3,3)
    love.graphics.setColor(Color.GUIDE_TB_BOR_BG)
    love.graphics.rectangle("line", xPos + 2, yPos + 2, width - 30, heightTextBlock, 3,3)
    love.graphics.setColor(Color.GUIDE_TB)
    Text.DrawLeftText(xPos + 2 + 2, yPos + 2 + 5, keyboardText)
    love.graphics.setColor(Color.GUIDE_TB)
    love.graphics.draw(Icon.Search, xPos + width - 50, yPos + 5, 0, 0.2)

    love.graphics.setColor(1,1,1,0.7)
    love.graphics.setFont(Font.Small())

    if isKeyboarFocus then
        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 20, "       Enter")
        love.graphics.draw(Icon.Y, xPos + 5, yPos + heightTextBlock + 18, 0, 0.4)

        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 50, "       Backspace")
        love.graphics.draw(Icon.X, xPos + 5, yPos + heightTextBlock + 48, 0, 0.4)

        Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 20, "       Space")
        love.graphics.draw(Icon.B, xPos + 5 + 100, yPos + heightTextBlock + 18, 0, 0.4)

        Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 50, "       Search")
        love.graphics.draw(Icon.Start, xPos + 5 + 100, yPos + heightTextBlock + 48, 0, 0.4)
    else
        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 20, "       Play")
        love.graphics.draw(Icon.A , xPos + 5, yPos + heightTextBlock + 18, 0, 0.4)
    end

    Text.DrawLeftText(xPos + 5, yPos + heightTextBlock + 120, "                     Exit")
    love.graphics.draw(Icon.Select, xPos + 5, yPos + heightTextBlock + 118, 0, 0.4)
    love.graphics.draw(Icon.Start, xPos + 5 + 30, yPos + heightTextBlock + 118, 0, 0.4)
end

function LoadImgData()
    for _,item in pairs(searchData) do
        local uChn = Thread.GetDownloadUrlChannel()
        uChn:push(
        {
            id = item.id,
            url = item.thumbnail.url,
            width = item.thumbnail.width,
            height = item.thumbnail.height,
            type = "thumbnail"
        })

        -- uChn:push(
        -- {
        --     id = item.id,
        --     url = item.thumbnailMed.url,
        --     width = item.thumbnailMed.width,
        --     height = item.thumbnailMed.height,
        --     type = "thumbnailMed"
        -- })
    end
end

function ScaleFactorImg(imgW, imgH, eW, eH)
    return {
        scaleW = eW / imgW,
        scaleH = eH / imgH
    }
end

function love.gamepadpressed(joystick, button)
    local key = ""
    if button == "dpleft" then
        key = "left"
    end
    if button == "dpright" then
        key = "right"
    end
    if button == "dpup" then
        key = "up"
    end
    if button == "dpdown" then
        key = "down"
    end
    if button == "a" then
        key = "a"
    end
    if button == "b" then
        key = "b"
    end
    if button == "x" then
        key = "x"
    end
    if button == "y" then
        key = "y"
    end
    if button == "back" then
        key = "select"
    end
    if button == "start" then
        key = "start"
    end
    if button == "leftshoulder" then
        key = "l1"
    end
    if button == "rightshoulder" then
        key = "r1"
    end
    if button == "guide" then
        key = "guide"
    end

    OnKeyPress(key)
end

function love.keypressed(key)
	OnKeyPress(key)
end

function OnKeyboarCallBack(value)
    -- msg = value
    if #keyboardText < 30 then
        keyboardText = keyboardText .. value
    end
end

function OnKeyPress(key)
    if isLoading then return end

    if key == "l1" or key == "l" then
        isKeyboarFocus = not isKeyboarFocus
    end

    if (key == "start" or key == "s") and #keyboardText > 0 then
        isLoading = true
        CT.Search(keyboardText)
    end

    if key == "select" then
    end

    if key == "x" then
        if #keyboardText > 0 then
            keyboardText = string.sub(keyboardText, 1, #keyboardText - 1)
        end
    end

    if isKeyboarFocus then
        Keyboard.keypressed(key, OnKeyboarCallBack)
        return
    end

    if key == "a" then
        if table.getn(searchData) >= cIdx  then
            isLoading = true
            CT.Play(string.format(Config.YT_PLAY_URL, searchData[cIdx].id))
        end
    end

    if table.getn(searchData) > 0 then
        if key == "up" then
            GridKeyUp(searchData, cPage, cIdx, Config.GRID_PAGE_ITEM,
            function(idx) cIdx = idx end,
            function(page) cPage = page end)
        end

        if key == "down" then
            GridKeyDown(searchData, cPage, cIdx, Config.GRID_PAGE_ITEM,
            function(idx)
                cIdx = idx
             end,
            function(page)
                cPage = page
            end)
        end
    end
 end

 function GridKeyUp(list,currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage > 1 then
            if idxCurr > 1 then
                callBackSetIdx(idxCurr - 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(currPage - 1) end
                callBackSetIdx(maxPageItem)
            end
        else
            if idxCurr > 1 then
                callBackSetIdx(idxCurr - 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(totalPage) end
                callBackSetIdx(remainder)
            end
        end
    else
        if idxCurr > 1 then
            callBackSetIdx(idxCurr - 1)
        else
            callBackSetIdx(total)
        end
    end
end

function GridKeyDown(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 then return end
    local isMultiplePage = total > maxPageItem
    if isMultiplePage then
        local remainder = total % maxPageItem
        local totalPage = 1
        local q, _ = math.modf(total / maxPageItem)
        if remainder > 0 then
            totalPage =  q + 1
        else
            totalPage = q
            remainder = maxPageItem
        end

        if currPage < totalPage then
            if idxCurr < maxPageItem then
                callBackSetIdx(idxCurr + 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(currPage + 1) end
                callBackSetIdx(1)
            end
        else
            if  idxCurr < remainder then
                callBackSetIdx(idxCurr + 1)
            else
                if callBackChangeCurrPage then callBackChangeCurrPage(1) end
                callBackSetIdx(1)
            end
        end
    else
        if idxCurr < total then
            callBackSetIdx(idxCurr + 1)
        else
            callBackSetIdx(1)
        end
    end
end