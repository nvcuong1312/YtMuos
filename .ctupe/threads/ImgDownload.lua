local love = require("love")
local http = require("socket.http")
local ltn12 = require("ltn12")
local Thread = require("thread")
local Config = require("config")

local rsChn  = Thread.GetDownloadResutlChannel()
local uChn = Thread.GetDownloadUrlChannel()

while true do
    local uObj = uChn:pop()
    if uObj then
        local url = uObj.url
        local width = uObj.width
        local height = uObj.height

        local buffer = {}
        local requestSuccess,_ = pcall(function()
            http.request{
                url = url,
                sink = ltn12.sink.table(buffer)
            }
        end)

        if requestSuccess then
            local _,_ = pcall(function()
                local file_data = love.filesystem.newFileData(table.concat(buffer), '' ,'file')
                rsChn:push(
                {
                    id = uObj.id,
                    imgData = file_data,
                    width = width,
                    height = height,
                    type = uObj.type
                })
            end)
        end
    end
end