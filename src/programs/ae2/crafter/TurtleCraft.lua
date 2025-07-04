local Container = require("utils.ContainerLoader")
local OSUtils = require("utils.OSUtils")

local _, vault = next(Container.load.item_vaults())
local _, partternProvider = next(Container.load.ae2_pattern_providers())
local _, dropper = next(Container.load.droppers())
local _, chest = next(Container.load.chests())

local TurtleCraft = {}

local STEPS ={
    PREPARE_ITEM = 1,
    CHECKING = 2,
    CRAFT = 3,
    DROP_OUTPUT = 4,
    PROVIDER_TAKE_OUTPUT = 5,
}

local CRAFTING_SLOT = {1, 2, 3, 5, 6, 7, 9, 10, 11}

TurtleCraft.hasMarkedItems = function(items, markTables)
    for _, item in pairs(items) do
        if markTables[item.name] and item.nbt ~=nil and markTables[item.name][item.nbt] then
            return true, item, markTables[item.name][item.nbt]
        end
    end
    return false, nil, nil
end

TurtleCraft.moveCraftingItemToBuffer = function(item, amount)
    return vault.moveItem(dropper, item.name, amount)
end

TurtleCraft.moveMarkItemToOutputChest = function(item, amount)
    return vault.moveItem(chest, item.name, amount)
end

TurtleCraft.getInputFromBuffer = function(slot, count)
    turtle.select(slot)
    return turtle.suckUp(count)
end


TurtleCraft.prepareItem = function(params)
    
    local movedMarkItemCount, err = TurtleCraft.moveMarkItemToOutputChest(params.markItem, params.inputAmt)
    if movedMarkItemCount <= 0 then
        return false, "Failed to move marked item to output chest: " .. (err or "unknown error")
    end

    TurtleCraft.saveStep(STEPS.PREPARE_ITEM, params)
    for idx, input in ipairs(params.recipe.input) do
        if input and input.name then
            local movedItemCount, err = TurtleCraft.moveCraftingItemToBuffer(input, params.inputAmt)
            if movedItemCount <= 0 then
                return false, "Failed to move crafting item to buffer: " .. (err or "unknown error")
            end
            local gotCount, err = TurtleCraft.getInputFromBuffer(CRAFTING_SLOT[idx], movedItemCount)
            if not gotCount then
                return false, "Failed to get input from buffer: " .. (err or "unknown error")
            end
        end
    end
end

TurtleCraft.checkingInput = function(params)
    TurtleCraft.saveStep(STEPS.CHECKING, params)
    for index, slot in ipairs(CRAFTING_SLOT) do
        local item = turtle.getItemDetail(slot)
        if params.recipe.input[index] and params.recipe.input[index].name then
            if not item or item.name ~= params.recipe.input[index].name or item.count ~= params.inputAmt then
                return false, "Input slot " .. index .. " has incorrect item or amount"
            end
        end
    end
    return true
end

TurtleCraft.craft = function(params)
    TurtleCraft.saveStep(STEPS.CRAFT, params)
    return turtle.craft()
end

TurtleCraft.dropOutput = function(params)
    TurtleCraft.saveStep(STEPS.DROP_OUTPUT, params)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.count > 0 then
            turtle.select(i)
            local moved = turtle.drop()
            if not moved then
                return false, "Failed to drop item from slot " .. i
            end
        end
    end
    return true, "Output items dropped successfully"
end

TurtleCraft.moveOutputItem = function(params)
    local items = chest.listItem()
    local outputItem, markItem = nil, nil
    for _, item in pairs(items) do
        if params.recipe.output and item.name == params.recipe.output.name then
            outputItem = item
        end
        if params.recipe.mark and item.name == params.recipe.mark.name and item.nbt == params.recipe.mark.nbt then
            markItem = item
        end
    end
    local requireOutputCount = params.inputAmt * params.recipe.output.count
    if outputItem and outputItem.count ~= requireOutputCount then
        return false, "Output item count mismatch: expected " .. requireOutputCount .. ", got " .. outputItem.count
    end
    TurtleCraft.saveStep(STEPS.PROVIDER_TAKE_OUTPUT, params)
    local totalMoved = 0
    local tryCount = 0
    while totalMoved < requireOutputCount do
        local movedCount, err = partternProvider.moveItem(chest, params.recipe.output.name, requireOutputCount - totalMoved)
        if movedCount <= 0 then
            tryCount = tryCount + 1
        end
        if tryCount > 5 then
            return false, "Failed to move output item after multiple attempts: " .. (err or "unknown error")
        end
        totalMoved = totalMoved + movedCount
    end
    return true, "Output item moved successfully: " .. totalMoved .. " items"
