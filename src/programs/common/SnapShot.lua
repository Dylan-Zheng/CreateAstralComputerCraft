local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local Logger = require("utils.Logger")

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
    if not items then return end
    for _, item in ipairs(items) do
        if item.name then
            itemsTable[item.name] = true
        end
    end
end

-- Helper function to add fluids to snapshot
local function addFluidsToSnapshot(peripheral, fluidsTable)
    if not peripheral.getFluids then return end
    
    local fluids = peripheral.getFluids()
    if not fluids then return end
    for _, fluid in ipairs(fluids) do
        if fluid.name then
            fluidsTable[fluid.name] = true
        end
    end
end

-- Helper function to load names from file
local function loadNamesFromFile(filename, targetTable)
    if not fs.exists(filename) then return false end
    
    local file = fs.open(filename, "r")
    if not file then return false end
    
    local count = 0
    while true do
        local line = file.readLine()
        if not line then break end
        
        -- Trim whitespace and skip empty lines
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            targetTable[line] = true
            count = count + 1
        end
    end
    
    file.close()
    return true, count
end

function PeripheralSnapShot.takeSnapShot()
    -- Reload all peripherals first
    PeripheralWrapper.reloadAll()
    
    local allPeripherals = PeripheralWrapper.getAll()

    for name, peripheral in pairs(allPeripherals) do
        if peripheral.isInventory() then
            PeripheralSnapShot.inventories[name] = true
            addItemsToSnapshot(peripheral, PeripheralSnapShot.items)
        end

        if peripheral.isTank() then
            PeripheralSnapShot.tanks[name] = true
            addFluidsToSnapshot(peripheral, PeripheralSnapShot.fluids)
        end
    end

    -- Load items and fluids from files if they exist
    PeripheralSnapShot.loadFromFiles()
end

-- Load item and fluid names from files
function PeripheralSnapShot.loadFromFiles()
    -- Load items from item_names file
    loadNamesFromFile("item_names", PeripheralSnapShot.items)
    -- Load fluids from fluid_names file
    loadNamesFromFile("fluid_names", PeripheralSnapShot.fluids)
end

-- Load only from files without scanning peripherals
function PeripheralSnapShot.loadFromFilesOnly()
    -- Clear existing data
    PeripheralSnapShot.items = {}
    PeripheralSnapShot.fluids = {}
    
    -- Load from files
    PeripheralSnapShot.loadFromFiles()
end

-- Reset all snapshot data
function PeripheralSnapShot.reset()
    PeripheralSnapShot.inventories = {}
    PeripheralSnapShot.tanks = {}
    PeripheralSnapShot.items = {}
    PeripheralSnapShot.fluids = {}
end

-- Get item count
function PeripheralSnapShot.getItemCount()
    local count = 0
    for _ in pairs(PeripheralSnapShot.items) do
        count = count + 1
    end
    return count
end

-- Get fluid count
function PeripheralSnapShot.getFluidCount()
    local count = 0
    for _ in pairs(PeripheralSnapShot.fluids) do
        count = count + 1
    end
    return count
end

return PeripheralSnapShot

