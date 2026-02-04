local love = require("love")
local Config = require("config")
local CT = require("ct")
local Font = require("font")
local Keyboard = require("keyboard")
local SearchHistory = require("searchhistory")
local Thread = require("thread")
local Loading = require("loading")
local Text = require("text")
local Color = require("color")
local Icon = require("icon")

local version = "v1.2.4 - by nvcuong1312"
local hasAPIKEY = false

local isShowOnlineList = true

local searchData = {}
local imgDataList = {}
local cPage = 1
local cIdx = 1

local downloadedData = {}
local imgDownloadedDataList = {}
local cDownloadedPage = 1
local cDownloadedIdx = 1

local isKeyboarFocus = false
local keyboardText = ""

local isLoading = false
local isPlaying = false
local loadingText = "loading..."

local isShowSearchHistory = false
local tableSearchHistory = {}
local searchHistoryIdx = 1
local searchHistoryPage = 1
local tableSearchHistoryDisplay = {}

local baseSavePath = ""

local _screenW, _screenH = love.window.getDesktopDimensions()

local function fileExists(path)
    local ok = os.execute('[ -f "' .. path .. '" ]')
    return ok == true or ok == 0
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if isPlaying then return end

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end

function love.load()
    Font.Load()
    Keyboard:create()
    Thread.Create()

    baseSavePath = CT.LoadSavePath()
    CT.LoadSearchType()
    CT.LoadAPIKEY()

    searchData = CT.LoadSearchData()
    LoadImgData()

    tableSearchHistory = CT.GetSearchHistory()
    if #tableSearchHistory > 0 then
        keyboardText = tableSearchHistory[1]
    end

    hasAPIKEY = true

    if not fileExists("bin/yt-dlp") then
        OnKeyPress("r1")
    end
end

function love.draw()
    pcall(function ()
        local scaleX = _screenW / 640
        local scaleY = _screenH / 480

        love.graphics.push()
        love.graphics.scale(scaleX, scaleY)
        
        love.graphics.setBackgroundColor(Color.BG)

        if not isLoading then
            HeaderUI()
            BodyUI()
            GuideUI()
            BottomUI()
            Keyboard:draw(isKeyboarFocus)
            
            if isShowSearchHistory then
                tableSearchHistoryDisplay = {}
                local startIdx = (searchHistoryPage - 1) * 10 + 1
                local endIdx = math.min(searchHistoryPage * 10, table.getn(tableSearchHistory))
                for i = startIdx, endIdx do
                    table.insert(tableSearchHistoryDisplay, tableSearchHistory[i])
                end
                
                SearchHistory.Draw(tableSearchHistoryDisplay, searchHistoryIdx)
            end
        end

        if isLoading then
            Loading.Draw(loadingText)
        end

        love.graphics.pop()
    end)
end

function love.update(dt)
    local playDone = Thread.GetPlayDone():pop()
    if playDone then
        isLoading = false
        isPlaying = false
    end

    if isPlaying then
        love.timer.sleep(1)
        return
    end

    local trackingYtDlp = Thread.GetTrackingYtDlpResultChannel():pop()
    if trackingYtDlp then
        if trackingYtDlp == "done" then
            isLoading = false
            isPlaying = true
        else
            setLoadingState(true, trackingYtDlp)
        end

        return
    end

    local ytdlpUpdated = Thread.GetUpdateYtDlpResultChannel():pop()
    if ytdlpUpdated then
        isLoading = false
    end

    local videoDownloaded = Thread.GetDownloadVideoResultChannel():pop()
    if videoDownloaded then
        isLoading = false
    end

    local imgDownloaded = Thread.GetDownloadResutlChannel():pop()
    if imgDownloaded then
        table.insert(imgDataList, imgDownloaded)
    end

    local imgOffline = Thread.GetOfflineResutlChannel():pop()
    if imgOffline then
        table.insert(imgDownloadedDataList, imgOffline)
    end

    local searchResult = Thread.GetSearchVideoResultChannel():pop()
    if searchResult then
        searchData = CT.LoadSearchData()
        LoadImgData()
        isLoading = false
        cPage = 1
        cIdx = 1
    end

    local deleteFile = Thread.GetDeleteVideoResultChannel():pop()
    if deleteFile then
        isLoading = false
        downloadedData = CT.LoadDataFromSavePath()
        LoadOfflineImgData()
        cDownloadedIdx = 1
        cDownloadedPage = 1
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
    if isShowOnlineList then
        RenderBodyList(searchData, cPage, cIdx, imgDataList)
    else
        RenderBodyList(downloadedData, cDownloadedPage, cDownloadedIdx, imgDownloadedDataList)
    end
