local basalt = require("libraries.basalt")
local StringUtils = require("utils.StringUtils")

local LogBox = {}
LogBox.__index = LogBox

-- Helper function to count newlines in a string
local function countNewlines(str)
    if not str or str == "" then
        return 0
    end
    local _, count = str:gsub("\n", "")
    return count
end

function LogBox:new(pframe, x, y, width, height, fg, bg)
    local instance = setmetatable({}, LogBox)

    instance.frame = pframe
    instance.text = ""

    instance.logs = {}
    instance.needUpdate = false

    instance.maxLines = 30

    instance.textBox = instance.frame:addTextBox()
            :setPosition(x, y)
            :setSize(width, height)
            :setBackground(bg or colors.gray)
            :setForeground(fg or colors.white)
            :setText("")

    return instance
end

function LogBox:addLog(message)
    local wrappedMsg = StringUtils:wrapText(message, self.textBox.getWidth())
    self.text = self.text .. wrappedMsg .. "\n"
    
    -- Check if we need to trim lines
    local currentLines = countNewlines(self.text)
    
    if currentLines > self.maxLines then
        local linesToRemove = currentLines - self.maxLines
        
        -- Find the position after the nth newline to remove
        local pos = 1
        for i = 1, linesToRemove do
            pos = self.text:find("\n", pos)
            if pos then
                pos = pos + 1  -- Move past the newline
            else
                break
            end
        end
        
        -- Keep only the text after the removed lines
        if pos and pos <= #self.text then
            self.text = self.text:sub(pos)
        end
    end
    
    self.textBox:setText(self.text)
end

function LogBox:setMaxLines(maxLines)
    self.maxLines = maxLines or 30
end

-- Get current number of lines in the log
function LogBox:getLineCount()
    return countNewlines(self.text)
end

-- Clear all logs
function LogBox:clear()
    self.text = ""
    self.logs = {}
    self.textBox:setText("")
end

return LogBox