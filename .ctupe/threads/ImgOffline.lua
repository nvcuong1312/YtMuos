local love = require("love")
local http = require("socket.http")
local ltn12 = require("ltn12")
local Thread = require("thread")
local Config = require("config")

local rsChn  = Thread.GetOfflineResutlChannel()
local uChn = Thread.GetOfflineUrlChannel()

while true do
    local uObj = uChn:pop()
    if uObj then
        local width = uObj.width
        local height = uObj.height

        local _,_ = pcall(function()
            local pathImg = uObj.basePath .. "/" .. uObj.id .. "/" .. Config.SAVE_THUMBNAIL_PATH
            local file = io.open(pathImg, "rb")
            if file then
                local data = file:read("*all")
                file:close()
                local file_data = love.filesystem.newFileData(data, '' ,"file")
                rsChn:push(
                {
                    id = uObj.id,
                    imgData = file_data,
                    width = width,
                    height = height,
                    type = uObj.type
                })
            else
                print("File not found: " .. pathImg)
            end
        end)
    end
end