end

function RenderBodyList(datas, page, idx, imgs)
    local xPos = 0
    local yPos = 30
    local widthItem = 400
    local heightItem = 83
    local widthImgItem = 83
    local heigthImgItem = 63

    local widthImgMain = 239
    local heightImgMain = 145

    local total = table.getn(datas)

    if total == 0 then
        love.graphics.setFont(Font.Big())
        Text.DrawCenteredText(0, 210, 400, "Nothing...")
        love.graphics.setFont(Font.Normal())
    end

    local idxStart = page * Config.GRID_PAGE_ITEM - Config.GRID_PAGE_ITEM + 1
    local idxEnd = page * Config.GRID_PAGE_ITEM
    local iPos = 0

    local imgSelected = nil
    local imgSelectedScale = {}

    for i = idxStart, idxEnd do
        if i > total then break end

        local h = heightItem * (iPos) + iPos + 1
        love.graphics.setColor(Color.BODY_ITEM_BG)
        love.graphics.rectangle("fill", xPos, yPos + h , widthItem, heightItem)

        for _,imgData in pairs(imgs) do
            pcall(function ()
                if imgData.id == datas[i].id then
                    local img = love.graphics.newImage(imgData.imgData)
                    love.graphics.setColor(Color.WHITE)
                    local scale = ScaleFactorImg(img:getWidth(), img:getHeight(), widthImgItem, heigthImgItem)
                    love.graphics.draw(img, xPos, yPos + h, 0, scale.scaleW, scale.scaleH, 0 , 0)
                end

                if idx == iPos + 1 then
                    if imgData.id == datas[i].id then
                        imgSelectedScale = ScaleFactorImg(imgData.width, imgData.height, widthImgMain, heightImgMain)
                        imgSelected = love.graphics.newImage(imgData.imgData)
                    end
                end
            end)
        end

        love.graphics.setColor(Color.BODY_TITLE_ITEM)
        love.graphics.setFont(Font.Normal())
        love.graphics.printf(datas[i].title, xPos + widthImgItem + 1, yPos + h, 320)

        love.graphics.setColor(Color.BODY_CHANNEL_ITEM)
        love.graphics.setFont(Font.Small())
        love.graphics.print(datas[i].channelTitle, xPos, yPos + h + 63)
        love.graphics.print(datas[i].time, xPos + widthImgItem + 240, yPos + h + 63)

        if idx == iPos + 1 then
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
        love.graphics.setColor(Color.WHITE)
        love.graphics.draw(Icon.Thumbnail, xPos + widthItem + 1 + 105, yPos + 45, 0, 0.5, 0.5)
    end

    love.graphics.setFont(Font.Big())
    love.graphics.setColor(Color.BODY_TITLE_ITEM)

    local infoText = tostring(((page -1) * Config.GRID_PAGE_ITEM) + idx) .. " / " .. tostring(total)
    Text.DrawLeftText(580, 3, infoText)
end

