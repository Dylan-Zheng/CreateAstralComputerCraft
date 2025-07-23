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

-- Global references for ComputerCraft
---@diagnostic disable-next-line: undefined-global
local textutils = textutils
---@diagnostic disable-next-line: undefined-global
local colors = colors

local Triggers = {}

Triggers.__index = Triggers

-- Trigger types
local TYPES = TransferJobManager.TRIGGER_TYPES
-- Condition types
local CONDITION_TYPES = TransferJobManager.TRIGGER_CONDITION_TYPES

function Triggers:new(pframe)
    local instance = setmetatable({}, Triggers)

    instance.selectNodeData = {}

    instance.pframe = pframe

    instance.frame = pframe:addFrame()
        :setPosition(1, 1)
        :setSize(pframe:getWidth(), pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setVisible(false)

    -- 计算布局尺寸 - 2:3 比例分配
    local frameWidth = instance.frame:getWidth()
    local frameHeight = instance.frame:getHeight()
    local leftWidth = math.floor(frameWidth * 2 / 5) - 1   -- 2/5 宽度，减去边距
    local rightWidth = frameWidth - leftWidth - 3          -- 3/5 宽度，减去边距
    
    instance.conditionTree = instance.frame:addTree()
        :setPosition(2, 2)
        :setSize(leftWidth, frameHeight - 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setSelectedColor(colors.lightBlue)
        :onSelect(function(_, selectedNode)
            if selectedNode and selectedNode.data then
                instance:updateDetails(selectedNode.data)
                instance.selectedTreeNode = selectedNode
            end
        end)

    instance.nodeDetailsFrame = instance.frame:addFrame()
        :setPosition(leftWidth + 3, 2)
        :setSize(rightWidth, frameHeight - 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    instance.parentNodeLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(2, 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Parent:")

    instance.displayedParentNodelabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(instance.parentNodeLabel:getX() + instance.parentNodeLabel:getWidth() + 1, 2)
        :setAutoSize(false)
        :setSize(rightWidth - instance.parentNodeLabel:getWidth() - 9, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("root")

    instance.changedParentNodeBtn = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.nodeDetailsFrame:getWidth() - 5, 2)
        :setSize(5, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("...")
        :onClick(function()
            instance:openParentNodeSelector()
        end)
        
    instance.nodeNameLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(2, 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Name:")

    instance.nodeNameInput = instance.nodeDetailsFrame:addInput()
        :setPosition(instance.nodeNameLabel:getX() + instance.nodeNameLabel:getWidth() + 1, instance.nodeNameLabel:getY())
        :setSize(instance.nodeDetailsFrame:getWidth() - instance.nodeNameLabel:getWidth() - 3, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("unnamed")
        :setPlaceholder("")

    instance.triggerTypeDropdown = instance.nodeDetailsFrame:addDropdown()
        :setPosition(2, instance.nodeNameInput:getY() + 2)
        :setSize(instance.nodeDetailsFrame:getWidth() - 2, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setItems({
            {
                text = "Item Count", 
                value = TYPES.ITEM_COUNT,
                selected = true,
                callback = function(self)
                    instance:updateUIForTriggerType()
                end
            },
            {
                text = "Fluid Count",
                value = TYPES.FLUID_COUNT,
                callback = function(self)
                    instance:updateUIForTriggerType()
                end
            },
            {
                text = "Item Count at Slots",
                value = TYPES.ITEM_COUNT_AT_SLOTS,
                callback = function(self)
                    instance:updateUIForTriggerType()
                end
            }
        })

    instance.targetLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(2, instance.triggerTypeDropdown:getY() + 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Target:")
    
    instance.selectedTargetLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(instance.targetLabel:getX() + instance.targetLabel:getWidth() + 1, instance.targetLabel:getY())
        :setAutoSize(false)
        :setSize(instance.nodeDetailsFrame:getWidth() - instance.targetLabel:getWidth() - 9, 1)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setText("")
    
    instance.selectTargetBtn = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.nodeDetailsFrame:getWidth() - 5, instance.targetLabel:getY())
        :setSize(5, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("...")
        :onClick(function()
            instance:openTargetSelector()
        end)
    
    instance.itemLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(2, instance.selectedTargetLabel:getY() + 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Item:")

    
    instance.selectedItemLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(instance.itemLabel:getX() + instance.itemLabel:getWidth() + 1, instance.itemLabel:getY())
        :setAutoSize(false)
        :setSize(instance.nodeDetailsFrame:getWidth() - instance.itemLabel:getWidth() - 9, 1)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setText("")

    instance.selectItemBtn = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.nodeDetailsFrame:getWidth() - 5, instance.itemLabel:getY())
        :setSize(5, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("...")
        :onClick(function()
            instance:openItemSelector()
        end)

    instance.conditionTypeDropdown = instance.nodeDetailsFrame:addDropdown()
        :setPosition(2, instance.selectedItemLabel:getY() + 2)
        :setSize(instance.nodeDetailsFrame:getWidth() - 2, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setItems({
            {
                text = "Count Greater", 
                value = CONDITION_TYPES.COUNT_GREATER,
                selected = true,
                callback = function(self)
                end
            },
            {
                text = "Count Less",
                value = CONDITION_TYPES.COUNT_LESS,
                callback = function(self)
                end
            },
            {
                text = "Count Equal",
                value = CONDITION_TYPES.COUNT_EQUAL,
                callback = function(self)
                end
            }
        })

    instance.amountLabel = instance.nodeDetailsFrame:addLabel()
        :setPosition(2, instance.conditionTypeDropdown:getY() + 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Amt:")

    instance.amountInput = instance.nodeDetailsFrame:addInput()
        :setPosition(instance.amountLabel:getX() + instance.amountLabel:getWidth() + 1, instance.amountLabel:getY())
        :setSize(12, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("0")
        :setPlaceholder("0")
        :setPattern("[0-9]") -- 只允许输入数字

    instance.slotButton = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.amountInput:getX() + instance.amountInput:getWidth() + 2, instance.amountInput:getY())
        :setSize(8, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setText("Slot")
        :setVisible(false) -- 默认隐藏
        :onClick(function()
            instance:openSlotSelector()
        end)

    instance.modifyNodeBtn = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.nodeDetailsFrame:getWidth() - 27, instance.amountInput:getY() + 2)
        :setSize(8, 1)
        :setBackground(colors.blue)
        :setForeground(colors.white)
        :setText("Modify")
        :setVisible(false) -- 默认隐藏
        :onClick(function()
            instance:modifySelectedNode()
        end)

    instance.addNodeBtn = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.nodeDetailsFrame:getWidth() - 16, instance.amountInput:getY() + 2)
        :setSize(6, 1)
        :setBackground(colors.green)
        :setForeground(colors.white)
        :setText("Add")
        :onClick(function()
            instance:addNodeToTree()
        end)

    instance.deleteNodeBtn = instance.nodeDetailsFrame:addButton()
        :setPosition(instance.nodeDetailsFrame:getWidth() - 8, instance.addNodeBtn:getY())
        :setSize(8, 1)
        :setBackground(colors.red)
        :setForeground(colors.white)
        :setVisible(false) -- 默认隐藏
        :setText("Delete")
        :onClick(function()
            instance:deleteSelectedNode()
        end)

    -- 计算按钮布局 - 放在 conditionTree 下面
    
    instance.NewTriggerBtn = instance.frame:addButton()
        :setPosition(2, instance.conditionTree:getY() + instance.conditionTree:getHeight() + 1)
        :setSize(5, 1)
        :setBackground(colors.red)
        :setForeground(colors.white)
        :setText("New")
        :onClick(function() 
            instance:updateDetails()
        end)

    instance.saveTriggerBtn = instance.frame:addButton()
        :setPosition(instance.NewTriggerBtn:getX() + instance.NewTriggerBtn:getWidth() + 1, instance.conditionTree:getY() + instance.conditionTree:getHeight() + 1)
        :setSize(6, 1)
        :setBackground(colors.green)
        :setForeground(colors.white)
        :setText("Save")
        :onClick(function()
            instance:saveTriggerStatement()
        end)
        
    instance.cancelBtn = instance.frame:addButton()
        :setPosition(instance.saveTriggerBtn:getX() + instance.saveTriggerBtn:getWidth() + 1, instance.conditionTree:getY() + instance.conditionTree:getHeight() + 1)
        :setSize(6, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Back")
        :onClick(function()
            instance:close()
        end)

   instance.itemListBox = ItemSelectedListBox:new(instance.pframe)
   
   -- 创建可重复使用的MessageBox实例
   instance.messageBox = MessageBox:new(instance.frame, 30, 10)
   
   -- 创建可重复使用的ConfirmMessageBox实例
   instance.confirmMessageBox = ConfirmMessageBox:new(instance.frame, 30, 10)

    -- 初始化UI状态
    instance:updateUIForTriggerType()

    return instance
end

function Triggers:open(tree, saveCallback)
    self.tree = tree or {
        id = "root"
    }
    Logger.debug("Opening Triggers with tree: " .. textutils.serialize(self.tree))
    self.saveCallback = saveCallback -- Store the save callback
    self.frame:setVisible(true)
    
    -- Tree 组件期望的是节点数组，而不是根节点对象
    local treeNodes = self.tree.children or {}
    self.conditionTree:setNodes(treeNodes)
    
    self:updateDetails()
end

function Triggers:addNode(tree, parentNode, node, data)
    node.data = data or {}
    if parentNode then
        if not parentNode.children then
            parentNode.children = {}
        end
        table.insert(parentNode.children, node)
        -- 更新树显示，传递children数组而不是整个tree对象
        self.conditionTree:setNodes(self.tree.children or {})
        self.conditionTree.get("expandedNodes")[node] = true
    end
    return node
end

-- 获取当前选中的触发器类型
function Triggers:getSelectedTriggerType()
    local selectedItems = self.triggerTypeDropdown:getSelectedItems()
    if #selectedItems > 0 then
        return selectedItems[1].value
    end
    return nil
end

-- 设置触发器类型选择
function Triggers:setTriggerType(triggerType)
    local items = self.triggerTypeDropdown.get("items")
    for i, item in ipairs(items) do
        if item.value == triggerType then
            -- 清除其他选择
            for _, otherItem in ipairs(items) do
                if type(otherItem) == "table" then
                    otherItem.selected = false
                end
            end
            -- 设置当前选择
            item.selected = true
            self.triggerTypeDropdown:updateRender()
            self:updateUIForTriggerType()
            return true
        end
    end
    return false
end

-- 设置条件类型选择
function Triggers:setConditionType(conditionType)
    local items = self.conditionTypeDropdown.get("items")
    for i, item in ipairs(items) do
        if item.value == conditionType then
            -- 清除其他选择
            for _, otherItem in ipairs(items) do
                if type(otherItem) == "table" then
                    otherItem.selected = false
                end
            end
            -- 设置当前选择
            item.selected = true
            self.conditionTypeDropdown:updateRender()
            return true
        end
    end
    return false
end

-- 获取当前选中的条件类型
function Triggers:getSelectedConditionType()
    local selectedItems = self.conditionTypeDropdown:getSelectedItems()
    if #selectedItems > 0 then
        return selectedItems[1].value
    end
    return nil
end

-- 获取数量输入的数值
function Triggers:getAmountValue()
    local text = self.amountInput.get("text")
    local amount = tonumber(text)
    return amount or 0
end

-- 设置数量输入的数值
function Triggers:setAmountValue(amount)
    if type(amount) == "number" and amount >= 0 then
        self.amountInput.set("text", tostring(math.floor(amount)))
        return true
    end
    return false
end

function Triggers:flattenTreeNodes(nodes, expandedNodes, level, result)
    result = result or {}
    level = level or 0

    for _, node in ipairs(nodes or {}) do
        table.insert(result, {node = node, level = level})
        if expandedNodes and expandedNodes[node] and node.children then
            self:flattenTreeNodes(node.children, expandedNodes, level + 1, result)
        end
    end
    return result
end

function Triggers:openParentNodeSelector()

    local nodes = self.conditionTree.get("nodes")
    local expandedNodes = self.conditionTree.get("expandedNodes")
    local flatNodes = self:flattenTreeNodes(nodes, expandedNodes)

    
    local listItems = {}

    -- 添加根节点选项
    table.insert(listItems, 1, {
        text = "root",
        data = {id = "root", text = "root"}
    })

    for _, nodeInfo in ipairs(flatNodes) do
        local node = nodeInfo.node
        table.insert(listItems, {
            text = node.text or "Unnamed Node",
            data = node
        })
    end

    -- 设置当前选中的父节点
    local currentParentId = self.selectNodeData and self.selectNodeData.parentNodeId or "root"
    for _, item in ipairs(listItems) do
        if (item.data.id == currentParentId) or (currentParentId == "root" and item.data.id == "root") then
            item.selected = true
            break
        end
    end

    self.itemListBox:open(listItems, false, {confirm = function(selectedItems)
        if not self.selectNodeData then
            self.selectNodeData = {}
        end
        
        local selectedNode = selectedItems[1].data
        if selectedNode.id == "root" then
            self.selectNodeData.parentNodeId = "root"
            self.selectNodeData.parentNodeName = "root"
            self.displayedParentNodelabel:setText("root")
        else
            self.selectNodeData.parentNodeId = selectedNode.data and selectedNode.data.id or selectedNode.id
            self.selectNodeData.parentNodeName = selectedNode.text or "Unnamed Node"
            self.displayedParentNodelabel:setText(StringUtils.ellipsisMiddle(self.selectNodeData.parentNodeName, self.displayedParentNodelabel:getWidth()))
        end
    end})
    
end

-- 打开目标选择器
function Triggers:openTargetSelector()
    local selectedTriggerType = self:getSelectedTriggerType()
    local peripherals = {}
    local listItems = {}
    
    -- 重新加载外设以获取最新信息
    PeripheralWrapper.reloadAll()
    
    -- 根据触发器类型获取对应的外设
    if selectedTriggerType == TYPES.ITEM_COUNT then
        -- Item Count: 获取 DEFAULT_INVENTORY 和 UNLIMITED_PERIPHERAL_INVENTORY
        peripherals = PeripheralWrapper.getByTypes({1, 2}) -- DEFAULT_INVENTORY=1, UNLIMITED_PERIPHERAL_INVENTORY=2
    elseif selectedTriggerType == TYPES.FLUID_COUNT then
        -- Fluid Count: 获取 TANK
        peripherals = PeripheralWrapper.getByTypes({3}) -- TANK=3
    elseif selectedTriggerType == TYPES.ITEM_COUNT_AT_SLOTS then
        -- Item Count at Slots: 获取 DEFAULT_INVENTORY
        peripherals = PeripheralWrapper.getByTypes({1}) -- DEFAULT_INVENTORY=1
    else
        -- 默认情况或未知类型
        peripherals = {}
    end

    local currentSelectedPeripheralId = self.selectNodeData and self.selectNodeData.targetPeripheralId or nil

    -- 转换为 ItemSelectedListBox 需要的格式
    for _, peripheral in pairs(peripherals) do
        if peripheral.getId() == currentSelectedPeripheralId then
            table.insert(listItems, {
            text = peripheral.getId() or "Unknown",
            selected = true,
            data = peripheral
        })
        else
            table.insert(listItems, {
                text = peripheral.getId() or "Unknown",
                data = peripheral
            })
        end
        
    end
    
    -- 打开选择器
    self.itemListBox:open(listItems, false, {
        confirm = function(selectedItems)
            if self.selectNodeData == nil then
                self.selectNodeData = {}
            end
            self.selectNodeData.targetPeripheralId = selectedItems[1].data.getId()
            self.selectedTargetLabel:setText(StringUtils.ellipsisMiddle(self.selectNodeData.targetPeripheralId, self.selectedTargetLabel:getWidth()))
            -- 更新槽位按钮
            self:updateSlotButton()
        end
    })
end

-- 打开物品/流体选择器
function Triggers:openItemSelector()
    local selectedTriggerType = self:getSelectedTriggerType()
    local listItems = {}
    
    if selectedTriggerType == TYPES.ITEM_COUNT or selectedTriggerType == TYPES.ITEM_COUNT_AT_SLOTS then
        -- 获取所有库存外设的物品
        local inventoryPeripherals = PeripheralWrapper.getByTypes({1, 2}) or {}
        
        -- 收集所有物品并去重
        local itemsTable = {}
        for _, peripheral in pairs(inventoryPeripherals) do
            if peripheral.getItems then
                local items = peripheral.getItems()
                for _, item in ipairs(items) do
                    if not itemsTable[item.name] then
                        itemsTable[item.name] = true
                        table.insert(listItems, {
                            text = item.name,
                            data = {type = "item", name = item.name}
                        })
                    end
                end
            end
        end
        
    elseif selectedTriggerType == TYPES.FLUID_COUNT then
        -- 获取所有储罐外设的流体
        local tankPeripherals = PeripheralWrapper.getByTypes({3}) or {} -- TANK=3
        
        -- 收集所有流体并去重
        local fluidsTable = {}
        for _, peripheral in pairs(tankPeripherals) do
            if peripheral.getFluids then
                local fluids = peripheral.getFluids()
                for _, fluid in ipairs(fluids) do
                    if not fluidsTable[fluid.name] then
                        fluidsTable[fluid.name] = true
                        table.insert(listItems, {
                            text = fluid.name,
                            data = {type = "fluid", name = fluid.name}
                        })
                    end
                end
            end
        end
    end
    
    -- 如果没有找到任何物品或流体，显示空列表
    if #listItems == 0 then
        if selectedTriggerType == TYPES.FLUID_COUNT then
            table.insert(listItems, {
                text = "No fluids found",
                data = nil
            })
        else
            table.insert(listItems, {
                text = "No items found", 
                data = nil
            })
        end
    end
    
    -- 设置当前选择
    local currentSelectedItem = self.selectNodeData and self.selectNodeData.itemName or nil
    for _, item in ipairs(listItems) do
        if item.data and item.data.name == currentSelectedItem then
            item.selected = true
            break
        end
    end
    
    -- 打开选择器
    self.itemListBox:open(listItems, false, {
        confirm = function(selectedItems)
            if selectedItems[1].data then
                if self.selectNodeData == nil then
                    self.selectNodeData = {}
                end
                self.selectNodeData.itemName = selectedItems[1].data.name
                self.selectNodeData.itemType = selectedItems[1].data.type
                self.selectedItemLabel:setText(StringUtils.ellipsisMiddle(self.selectNodeData.itemName, self.selectedItemLabel:getWidth()))
            end
        end
    })
end

-- 打开槽位选择器
function Triggers:openSlotSelector()
    local selectedTriggerType = self:getSelectedTriggerType()
    
    -- 只有在 ITEM_COUNT_AT_SLOTS 类型时才显示槽位选择器
    if selectedTriggerType ~= TYPES.ITEM_COUNT_AT_SLOTS then
        return
    end
    
    local listItems = {}
    
    -- 如果有选中的目标外设，获取其槽位数量
    if self.selectNodeData and self.selectNodeData.targetPeripheralId then
        -- 确保外设已加载
        PeripheralWrapper.reloadAll()
        local peripheral = PeripheralWrapper.getByName(self.selectNodeData.targetPeripheralId)
        if peripheral and peripheral.size then
            local slotCount = peripheral.size()
            
            -- 添加所有槽位到列表
            for i = 1, slotCount do
                local isSelected = (self.selectNodeData.selectedSlot == i)
                table.insert(listItems, {
                    text = "Slot " .. i,
                    data = {slotId = i},
                    selected = isSelected
                })
            end
        else
            -- 如果无法获取槽位信息，显示默认槽位
            table.insert(listItems, {
                text = "Slot 1",
                data = {slotId = 1},
                selected = true
            })
        end
    else
        -- 没有选中目标外设时的提示
        table.insert(listItems, {
            text = "Select Target First",
            data = nil
        })
    end
    
    -- 打开选择器
    self.itemListBox:open(listItems, false, {
        confirm = function(selectedItems)
            if selectedItems[1].data then
                if self.selectNodeData == nil then
                    self.selectNodeData = {}
                end
                self.selectNodeData.selectedSlot = selectedItems[1].data.slotId
                self.slotButton:setText("Slot " .. self.selectNodeData.selectedSlot)
            end
        end
    })
end

-- 更新槽位按钮
function Triggers:updateSlotButton()
    local selectedTriggerType = self:getSelectedTriggerType()
    
    if selectedTriggerType == TYPES.ITEM_COUNT_AT_SLOTS then
        -- 显示槽位按钮
        self.slotButton:setVisible(true)
        
        -- 如果有选中的槽位，显示槽位号码
        if self.selectNodeData and self.selectNodeData.selectedSlot then
            self.slotButton:setText("Slot " .. self.selectNodeData.selectedSlot)
        else
            -- 没有选中槽位时的默认状态
            if self.selectNodeData and self.selectNodeData.targetPeripheralId then
                self.slotButton:setText("Select Slot")
            else
                self.slotButton:setText("Select Target")
            end
        end
    else
        -- 隐藏槽位按钮
        self.slotButton:setVisible(false)
    end
end

-- 获取选中的槽位
function Triggers:getSelectedSlot()
    if self.selectNodeData and self.selectNodeData.selectedSlot then
        return self.selectNodeData.selectedSlot
    end
    return nil
end

-- 根据触发器类型更新UI
function Triggers:updateUIForTriggerType()
    local selectedTriggerType = self:getSelectedTriggerType()
    
    if selectedTriggerType == TYPES.FLUID_COUNT then
        self.itemLabel:setText("Fluid:")
    else
        self.itemLabel:setText("Item:")
    end
    
    -- 更新槽位按钮
    self:updateSlotButton()
end

-- 更新节点详情区域
function Triggers:updateDetails(nodeData)
    if nodeData == nil then
        -- 清空所有字段，设置为默认值
        self.selectNodeData = {}
        
        -- 重置UI元素
        self.nodeNameInput:setText("unnamed")
        self.displayedParentNodelabel:setText("root")
        self.selectedTargetLabel:setText("")
        self.selectedItemLabel:setText("")
        self.amountInput:setText("0")
        
        -- 重置下拉菜单到默认选择
        self:setTriggerType(TYPES.ITEM_COUNT)
        self:setConditionType(CONDITION_TYPES.COUNT_GREATER)
        
        -- 重置槽位按钮
        self.slotButton:setText("Slot")
        
        -- 更新UI状态
        self:updateUIForTriggerType()
        self.modifyNodeBtn:setVisible(false)
        self.deleteNodeBtn:setVisible(false)
    else
        -- 根据node数据更新selectNodeData和UI
        self.selectNodeData = {
            parentNodeId = nodeData.parentNodeId or "",
            parentNodeName = nodeData.parentNodeName or "root",
            targetPeripheralId = nodeData.targetPeripheralId or "",
            name = nodeData.name or "unnamed",
            id = nodeData.id or OSUtils.timestampBaseIdGenerate(),
            triggerType = nodeData.triggerType or TYPES.ITEM_COUNT,
            triggerConditionType = nodeData.triggerConditionType or CONDITION_TYPES.COUNT_GREATER,
            itemName = nodeData.itemName or "",
            itemType = nodeData.itemType or "item",
            amount = nodeData.amount or 0,
            selectedSlot = nodeData.selectedSlot,
        }
        
        -- 更新UI元素
        self.nodeNameInput:setText(self.selectNodeData.name)
        self.displayedParentNodelabel:setText(self.selectNodeData.parentNodeName)
        self.selectedTargetLabel:setText(StringUtils.ellipsisMiddle(self.selectNodeData.targetPeripheralId or "", self.selectedTargetLabel:getWidth()))
        self.selectedItemLabel:setText(StringUtils.ellipsisMiddle(self.selectNodeData.itemName or "", self.selectedItemLabel:getWidth()))
        self.amountInput:setText(tostring(self.selectNodeData.amount))
        
        -- 设置下拉菜单选择
        self:setTriggerType(self.selectNodeData.triggerType)
        self:setConditionType(self.selectNodeData.triggerConditionType)
        
        -- 更新槽位按钮
        if self.selectNodeData.selectedSlot then
            self.slotButton:setText("Slot " .. self.selectNodeData.selectedSlot)
        else
            self.slotButton:setText("Slot")
        end
        
        -- 更新UI状态
        self:updateUIForTriggerType()
        self.modifyNodeBtn:setVisible(true)
        self.deleteNodeBtn:setVisible(true)
    end
end

-- 添加节点到树中
function Triggers:addNodeToTree()
    
    -- 更新selectNodeData中的当前值
    self.selectNodeData.name = self.nodeNameInput:getText() or "unnamed"
    self.selectNodeData.triggerType = self:getSelectedTriggerType() or TYPES.ITEM_COUNT
    self.selectNodeData.triggerConditionType = self:getSelectedConditionType() or CONDITION_TYPES.COUNT_GREATER
    self.selectNodeData.amount = self:getAmountValue() or 0
    self.selectNodeData.id = OSUtils.timestampBaseIdGenerate()

    
    -- 验证数据
    local errors = self:validateSelectNodeData()
    if #errors > 0 then
        -- 显示错误信息
        self.messageBox:open("Validation Errors", table.concat(errors, "\n"))
        return
    end
    
    -- 创建新节点
    local newNode = {
        text = self.selectNodeData.name,
        data = textutils.unserialize(textutils.serialize(self.selectNodeData)), -- 深拷贝数据
        children = {}
    }

    Logger.debug("Adding node with data: " .. textutils.serialize(newNode.data))
    
    -- 查找父节点
    local parentNodeId = self.selectNodeData.parentNodeId
    local parentNode = nil
    
    -- 如果parentNodeId为nil或者等于"root"，添加到根节点
    if not parentNodeId or parentNodeId == "" or parentNodeId == "root" then
        -- 添加到根节点
        if not self.tree.children then
            self.tree.children = {}
        end
        table.insert(self.tree.children, newNode)
        
        -- 更新树显示
        self.conditionTree:setNodes(self.tree.children or {})
    else
        -- 查找指定的父节点
        parentNode = self:findNodeById(self.tree, parentNodeId)
        if parentNode then
            if not parentNode.children then
                parentNode.children = {}
            end
            table.insert(parentNode.children, newNode)
            
            -- 展开父节点
            self.conditionTree:expandNode(parentNode)
            
            -- 更新树显示
            self.conditionTree:setNodes(self.tree.children or {})
        else
            -- 父节点未找到，添加到根节点
            if not self.tree.children then
                self.tree.children = {}
            end
            table.insert(self.tree.children, newNode)
            
            -- 更新树显示
            self.conditionTree:setNodes(self.tree.children or {})
        end
    end
    
    -- 清空详情区域准备添加下一个节点
    self:updateDetails(nil)
end

-- 修改选中的节点
function Triggers:modifySelectedNode()
    if not self.selectedTreeNode or not self.selectedTreeNode.data then
        return
    end
    
    -- 更新selectNodeData中的当前值
    self.selectNodeData.name = self.nodeNameInput:getText() or "unnamed"
    self.selectNodeData.triggerType = self:getSelectedTriggerType() or TYPES.ITEM_COUNT
    self.selectNodeData.triggerConditionType = self:getSelectedConditionType() or CONDITION_TYPES.COUNT_GREATER
    self.selectNodeData.amount = self:getAmountValue() or 0
    -- 保持原有的ID，不更新
    self.selectNodeData.id = self.selectedTreeNode.data.id
    
    -- 验证数据
    local errors = self:validateSelectNodeData()
    if #errors > 0 then
        -- 显示错误信息
        self.messageBox:open("Validation Errors", table.concat(errors, "\n"))
        return
    end
    
    -- 检查是否需要移动节点（父节点是否发生变化）
    local currentParentId = self.selectedTreeNode.data.parentNodeId or ""
    local newParentId = self.selectNodeData.parentNodeId or ""
    
    if currentParentId ~= newParentId then
        -- 需要移动节点到新的父节点
        self:moveNodeToNewParent(self.selectedTreeNode, newParentId)
    end
    
    -- 更新选中节点的数据
    self.selectedTreeNode.data = textutils.unserialize(textutils.serialize(self.selectNodeData)) -- 深拷贝数据
    self.selectedTreeNode.text = self.selectNodeData.name
    
    Logger.debug("Modified node with data: " .. textutils.serialize(self.selectedTreeNode.data))
    
    -- 刷新树显示
    self.conditionTree:setNodes(self.tree.children or {})
end

-- 将节点移动到新的父节点
function Triggers:moveNodeToNewParent(node, newParentId)
    if not node then
        return
    end
    
    -- 从当前父节点中移除节点
    self:removeNodeFromParent(node)
    
    -- 添加到新的父节点
    local newParentNode = nil
    if not newParentId or newParentId == "" or newParentId == "root" then
        -- 移动到根节点
        if not self.tree.children then
            self.tree.children = {}
        end
        table.insert(self.tree.children, node)
    else
        -- 查找新的父节点
        newParentNode = self:findNodeById(self.tree, newParentId)
        if newParentNode then
            if not newParentNode.children then
                newParentNode.children = {}
            end
            table.insert(newParentNode.children, node)
            
            -- 展开新的父节点
            self.conditionTree:expandNode(newParentNode)
        else
            -- 新父节点未找到，移动到根节点
            if not self.tree.children then
                self.tree.children = {}
            end
            table.insert(self.tree.children, node)
        end
    end
end

-- 从父节点中移除节点（不依赖parent字段）
function Triggers:removeNodeFromParent(nodeToRemove)
    if not nodeToRemove then
        return false
    end
    
    -- 递归查找并移除节点
    return self:removeNodeRecursive(self.tree, nodeToRemove)
end

-- 递归查找并移除节点
function Triggers:removeNodeRecursive(parentNode, nodeToRemove)
    if not parentNode or not parentNode.children then
        return false
    end
    
    -- 在当前层级查找目标节点
    for i, child in ipairs(parentNode.children) do
        if child == nodeToRemove then
            table.remove(parentNode.children, i)
            return true
        end
    end
    
    -- 递归在子节点中查找
    for _, child in ipairs(parentNode.children) do
        if self:removeNodeRecursive(child, nodeToRemove) then
            return true
        end
    end
    
    return false
end

-- 根据ID查找节点
function Triggers:findNodeById(node, targetId)
    if not node then
        return nil
    end
    
    -- 检查当前节点
    if node.data and node.data.id == targetId then
        return node
    end
    
    -- 检查子节点
    if node.children then
        for _, child in ipairs(node.children) do
            local found = self:findNodeById(child, targetId)
            if found then
                return found
            end
        end
    end
    
    return nil
end

-- 验证selectNodeData的有效性
function Triggers:validateSelectNodeData()
    local errors = {}
    
    -- 检查name是否为空
    if not self.selectNodeData.name or self.selectNodeData.name == "" or self.selectNodeData.name == "unnamed" then
        table.insert(errors, "Name cannot be empty")
    end
    
    -- 检查triggerType是否存在
    if not self.selectNodeData.triggerType then
        table.insert(errors, "Trigger type is required")
        return errors -- 如果没有triggerType，后续检查无法进行
    end
    
    -- 根据trigger type验证
    if self.selectNodeData.triggerType == TYPES.ITEM_COUNT then
        -- Item Count: peripheral必须是type 1或2，itemType必须是item
        if not self.selectNodeData.targetPeripheralId or self.selectNodeData.targetPeripheralId == "" then
            table.insert(errors, "Target peripheral is required for Item Count trigger")
        else
            -- 验证peripheral类型
            PeripheralWrapper.reloadAll()
            local peripheral = PeripheralWrapper.getByName(self.selectNodeData.targetPeripheralId)
            if peripheral then
                local peripheralTypes = peripheral.getTypes()
                local isValidType = false
                for _, pType in ipairs(peripheralTypes) do
                    if pType == 1 or pType == 2 then
                        isValidType = true
                        break
                    end
                end
                if not isValidType then
                    table.insert(errors, "Target peripheral must be inventory type (type 1 or 2) for Item Count trigger")
                end
            else
                table.insert(errors, "Target peripheral not found")
            end
        end
        
        -- 验证itemType
        if not self.selectNodeData.itemType or self.selectNodeData.itemType ~= "item" then
            table.insert(errors, "Item type must be 'item' for Item Count trigger")
        end
        
        -- 验证itemName
        if not self.selectNodeData.itemName or self.selectNodeData.itemName == "" then
            table.insert(errors, "Item name is required for Item Count trigger")
        end
        
    elseif self.selectNodeData.triggerType == TYPES.FLUID_COUNT then
        -- Fluid Count: peripheral必须是type 3，itemType必须是fluid
        if not self.selectNodeData.targetPeripheralId or self.selectNodeData.targetPeripheralId == "" then
            table.insert(errors, "Target peripheral is required for Fluid Count trigger")
        else
            -- 验证peripheral类型
            PeripheralWrapper.reloadAll()
            local peripheral = PeripheralWrapper.getByName(self.selectNodeData.targetPeripheralId)
            if peripheral then
                local peripheralTypes = peripheral.getTypes()
                local isValidType = false
                for _, pType in ipairs(peripheralTypes) do
                    if pType == 3 then
                        isValidType = true
                        break
                    end
                end
                if not isValidType then
                    table.insert(errors, "Target peripheral must be tank type (type 3) for Fluid Count trigger")
                end
            else
                table.insert(errors, "Target peripheral not found")
            end
        end
        
        -- 验证itemType
        if not self.selectNodeData.itemType or self.selectNodeData.itemType ~= "fluid" then
            table.insert(errors, "Item type must be 'fluid' for Fluid Count trigger")
        end
        
        -- 验证itemName (fluid name)
        if not self.selectNodeData.itemName or self.selectNodeData.itemName == "" then
            table.insert(errors, "Fluid name is required for Fluid Count trigger")
        end
        
    elseif self.selectNodeData.triggerType == TYPES.ITEM_COUNT_AT_SLOTS then
        -- Item Count at Slots: peripheral必须是type 1，itemType必须是item
        if not self.selectNodeData.targetPeripheralId or self.selectNodeData.targetPeripheralId == "" then
            table.insert(errors, "Target peripheral is required for Item Count at Slots trigger")
        else
            -- 验证peripheral类型
            PeripheralWrapper.reloadAll()
            local peripheral = PeripheralWrapper.getByName(self.selectNodeData.targetPeripheralId)
            if peripheral then
                local peripheralTypes = peripheral.getTypes()
                local isValidType = false
                for _, pType in ipairs(peripheralTypes) do
                    if pType == 1 then
                        isValidType = true
                        break
                    end
                end
                if not isValidType then
                    table.insert(errors, "Target peripheral must be inventory type (type 1) for Item Count at Slots trigger")
                end
            else
                table.insert(errors, "Target peripheral not found")
            end
        end
        
        -- 验证itemType
        if not self.selectNodeData.itemType or self.selectNodeData.itemType ~= "item" then
            table.insert(errors, "Item type must be 'item' for Item Count at Slots trigger")
        end
        
        -- 验证itemName
        if not self.selectNodeData.itemName or self.selectNodeData.itemName == "" then
            table.insert(errors, "Item name is required for Item Count at Slots trigger")
        end
        
        -- 验证selectedSlot
        if not self.selectNodeData.selectedSlot or self.selectNodeData.selectedSlot <= 0 then
            table.insert(errors, "Valid slot selection is required for Item Count at Slots trigger")
        end
        
    else
        table.insert(errors, "Unknown trigger type: " .. tostring(self.selectNodeData.triggerType))
    end
    
    -- 验证amount
    if not self.selectNodeData.amount or self.selectNodeData.amount < 0 then
        table.insert(errors, "Amount must be a non-negative number")
    end
    
    -- 验证triggerConditionType
    if not self.selectNodeData.triggerConditionType then
        table.insert(errors, "Trigger condition type is required")
    end
    
    return errors
end

-- 删除选中的节点
function Triggers:deleteSelectedNode()
    if not self.selectedTreeNode or not self.selectedTreeNode.data then
        return
    end
    
    local nodeId = self.selectedTreeNode.data.id
    local nodeName = self.selectedTreeNode.data.name or "Unnamed Node"
    
    -- 显示确认对话框
    self.confirmMessageBox:open(
        "Confirm Delete", 
        "Are you sure you want to delete node '" .. nodeName .. "'?",
        function()
            self:deleteNodeById(nodeId)
        end,
        function()
            -- 取消删除，什么都不做
        end
    )
end

-- 根据ID删除节点
function Triggers:deleteNodeById(nodeId)
    if not nodeId then
        return false
    end
    
    -- 查找要删除的节点
    local nodeToDelete = self:findNodeById(self.tree, nodeId)
    if not nodeToDelete then
        return false
    end
    
    -- 从父节点中移除该节点
    self:removeNodeFromParent(nodeToDelete)
    
    -- 清空选择状态
    self.selectedTreeNode = nil
    
    -- 刷新树显示
    self.conditionTree:setNodes(self.tree.children or {})
    
    -- 清空详情区域
    self:updateDetails(nil)
    
    return true
end

-- Save trigger statement and call the callback
function Triggers:saveTriggerStatement()
    if self.saveCallback then
        -- 直接使用原始树，因为没有循环引用了
        self.saveCallback(self.tree)
    end
    self:close()
end

-- Close the trigger interface
function Triggers:close()
    self.frame:setVisible(false)
    self.saveCallback = nil -- Clear the callback
end

return Triggers
