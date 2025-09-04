local Logger = require("utils.Logger")

local PeripheralWrapper = {}

local TYPES = {
    DEFAULT_INVENTORY = 1,
    UNLIMITED_PERIPHERAL_INVENTORY = 2,
    TANK = 3,
    REDSTONE = 4,
}

PeripheralWrapper.SIDES = {
    "top",
    "bottom",
    "left",
    "right",
    "front",
    "back"
}

PeripheralWrapper.loadedPeripherals = {}

PeripheralWrapper.wrap = function(peripheralName)
    if peripheralName == nil or peripheralName == "" then
        error("Peripheral name cannot be nil or empty")
    end

    local wrappedPeripheral = peripheral.wrap(peripheralName)
    PeripheralWrapper.addBaseMethods(wrappedPeripheral, peripheralName)

    if wrappedPeripheral == nil then
        error("Failed to wrap peripheral '" .. peripheralName .. "'")
    end

    if wrappedPeripheral.isInventory() then
        PeripheralWrapper.addInventoryMethods(wrappedPeripheral)
    end

    if wrappedPeripheral.isTank() then
        PeripheralWrapper.addTankMethods(wrappedPeripheral)
    end

    if wrappedPeripheral.isRedstone() then
        PeripheralWrapper.addRedstoneMethods(wrappedPeripheral)
    end

    return wrappedPeripheral
end


PeripheralWrapper.addBaseMethods = function(peripheral, peripheralName)
    if peripheral == nil then
        error("Peripheral cannot be nil")
    end

    if peripheral.getTypes == nil then
        peripheral._types = PeripheralWrapper.getTypes(peripheral)
        peripheral.getTypes = function()
            return peripheral._types
        end
    end

    if peripheral.isTypeOf == nil then
        peripheral.isTypeOf = function(type)
            return PeripheralWrapper.isTypeOf(peripheral, type)
        end
    end

    peripheral._id = peripheralName
    peripheral.getName = function()
        return peripheral._id
    end

    peripheral.getId = function()
        return peripheral._id
    end

    peripheral._isInventory = PeripheralWrapper.isInventory(peripheral)
    peripheral.isInventory = function()
        return peripheral._isInventory
    end

    peripheral._isTank = PeripheralWrapper.isTank(peripheral)
    peripheral.isTank = function()
        return peripheral._isTank
    end

    peripheral._isRedstone = PeripheralWrapper.isRedstone(peripheral)
    peripheral.isRedstone = function()
        return peripheral._isRedstone
    end

    peripheral._isDefaultInventory = PeripheralWrapper.isTypeOf(peripheral, TYPES.DEFAULT_INVENTORY)
    peripheral.isDefaultInventory = function()
        return peripheral._isDefaultInventory
    end

    peripheral._isUnlimitedPeripheralInventory = PeripheralWrapper.isTypeOf(peripheral,
        TYPES.UNLIMITED_PERIPHERAL_INVENTORY)
    peripheral.isUnlimitedPeripheralInventory = function()
        return peripheral._isUnlimitedPeripheralInventory
    end
end