function BottomUI()
    local xPos = 0
    local yPos = 480 - 30 + 1
    love.graphics.setColor(Color.BOTTOM_BG)
    love.graphics.rectangle("fill", xPos, yPos, 640, 29)

    love.graphics.setColor(1,1,1)
    Text.DrawLeftText(xPos + 5, 450 + 5, version)
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
    Text.DrawLeftText(xPos + 2 + 2, yPos + 2 + 2, keyboardText)
    love.graphics.setColor(Color.GUIDE_TB)
    love.graphics.draw(Icon.Search, xPos + width - 50, yPos + 5, 0, 0.2)

    love.graphics.setColor(1,1,1,0.7)
    love.graphics.setFont(Font.Small())

    if isKeyboarFocus then
        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 20, "       Enter")
        love.graphics.draw(Icon.A, xPos + 5, yPos + heightTextBlock + 18, 0, 0.4)

        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 50, "       Backspace")
        love.graphics.draw(Icon.X, xPos + 5, yPos + heightTextBlock + 48, 0, 0.4)

        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 80, "       History")
        love.graphics.draw(Icon.R1, xPos + 5, yPos + heightTextBlock + 82, 0, 0.4)

        Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 20, "       Space")
        love.graphics.draw(Icon.B, xPos + 5 + 100, yPos + heightTextBlock + 18, 0, 0.4)

        Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 50, "       Search")
        love.graphics.draw(Icon.Start, xPos + 5 + 100, yPos + heightTextBlock + 48, 0, 0.4)
    else
        Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 20, "       Play")
        love.graphics.draw(Icon.A , xPos + 5, yPos + heightTextBlock + 18, 0, 0.4)

        if isShowOnlineList then
            Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 50, "       Offline List")
        else
            Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 50, "       Online List")
        end
        love.graphics.draw(Icon.Select, xPos + 5, yPos + heightTextBlock + 48, 0, 0.4)

        if isShowOnlineList then
            Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 20, "       Download")
        else
            Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 20, "       Delete")
        end
        love.graphics.draw(Icon.X , xPos + 5 + 100, yPos + heightTextBlock + 18, 0, 0.4)
    end

    Text.DrawLeftText(xPos + 10, yPos + heightTextBlock + 120, "       Exit")
    love.graphics.draw(Icon.B, xPos + 5, yPos + heightTextBlock + 118, 0, 0.4)

    Text.DrawLeftText(xPos + 10 + 100, yPos + heightTextBlock + 120, "       Update yt-dlp")
    love.graphics.draw(Icon.R1 , xPos + 5 + 100, yPos + heightTextBlock + 122, 0, 0.4)
end

function LoadImgData()
    imgDataList = {}
    for _,item in pairs(searchData) do
        local uChn = Thread.GetDownloadUrlChannel()
        uChn:push(
        {
            id = item.id,
            url = item.thumbnail.url,
            width = item.thumbnail.width,
            height = item.thumbnail.height,
            type = "online"
        })
    end
end

function LoadOfflineImgData()
    imgDownloadedDataList = {}
    for _,item in pairs(downloadedData) do
        local uChn = Thread.GetOfflineUrlChannel()
        uChn:push(
        {
            id = item.id,
            url = item.thumbnail.url,
            width = item.thumbnail.width,
            height = item.thumbnail.height,
            type = "offline",
            basePath = baseSavePath
        })
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
    if #keyboardText < 30 then
        keyboardText = keyboardText .. value
    end
end

