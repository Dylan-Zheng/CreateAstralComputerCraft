local Logger = require("utils.Logger")
local Triggers = {}

Triggers.TYPES = {
    FLUID_COUNT = "fluid_count",
    ITEM_COUNT = "item_count",
    REDSTONE_SIGNAL = "redstone_signal",
}

Triggers.CONDITION_TYPES = {
    COUNT_GREATER = "count_greater",
    COUNT_LESS = "count_less",
    COUNT_EQUAL = "count_equal"
}

Triggers.eval = function(triggerStatement, getFn)
    -- If no trigger statement or invalid structure, return true (no restrictions)
    if not triggerStatement or not triggerStatement.children then
        return true
    end
    
    for _, childNode in ipairs(triggerStatement.children) do
        if Triggers.evalTriggerNode(childNode, getFn) then
            return true
        end
    end
    
    return false -- All children passed
end

-- Evaluate a single trigger node and its children
Triggers.evalTriggerNode = function(node, getFn)
    if not node or not node.data then
        return true -- Invalid node, skip
    end
    
    local data = node.data
    local nodeResult = false
    
    -- Evaluate current node based on its trigger type
    if data.triggerType == Triggers.TYPES.ITEM_COUNT then
        nodeResult = Triggers.evalItemCountTrigger(data, getFn)
    elseif data.triggerType == Triggers.TYPES.FLUID_COUNT then
        nodeResult = Triggers.evalFluidCountTrigger(data, getFn)
    elseif data.triggerType == Triggers.TYPES.REDSTONE_SIGNAL then
        nodeResult = Triggers.evalRedstoneSignalTrigger(data, getFn)
    else
        return true -- Unknown type, skip
    end
    
    -- Evaluate children with OR logic
    local childrenResult = true
    if node.children and #node.children > 0 then
        childrenResult = false -- Start with false for OR logic
        for _, childNode in ipairs(node.children) do
            if Triggers.evalTriggerNode(childNode, getFn) then
                childrenResult = true -- If any child passes, children pass (OR logic)
                break
            end
        end
    end
    
    -- Return AND of parent node and children result
    return nodeResult and childrenResult
end

-- Evaluate ITEM_COUNT trigger using getFn
Triggers.evalItemCountTrigger = function(data, getFn)
    if not data.itemName or not getFn then
        return false
    end
    
    local currentCount = 0
    local item = getFn("item", data.itemName)
    if item then
        currentCount = item.count or 0
    end
    return Triggers.evalCondition(currentCount, data.amount, data.triggerConditionType)
end

-- Evaluate FLUID_COUNT trigger using getFn
Triggers.evalFluidCountTrigger = function(data, getFn)
    if not data.itemName or not getFn then
        return false
    end

    local currentAmount = 0
    local fluid = getFn("fluid", data.itemName)
    if fluid then
        currentAmount = fluid.amount or 0
    end
    return Triggers.evalCondition(currentAmount, data.amount, data.triggerConditionType)
end

-- Evaluate REDSTONE_SIGNAL trigger (placeholder implementation)
Triggers.evalRedstoneSignalTrigger = function(data, getFn)
    -- TODO: Implement redstone signal evaluation
    -- For now, always return true as placeholder
    return true
end

-- Helper function to evaluate condition based on condition type
Triggers.evalCondition = function(currentValue, targetValue, conditionType)
    if conditionType == Triggers.CONDITION_TYPES.COUNT_GREATER then
        return currentValue > targetValue
    elseif conditionType == Triggers.CONDITION_TYPES.COUNT_LESS then
        return currentValue < targetValue
    elseif conditionType == Triggers.CONDITION_TYPES.COUNT_EQUAL then
        return currentValue == targetValue
    else
        return false
    end
end

return Triggers