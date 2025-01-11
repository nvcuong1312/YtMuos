local love = require("love")
local Font = require("font")
local Keyboard = {}

Keyboard.width = 215.1
Keyboard.height = 84.6
Keyboard.spacing = 1
Keyboard.start_x = 401 + 10
Keyboard.start_y = 175 + 5

Keyboard.rows = {
    {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L", "?"},
    {"Z", "X", "C", "V", "B", "N", "M", "^", ".", "^"}
}

Keyboard.keys = {}
Keyboard.selected_key = 1

function Keyboard:calculateKeySize()
    local row_count = #self.rows
    local key_height = (self.height - self.spacing * (row_count - 1)) / row_count
    local key_width = (self.width - self.spacing * (#self.rows[2] - 1)) / #self.rows[2]
    return key_width, key_height
end

function Keyboard:create()
    self.keys = {}

    local key_width, key_height = self:calculateKeySize()
    local y = self.start_y
    local key_index = 1

    for row_index, row in ipairs(self.rows) do
        local row_width = (#row * (key_width + self.spacing)) - self.spacing
        local x = self.start_x

        for _, key in ipairs(row) do
            table.insert(self.keys, {key = key, x = x, y = y, w = key_width, h = key_height, index = key_index})
            x = x + key_width + self.spacing
            key_index = key_index + 1
        end
        y = y + key_height + self.spacing
    end
end

function Keyboard:draw()
    love.graphics.setFont(Font.Small())
    for _, key in ipairs(self.keys) do
        if key.index == self.selected_key then
            love.graphics.setColor(0.6, 0.6, 0.6)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        love.graphics.rectangle("fill", key.x, key.y, key.w, key.h, 3, 3)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", key.x, key.y, key.w, key.h, 3, 3)

        local label = key.key:lower()

        local text_width = love.graphics.getFont():getWidth(label)
        local text_height = love.graphics.getFont():getHeight()

        love.graphics.print(label, key.x + (key.w - text_width) / 2, key.y + (key.h - text_height) / 2)
    end
end

function Keyboard.keypressed(key, callback)
    local row_index = 1
    local column_index = 1

    for i, row in ipairs(Keyboard.rows) do
        for j, key in ipairs(row) do
            if Keyboard.selected_key == (i - 1) * #Keyboard.rows[1] + j then
                row_index = i
                column_index = j
                break
            end
        end
    end

    if key == "up" then
        if row_index > 1 and column_index <= #Keyboard.rows[row_index - 1] then
            Keyboard.selected_key = (row_index - 2) * #Keyboard.rows[1] + column_index
        end
    elseif key == "down" then
        if row_index < #Keyboard.rows and column_index <= #Keyboard.rows[row_index + 1] then
            Keyboard.selected_key = (row_index) * #Keyboard.rows[1] + column_index
        end
    elseif key == "left" then
        if Keyboard.selected_key > 1 then
            Keyboard.selected_key = Keyboard.selected_key - 1
        end
    elseif key == "right" then
        if Keyboard.selected_key < #Keyboard.keys then
            Keyboard.selected_key = Keyboard.selected_key + 1
        end
    end

    if key == "a" then
        callback(Keyboard.rows[row_index][column_index]:lower())
    end
end

return Keyboard