function OnKeyPress(key)
    if isLoading or isPlaying then return end

    if isShowSearchHistory then
        SearchHistory.keypressed(key,
        function(action)
            if action == "close" then
                isShowSearchHistory = false
            elseif action == "select" then
                local selPos = (searchHistoryPage - 1) * 10 + searchHistoryIdx
                keyboardText = tableSearchHistory[selPos]
                isShowSearchHistory = false
            elseif action == "delete" then
                local delPos = (searchHistoryPage - 1) * 10 + searchHistoryIdx
                table.remove(tableSearchHistory, delPos)
                if searchHistoryIdx > table.getn(tableSearchHistory) then
                    searchHistoryIdx = table.getn(tableSearchHistory)
                end
                CT.SaveSearchHistory(tableSearchHistory)

            elseif action == "up" then
                GridKeyUp(tableSearchHistory, searchHistoryPage, searchHistoryIdx, 10,
                function(idx) searchHistoryIdx = idx end,
                function(page) searchHistoryPage = page end)
            elseif action == "down" then
                GridKeyDown(tableSearchHistory, searchHistoryPage, searchHistoryIdx, 10,
                function(idx) searchHistoryIdx = idx end,
                function(page) searchHistoryPage = page end)
            end
        end)
        
        return
    end

    if key == "b" and not isPlaying and not isKeyboarFocus then
        love.event.quit()
    end

    if key == "l1" or key == "l" then
        isKeyboarFocus = not isKeyboarFocus
    end

    if (key == "start" or key == "s") and #keyboardText > 0 then
        setLoadingState(true, "searching...")
        isKeyboarFocus = false

        local isExist = false
        for _,text in pairs(tableSearchHistory) do
            if text == keyboardText then
                isExist = true
                break
            end
        end
        if not isExist then
            table.insert(tableSearchHistory, 1, keyboardText)
            CT.SaveSearchHistory(tableSearchHistory)
        end

        CT.Search(keyboardText)
    end

    if key == "x" then
        if #keyboardText > 0 then
            keyboardText = string.sub(keyboardText, 1, #keyboardText - 1)
        end
    end

    if isKeyboarFocus then
        if key == "r1" then
            isShowSearchHistory = true
            return
        end

        Keyboard.keypressed(key, OnKeyboarCallBack)
        return
    end

    if key == "select" or key == "t" then
        ChangeOfflineMode()
    end

    if key == "a" then
        if isShowOnlineList then
            local pos = (cPage - 1) * Config.GRID_PAGE_ITEM + cIdx
            if table.getn(searchData) >= pos  then
                 setLoadingState(true, "loading...")
                CT.Play(string.format(Config.YT_PLAY_URL, searchData[pos].id), _screenH)
            end
        else
            local pos = (cDownloadedPage - 1) * Config.GRID_PAGE_ITEM + cDownloadedIdx
            if table.getn(downloadedData) >= pos  then
                isPlaying = true
                CT.PlayOffline(baseSavePath .. Config.PATH_SEPARATOR .. downloadedData[pos].id .. Config.PATH_SEPARATOR .. Config.SAVE_MEDIA_PATH, _screenH)
            end
        end
    end

    if key == "x" then
        if isShowOnlineList then
            local pos = (cPage - 1) * Config.GRID_PAGE_ITEM + cIdx
            if table.getn(searchData) >= pos  then
                isLoading = true
                loadingText = "downloading..."
                CT.GenerateMediaFile(searchData[pos])
            end
        else
            local pos = (cDownloadedPage - 1) * Config.GRID_PAGE_ITEM + cDownloadedIdx
            if table.getn(downloadedData) >= pos  then
                setLoadingState(true, "deleting...")
                CT.DeleteMediaFile(downloadedData[pos].id)
            end
        end
    end

    if key == "r1" then
        setLoadingState(true, "updating yt-dlp...")
        Thread.GetUpdateYtDlpChannel():push({type = "update"})
        return
    end

    if table.getn(searchData) > 0 then
        if key == "up" then
            if isShowOnlineList then
                GridKeyUp(searchData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
            else
                GridKeyUp(downloadedData, cDownloadedPage, cDownloadedIdx, Config.GRID_PAGE_ITEM,
                function(idx) cDownloadedIdx = idx end,
                function(page) cDownloadedPage = page end)
            end
        end

        if key == "down" then
            if isShowOnlineList then
                GridKeyDown(searchData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
            else
                GridKeyDown(downloadedData, cDownloadedPage, cDownloadedIdx, Config.GRID_PAGE_ITEM,
                function(idx) cDownloadedIdx = idx end,
                function(page) cDownloadedPage = page end)
            end
        end

        if key == "left" then
            if isShowOnlineList then
                GridKeyLeft(searchData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
            else
                GridKeyLeft(downloadedData, cDownloadedPage, cDownloadedIdx, Config.GRID_PAGE_ITEM,
                function(idx) cDownloadedIdx = idx end,
                function(page) cDownloadedPage = page end)
            end
        end

        if key == "right" then
            if isShowOnlineList then
                GridKeyRight(searchData, cPage, cIdx, Config.GRID_PAGE_ITEM,
                function(idx) cIdx = idx end,
                function(page) cPage = page end)
            else
                GridKeyRight(downloadedData, cDownloadedPage, cDownloadedIdx, Config.GRID_PAGE_ITEM,
                function(idx) cDownloadedIdx = idx end,
                function(page) cDownloadedPage = page end)
            end
        end
    end
end

function ChangeOfflineMode()
    isShowOnlineList = not isShowOnlineList

    if not isShowOnlineList then
        downloadedData = CT.LoadDataFromSavePath()
        LoadOfflineImgData()
    end
end

function setLoadingState(isShow, text)
    isLoading = isShow
    loadingText = text
end

 function GridKeyUp(list,currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
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
    if total < 1 or total == 1 then return end
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

function GridKeyLeft(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
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
            callBackChangeCurrPage(currPage - 1)
            callBackSetIdx(1)
        end
    end
end

function GridKeyRight(list, currPage, idxCurr, maxPageItem, callBackSetIdx, callBackChangeCurrPage)
    local total = table.getn(list)
    if total < 1 or total == 1 then return end
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
            callBackChangeCurrPage(currPage + 1)
            callBackSetIdx(1)
        end
    end
end