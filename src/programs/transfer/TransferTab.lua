local StringUtils = require("utils.StringUtils")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local OSUtils = require("utils.OSUtils")
local Logger = require("utils.Logger")
local TabView = require("elements.TabView")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local TableUtils = require("utils.TableUtils")
local TransferJobManager = require("programs.transfer.TransferJobManager")
local MessageBox = require("elements.MessageBox")


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
    for selectedName, _ in pairs(selectedNames) do
        isAdded[selectedName] = true
        table.insert(items, {text= selectedName, name = selectedName, selected = true})
    end

    for name, p in pairs(peripherals) do
        Logger.debug("Peripheral: " .. name)
        if p.isInventory() then
            local pItems = p.getItems()
            for _, item in pairs(pItems) do
                if item.name and not isAdded[item.name] then
                    isAdded[item.name] = true
                    table.insert(items, {text= item.displayName or item.name, name = item.name, selected = false})
                end
            end
        end
        if p.isTank() then
            local pItems = p.tanks()
            for _, item in pairs(pItems) do
                if item.name and not isAdded[item.name] then
                    isAdded[item.name] = true
                    table.insert(items, {text= item.displayName or item.name, name = item.name, selected = false})
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
            TransferJobManager.removeTransfer(item.id)
            instance:openDetail(nil)
            instance:updateTransferList()
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
        :setText("Input Inventory: 0")
        :setPosition(2, instance.idLabel:getY() + instance.idLabel:getHeight() + 1)
        :setForeground(colors.white)

    instance.editinputInv = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 3, instance.inputInvLabel:getY())
        :setSize(3, 1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            PeripheralWrapper.reloadAll()
            local peripheral =  PeripheralWrapper.getAll()
            Logger.debug("Peripherals: ")
            local items = setSelectedPeripherals(peripheral, instance.selectedTransfer and instance.selectedTransfer.inputInv or {})
            Logger.debug(textutils.serialize(items))
            instance.itemListBox:open(items, true, {confirm = function(selectedItems) 
                local items = {}
                for _, item in pairs(selectedItems) do
                    items[item.name] = true
                end
                instance.selectedTransfer.inputInv = items
                instance.inputInvLabel:setText(string.format("Input Inventory: %d", TableUtils.getLength(items)))
            end})
        end)

    -- Output Inventory
    instance.outputInvLabel = instance.detailsTabFrame:addLabel()
        :setText("Output Inventory: 0")
        :setPosition(2, instance.inputInvLabel:getY() + instance.inputInvLabel:getHeight() + 1)
        :setForeground(colors.white)

    instance.editoutputInv = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 3, instance.outputInvLabel:getY())
        :setSize(3, 1)
        :setText("...")
        :setBackground(colors.lightGray)
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
                instance.outputInvLabel:setText(string.format("Output Inventory: %d", TableUtils.getLength(items)))
            end})
        end)

    -- Item Filter
    instance.itemLabel = instance.detailsTabFrame:addLabel()
        :setText("Item Filter: 0")
        :setPosition(2, instance.outputInvLabel:getY() + instance.outputInvLabel:getHeight() + 1)
        :setForeground(colors.white)
        :setAutoSize(false)

    instance.editItemBtn = instance.detailsTabFrame:addButton()
        :setPosition(instance.detailsTabFrame:getWidth() - 3, instance.itemLabel:getY())
        :setSize(3, 1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local peripheral =  PeripheralWrapper.getAll()
            local items = setSelectedItems(peripheral, instance.selectedTransfer and instance.selectedTransfer.itemFilter or {})
            instance.itemListBox:open(items, true, {confirm = function(selectedItems) 
                local items = {}
                for _, item in pairs(selectedItems) do
                    items[item.name] = true
                end
                instance.selectedTransfer.itemFilter = items
                instance.itemLabel:setText(string.format("Item Filter: %d", TableUtils.getLength(items)))
            end})
        end)

    instance.isBlackListCheckBox = instance.detailsTabFrame:addCheckbox()
        :setSize(1, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("[ ] Black List")
        :setCheckedText("[x] Black List")
        :setChecked(false)
        :setPosition(2, instance.itemLabel:getY() + instance.itemLabel:getHeight())

    instance.isDisabledCheckBox = instance.detailsTabFrame:addCheckbox()
        :setSize(1, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("[ ] Disabled")
        :setCheckedText("[x] Disabled")
        :setChecked(false)
        :setPosition(2, instance.isBlackListCheckBox:getY() + instance.isBlackListCheckBox:getHeight())

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

    instance.itemListBox = ItemSelectedListBox:new(instance.pframe)

    instance.messageBox = MessageBox:new(instance.pframe, 40, 15)

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
    self.list:setItems(items)
end

function TransferTab:openDetail(transfer)

    if(transfer == nil) then
        self.selectedTransfer = {
            id = OSUtils.timestampBaseIdGenerate(),
            name = "unnamed",
            inputInv = {},
            outputInv = {},
            itemFilter = {},
            isBlackList = false,
            isDisabled = false
        }

        self.nameInput:setText(self.selectedTransfer.name)
        self.inputInvLabel:setText("Input Inventory: 0")
        self.outputInvLabel:setText("Output Inventory: 0")
        self.itemLabel:setText("Item Filter: 0")
        self.isBlackListCheckBox:setChecked(false)
        self.idLabel:setText(StringUtils.ellipsisMiddle(string.format("ID: %s", self.selectedTransfer.id), self.idLabel:getWidth()))
        self.isDisabledCheckBox:setChecked(false)
    else 
        self.selectedTransfer = transfer
        self.nameInput:setText(self.selectedTransfer.name or "unnamed")
        self.inputInvLabel:setText(string.format("Input Inventory: %d", TableUtils.getLength(self.selectedTransfer.inputInv)))
        self.outputInvLabel:setText(string.format("Output Inventory: %d", TableUtils.getLength(self.selectedTransfer.outputInv)))
        self.itemLabel:setText(string.format("Item Filter: %d", TableUtils.getLength(self.selectedTransfer.itemFilter)))
        self.isBlackListCheckBox:setChecked(self.selectedTransfer.isBlackList or false)
        self.idLabel:setText(StringUtils.ellipsisMiddle(string.format("ID: %s", self.selectedTransfer.id), self.idLabel:getWidth()))
        self.isDisabledCheckBox:setChecked(self.selectedTransfer.isDisabled or false)
    end

    return self.frame
end


return TransferTab