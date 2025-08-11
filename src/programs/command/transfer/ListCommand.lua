local SnapShot = require("programs.command.transfer.SnapShot")
local CommandLine = require("programs.command.CommandLine")

local ListCommand = {}

-- Utility function to parse arguments
local function parseArgs(input)
    local args = {}
    for arg in string.gmatch(input, "%S+") do
        table.insert(args, arg)
    end
    return args
end

-- Utility function for pagination
local function paginateResults(results, page, itemsPerPage)
    itemsPerPage = itemsPerPage or 10
    page = page or 1
    
    local startIndex = (page - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #results)
    local totalPages = math.ceil(#results / itemsPerPage)
    
    local pageResults = {}
    for i = startIndex, endIndex do
        table.insert(pageResults, results[i])
    end
    
    return pageResults, page, totalPages, #results
end

-- Convert table keys to array for pagination
local function tableKeysToArray(t)
    local array = {}
    for key, _ in pairs(t) do
        table.insert(array, key)
    end
    table.sort(array) -- Sort alphabetically
    return array
end

-- List command implementation
function ListCommand.execute(input)
    local args = parseArgs(input)
    
    if #args < 2 then
        print("Usage: list <inventory|tank|item|fluid|reload> [page]")
        return
    end
    
    local listType = string.lower(args[2])
    
    if listType == "reload" then
        print("Reloading peripherals and taking snapshot...")
        SnapShot:takeSnapShot()
        print("Reload completed.")
        return
    end
    
    local page = tonumber(args[3]) or 1
    
    if listType == "inventory" then
        -- List all inventories from snapshot
        local inventoryArray = tableKeysToArray(SnapShot.inventories)
        local pageResults, currentPage, totalPages, totalCount = paginateResults(inventoryArray, page)
        
        print(string.format("=== Inventories (Page %d of %d, Total: %d) ===", currentPage, totalPages, totalCount))
        for _, name in ipairs(pageResults) do
            print(string.format("- %s", name))
        end
        
    elseif listType == "tank" then
        -- List all tanks from snapshot
        local tankArray = tableKeysToArray(SnapShot.tanks)
        local pageResults, currentPage, totalPages, totalCount = paginateResults(tankArray, page)

        print(string.format("=== Tanks (Page %d of %d, Total: %d) ===", currentPage, totalPages, totalCount))
        for _, name in ipairs(pageResults) do
            print(string.format("- %s", name))
        end
        
    elseif listType == "item" then
        -- List all items from snapshot
        local itemArray = tableKeysToArray(SnapShot.items)
        local pageResults, currentPage, totalPages, totalCount = paginateResults(itemArray, page)
        
        print(string.format("=== Items (Page %d of %d, Total: %d) ===", currentPage, totalPages, totalCount))
        for _, name in ipairs(pageResults) do
            print(string.format("- %s", name))
        end
        
    elseif listType == "fluid" then
        -- List all fluids from snapshot
        local fluidArray = tableKeysToArray(SnapShot.fluids)
        local pageResults, currentPage, totalPages, totalCount = paginateResults(fluidArray, page)
        
        print(string.format("=== Fluids (Page %d of %d, Total: %d) ===", currentPage, totalPages, totalCount))
        for _, name in ipairs(pageResults) do
            print(string.format("- %s", name))
        end
        
    else
        print("Invalid list type. Use: inventory, tank, item, fluid, or reload")
        print("Usage: list <inventory|tank|item|fluid|reload> [page]")
    end
end

-- Auto-completion for list command
function ListCommand.complete(argsText)
    local args = parseArgs("list " .. argsText)
    local suggestions = {}
    
    if #args == 2 then
        -- Suggest list types
        local types = {"inventory", "tank", "item", "fluid", "reload"}
        return CommandLine.filterSuggestions(types, args[2])
    elseif #args == 3 and string.lower(args[2]) ~= "reload" then
        -- Suggest page numbers (1-10) only if not reload command
        local pageNumbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
        return CommandLine.filterSuggestions(pageNumbers, args[3])
    end
    
    return suggestions
end

return ListCommand
