local basalt = require("libraries.basalt")
local StringUtils = require("utils.StringUtils")

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

    instance.boxFrame = instance.coverFrame:addFrame()
        :setPosition(5, 2)
        :setSize(width, height)
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