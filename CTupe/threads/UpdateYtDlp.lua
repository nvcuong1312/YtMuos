local Thread = require("thread")

local uChn = Thread.GetUpdateYtDlpChannel()

-- true/false
local dChn = Thread.GetUpdateYtDlpResultChannel()

while true do
    local uObj = uChn:pop()
    if uObj then
        os.execute('[ -d "CTupeData" ] && rm -rf CTupeData')
        os.execute('mkdir -p CTupeData')
        os.execute('wget -P CTupeData/ https://github.com/yt-dlp/yt-dlp-master-builds/releases/latest/download/yt-dlp_linux_aarch64')
        os.execute('cp CTupeData/yt-dlp_linux_aarch64 /usr/bin/yt-dlp')
        os.execute('chmod a+rx /usr/bin/yt-dlp')
        dChn:push(true)
    end
end
