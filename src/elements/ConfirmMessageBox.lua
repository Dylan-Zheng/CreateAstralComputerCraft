local basalt = require("libraries.basalt")
local StringUtils = require("utils.StringUtils")
local Logger = require("utils.Logger")

-- Global references for ComputerCraft
---@diagnostic disable-next-line: undefined-global
local colors = colors

local ConfirmMessageBox = {}
ConfirmMessageBox.__index = ConfirmMessageBox

function ConfirmMessageBox:new(pframe, width, height)
    local instance = setmetatable({}, ConfirmMessageBox)

    instance.frame = pframe
    instance.title = "Confirm"
    instance.message = "No message provided."
    instance.onConfirm = nil
    instance.onCancel = nil

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

    -- Yes 按钮
    instance.yesBtn = instance.boxFrame:addButton()
        :setText("Yes")
        :setPosition(instance.boxFrame:getWidth() - 15, instance.boxFrame:getHeight() - 1)
        :setSize(6, 1)
        :setBackground(colors.green)
        :setForeground(colors.white)
        :onClick(function()
            instance:confirm()
        end)

    -- No 按钮
    instance.noBtn = instance.boxFrame:addButton()
        :setText("No")
        :setPosition(instance.boxFrame:getWidth() - 7, instance.boxFrame:getHeight() - 1)
        :setSize(6, 1)
        :setBackground(colors.red)
        :setForeground(colors.white)
        :onClick(function()
            instance:cancel()
        end)

    return instance
end

function ConfirmMessageBox:open(title, message, onConfirm, onCancel)
    if title then
        self.title = title
        self.titleLabel:setText(title)
    end
    
    if message then
        self.message = message
        self.textBox:setText(StringUtils.wrapText(message, self.textBox:getWidth()))
    end
    
    -- 设置回调函数
    self.onConfirm = onConfirm
    self.onCancel = onCancel

    self.coverFrame:setVisible(true)
end

function ConfirmMessageBox:confirm()
    if self.onConfirm then
        local success, error = pcall(self.onConfirm)
        if not success then
            -- Handle error silently or log if needed
        end
    end
    self:close()
end

function ConfirmMessageBox:cancel()
    if self.onCancel then
        self.onCancel()
    end
    self:close()
end

function ConfirmMessageBox:close()
    self.coverFrame:setVisible(false)
    -- 清理回调函数
    self.onConfirm = nil
    self.onCancel = nil
end

return ConfirmMessageBox
