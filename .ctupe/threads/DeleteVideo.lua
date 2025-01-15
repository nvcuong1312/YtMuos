local Thread = require("thread")

-- baseSavePath, id 
local uChn = Thread.GetDeleteVideoIdChannel()

-- true/false
local dChn = Thread.GetDeleteVideoResultChannel()

while true do
    local uObj = uChn:pop()
    if uObj then
        local dirPath = uObj.baseSavePath .. "/" .. uObj.id
        local cmd = 'rm -rf "' .. dirPath .. '"'
        os.execute(cmd)
        dChn:push(true)
    end
end