PeripheralWrapper.addInventoryMethods = function(peripheral)
    -- add for DEFAULT_INVENTORY
    if PeripheralWrapper.isTypeOf(peripheral, TYPES.DEFAULT_INVENTORY) then
        -- add getItems method
        peripheral.getItems = function()
            local itemsTable = {}
            local items = {}
            for _, item in pairs(peripheral.list()) do
                if itemsTable[item.name] == nil then
                    itemsTable[item.name] = {
                        name = item.name,
                        count = 0,
                    }
                    table.insert(items, itemsTable[item.name])
                end
                itemsTable[item.name].count = itemsTable[item.name].count + item.count
            end
            return items, itemsTable
        end

        peripheral.getItem = function(item_name)
            local _, itemsTable = peripheral.getItems()
            if itemsTable[item_name] then
                return itemsTable[item_name]
            end
            return nil
        end

        -- add transferItemTo method (renamed from pushItems)
        peripheral.transferItemTo = function(toPeripheral, itemName, amount)
            if toPeripheral.isDefaultInventory() then
                local size = peripheral.size()
                local totalTransferred = 0
                for slot = 1, size do
                    local item = peripheral.getItemDetail(slot)
                    if item ~= nil and item.name == itemName then
                        local toTransfer = math.min(item.count, amount)
                        local transferred = peripheral.pushItems(toPeripheral.getName(), slot, toTransfer)
                        if transferred == 0 then
                            return totalTransferred
                        end
                        totalTransferred = totalTransferred + transferred
                        amount = amount - transferred
                    end
                    if amount <= 0 then
                        return totalTransferred
                    end
                end
                return totalTransferred
            elseif toPeripheral.isUnlimitedPeripheralInventory() then
                local totalTransferred = 0
                while totalTransferred < amount do
                    local transferred = toPeripheral.pullItem(peripheral.getName(), itemName, amount - totalTransferred)
                    if transferred == 0 then
                        return totalTransferred
                    end
                    totalTransferred = totalTransferred + transferred
                end
                return totalTransferred
            end
            return 0
        end

        -- add transferItemFrom method (renamed from pullItems)
        peripheral.transferItemFrom = function(fromPeripheral, itemName, amount)
            if fromPeripheral.isDefaultInventory() then
                local size = fromPeripheral.size()
                local totalTransferred = 0
                for slot = 1, size do
                    local item = fromPeripheral.getItemDetail(slot)
                    if item ~= nil and item.name == itemName then
                        local transferred = peripheral.pullItems(fromPeripheral.getName(), slot, amount)
                        if transferred == 0 then
                            return totalTransferred
                        end
                        totalTransferred = totalTransferred + transferred
                        amount = amount - transferred
                    end
                    if amount <= 0 then
                        return totalTransferred
                    end
                end
                return totalTransferred
            elseif fromPeripheral.isUnlimitedPeripheralInventory() then
                local totalTransferred = 0
                while totalTransferred < amount do
                    local transferred = fromPeripheral.pushItem(peripheral.getName(), itemName, amount - totalTransferred)
                    if transferred == 0 then
                        return totalTransferred
                    end
                    totalTransferred = totalTransferred + transferred
                end
                return totalTransferred
            end
        end
        -- for UNLIMITED_PERIPHERAL_INVENTORY
    elseif peripheral.isUnlimitedPeripheralInventory() then
        if string.find(peripheral.getName(), "crafting_storage") or peripheral.getPatternsFor ~= nil then
            peripheral.isUnlimitedPeripheralSpecificInventory = true

            peripheral.getItems = function()
                local items = peripheral.items()
                for _, item in ipairs(items) do
                    item.displayName = item.name
                    item.name = item.technicalName
                end
                return items
            end

            peripheral.getItemFinder = function(item_name)
                local cacheIndex = nil
                return function()
                    local items = peripheral.items()
                    if not items or #items == 0 then
                        return nil -- No items in the container
                    end
                    if cacheIndex ~= nil and items[cacheIndex] and items[cacheIndex].technicalName == item_name then
                        local item, index = items[cacheIndex], cacheIndex
                        item.displayName = item.name
                        item.name = item.technicalName
                        return item, index
                    end
                    -- If cache is invalid or not set, find the item in the list again
                    for index, item in ipairs(items) do
                        if item.technicalName == item_name then
                            cacheIndex = index -- Cache the index for future calls
                            item.displayName = item.name
                            item.name = item.technicalName
                            return item, cacheIndex -- Return the found item
                        end
                    end
                    return nil
                end
            end
        else
            peripheral.getItems = function()
                return peripheral.items()
            end

            peripheral.getItemFinder = function(item_name)
                local cacheIndex = nil
                return function()
                    local items = peripheral.items()
                    if not items or #items == 0 then
                        return nil -- No items in the container
                    end
                    if cacheIndex ~= nil and items[cacheIndex] and items[cacheIndex].name == item_name then
                        local item, index = items[cacheIndex], cacheIndex
                        return item, index
                    end
                    -- If cache is invalid or not set, find the item in the list again
                    for index, item in ipairs(items) do
                        if item.name == item_name then
                            cacheIndex = index      -- Cache the index for future calls
                            return item, cacheIndex -- Return the found item
                        end
                    end
                    return nil
                end
            end
        end

        peripheral._itemFinders = {}
        peripheral.getItem = function(item_name)
            if peripheral._itemFinders[item_name] == nil then
                peripheral._itemFinders[item_name] = peripheral.getItemFinder(item_name)
            end
            return peripheral._itemFinders[item_name]()
        end

        peripheral.transferItemTo = function(toPeripheral, itemName, amount)
            if toPeripheral.isUnlimitedPeripheralSpecificInventory then
                return toPeripheral.transferItemFrom(peripheral, itemName, amount)
            else
                local totalTransferred = 0
                while totalTransferred < amount do
                    local transferred = peripheral.pushItem(toPeripheral.getName(), itemName, amount - totalTransferred)
                    if transferred == 0 then
                        return totalTransferred
                    end
                    totalTransferred = totalTransferred + transferred
                end
                return totalTransferred
            end
        end

        peripheral.transferItemFrom = function(fromPeripheral, itemName, amount)
            if fromPeripheral.isUnlimitedPeripheralSpecificInventory then
                return fromPeripheral.transferItemTo(peripheral, itemName, amount)
            else
                local totalTransferred = 0
                while totalTransferred < amount do
                    local transferred = peripheral.pullItem(fromPeripheral.getName(), itemName, amount - totalTransferred)
                    if transferred == 0 then
                        return totalTransferred
                    end
                    totalTransferred = totalTransferred + transferred
                end
                return totalTransferred
            end
        end
    else
        error("Peripheral " ..
            peripheral.getName() ..
            " types " .. table.concat(PeripheralWrapper.getTypes(peripheral), ", ") .. " is not an inventory")
    end
