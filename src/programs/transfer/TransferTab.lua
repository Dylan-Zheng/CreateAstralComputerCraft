local StringUtils = require("utils.StringUtils")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local OSUtils = require("utils.OSUtils")
local Logger = require("utils.Logger")
local TabView = require("elements.TabView")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local TableUtils = require("utils.TableUtils")
local TransferJobManager = require("programs.transfer.TransferJobManager")
local MessageBox = require("elements.MessageBox")
local ConfirmMessageBox = require("elements.ConfirmMessageBox")
local Triggers = require("programs.transfer.Triggers")

-- Global references for ComputerCraft
---@diagnostic disable-next-line: undefined-global
local colors = colors
---@diagnostic disable-next-line: undefined-global
local textutils = textutils


local setSelectedPeripherals = function(peripherals, selectedNames)       
    local isAdded = {}
    local items = {}
    for selectedName, _ in pairs(selectedNames) do
        isAdded[selectedName] = true
        table.insert(items, {text= selectedName, name = selectedName, selected = true})
    end
    for name, p in pairs(peripherals) do
        if PeripheralWrapper.isInventory(p) or PeripheralWrapper.isTank(p) then
            if not isAdded[name] then
                isAdded[name] = true
                table.insert(items, {text= name, name = name, selected = false})
            end
            
        end
    end
    return items
end

local setSelectedItems = function (peripherals, selectedNames)
    local isAdded = {}
    local items = {}
    for selectedName, type in pairs(selectedNames) do
        isAdded[selectedName] = true
        table.insert(items, {text= selectedName, name = selectedName, type=type, selected = true})
    end

    for name, p in pairs(peripherals) do
        Logger.debug("Peripheral: " .. name)
        if p.isInventory() then
            local pItems = p.getItems()
            for _, item in pairs(pItems) do
                if item.name and not isAdded[item.name] then
                    isAdded[item.name] = true
                    table.insert(items, {text= item.displayName or item.name, name = item.name, type="item", selected = false})
                end
            end
        end
        if p.isTank() then
            local pItems = p.tanks()
            for _, item in pairs(pItems) do
                if item.name and not isAdded[item.name] then
                    isAdded[item.name] = true
                    table.insert(items, {text= item.displayName or item.name, name = item.name, type="fluid", selected = false})
                end
            end
        end
    end

    return items
end


local TransferTab = {}

TransferTab.__index = TransferTab

