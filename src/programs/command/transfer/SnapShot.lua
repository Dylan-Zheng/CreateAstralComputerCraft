local PeripheralWrapper = require("wrapper.PeripheralWrapper")

local PeripheralSnapShot = {
    inventories = {},
    tanks = {},
    items = {},
    fluids = {}
}

-- Helper function to add items to snapshot
local function addItemsToSnapshot(peripheral, itemsTable)
    if not peripheral.getItems then return end
    
    local items = peripheral.getItems()
    for _, item in ipairs(items) do
        itemsTable[item.name] = true
    end
end

-- Helper function to add fluids to snapshot
local function addFluidsToSnapshot(peripheral, fluidsTable)
    if not peripheral.getFluids then return end
    
    local fluids = peripheral.getFluids()
    for _, fluid in ipairs(fluids) do
        fluidsTable[fluid.name] = true
    end
end

function PeripheralSnapShot:takeSnapShot()
    -- Reload all peripherals first
    PeripheralWrapper.reloadAll()
    
    local allPeripherals = PeripheralWrapper.getAll()

    for name, peripheral in pairs(allPeripherals) do
        if peripheral.isInventory() then
            self.inventories[name] = true
            addItemsToSnapshot(peripheral, self.items)
        end

        if peripheral.isTank() then
            self.tanks[name] = true
            addFluidsToSnapshot(peripheral, self.fluids)
        end
    end
end

return PeripheralSnapShot

