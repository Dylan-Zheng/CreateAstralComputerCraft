local basalt = require("libraries.basalt")
local StringUtils = require("utils.StringUtils")

-- Global references for ComputerCraft
---@diagnostic disable-next-line: undefined-global
local colors = colors

local MessageBox = {}
MessageBox.__index = MessageBox

function MessageBox:new(pframe, width, height)
    local instance = setmetatable({}, MessageBox)

    instance.frame = pframe
    instance.title = "Message"
    instance.message = "No message provided."

    instance.coverFrame = pframe:addFrame()
        :setPosition(1, 1)
        :setSize(pframe:getWidth(), pframe:getHeight())
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setVisible(false)

    -- 限制box的尺寸，不能大于coverFrame的尺寸-2
    local maxWidth = pframe:getWidth() - 2
    local maxHeight = pframe:getHeight() - 2
    local actualWidth = math.min(width or maxWidth, maxWidth)
    local actualHeight = math.min(height or maxHeight, maxHeight)

    -- 计算居中位置
    local centerX = math.floor((pframe:getWidth() - actualWidth) / 2) + 1
    local centerY = math.floor((pframe:getHeight() - actualHeight) / 2) + 1

    instance.boxFrame = instance.coverFrame:addFrame()
        :setPosition(centerX, centerY)
        :setSize(actualWidth, actualHeight)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    instance.titleLabel = instance.boxFrame:addLabel()
        :setText(instance.title)
        :setPosition(2, 2)
        :setBackgroundEnabled(true)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    instance.textBox = instance.boxFrame:addTextBox()
        :setText(instance.message)
        :setSize(instance.boxFrame:getWidth() - 2, instance.boxFrame:getHeight() - 6)
        :setPosition(2, 4)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    instance.closeBtn = instance.boxFrame:addButton()
        :setText("Close")
        :setPosition(instance.boxFrame:getWidth() -7, instance.boxFrame:getHeight() - 1)
        :setSize(7, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            instance:close()
        end)

    return instance
end

function MessageBox:open(title, message)
    if title then
        self.title = title
        self.titleLabel:setText(title)

    end
    if message then
        self.message = message
        self.textBox:setText(StringUtils.wrapText(message, self.textBox:getWidth()))
    end

    self.coverFrame:setVisible(true)
end

function MessageBox:close()
    self.coverFrame:setVisible(false)
end

return MessageBox