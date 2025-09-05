local OSUtils = require("utils.OSUtils")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")

local TransferJobManager = {}

local Logger = require("utils.Logger")

TransferJobManager.TRIGGER_TYPES = {
    FLUID_COUNT = "fluid_count",
    ITEM_COUNT = "item_count",
    ITEM_COUNT_AT_SLOTS = "item_count_at_slot",
    REDSTONE_SIGNAL = "redstone_signal",
}

TransferJobManager.TRIGGER_CONDITION_TYPES = {
    COUNT_GREATER = "count_greater",
    COUNT_LESS = "count_less",
    COUNT_EQUAL = "count_equal"
}

TransferJobManager.transfers = {}
-- {
--     id = OSUtils.timestampBaseIdGenerate(),
--     name = "unnamed",
--     inputInv = {},
--     outputInv = {},
--     itemFilter = {},
--     isBlackList = false,
--     isDisabled = false
-- }

TransferJobManager.load = function()
    local transfers = OSUtils.loadTable("transfers")
    if transfers ~= nil then
        TransferJobManager.transfers = transfers
    end
end

TransferJobManager.save = function()
    OSUtils.saveTable("transfers", TransferJobManager.transfers)
end

TransferJobManager.addTransfer = function(transfer)
    TransferJobManager.transfers[transfer.id] = textutils.unserialize(textutils.serialize(transfer))
    TransferJobManager.save()
end

TransferJobManager.removeTransfer = function(transferId)
    TransferJobManager.transfers[transferId] = nil
    TransferJobManager.save()
end

TransferJobManager.getTransfer = function(transferId)
    return textutils.unserialize(textutils.serialize(TransferJobManager.transfers[transferId]))
end

TransferJobManager.getAllTransfers = function()
    return textutils.unserialize(textutils.serialize(TransferJobManager.transfers))
end

TransferJobManager.exec = function()
    local jobs = TransferJobManager.buildJobsFns()
    if #jobs > 0 then
        local ok, err = pcall(function()
            parallel.waitForAll(table.unpack(jobs))
        end)
        if not ok then
            Logger.error("Error executing transfer jobs: {}", err)
        end
    end
end

TransferJobManager.buildJobsFns = function()
    local jobs = {}
    for _, transfer in pairs(TransferJobManager.transfers) do
        if not transfer.isDisabled then
            -- Evaluate trigger conditions before creating the job
            local triggerPassed = TransferJobManager.evalTrigger(transfer.triggerStatement)
            if triggerPassed then
                table.insert(jobs, function()
                    local ok, err = pcall(function()
                        Logger.info("Starting transfer job: {} (ID: {})", transfer.name, transfer.id)
                        for name, _ in pairs(transfer.inputInv) do
                            local result = TransferJobManager.transferItem(name, transfer.outputInv,
                                transfer.itemFilter, transfer.isBlackList, transfer.inputSlots, transfer.outputSlots, transfer.itemRate, transfer.fluidRate)
                            if result.itemCount > 0 or result.fluidCount > 0 then
                                Logger.info("Transfer job '{}' transferred {} items and {} fluid units from {}", 
                                    transfer.name, result.itemCount, result.fluidCount, name)
                            end
                        end
                        Logger.info("Completed transfer job: {}", transfer.name)
                    end)
                    if not ok then
                        Logger.error("Error executing transfer job '{}' (ID: {}): {}", 
                            transfer.name, transfer.id, err)
                    end
                end)
            else
                Logger.debug("Transfer job '{}' skipped: trigger conditions not met", transfer.name)
            end
        end
    end
    return jobs
end

-- Helper function to iterate over slots
local function forSlots(peripheral, inputSlots, callback)
    if inputSlots == nil or #inputSlots == 0 then
        -- If no specific input slots, iterate over all slots
        local size = peripheral.size()
        for slot = 1, size do
            callback(slot)
        end
    else
        -- Iterate only over specified input slots
        for _, slot in ipairs(inputSlots) do
            callback(slot)
        end
    end
end

-- Helper function to check if an item should be transferred based on filter
local function shouldTransferItem(itemName, itemFilter, isBlackList)
    if itemFilter == nil or next(itemFilter) == nil then
        -- Empty filter behavior depends on list type
        return isBlackList -- Black list: transfer all, White list: transfer none
    else
        -- Apply filter logic
        local itemInFilter = itemFilter[itemName] ~= nil
        return isBlackList and (not itemInFilter) or (not isBlackList and itemInFilter)
    end
