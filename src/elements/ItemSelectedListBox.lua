local basalt = require("libraries.basalt")

local ItemSelectedListBox = {}

ItemSelectedListBox.__index = ItemSelectedListBox

function ItemSelectedListBox:new(pframe, frameBg, bg, fg, searchPlaceholderColor)

    local instance = setmetatable({}, ItemSelectedListBox)

    frameBg = frameBg or colors.lightGray
    bg = bg or colors.gray
    fg = fg or colors.white
    searchPlaceholderColor = searchPlaceholderColor or colors.lightGray

    instance.frame = pframe:addFrame()
        :setPosition(1, 1)
        :setSize(pframe:getWidth(), pframe:getHeight())
        :setBackground(frameBg)
        :setForeground(fg)
        :setVisible(false)

    instance.items = {}

    instance.callbacks = {}

    instance.searchInput = instance.frame:addInput()
        :setPosition(2, 2)
        :setSize(instance.frame:getWidth() - 6, 1)
        :setBackground(bg)
        :setForeground(fg)
        :setPlaceholderColor(searchPlaceholderColor)
        :setPlaceholder("Search...")

    instance.searchBtn = instance.frame:addButton()
        :setPosition(instance.searchInput:getX() + instance.searchInput:getWidth() + 1, instance.searchInput:getY())
        :setSize(1, 1)
        :setText("S")
        :setBackground(bg)
        :setForeground(fg)
        :onClick(function()
            local text = instance.searchInput:getText()
            if text == nil or text == "" then
                instance.list:setItems(instance.items)
            else
                local filtered = {}
                for _, item in pairs(instance.items) do
                    if item.text:find(text) then
                        table.insert(filtered, item)
                    end
                end
                instance.list:setItems(filtered)
            end
        end)

    instance.cleanInputBtn = instance.frame:addButton()
        :setPosition(instance.searchBtn:getX() + instance.searchBtn:getWidth() + 1, instance.searchBtn:getY())
        :setSize(1, 1)
        :setText("C")
        :setBackground(bg)
        :setForeground(fg)
        :onClick(function()
            instance.searchInput:setText("")
            instance.list:setItems(instance.items)
        end)

    instance.list = instance.frame:addList()
        :setPosition(2, instance.searchInput:getY() + instance.searchInput:getHeight() + 1)
        :setSize(instance.frame:getWidth() - 2, instance.frame:getHeight() - instance.searchInput:getHeight() - 5)
        :setBackground(bg)
        :setForeground(fg)

    instance.confirmBtn = instance.frame:addButton()
        :setText("Confirm")
        :setSize(9, 1)
        :setPosition(instance.frame:getWidth() - 18, instance.list:getY() + instance.list:getHeight() + 1)
        :setBackground(bg)
        :setForeground(fg)
        :onClick(function()
            local selectedItems = {}
            for _, item in ipairs(instance.items) do
                if item.selected then
                    table.insert(selectedItems, item)
                end
            end
            
            if instance.callbacks.confirm ~= nil then
                instance.callbacks.confirm(selectedItems)
            end
            instance:close()
        end)

    instance.cancelBtn = instance.frame:addButton()
        :setText("Cancel")
        :setSize(8, 1)
        :setPosition(instance.confirmBtn:getX() + instance.confirmBtn:getWidth() + 1, instance.confirmBtn:getY())
        :setBackground(bg)
        :setForeground(fg)
        :onClick(function()
            if instance.callbacks.cancel ~= nil then
                instance.callbacks.cancel()
            end
            instance:close()
        end)

    return instance
end

function ItemSelectedListBox:open(items, multiSelection, callbacks)
    self.items = items or {}
    self.list:setItems(self.items)
    self.list:setMultiSelection(multiSelection or false)
    self.list:setOffset(0)
    self.callbacks = callbacks or {}
    self.frame:setVisible(true)
end

function ItemSelectedListBox:close()
    self.frame:setVisible(false)
end

return ItemSelectedListBox