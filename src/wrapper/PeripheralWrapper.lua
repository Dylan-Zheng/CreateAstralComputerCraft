local Logger = require("utils.Logger")

local PeripheralWrapper = {}

TYPES = {
    DEFAULT_INVENTORY = 1,
    UNLIMITED_PERIPHERAL_INVENTORY = 2,
    TANK = 3,
    REDSTONE = 4,
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

    peripheral._id = peripheralName or peripheral.id or "unknown"
    peripheral.getName = function()
        return peripheral._id
    end

    if peripheral.getID == nil and peripheral.id ~= nil then
        peripheral.getID = function()
            return peripheral._id
        end
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
        return PeripheralWrapper.isInventory(peripheral)
    end

    peripheral._isUnlimitedPeripheralInventory = PeripheralWrapper.isTypeOf(peripheral,
        TYPES.UNLIMITED_PERIPHERAL_INVENTORY)
    peripheral.isUnlimitedPeripheralInventory = function()
        return PeripheralWrapper._isUnlimitedPeripheralInventory
    end
end


PeripheralWrapper.addInventoryMethods = function(peripheral)
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

        -- add transferItemFrom method (renamed from pullItem)
        peripheral.transferItemTo = function(toPeripheral, itemName, amount)
            if toPeripheral.isDefaultInventory() then
                local size = peripheral.size()
                local totalTransferred = 0
                for slot = 1, size do
                    local item = peripheral.getItemDetail(slot)
                    if item ~= nil and item.name == itemName then
                        local transferred = peripheral.pushItems(toPeripheral.getName(), slot, amount)
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
            elseif toPeripheral.isUnlimitedPeripheralInventory() then
                toPeripheral.pullItem(peripheral.getName(), itemName, amount)
            end
        end

        -- add transferItemTo method (renamed from pushItem)
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
            elseif fromPeripheral.isUnlimitedPeripheralInventory() then
                fromPeripheral.pushItem(peripheral.getName(), itemName, amount)
            end
        end
    elseif peripheral.isUnlimitedPeripheralInventory() then
        peripheral.getItems = function()
            return peripheral.items()
        end

        peripheral.transferItemFrom = function(toPeripheral, itemName, amount)
            local transferred = peripheral.pushItem(toPeripheral.getName(), itemName, amount)
            return transferred
        end

        peripheral.transferItemTo = function(fromPeripheral, itemName, amount)
            local transferred = peripheral.pullItem(fromPeripheral.getName(), itemName, amount)
            return transferred
        end
    else
        error("Peripheral is not an inventory")
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
    if peripheral.items ~= nil and peripheral.pullItems ~= nil then
        table.insert(types, TYPES.UNLIMITED_PERIPHERAL_INVENTORY)
    end
    if peripheral.getFluidInTank ~= nil and peripheral.tank ~= nil then
        table.insert(types, TYPES.TANK)
    end
    if peripheral.redstone ~= nil then
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
    for _, name in ipairs(peripheral.getNames()) do
        PeripheralWrapper.addPeripherals(name)
    end
end

PeripheralWrapper.getAll = function()
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

return PeripheralWrapper