end

PeripheralWrapper.addTankMethods = function(peripheral)
    if peripheral == nil then
        error("Peripheral cannot be nil")
    end

    if not PeripheralWrapper.isTank(peripheral) then
        error("Peripheral is not a tank")
    end

    peripheral.getFluids = function()
        local fluidTable = {}
        local fluids = {}
        for _, tank in pairs(peripheral.tanks()) do
            if fluidTable[tank.name] == nil then
                fluidTable[tank.name] = {
                    name = tank.name,
                    amount = 0,
                }
                table.insert(fluids, fluidTable[tank.name])
            end
            fluidTable[tank.name].amount = fluidTable[tank.name].amount + tank.amount
        end
        return fluids
    end

    peripheral.getFluidFinder = function(fluid_name)
        local cacheIndex = nil
        return function()
            local fluids = peripheral.tanks()
            if not fluids or #fluids == 0 then
                return nil -- No items in the container
            end
            if cacheIndex ~= nil and fluids[cacheIndex] and fluids[cacheIndex].name == fluid_name then
                return fluids[cacheIndex], cacheIndex
            end
            -- If cache is invalid or not set, find the item in the list again
            for index, fluid in ipairs(fluids) do
                if fluid.name == fluid_name then
                    cacheIndex = index       -- Cache the index for future calls
                    return fluid, cacheIndex -- Return the found item
                end
            end
            return nil
        end
    end

    peripheral._fluidFinders = {}
    peripheral.getFluid = function(fluidName)
        if peripheral._fluidFinders[fluidName] == nil then
            peripheral._fluidFinders[fluidName] = peripheral.getFluidFinder(fluidName)
        end
        return peripheral._fluidFinders[fluidName]()
    end

    peripheral.transferFluidTo = function(toPeripheral, fluidName, amount, rateLimit)
        if toPeripheral.isTank() == false then
            error(string.format("Peripheral '%s' is not a tank", toPeripheral.getName()))
        end
        local totalTransferred = 0
        while totalTransferred < amount do
            local transferAmount = rateLimit ~= nil and rateLimit or (amount - totalTransferred)
            local transferred = peripheral.pushFluid(toPeripheral.getName(), transferAmount, fluidName)
            if transferred == 0 then
                return totalTransferred
            end
            totalTransferred = totalTransferred + transferred
        end
        return totalTransferred
    end

    peripheral.transferFluidFrom = function(fromPeripheral, fluidName, amount)
        if fromPeripheral.isTank() == false then
            error(string.format("Peripheral '%s' is not a tank", fromPeripheral.getName()))
        end
        local totalTransferred = 0
        while totalTransferred < amount do
            local transferred = peripheral.pullFluid(fromPeripheral.getName(), amount - totalTransferred, fluidName)
            if transferred == 0 then
                return totalTransferred
            end
            totalTransferred = totalTransferred + transferred
        end
        return totalTransferred
    end
end

PeripheralWrapper.addRedstoneMethods = function(peripheral)
    if peripheral == nil then
        error("Peripheral cannot be nil")
    end

    if not PeripheralWrapper.isRedstone(peripheral) then
        error("Peripheral is not a redstone peripheral")
    end

    peripheral.setOutputSignals = function(isEmited, ...)
        local sides = { ... }
        if not sides or #sides == 0 then
            sides = PeripheralWrapper.SIDES
        end
        for _, side in ipairs(sides) do
            if peripheral.getOutput(side) ~= isEmited then
                peripheral.setOutput(side, isEmited)
            end
        end
    end

    peripheral.getInputSignals = function(...)
        local sides = { ... }
        if not sides or #sides == 0 then
            sides = PeripheralWrapper.SIDES
        end
        for _, side in ipairs(sides) do
            if peripheral.getInput(side) then
                return true
            end
        end
        return false
    end

    peripheral.getOutputSignals = function(...)
        local sides = { ... }
        if not sides or #sides == 0 then
            sides = PeripheralWrapper.SIDES
        end
        local signals = {}
        for _, side in ipairs(sides) do
            signals[side] = peripheral.getOutput(side)
        end
        return signals
    end
