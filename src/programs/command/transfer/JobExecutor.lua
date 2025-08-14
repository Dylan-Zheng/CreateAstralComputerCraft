local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local Logger = require("utils.Logger")

local JobExecutor = {}

JobExecutor.executableJobs = {}

-- Helper function to match peripheral names with wildcards
local function matchWildcard(pattern, name)
    if not pattern:find("*") then
        return pattern == name
    end
    
    -- Convert wildcard pattern to lua pattern
    local luaPattern = pattern:gsub("%*", ".*")
    luaPattern = "^" .. luaPattern .. "$"
    
    return name:match(luaPattern) ~= nil
end

-- Helper function to find peripherals matching a pattern
local function findMatchingPeripherals(pattern, allPeripherals)
    local matches = {}
    for name, peripheral in pairs(allPeripherals) do
        if matchWildcard(pattern, name) then
            matches[name] = peripheral
        end
    end
    return matches
end

-- Helper function to check if an item/fluid should be transferred based on filters
local function shouldTransferItem(itemName, itemFilter, isBlacklist)
    if not itemFilter or #itemFilter == 0 then
        return true
    end
    
    local isInFilter = false
    -- Check if item name matches any filter pattern
    for _, filterPattern in ipairs(itemFilter) do
        if matchWildcard(filterPattern, itemName) then
            isInFilter = true
            break
        end
    end
    
    -- Apply blacklist/whitelist logic
    return isBlacklist and not isInFilter or not isBlacklist and isInFilter
end

local transferItems = function(inputInventories, outputInventories, itemFilter, isBlacklist)
    for inputName, inputPeripheral in pairs(inputInventories) do
        local items = inputPeripheral.getItems()
        for _, item in ipairs(items) do
            if shouldTransferItem(item.name, itemFilter, isBlacklist) then
                local toTransfer = item.count
                for outputName, outputPeripheral in pairs(outputInventories) do
                    -- Attempt to transfer the item
                    Logger.debug("Transferring item: {} x{}", item.name, item.count)
                    while true do
                        local transferred = inputPeripheral.transferItemTo(outputPeripheral, item.name, toTransfer)
                        toTransfer = toTransfer - transferred
                        if transferred == 0 then
                            break -- Move to next item after no more can be transferred
                        end
                    end
                    if toTransfer <= 0 then
                        break -- All items transferred, move to next item
                    end
                end
            end
        end
    end
end

local transferFluids = function(inputTanks, outputTanks, fluidFilter, isBlacklist)
    for inputName, inputPeripheral in pairs(inputTanks) do
        local fluids = inputPeripheral.getFluids()
        for _, fluid in ipairs(fluids) do
            if shouldTransferItem(fluid.name, fluidFilter, isBlacklist) then
                for outputName, outputPeripheral in pairs(outputTanks) do
                    -- Attempt to transfer the fluid
                    while true do
                        local transferred = inputPeripheral.transferFluidTo(outputPeripheral, fluid.name, fluid.amount)
                        if transferred == 0 then
                            break -- Move to next fluid after no more can be transferred
                        end
                    end
                end
            end
        end
    end
end

function JobExecutor.load(jobsData)

    if not jobsData then
        return
    end

    PeripheralWrapper.reloadAll()
    local peripheral = PeripheralWrapper.getAll()
    
    for jobName, job in pairs(jobsData) do
        -- Only process enabled jobs
        if job.enabled then

            local inputInventoriesPeripheral = {}
            local outputInventoriesPeripheral = {}
            local inputTanksPeripheral = {}
            local outputTanksPeripheral = {}

            -- Process input inventories with wildcard support
            if job.inputInventories then
                for _, inventoryPattern in ipairs(job.inputInventories) do
                    local matches = findMatchingPeripherals(inventoryPattern, peripheral)
                    for name, periph in pairs(matches) do
                        inputInventoriesPeripheral[name] = periph
                    end
                end
            end

            -- Process output inventories with wildcard support
            if job.outputInventories then
                for _, inventoryPattern in ipairs(job.outputInventories) do
                    local matches = findMatchingPeripherals(inventoryPattern, peripheral)
                    for name, periph in pairs(matches) do
                        outputInventoriesPeripheral[name] = periph
                    end
                end
            end

            -- Process input tanks with wildcard support
            if job.inputTanks then
                for _, tankPattern in ipairs(job.inputTanks) do
                    local matches = findMatchingPeripherals(tankPattern, peripheral)
                    for name, periph in pairs(matches) do
                        inputTanksPeripheral[name] = periph
                    end
                end
            end

            -- Process output tanks with wildcard support
            if job.outputTanks then
                for _, tankPattern in ipairs(job.outputTanks) do
                    local matches = findMatchingPeripherals(tankPattern, peripheral)
                    for name, periph in pairs(matches) do
                        outputTanksPeripheral[name] = periph
                    end
                end
            end

            JobExecutor.executableJobs[jobName] = {
                enable = true,
                exec = function() 
                    -- Prepare filters
                    local itemFilter = job.filters or {}
                    local isBlacklist = job.isFilterBlacklist or false
                    
                    -- Transfer items if there are inventories configured
                    if next(inputInventoriesPeripheral) and next(outputInventoriesPeripheral) then
                        transferItems(inputInventoriesPeripheral, outputInventoriesPeripheral, itemFilter, isBlacklist)
                    end
                    
                    -- Transfer fluids if there are tanks configured
                    if next(inputTanksPeripheral) and next(outputTanksPeripheral) then
                        transferFluids(inputTanksPeripheral, outputTanksPeripheral, itemFilter, isBlacklist)
                    end
                end
            }
        else 
            JobExecutor.executableJobs[jobName] = nil
        end
    end
end

function JobExecutor.run()
    for jobName, job in pairs(JobExecutor.executableJobs) do
        if job.enable then
            local success, error = pcall(job.exec)
            if not success then
                job.enable = false  -- Disable job on error
                print(string.format("Job '%s' encountered an error and has been disabled: %s", jobName, error))
            end
        end
    end
end

return JobExecutor