end

-- Helper function to transfer to all output inventories
local function transferToOutputs(inv, outputInvNames, itemName, totalAmount, isFluid, rateLimit)
    local transferred = 0
    local amountToTransfer = totalAmount
    
    -- Apply rate limiting if specified (rateLimit >= 0)
    if rateLimit and rateLimit >= 0 then
        amountToTransfer = math.min(totalAmount, rateLimit)
    end
    
    for outputName, _ in pairs(outputInvNames) do
        local outputInv = PeripheralWrapper.getByName(outputName)
        if outputInv == nil then
            error("Output inventory '" .. outputName .. "' not found")
        end
        while amountToTransfer > transferred do
            local moved
            if isFluid then
                moved = inv.transferFluidTo(outputInv, itemName, amountToTransfer - transferred)
            else
                moved = inv.transferItemTo(outputInv, itemName, amountToTransfer - transferred)
            end
            
            if moved == 0 then
                break
            end
            transferred = transferred + moved
        end
        
        if transferred >= amountToTransfer then
            break
        end
    end
    return transferred
end

-- Helper function for slot-specific transfers using native pushItems
local function transferSlotSpecific(inv, outputInvNames, itemFilter, isBlackList, inputSlots, outputSlots, itemRate)
    local overallItemTransferred = 0
    local remainingRate = itemRate
    
    -- Ensure input peripheral is DEFAULT_INVENTORY type
    if not inv.isDefaultInventory() then
        Logger.warn("Slot-specific transfer requires DEFAULT_INVENTORY type for input: {}", inv.getName())
        return 0
    end
    
    -- Process each input slot
    forSlots(inv, inputSlots, function(inputSlot)
        -- Check if we've reached the rate limit
        if itemRate >= 0 and remainingRate <= 0 then
            return -- Stop processing if rate limit reached
        end
        
        local item = inv.getItemDetail(inputSlot)
        if item and shouldTransferItem(item.name, itemFilter, isBlackList) then
            local remainingToTransfer = item.count
            
            -- Apply rate limiting if itemRate >= 0
            if itemRate >= 0 then
                remainingToTransfer = math.min(remainingToTransfer, remainingRate)
            end
            
            -- Try each output inventory
            for outputName, _ in pairs(outputInvNames) do
                if remainingToTransfer <= 0 then break end
                
                local outputInv = PeripheralWrapper.getByName(outputName)
                if outputInv and outputInv.isDefaultInventory() then
                    -- If specific output slots defined, use them; otherwise let CC find empty slots
                    if outputSlots and next(outputSlots) ~= nil then
                        for _, outputSlot in ipairs(outputSlots) do
                            if remainingToTransfer <= 0 then break end
                            local transferred = inv.pushItems(outputName, inputSlot, remainingToTransfer, outputSlot)
                            if transferred > 0 then
                                overallItemTransferred = overallItemTransferred + transferred
                                remainingToTransfer = remainingToTransfer - transferred
                                if itemRate >= 0 then
                                    remainingRate = remainingRate - transferred
                                end
                            end
                        end
                    else
                        -- No specific output slots, let CC find available space
                        local transferred = inv.pushItems(outputName, inputSlot, remainingToTransfer)
                        if transferred > 0 then
                            overallItemTransferred = overallItemTransferred + transferred
                            remainingToTransfer = remainingToTransfer - transferred
                            if itemRate >= 0 then
                                remainingRate = remainingRate - transferred
                            end
                        end
                    end
                else
                    if not outputInv then
                        Logger.warn("Output inventory not found: {}", outputName)
                    else
                        Logger.warn("Slot-specific transfer requires DEFAULT_INVENTORY type for output: {}", outputName)
                    end
                end
            end
        end
    end)
    
    return overallItemTransferred
end