function TransferTab:new(pframe)

    local instance = setmetatable({}, TransferTab)

    instance.pframe = pframe

    instance.frame = pframe:addFrame()
        :setPosition(1, 1)
        :setSize(pframe:getWidth(), pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    instance.list = instance.frame:addList()
        :setPosition(2, 2)
        :setSize(18, instance.frame:getHeight() - 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    instance.addButton = instance.frame:addButton()
        :setPosition(2, instance.list:getY() + instance.list:getHeight() + 1)
        :setSize(5, 1)
        :setText(" New ")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :onClick(function()
            instance:openDetail(nil)
        end)

    instance.editBtn = instance.frame:addButton()
        :setPosition(instance.addButton:getX() + instance.addButton:getWidth() + 1, instance.addButton:getY())
        :setSize(6, 1)
        :setText(" Edit ")
        :setBackground(colors.yellow)
        :setForeground(colors.black)
        :onClick(function()
            local item = instance.list:getSelectedItem()
            if not item then
                instance.messageBox:open("Warning", "No transfer selected")
                return
            end
            instance:openDetail(TransferJobManager.getTransfer(item.id))
        end)

    instance.delBtn = instance.frame:addButton()
        :setPosition(instance.editBtn:getX() + instance.editBtn:getWidth() + 1, instance.editBtn:getY())
        :setSize(5, 1)
        :setText(" Del ")
        :setBackground(colors.red)
        :setForeground(colors.black)
        :onClick(function()
            local item = instance.list:getSelectedItem()
            if not item then
                instance.messageBox:open("Warning", "No transfer selected")
                return
            end
            
            instance.confirmMessageBox:open("Confirm Delete", 
                "Are you sure you want to delete this transfer?", 
                function()
                    TransferJobManager.removeTransfer(item.id)
                    instance:openDetail(nil)
                    instance:updateTransferList()
                end)
        end)

    instance.tabView = TabView:new(
        instance.frame:addFrame(), 
        instance.list:getX() + instance.list:getWidth() + 1, 
        2, instance.frame:getWidth() - instance.list:getWidth() - 3, instance.frame:getHeight() - 2, 
        colors.lightGray, colors.white, colors.gray ,colors.white
    )

    instance.detailsTab = instance.tabView:createTab("Detail")

    instance.detailsTabFrame = instance.detailsTab.frame

    -- Name Input
    instance.nameInput = instance.detailsTabFrame:addInput()
        :setPosition(2, 2)
        :setSize(instance.detailsTabFrame:getWidth() - 2, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setPlaceholderColor(colors.gray)
        :setPlaceholder("Transfer Name")

    -- ID Label
    instance.idLabel = instance.detailsTabFrame:addLabel()
        :setText(StringUtils.ellipsisMiddle("ID: nil", instance.detailsTabFrame:getWidth() - 4))
        :setSize(instance.detailsTabFrame:getWidth() - 4, 1)
        :setPosition(2, instance.nameInput:getY() + instance.nameInput:getHeight() + 1)
        :setAutoSize(false)
        :setForeground(colors.white)

    instance.newIdBtn = instance.detailsTabFrame:addButton()
        :setPosition(instance.idLabel:getX() + instance.idLabel:getWidth() + 1, instance.idLabel:getY())
        :setSize(1, 1)
        :setText("N")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            if instance.selectedTransfer then
                instance.selectedTransfer.id = OSUtils.timestampBaseIdGenerate()
                instance.idLabel:setText(StringUtils.ellipsisMiddle(string.format("ID: %s", instance.selectedTransfer.id), instance.idLabel:getWidth()))
            end
        end)

    -- Input Inventory
    instance.inputInvLabel = instance.detailsTabFrame:addLabel()
        :setText("Input: 0")
        :setPosition(2, instance.idLabel:getY() + instance.idLabel:getHeight() + 1)
        :setForeground(colors.white)

    instance.editInputSlots = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 9, instance.inputInvLabel:getY())
        :setSize(5, 1)
        :setText("Slots")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            instance:openSlotSelector("input")
        end)

    instance.editinputInv = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 3, instance.inputInvLabel:getY())
        :setSize(3, 1)
        :setText("...")
        :setBackground(colors.blue)
        :setForeground(colors.white)
        :onClick(function()
            PeripheralWrapper.reloadAll()
            local peripheral =  PeripheralWrapper.getAll()
            Logger.debug("Peripherals: ")
            local items = setSelectedPeripherals(peripheral, instance.selectedTransfer and instance.selectedTransfer.inputInv or {})
            instance.itemListBox:open(items, true, {confirm = function(selectedItems) 
                local items = {}
                for _, item in pairs(selectedItems) do
                    items[item.name] = true
                end
                instance.selectedTransfer.inputInv = items
                instance.inputInvLabel:setText(string.format("Input: %d", TableUtils.getLength(items)))
            end})
        end)

    -- Output Inventory
    instance.outputInvLabel = instance.detailsTabFrame:addLabel()
        :setText("Output: 0")
        :setPosition(2, instance.inputInvLabel:getY() + instance.inputInvLabel:getHeight())
        :setForeground(colors.white)

    instance.editOutputSlots = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 9, instance.outputInvLabel:getY())
        :setSize(5, 1)
        :setText("Slots")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            instance:openSlotSelector("output")
        end)

    instance.editoutputInv = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 3, instance.outputInvLabel:getY())
        :setSize(3, 1)
        :setText("...")
        :setBackground(colors.blue)
        :setForeground(colors.white)
        :onClick(function()
            PeripheralWrapper.reloadAll()
            local peripheral =  PeripheralWrapper.getAll()
            local items = setSelectedPeripherals(peripheral, instance.selectedTransfer and instance.selectedTransfer.outputInv or {})
            instance.itemListBox:open(items, true, {confirm = function(selectedItems) 
                local items = {}
                for _, item in pairs(selectedItems) do
                    items[item.name] = true
                end
                instance.selectedTransfer.outputInv = items
                instance.outputInvLabel:setText(string.format("Output: %d", TableUtils.getLength(items)))
            end})
        end)

    -- Item Filter
    instance.itemLabel = instance.detailsTabFrame:addLabel()
        :setText("Item Filter: 0")
        :setPosition(2, instance.outputInvLabel:getY() + instance.outputInvLabel:getHeight())
        :setForeground(colors.white)
        :setAutoSize(false)

    instance.editItemBtn = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 3, instance.itemLabel:getY())
        :setSize(3, 1)
        :setText("...")
        :setBackground(colors.blue)
        :setForeground(colors.white)
        :onClick(function()
            local peripheral =  PeripheralWrapper.getAll()
            local items = setSelectedItems(peripheral, instance.selectedTransfer and instance.selectedTransfer.itemFilter or {})
            instance.itemListBox:open(items, true, {confirm = function(selectedItems) 
                local items = {}
                for _, item in pairs(selectedItems) do
                    items[item.name] = item.type
                end
                instance.selectedTransfer.itemFilter = items
                instance.itemLabel:setText(string.format("Item Filter: %d", TableUtils.getLength(items)))
            end})
        end)

    -- Transfer Rate
    instance.itemRateLabel = instance.detailsTabFrame:addLabel()
        :setText("I-R:")
        :setPosition(2, instance.itemLabel:getY() + instance.itemLabel:getHeight())
        :setForeground(colors.white)

    instance.itemRateInput = instance.detailsTabFrame:addInput()
        :setPosition(instance.itemRateLabel:getX() + instance.itemRateLabel:getWidth() + 1, instance.itemRateLabel:getY())
        :setSize(8, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("-1")
        :setPlaceholder("-1")

    instance.fluidRateLabel = instance.detailsTabFrame:addLabel()
        :setText("F-R:")
        :setPosition(instance.itemRateInput:getX() + instance.itemRateInput:getWidth() + 2, instance.itemRateLabel:getY())
        :setForeground(colors.white)

    instance.fluidRateInput = instance.detailsTabFrame:addInput()
        :setPosition(instance.fluidRateLabel:getX() + instance.fluidRateLabel:getWidth() + 1, instance.fluidRateLabel:getY())
        :setSize(8, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("-1")
        :setPlaceholder("-1")

    instance.isBlackListCheckBox = instance.detailsTabFrame:addCheckbox()
        :setSize(1, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("[ ] BlackList")
        :setCheckedText("[x] BlackList")
        :setChecked(false)
        :setPosition(2, instance.itemRateLabel:getY() + instance.itemRateLabel:getHeight())

    instance.isDisabledCheckBox = instance.detailsTabFrame:addCheckbox()
        :setSize(1, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("[ ] Disabled")
        :setCheckedText("[x] Disabled")
        :setChecked(false)
        :setPosition(instance.isBlackListCheckBox:getX() +  instance.isBlackListCheckBox:getWidth() + 3, instance.isBlackListCheckBox:getY())

    instance.setTriggerBtn = instance.detailsTabFrame:addButton()
        :setPosition(2, instance.isBlackListCheckBox:getY() + instance.isBlackListCheckBox:getHeight() + 1)
        :setSize(10, 1)
        :setText("SetTrigger")
        :setBackground(colors.blue)
        :setForeground(colors.white)
        :onClick(function()
            instance:openTriggerInterface()
        end)

    instance.clearTriggerBtn = instance.detailsTabFrame:addButton()
        :setPosition(instance.setTriggerBtn:getX() + instance.setTriggerBtn:getWidth() + 1, instance.setTriggerBtn:getY())
        :setSize(11, 1)
        :setText("ClearTrigger")
        :setBackground(colors.red)
        :setForeground(colors.white)
        :onClick(function()
            instance:clearTriggerWithConfirm()
        end)

    instance.saveBtn = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 6, instance.detailsTabFrame:getHeight() - 1)
        :setSize(6, 1)
        :setText(" Save ")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :onClick(function()
            if instance.selectedTransfer == nil then
                instance.messageBox:open("Error", "No transfer to save")
                return
            end
            instance.selectedTransfer.name = instance.nameInput:getText() or "unnamed"
            instance.selectedTransfer.isBlackList = instance.isBlackListCheckBox:getChecked()
            instance.selectedTransfer.isDisabled = instance.isDisabledCheckBox:getChecked()
            instance.selectedTransfer.itemRate = tonumber(instance.itemRateInput:getText()) or -1
            instance.selectedTransfer.fluidRate = tonumber(instance.fluidRateInput:getText()) or -1
            TransferJobManager.addTransfer(instance.selectedTransfer)
            instance:updateTransferList()
        end)

    instance.srcTab = instance.tabView:createTab("Source")
    instance.srcTextBox = instance.srcTab.frame:addTextBox()
        :setPosition(2, 2)
        :setSize(instance.srcTab.frame:getWidth() - 2, instance.srcTab.frame:getHeight() - 2)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("")
    instance.srcTab.onSelect = function()
        instance:updateSrcText()
    end

    instance.trigger = Triggers:new(instance.pframe)
    -- instance.trigger:open()

    instance.itemListBox = ItemSelectedListBox:new(instance.pframe)

    instance.messageBox = MessageBox:new(instance.pframe, 40, 15)
    instance.confirmMessageBox = ConfirmMessageBox:new(instance.pframe, 40, 10)

    return instance
    
end

function TransferTab:init()
    self.tabView:init()
    self:openDetail(nil)
    self:updateTransferList()
    return self
end

function TransferTab:updateSrcText()
    self.selectedTransfer.name = self.nameInput:getText() or "unnamed"
    self.selectedTransfer.isBlackList = self.isBlackListCheckBox:getChecked()
    self.selectedTransfer.isDisabled = self.isDisabledCheckBox:getChecked()
    self.srcTextBox:setText(textutils.serialize(self.selectedTransfer or {}))
end

function TransferTab:updateTransferList()
    local transfers = TransferJobManager.getAllTransfers()
    local items = {}
    for _, t in pairs(transfers) do
        table.insert(items, {text = t.name or "unnamed", id = t.id})
    end
    
    -- Sort items by name (text field)
    table.sort(items, function(a, b)
        return a.text < b.text
    end)
    
    self.list:setItems(items)
end

function TransferTab:openDetail(transfer)

    if(transfer == nil) then
        self.selectedTransfer = {
            id = OSUtils.timestampBaseIdGenerate(),
            name = "unnamed",
            inputInv = {},
            outputInv = {},
            inputSlots = {},
            outputSlots = {},
            itemFilter = {},
            itemRate = -1,
            fluidRate = -1,
            isBlackList = false,
            isDisabled = false,
            triggerStatement = {
                id = "root"
            }
        }

        self.nameInput:setText(self.selectedTransfer.name)
        self.inputInvLabel:setText("Input: 0")
        self.outputInvLabel:setText("Output: 0")
        self.itemLabel:setText("Item Filter: 0")
        self.itemRateInput:setText("-1")
        self.fluidRateInput:setText("-1")
        self.isBlackListCheckBox:setChecked(false)
        self.idLabel:setText(StringUtils.ellipsisMiddle(string.format("ID: %s", self.selectedTransfer.id), self.idLabel:getWidth()))
        self.isDisabledCheckBox:setChecked(false)
    else 
        self.selectedTransfer = transfer
        -- 确保新字段存在
        if not self.selectedTransfer.inputSlots then
            self.selectedTransfer.inputSlots = {}
        end
        if not self.selectedTransfer.outputSlots then
            self.selectedTransfer.outputSlots = {}
        end
        if not self.selectedTransfer.itemRate then
            self.selectedTransfer.itemRate = -1
        end
        if not self.selectedTransfer.fluidRate then
            self.selectedTransfer.fluidRate = -1
        end
        if not self.selectedTransfer.triggerStatement then
            self.selectedTransfer.triggerStatement = {
                id = "root"
            }
        end
        
        self.nameInput:setText(self.selectedTransfer.name or "unnamed")
        self.inputInvLabel:setText(string.format("Input: %d", TableUtils.getLength(self.selectedTransfer.inputInv)))
        self.outputInvLabel:setText(string.format("Output: %d", TableUtils.getLength(self.selectedTransfer.outputInv)))
        self.itemLabel:setText(string.format("Item Filter: %d", TableUtils.getLength(self.selectedTransfer.itemFilter)))
        self.itemRateInput:setText(tostring(self.selectedTransfer.itemRate))
        self.fluidRateInput:setText(tostring(self.selectedTransfer.fluidRate))
        self.isBlackListCheckBox:setChecked(self.selectedTransfer.isBlackList or false)
        self.idLabel:setText(StringUtils.ellipsisMiddle(string.format("ID: %s", self.selectedTransfer.id), self.idLabel:getWidth()))
        self.isDisabledCheckBox:setChecked(self.selectedTransfer.isDisabled or false)
    end

    return self.frame
end

function TransferTab:openSlotSelector(slotType)
    PeripheralWrapper.reloadAll()
    local peripherals = PeripheralWrapper.getAll()
    
    -- 根据槽位类型确定要检查的库存类型和目标字段
    local invType = slotType == "input" and "inputInv" or "outputInv"
    local slotsType = slotType == "input" and "inputSlots" or "outputSlots"
    local warningMsg = slotType == "input" and 
        "No DEFAULT_INVENTORY found in input peripherals" or 
        "No DEFAULT_INVENTORY found in output peripherals"
    
    -- 查找最大槽位数的 DEFAULT_INVENTORY 外设
    local maxSlots = 0
    for name, p in pairs(peripherals) do
        if self.selectedTransfer and self.selectedTransfer[invType] and self.selectedTransfer[invType][name] then
            local pTypes = p.getTypes()
            for _, pType in ipairs(pTypes) do
                if pType == 1 then -- DEFAULT_INVENTORY
                    local slots = p.size()
                    if slots > maxSlots then
                        maxSlots = slots
                    end
                    break
                end
            end
        end
    end
    
    if maxSlots == 0 then
        self.messageBox:open("Warning", warningMsg)
        return
    end
    
    -- 创建槽位列表
    local slotItems = {}
    local selectedSlots = self.selectedTransfer and self.selectedTransfer[slotsType] or {}
    
    -- 将数组格式的槽位转换为查找表以便检查选中状态
    local selectedSlotsLookup = {}
    if type(selectedSlots) == "table" then
        for _, slotNum in ipairs(selectedSlots) do
            selectedSlotsLookup[tostring(slotNum)] = true
        end
    end
    
    for i = 1, maxSlots do
        table.insert(slotItems, {
            text = "Slot " .. i,
            slotId = i,
            selected = selectedSlotsLookup[tostring(i)] or false
        })
    end
    
    self.itemListBox:open(slotItems, true, {confirm = function(selectedItems)
        local slots = {}
        for _, item in pairs(selectedItems) do
            table.insert(slots, item.slotId)
        end
        self.selectedTransfer[slotsType] = slots
    end})
end

function TransferTab:openTriggerInterface()
    if not self.selectedTransfer then
        self.messageBox:open("Error", "No transfer selected")
        return
    end
    
    -- 获取当前的trigger statement，如果没有则使用默认值
    local currentTriggerStatement = self.selectedTransfer.triggerStatement or {
        id = "root"
    }
    
    -- 打开trigger界面，传递save callback
    self.trigger:open(currentTriggerStatement, function(triggerStatement)
        -- 保存trigger statement到selectedTransfer
        self.selectedTransfer.triggerStatement = triggerStatement
    end)
end

function TransferTab:clearTriggerWithConfirm()
    if not self.selectedTransfer then
        self.messageBox:open("Error", "No transfer selected")
        return
    end
    
    self.confirmMessageBox:open("Confirm Clear Trigger", 
        "Are you sure you want to clear the trigger statement?", 
        function()
            -- 清除trigger statement，重置为默认值
            self.selectedTransfer.triggerStatement = {
                id = "root"
            }
        end)
end


return TransferTab