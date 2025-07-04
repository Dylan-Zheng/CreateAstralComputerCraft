local Container = require("utils.ContainerLoader")
local OSUtils = require("utils.OSUtils")

local _, vault = next(Container.load.item_vaults())
local _, partternProvider = next(Container.load.ae2_pattern_providers())
local _, dropper = next(Container.load.droppers())
local _, chest = next(Container.load.chests())

local TurtleCraft = {
    printFn = print
}

TurtleCraft.setPrintFunction = function (printFunction)
    if type(printFunction) ~= "function" then
        error("printFunction must be a function")
    end
    TurtleCraft.printFn = printFunction
end

TurtleCraft.print = function (message)
    TurtleCraft.printFn(message)
end

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
    if not vault or not item or not item.name then
        return 0, "Invalid parameters"
    end
    return vault.moveItem(dropper, item.name, amount)
end

TurtleCraft.moveMarkItemToOutputChest = function(item, amount)
    if not vault or not item or not item.name then
        return 0, "Invalid parameters"
    end
    return vault.moveItem(chest, item.name, amount)
end

TurtleCraft.getInputFromBuffer = function(slot, count)
    turtle.select(slot)
    return turtle.suckUp(count)
end


TurtleCraft.prepareItem = function(params)
    
    local movedMarkItemCount, err = TurtleCraft.moveMarkItemToOutputChest(params.markItem, params.inputAmt)
    if movedMarkItemCount <= 0 then
        TurtleCraft.print("Failed to move marked item to output chest: " .. (err or "unknown error"))
        return false
    end

    TurtleCraft.saveStep(STEPS.PREPARE_ITEM, params)
    for idx, input in ipairs(params.recipe.input) do
        if input and input.name then
            local movedItemCount, err = TurtleCraft.moveCraftingItemToBuffer(input, params.inputAmt)
            if movedItemCount <= 0 then
                TurtleCraft.print("Failed to move crafting item to buffer: " .. (err or "unknown error"))
                return false
            end
            local gotCount, err = TurtleCraft.getInputFromBuffer(CRAFTING_SLOT[idx], movedItemCount)
            if not gotCount then
                TurtleCraft.print("Failed to get input from buffer: " .. (err or "unknown error"))
                return false
            end
        end
    end
    return true
end

