local love = require("love")

local Thread = {}

function Thread.Create()
    love.thread.newThread("threads/ImgDownload.lua"):start()
    love.thread.newThread("threads/ImgOffline.lua"):start()
    love.thread.newThread("threads/PlayVideo.lua"):start()
    love.thread.newThread("threads/SearchVideo.lua"):start()
    love.thread.newThread("threads/DownloadVideo.lua"):start()
    love.thread.newThread("threads/DeleteVideo.lua"):start()
end

function Thread.GetDownloadResutlChannel()
    return love.thread.getChannel("download_result")
end

function Thread.GetDownloadUrlChannel()
    return love.thread.getChannel("download_url")
end

function Thread.GetOfflineResutlChannel()
    return love.thread.getChannel("offline_result")
end

function Thread.GetOfflineUrlChannel()
    return love.thread.getChannel("offline_url")
end

function Thread.GetPlayUrl()
    return love.thread.getChannel("play_url")
end

function Thread.GetPlayDone()
    return love.thread.getChannel("play_done")
end

function Thread.GetSearchVideoKeywordChannel()
    return love.thread.getChannel("search_keyword")
end

function Thread.GetSearchVideoResultChannel()
    return love.thread.getChannel("search_result")
end

function Thread.GetDownloadVideoUrlChannel()
    return love.thread.getChannel("download_video_url")
end

function Thread.GetDownloadVideoResultChannel()
    return love.thread.getChannel("download_video_result")
end

function Thread.GetDeleteVideoIdChannel()
    return love.thread.getChannel("delete_video_id")
end

function Thread.GetDeleteVideoResultChannel()
    return love.thread.getChannel("delete_video_result")
end

return Thread