end

TurtleCraft.saveStep = function(step, params)
    OSUtils.saveTable("step", {step=step, params=params})
end

TurtleCraft.readStep = function()
    return OSUtils.loadTable("step")
end

TurtleCraft.clearBuffer = function()
    local items = dropper.list()
    for _, item in pairs(items) do
        vault.takeItem(dropper, item.name, item.count)
    end
end

TurtleCraft.clearTurtle = function()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.count > 0 then
            turtle.select(i)
            turtle.dropUp()
            vault.takeItem(dropper, item.name, item.count)
        end
    end
end

TurtleCraft.clearOutputChest = function()
    local items = chest.listItem()
    for _, item in pairs(items) do
        vault.takeItem(chest, item.name, item.count)
    end
end

TurtleCraft.clear = function()
    TurtleCraft.clearBuffer()
    TurtleCraft.clearTurtle()
    TurtleCraft.clearOutputChest()
end

TurtleCraft.process = function(params, save)
    local step = 0
    if not save then
        params.inputAmt = math.min(12, params.markItem.count)
        step = save.step
        if params.inputAmt <= 0 then
            return false, "No marked item available for crafting:"
        end
    end
    
    if STEPS.PREPARE_ITEM >= step then
        local success, msg = TurtleCraft.prepareItem(params)
        if not success then
            return false, "Preparation failed: " .. msg
        end
    end
    if STEPS.CHECKING >= step then
        local success, msg = TurtleCraft.checkingInput(params)
        if not success then
            return false, "Checking input failed: " .. msg
        end
    end
    if STEPS.CRAFT >= step then
        local success, msg = TurtleCraft.craft(params)
        if not success then
            return false, "Crafting failed: " .. msg
        end
    end
    if STEPS.DROP_OUTPUT >= step then
        local success, msg = TurtleCraft.dropOutput(params)
        if not success then
            return false, "Dropping output failed: " .. msg
        end
    end
    if STEPS.PROVIDER_TAKE_OUTPUT >= step then
        local success, msg = TurtleCraft.moveOutputItem(params)
        if not success then
            return false, "Moving output item failed: " .. msg
        end
    end
    TurtleCraft.saveStep(nil, nil)
    return true, "Crafting process completed successfully"
end

TurtleCraft.hasUnfinishedJob = function()
    local save = TurtleCraft.readStep()
    if not save or not save.step then
        return false, "No unfinished job found"
    end
    if save.step == STEPS.PREPARE_ITEM then
        TurtleCraft.clear()
    end
    if save.step == STEPS.CRAFT then
        local success, msg = TurtleCraft.checkingInput(save.params)
        if not success then
            save.step = STEPS.DROP_OUTPUT
            TurtleCraft.saveStep(STEPS.DROP_OUTPUT, save.params)
            return true, save
        end
    end
    return true, save
end

TurtleCraft.listen = function(getMarkTable)
    while true do 
        local waitTime = 3
        local shouldProcess = false

        local hasUnfinished, save = TurtleCraft.hasUnfinishedJob()
        if hasUnfinished then
            TurtleCraft.process(save.params, save)
            waitTime = 0.2
        else
            local vaultItems = vault.listItem()
            if vaultItems and #vaultItems > 0 then
                local markTables = getMarkTable()
                if markTables then
                    local hasMarked, markItem, recipe = TurtleCraft.hasMarkedItems(vaultItems, markTables)
                    if hasMarked then
                        waitTime = 0.2
                        TurtleCraft.process({markItem = markItem, recipe = recipe})
                    end
                end
            end
        end

        os.sleep(waitTime)
    end
end

return TurtleCraft