TurtleCraft.checkingInput = function(params)
    TurtleCraft.saveStep(STEPS.CHECKING, params)
    for index, slot in ipairs(CRAFTING_SLOT) do
        local item = turtle.getItemDetail(slot)
        if params.recipe.input[index] and params.recipe.input[index].name then
            if not item or item.name ~= params.recipe.input[index].name or item.count ~= params.inputAmt then
                TurtleCraft.print("Input slot " .. index .. " has incorrect item or amount")
                return false
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
                TurtleCraft.print("Failed to drop item from slot " .. i)
                return false
            end
        end
    end
    return true
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
    if not params.isRecovering and outputItem and outputItem.count ~= requireOutputCount then
        TurtleCraft.print("Output item count mismatch: expected " .. requireOutputCount .. ", got " .. outputItem.count)
        return false
    elseif params.isRecovering then
        requireOutputCount = outputItem and outputItem.count or 0
    end
    TurtleCraft.print("Moving output item: " .. (outputItem and outputItem.name or "none") .. ", count: " .. (outputItem and outputItem.count or 0))
    TurtleCraft.saveStep(STEPS.PROVIDER_TAKE_OUTPUT, params)
    local totalMoved = 0
    local tryCount = 0
    while totalMoved < requireOutputCount do
        local movedCount, err = partternProvider.takeItem(chest, params.recipe.output.name, requireOutputCount - totalMoved)
        if movedCount <= 0 then
            tryCount = tryCount + 1
        else
            tryCount = 0  -- Reset try count on successful move
        end
        if tryCount > 5 then
            TurtleCraft.print("Failed to move output item after multiple attempts: " .. (err or "unknown error"))
            return false
        end
        totalMoved = totalMoved + movedCount
        if movedCount > 0 then
            TurtleCraft.print("Moved " .. movedCount .. " " .. params.recipe.output.name .. " (total: " .. totalMoved .. "/" .. requireOutputCount .. ")")
        end
    end
    TurtleCraft.print("Moved all output items to pattern provider: " .. params.recipe.output.name)
    
    -- Move mark item back to pattern provider if it exists
    if markItem then
        local totalMovedMarkCount = 0
        local tryCountMark = 0
        local requireMarkCount = markItem.count
        while totalMovedMarkCount < requireMarkCount do
            local movedMarkCount, err = partternProvider.takeItem(chest, params.recipe.mark.name, requireMarkCount - totalMovedMarkCount)
            if movedMarkCount <= 0 then
                tryCountMark = tryCountMark + 1
            else
                tryCountMark = 0  -- Reset try count on successful move
            end
            if tryCountMark > 5 then
                TurtleCraft.print("Failed to move mark item after multiple attempts: " .. (err or "unknown error"))
                return false
            end
            totalMovedMarkCount = totalMovedMarkCount + movedMarkCount
            if movedMarkCount > 0 then
                TurtleCraft.print("Moved " .. movedMarkCount .. " " .. params.recipe.mark.name .. " (total: " .. totalMovedMarkCount .. "/" .. requireMarkCount .. ")")
            end
        end 
        TurtleCraft.print("Moved all mark items to pattern provider: " .. params.recipe.mark.name)
    end
    return true
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
    if save then
        step = save.step or 0
    else
        params.inputAmt = math.min(16, params.markItem.count)
        if params.inputAmt <= 0 then
            TurtleCraft.print("No marked item available for crafting:")
            return false
        end
    end
    
    if step <= STEPS.PREPARE_ITEM then
        TurtleCraft.print("Preparing items for crafting...")
        local success = TurtleCraft.prepareItem(params)
        if not success then
            return false
        end
    end
    if step <= STEPS.CHECKING then
        TurtleCraft.print("Checking input items...")
        local success = TurtleCraft.checkingInput(params)
        if not success then
            return false
        end
    end
    if step <= STEPS.CRAFT then
        TurtleCraft.print("Crafting items...")
        local success = TurtleCraft.craft(params)
        if not success then
            return false
        end
    end
    if step <= STEPS.DROP_OUTPUT then
        TurtleCraft.print("Dropping output items...")
        local success = TurtleCraft.dropOutput(params)
        if not success then
            return false
        end
    end
    if step <= STEPS.PROVIDER_TAKE_OUTPUT then
        TurtleCraft.print("Moving output item to pattern provider...")
        local success = TurtleCraft.moveOutputItem(params)
        if not success then
            return false
        end
    end
    TurtleCraft.saveStep(nil, nil)
    TurtleCraft.print("Crafting process completed successfully")
    return true
end

TurtleCraft.hasUnfinishedJob = function()
    local save = TurtleCraft.readStep()
    if not save or not save.step then
        return false
    end
    TurtleCraft.print("Found unfinished job with step: " .. save.step)
    if save.step == STEPS.PREPARE_ITEM then
        TurtleCraft.clear()
    end
    if save.step == STEPS.CRAFT then
        local success = TurtleCraft.checkingInput(save.params)

        if not success then
            save.step = STEPS.DROP_OUTPUT
            TurtleCraft.saveStep(STEPS.DROP_OUTPUT, save.params)
            return true, save
        end
    end
    if save.step == STEPS.PROVIDER_TAKE_OUTPUT then
        save.params.isRecovering = true
        return true, save
    end
    return true, save
end

TurtleCraft.listen = function(getMarkTable)
    while true do 
        local waitTime = 3

        local hasUnfinished, save = TurtleCraft.hasUnfinishedJob()
        if hasUnfinished then
            local success = TurtleCraft.process(save.params, save)
            if success then
                waitTime = 0.2
            else
                -- Don't clear here - let the save state handle recovery on next iteration
                waitTime = 1  -- Short wait before retry
            end
        else
            local vaultItems = vault.listItem()
            if vaultItems and #vaultItems > 0 then
                local markTables = getMarkTable()
                if markTables then
                    local hasMarked, markItem, recipe = TurtleCraft.hasMarkedItems(vaultItems, markTables)
                    if hasMarked then
                        waitTime = 0.2
                        local success = TurtleCraft.process({markItem = markItem, recipe = recipe})
                        if not success then
                            TurtleCraft.print("Processing failed")
                            TurtleCraft.clear()
                            waitTime = 1
                        end
                    end
                end
            end
        end

        os.sleep(waitTime)
    end
end

return TurtleCraft