TransferJobManager.transferItem = function(inputName, outputInvNames, itemFilter, isBlackList, inputSlots, outputSlots, itemRate, fluidRate)
    local inv = PeripheralWrapper.getByName(inputName)
    if inv == nil then
        error("Input inventory '" .. inputName .. "' not found")
    end

    local overallItemTransferred = 0
    local overallFluidTransferred = 0
    local remainingItemRate = itemRate or -1
    local remainingFluidRate = fluidRate or -1

    -- Handle tank transfers
    if inv.isTank() then
        local fluids = inv.getFluids() or {}
        for _, fluid in pairs(fluids) do
            -- Check if we've reached the fluid rate limit
            if fluidRate and fluidRate >= 0 and remainingFluidRate <= 0 then
                break
            end
            
            if shouldTransferItem(fluid.name, itemFilter, isBlackList) then
                local transferAmount = fluid.amount
                
                -- Apply fluid rate limiting if fluidRate >= 0
                if fluidRate and fluidRate >= 0 then
                    transferAmount = math.min(fluid.amount, remainingFluidRate)
                end
                
                local transferred = transferToOutputs(inv, outputInvNames, fluid.name, transferAmount, true, fluidRate and fluidRate >= 0 and remainingFluidRate or nil)
                if transferred > 0 then
                    overallFluidTransferred = overallFluidTransferred + transferred
                    if fluidRate and fluidRate >= 0 then
                        remainingFluidRate = remainingFluidRate - transferred
                    end
                end
            end
        end
    end

    -- Handle inventory transfers
    if inv.isInventory() then
        -- Use slot-specific transfers if input or output slots are specified
        if (inputSlots and next(inputSlots) ~= nil) or (outputSlots and next(outputSlots) ~= nil) then
            local slotTransferred = transferSlotSpecific(inv, outputInvNames, itemFilter, isBlackList, inputSlots, outputSlots, remainingItemRate)
            overallItemTransferred = overallItemTransferred + slotTransferred
        else
            -- Use normal inventory transfers
            local items = inv:getItems()
            if items ~= nil and #items > 0 then
                for _, item in ipairs(items) do
                    -- Check if we've reached the item rate limit
                    if itemRate and itemRate >= 0 and remainingItemRate <= 0 then
                        break
                    end
                    
                    if shouldTransferItem(item.name, itemFilter, isBlackList) then
                        local transferAmount = item.count
                        
                        -- Apply item rate limiting if itemRate >= 0
                        if itemRate and itemRate >= 0 then
                            transferAmount = math.min(item.count, remainingItemRate)
                        end
                        
                        local transferred = transferToOutputs(inv, outputInvNames, item.name, transferAmount, false, itemRate and itemRate >= 0 and remainingItemRate or nil)
                        if transferred > 0 then
                            overallItemTransferred = overallItemTransferred + transferred
                            if itemRate and itemRate >= 0 then
                                remainingItemRate = remainingItemRate - transferred
                            end
                        end
                    end
                end
            end
        end
    end

    return {
        itemCount = overallItemTransferred,
        fluidCount = overallFluidTransferred
    }
end

-- Evaluate trigger statement tree recursively
-- Returns true if all conditions in the tree are met
TransferJobManager.evalTrigger = function(triggerStatement)
    -- If no trigger statement or invalid structure, return true (no restrictions)
    if not triggerStatement or not triggerStatement.children then
        return true
    end
    
    for _, childNode in ipairs(triggerStatement.children) do
        Logger.debug("Evaluating child node: {}", childNode.data and childNode.data.name or "Unnamed")
        if TransferJobManager.evalTriggerNode(childNode) then
            return true
        end
    end
    
    return false -- All children passed
end

-- Evaluate a single trigger node and its children
TransferJobManager.evalTriggerNode = function(node)
    if not node or not node.data then
        return true -- Invalid node, skip
    end
    
    local data = node.data
    local nodeResult = false
    
    -- Evaluate current node based on its trigger type
    if data.triggerType == TransferJobManager.TRIGGER_TYPES.ITEM_COUNT then
        nodeResult = TransferJobManager.evalItemCountTrigger(data)
    elseif data.triggerType == TransferJobManager.TRIGGER_TYPES.FLUID_COUNT then
        nodeResult = TransferJobManager.evalFluidCountTrigger(data)
    elseif data.triggerType == TransferJobManager.TRIGGER_TYPES.ITEM_COUNT_AT_SLOTS then
        nodeResult = TransferJobManager.evalItemCountAtSlotsTrigger(data)
    elseif data.triggerType == TransferJobManager.TRIGGER_TYPES.REDSTONE_SIGNAL then
        nodeResult = TransferJobManager.evalRedstoneSignalTrigger(data)
    else
        Logger.warn("Unknown trigger type: {}", data.triggerType)
        return true -- Unknown type, skip
    end
    
    -- Evaluate children with OR logic
    local childrenResult = true
    if node.children and #node.children > 0 then
        childrenResult = false -- Start with false for OR logic
        for _, childNode in ipairs(node.children) do
            if TransferJobManager.evalTriggerNode(childNode) then
                childrenResult = true -- If any child passes, children pass (OR logic)
                Logger.debug("Child node passed: {}", childNode.data.name)
                break
            end
        end
    end
    
    -- Return AND of parent node and children result
    return nodeResult and childrenResult