end

PeripheralWrapper.getTypes = function(peripheral)
    if peripheral._types ~= nil then
        return peripheral._types
    end
    local types = {}
    if peripheral.list ~= nil then
        table.insert(types, TYPES.DEFAULT_INVENTORY)
    end
    if peripheral.items ~= nil then
        table.insert(types, TYPES.UNLIMITED_PERIPHERAL_INVENTORY)
    end
    if peripheral.tanks ~= nil then
        table.insert(types, TYPES.TANK)
    end
    if peripheral.getInput ~= nil then
        table.insert(types, TYPES.REDSTONE)
    end
    peripheral._types = types
    return types
end

PeripheralWrapper.isInventory = function(peripheral)
    local types = PeripheralWrapper.getTypes(peripheral)
    if peripheral._isInventory ~= nil then
        return peripheral._isInventory
    end
    for _, t in ipairs(types) do
        if t == TYPES.DEFAULT_INVENTORY or t == TYPES.UNLIMITED_PERIPHERAL_INVENTORY then
            peripheral._isInventory = true
            return true
        end
    end
    peripheral._isInventory = false
    return false
end

PeripheralWrapper.isTank = function(peripheral)
    local types = PeripheralWrapper.getTypes(peripheral)
    if peripheral._isTank ~= nil then
        return peripheral._isTank
    end
    for _, t in ipairs(types) do
        if t == TYPES.TANK then
            peripheral._isTank = true
            return true
        end
    end
    peripheral._isTank = false
    return false
end

PeripheralWrapper.isRedstone = function(peripheral)
    local types = PeripheralWrapper.getTypes(peripheral)
    if peripheral._isRedstone ~= nil then
        return peripheral._isRedstone
    end
    for _, t in ipairs(types) do
        if t == TYPES.REDSTONE then
            peripheral._isRedstone = true
            return true
        end
    end
    peripheral._isRedstone = false
    return false
end

PeripheralWrapper.isTypeOf = function(peripheral, type)
    if peripheral == nil then
        error("Peripheral cannot be nil")
    end
    if type == nil then
        error("Type cannot be nil")
    end
    local types = PeripheralWrapper.getTypes(peripheral)
    for _, t in ipairs(types) do
        if t == type then
            return true
        end
    end
    return false
end

PeripheralWrapper.addPeripherals = function(peripheralName)
    if peripheralName == nil then
        error("Peripheral name cannot be nil")
    end
    local p = PeripheralWrapper.wrap(peripheralName)
    if p ~= nil then
        PeripheralWrapper.loadedPeripherals[peripheralName] = p
    end
end

PeripheralWrapper.reloadAll = function()
    PeripheralWrapper.loadedPeripherals = {}
    for _, name in ipairs(peripheral.getNames()) do
        Logger.debug("Loading peripheral: {}", name)
        PeripheralWrapper.addPeripherals(name)
    end
end

PeripheralWrapper.getAll = function()
    if PeripheralWrapper.loadedPeripherals == nil then
        PeripheralWrapper.reloadAll()
    end
    return PeripheralWrapper.loadedPeripherals
end

PeripheralWrapper.getByName = function(peripheralName)
    if peripheralName == nil then
        error("Peripheral name cannot be nil")
    end
    if PeripheralWrapper.loadedPeripherals[peripheralName] == nil then
        PeripheralWrapper.addPeripherals(peripheralName)
    end
    return PeripheralWrapper.loadedPeripherals[peripheralName]
end

PeripheralWrapper.getByTypes = function(types)
    if types == nil or #types == 0 then
        error("Types cannot be nil or empty")
    end
    local matchedPeripherals = {}
    for name, peripheral in pairs(PeripheralWrapper.getAll()) do
        for _, t in ipairs(types) do
            if PeripheralWrapper.isTypeOf(peripheral, t) then
                matchedPeripherals[name] = peripheral
                break
            end
        end
    end
    return matchedPeripherals
end

PeripheralWrapper.getAllPeripheralsNameContains = function(partOfName)
    if partOfName == nil or partOfName == "" then
        error("Part of name input cannot be nil or empty")
    end
    local matchedPeripherals = {}
    for name, peripheral in pairs(PeripheralWrapper.getAll()) do
        if string.find(name, partOfName) then
            matchedPeripherals[name] = peripheral
        end
    end
    return matchedPeripherals
end

return PeripheralWrapper