end

-- Evaluate ITEM_COUNT trigger
TransferJobManager.evalItemCountTrigger = function(data)
    if not data.targetPeripheralId or not data.itemName then
        Logger.warn("Invalid ITEM_COUNT trigger data: missing targetPeripheralId or itemName")
        return false
    end
    
    local peripheral = PeripheralWrapper.getByName(data.targetPeripheralId)
    if not peripheral or not peripheral.isInventory() then
        Logger.warn("Peripheral not found or not an inventory: {}", data.targetPeripheralId)
        return false
    end
    
    local item = peripheral.getItem(data.itemName)
    local currentCount = 0
    if item and item then
        currentCount = item.count
    end
    
    return TransferJobManager.evalCondition(currentCount, data.amount, data.triggerConditionType)
end

-- Evaluate FLUID_COUNT trigger
TransferJobManager.evalFluidCountTrigger = function(data)
    if not data.targetPeripheralId or not data.itemName then
        Logger.warn("Invalid FLUID_COUNT trigger data: missing targetPeripheralId or itemName")
        return false
    end
    
    local peripheral = PeripheralWrapper.getByName(data.targetPeripheralId)
    if not peripheral or not peripheral.isTank() then
        Logger.warn("Peripheral not found or not a tank: {}", data.targetPeripheralId)
        return false
    end
    
    local fluids = peripheral.getFluids()
    local currentAmount = 0
    if fluids then
        for _, fluid in pairs(fluids) do
            if fluid.name == data.itemName then
                currentAmount = currentAmount + fluid.amount
            end
        end
    end
    
    return TransferJobManager.evalCondition(currentAmount, data.amount, data.triggerConditionType)
end

-- Evaluate ITEM_COUNT_AT_SLOTS trigger
TransferJobManager.evalItemCountAtSlotsTrigger = function(data)

    if not data.targetPeripheralId or not data.itemName or not data.selectedSlot then
        Logger.warn("Invalid ITEM_COUNT_AT_SLOTS trigger data: missing required fields")
        return false
    end
    
    local peripheral = PeripheralWrapper.getByName(data.targetPeripheralId)
    if not peripheral then
        Logger.warn("Peripheral not found: {}", data.targetPeripheralId)
        return false
    end
    
    -- Check if peripheral is DEFAULT_INVENTORY type (has getItemDetail method)
    if not peripheral.isDefaultInventory() then
        Logger.warn("ITEM_COUNT_AT_SLOTS trigger requires DEFAULT_INVENTORY type peripheral: {}", data.targetPeripheralId)
        return false
    end
    
    local slotItem = peripheral.getItemDetail(data.selectedSlot)
    local currentCount = 0
    if slotItem and slotItem.name == data.itemName then
        currentCount = slotItem.count
    end
    
    return TransferJobManager.evalCondition(currentCount, data.amount, data.triggerConditionType)
end

-- Evaluate REDSTONE_SIGNAL trigger (placeholder implementation)
TransferJobManager.evalRedstoneSignalTrigger = function(data)
    -- TODO: Implement redstone signal evaluation
    Logger.warn("REDSTONE_SIGNAL trigger not implemented yet")
    return true
end

-- Helper function to evaluate condition based on condition type
TransferJobManager.evalCondition = function(currentValue, targetValue, conditionType)
    if conditionType == TransferJobManager.TRIGGER_CONDITION_TYPES.COUNT_GREATER then
        return currentValue > targetValue
    elseif conditionType == TransferJobManager.TRIGGER_CONDITION_TYPES.COUNT_LESS then
        return currentValue < targetValue
    elseif conditionType == TransferJobManager.TRIGGER_CONDITION_TYPES.COUNT_EQUAL then
        return currentValue == targetValue
    else
        Logger.warn("Unknown condition type: {}", conditionType)
        return false
    end
end

return TransferJobManager
