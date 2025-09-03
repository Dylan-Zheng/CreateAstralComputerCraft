local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local CommandLine = require("programs.command.CommandLine")
local OSUtils = require("utils.OSUtils")
local Trigger = require("programs.common.Trigger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local TableUtils = require("utils.TableUtils")
local BlazeBurnerFeederFactory = require("programs.common.BlazeBurnerFeederFactory")
local StoreManager = require("programs.recipe.manager.StoreManager")

Logger.useDefault()
Logger.currentLevel = Logger.levels.ERROR

local args = { ... }

-- Groups storage
local groups = {}

-- Recipes storage
local recipes = {}
local remoteRecipes = {}

-- Recipe-Group links storage
local recipeLinks = {}

-- Load groups from file
local function loadGroups()
    local data = OSUtils.loadTable("cabasin_groups")
    if data ~= nil then
        groups = data
    end
end

-- Save groups to file
local function saveGroups()
    OSUtils.saveTable("cabasin_groups", groups)
end

-- Load recipe-group links from file
local function loadRecipeLinks()
    local data = OSUtils.loadTable("cabasin_recipe_links")
    if data ~= nil then
        recipeLinks = data
    end
end

-- Save recipe-group links to file
local function saveRecipeLinks()
    OSUtils.saveTable("cabasin_recipe_links", recipeLinks)
end

-- Initialize groups and recipe links
loadGroups()
loadRecipeLinks()

-- Load recipes from file
local function loadRecipes()
    local data = OSUtils.loadTable("cabasin_recipes")
    if data ~= nil then
        recipes = data
    end
end

-- Save recipes to file
local function saveRecipes()
    OSUtils.saveTable("cabasin_recipes", recipes)
end

-- Load communicator config from file
local function loadCommunicatorConfig()
    return OSUtils.loadTable("cabasin_communicator_config")
end

-- Save communicator config to file
local function saveCommunicatorConfig(side, channel, secret)
    local config = {
        side = side,
        channel = channel,
        secret = secret
    }
    OSUtils.saveTable("cabasin_communicator_config", config)
end

-- Update recipes by ID
local function updateRecipesByID(newRecipes)
    local recipeMap = {}
    local nameChangeMap = {} -- Track recipe name changes
    
    -- Create a map of existing recipes by ID
    for i, recipe in ipairs(recipes) do
        if recipe.id then
            recipeMap[recipe.id] = i
        end
    end

    -- Update existing recipes or add new ones
    for _, newRecipe in ipairs(newRecipes) do
        if newRecipe.id then
            local existingIndex = recipeMap[newRecipe.id]
            if existingIndex then
                -- Track name changes for link updates
                local oldName = recipes[existingIndex].name
                local newName = newRecipe.name
                if oldName ~= newName then
                    nameChangeMap[oldName] = newName
                end
                
                -- Update existing recipe
                recipes[existingIndex] = newRecipe
            end
        end
    end

    -- Update recipe links based on name changes
    for oldName, newName in pairs(nameChangeMap) do
        if recipeLinks[oldName] then
            local groupName = recipeLinks[oldName]
            recipeLinks[oldName] = nil -- Remove old link
            recipeLinks[newName] = groupName -- Add new link with updated name
        end
    end

    -- Save updated recipes and links
    saveRecipes()
    saveRecipeLinks()
end

local getflattedGroupMachineNames = function(groups)
    local flatted = {}

    for _, group in pairs(groups) do
        for _, basin in ipairs(group.basins) do
            flatted[basin] = true
        end
        for _, burner in ipairs(group.blazeBurners) do
            flatted[burner] = true
        end
        for _, redstone in ipairs(group.redstones or {}) do
            flatted[redstone] = true
        end
    end

    return flatted
end

local getGroupMachineNames = function(flattedExistingGroupMachines)
    local names = peripheral.getNames()
    local basins = {}
    local blazeBurners = {}
    local redstones = {}
    for _, name in pairs(names) do
        if not flattedExistingGroupMachines[name] then
            if name:find("basin") then
                table.insert(basins, name)
            end
            if name:find("blaze_burner") then
                table.insert(blazeBurners, name)
            end
            if name:find("redrouter") then
                table.insert(redstones, name)
            end
        end
    end
    return {
        basins = basins,
        blazeBurners = blazeBurners,
        redstones = redstones
    }
end

-- Display recipes with pagination
local function displayRecipes(recipeList, page, pageSize, location)
    page = page or 1
    pageSize = pageSize or 5
    location = location or "local" -- Default to local for backward compatibility

    if #recipeList == 0 then
        print("No recipes found.")
        return
    end

    local totalPages = math.ceil(#recipeList / pageSize)
    local startIdx = (page - 1) * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, #recipeList)

    print(string.format("=== Basin Recipes (Page %d/%d) ===", page, totalPages))
    for i = startIdx, endIdx do
        local recipe = recipeList[i]
        -- Only display recipe name, consistent with BasinRecipeTab structure
        local recipeName = recipe.name or "Unnamed Recipe"
        local linkedGroup = recipeLinks[recipeName]
        if linkedGroup then
            print(string.format("%d. %s -> [%s]", i, recipeName, linkedGroup))
        else
            print(string.format("%d. %s", i, recipeName))
        end
    end

    if totalPages > 1 then
        print(string.format("Showing %d-%d of %d recipes", startIdx, endIdx, #recipeList))
        if page < totalPages then
            print(string.format("Use 'list recipe %s %d' for next page", location, page + 1))
        end
        if page > 1 then
            print(string.format("Use 'list recipe %s %d' for previous page", location, page - 1))
        end
    end
end

-- Display groups
local function displayGroups()
    if TableUtils.getLength(groups) == 0 then
        print("No groups found.")
        return
    end

    print("=== Basin Groups ===")
    local groupCount = 0
    for name, group in pairs(groups) do
        groupCount = groupCount + 1
        print(string.format("%d. %s - Basins: %d, Burners: %d", groupCount, name, #group.basins, #group.blazeBurners))
    end
end

-- Display recipe-group links
local function displayLinks()
    local linkCount = 0
    for _, _ in pairs(recipeLinks) do
        linkCount = linkCount + 1
    end

    if linkCount == 0 then
        print("No recipe-group links found.")
        return
    end

    print("=== Recipe-Group Links ===")
    for recipeName, groupName in pairs(recipeLinks) do
        print(string.format("%s -> %s", recipeName, groupName))
    end
end

-- Command line interface
local function createCommandLine()
    local cli = CommandLine:new("cabasin> ")

    -- Group command
    cli:addCommand("group", "Manage basin groups", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: group [name]")
            print("Creates a new group with the given name using current basins and blaze burners")
            return
        end

        local groupName = parts[2]

        -- Get current basins and blaze burners

        -- Create group entry
        local group = getGroupMachineNames(getflattedGroupMachineNames(groups))
        groups[groupName] = group

        -- Save to file
        saveGroups()

        print("Group '" .. groupName .. "' created successfully:")
        print("  Name: " .. groupName)
        print("  Basins: " .. #group.basins .. " found")
        for i, basin in ipairs(group.basins) do
            print("    " .. i .. ". " .. basin)
        end
        print("  Blaze Burners: " .. #group.blazeBurners .. " found")
        for i, burner in ipairs(group.blazeBurners) do
            print("    " .. i .. ". " .. burner)
        end
        print("  Redstone Routers: " .. #group.redstones .. " found")
        for i, redstone in ipairs(group.redstones) do
            print("    " .. i .. ". " .. redstone)
        end
    end, function(text)
        -- No completion for group names as they are user-defined
        return {}
    end)

    -- List command - following CADepot pattern
    cli:addCommand("list", "List recipes or groups", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: list [recipe|group|link] [remote|local] [page]")
            print("Examples:")
            print("  list group              - List all groups")
            print("  list link               - List recipe-group links")
            print("  list recipe remote      - List remote recipes")
            print("  list recipe local       - List local recipes")
            print("  list recipe local 2     - List local recipes page 2")
            return
        end

        local listType = parts[2]

        if listType == "group" then
            displayGroups()
        elseif listType == "link" then
            displayLinks()
        elseif listType == "recipe" then
            if #parts < 3 then
                print("Usage: list recipe [remote|local] [page]")
                return
            end

            local location = parts[3]
            local page = tonumber(parts[4]) or 1

            if location == "local" then
                displayRecipes(recipes, page, nil, "local")
            elseif location == "remote" then
                if #remoteRecipes == 0 then
                    print("No remote recipes available.")
                    return
                end
                displayRecipes(remoteRecipes, page, nil, "remote")
            else
                print("Usage: list recipe [remote|local] [page]")
            end
        elseif listType == "link" then
            displayLinks()
        else
            print("Usage: list [recipe|group] [remote|local] [page]")
            print("Available list types: recipe, group")
        end
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end
        local numOfParts = #parts
        if (numOfParts == 0 or numOfParts == 1) and text:sub(-1) ~= " " then
            -- 补全第二个参数 "recipe" or "group" or "link"
            local partial = text:match("%S+$") or ""
            local suggestions = {}
            local options = { "recipe", "group", "link" }
            for _, option in ipairs(options) do
                if option:find(partial, 1, true) == 1 then
                    table.insert(suggestions, option:sub(#partial + 1))
                end
            end
            return suggestions
        elseif (numOfParts == 1 and text:sub(-1) == " ") or numOfParts == 2 then
            -- 如果第二个参数是 "recipe"，补全第三个参数 "remote"/"local" (CADepot order)
            if parts[1] == "recipe" then
                local partial = text:match("%S+$") or ""
                local suggestions = {}
                local options = { "remote", "local" } -- CADepot order: remote first
                for _, option in ipairs(options) do
                    if option:find(partial, 1, true) == 1 then
                        table.insert(suggestions, option:sub(#partial + 1))
                    end
                end
                return suggestions
            end
        end
        return {}
    end)

    -- Add recipe command (from remote by name)
    cli:addCommand("add", "Add recipe from remote by name", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: add [recipe_name]")
            print("Examples:")
            print("  add SteelRecipe            - Add recipe by name")
            print("Use 'list recipe remote' to see available recipes")
            return
        end

        local recipeName = parts[2]

        if #remoteRecipes == 0 then
            print("No remote recipes available. Use network mode to connect first.")
            return
        end

        -- Find remote recipe by name
        local remoteRecipe = nil
        for _, recipe in ipairs(remoteRecipes) do
            if recipe.name == recipeName then
                remoteRecipe = recipe
                break
            end
        end

        if not remoteRecipe then
            print("Remote recipe '" .. recipeName .. "' not found")
            print("Use 'list recipe remote' to see available recipes")
            return
        end

        -- Check if recipe already exists locally
        for _, recipe in ipairs(recipes) do
            if recipe.name == recipeName then
                print("Recipe '" .. recipeName .. "' already exists locally")
                return
            end
        end

        -- Add recipe to local storage (deep copy)
        local newRecipe = {}
        for key, value in pairs(remoteRecipe) do
            if type(value) == "table" then
                newRecipe[key] = {}
                for k, v in pairs(value) do
                    if type(v) == "table" then
                        newRecipe[key][k] = {}
                        for i, item in ipairs(v) do
                            newRecipe[key][k][i] = item
                        end
                    else
                        newRecipe[key][k] = v
                    end
                end
            else
                newRecipe[key] = value
            end
        end

        table.insert(recipes, newRecipe)
        saveRecipes()

        print("Recipe '" .. recipeName .. "' added successfully")
    end, function(text)
        -- Provide completion for remote recipe names
        local suggestions = {}
        local partial = text:match("%S+$") or ""

        for _, recipe in ipairs(remoteRecipes) do
            if recipe.name and recipe.name:find(partial, 1, true) == 1 then
                local suggestion = recipe.name:sub(#partial + 1)
                table.insert(suggestions, suggestion)
            end
        end

        return suggestions
    end)

    -- Link recipe to group command
    cli:addCommand("link", "Link recipe to group", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 3 then
            print("Usage: link [recipe_name] [group_name]")
            print("Examples:")
            print("  link SteelRecipe production      - Link recipe to group")
            return
        end

        local recipeName = parts[2]
        local groupName = parts[3]

        -- Check if recipe exists locally
        local recipeExists = false
        for _, recipe in ipairs(recipes) do
            if recipe.name == recipeName then
                recipeExists = true
                break
            end
        end

        if not recipeExists then
            print("Recipe '" .. recipeName .. "' not found in local recipes")
            print("Use 'list recipe local' to see available recipes")
            return
        end

        -- Check if group exists
        if not groups[groupName] then
            print("Group '" .. groupName .. "' not found")
            print("Use 'list group' to see available groups")
            return
        end

        -- Link recipe to group
        recipeLinks[recipeName] = groupName
        saveRecipeLinks()

        print("Recipe '" .. recipeName .. "' linked to group '" .. groupName .. "' successfully")
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts == 1 then
            -- Provide completion for local recipe names
            local suggestions = {}
            local partial = text:match("%S+$") or ""
            for _, recipe in ipairs(recipes) do
                if recipe.name and recipe.name:find(partial, 1, true) == 1 then
                    local suggestion = recipe.name:sub(#partial + 1)
                    table.insert(suggestions, suggestion)
                end
            end
            return suggestions
        elseif #parts == 2 then
            -- Provide completion for group names
            local suggestions = {}
            local partial = text:match("%S+$") or ""
            for groupName, _ in pairs(groups) do
                if groupName:find(partial, 1, true) == 1 then
                    table.insert(suggestions, groupName:sub(#partial + 1))
                end
            end
            return suggestions
        end
        return {}
    end)

    -- Unlink recipe from group command
    cli:addCommand("unlink", "Unlink recipe from group", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: unlink [recipe_name]")
            print("Examples:")
            print("  unlink SteelRecipe     - Unlink recipe from group")
            return
        end

        local recipeName = parts[2]

        -- Check if recipe is linked
        if not recipeLinks[recipeName] then
            print("Recipe '" .. recipeName .. "' is not linked to any group")
            return
        end

        local oldGroupName = recipeLinks[recipeName]
        recipeLinks[recipeName] = nil
        saveRecipeLinks()

        print("Recipe '" .. recipeName .. "' unlinked from group '" .. oldGroupName .. "' successfully")
    end, function(text)
        -- Provide completion for linked recipe names
        local suggestions = {}
        local partial = text:match("%S+$") or ""
        for recipeName, _ in pairs(recipeLinks) do
            if recipeName:find(partial, 1, true) == 1 then
                local suggestion = recipeName:sub(#partial + 1)
                table.insert(suggestions, suggestion)
            end
        end
        return suggestions
    end)

    -- Delete command (group or recipe)
    cli:addCommand("delete", "Delete group or recipe", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 3 then
            print("Usage: delete [group|recipe] [name]")
            print("Examples:")
            print("  delete group production     - Delete group by name")
            print("  delete recipe SteelRecipe   - Delete recipe by name")
            return
        end

        local deleteType = parts[2]
        local itemName = parts[3]

        if deleteType == "group" then
            -- Check if group exists
            if not groups[itemName] then
                print("Group '" .. itemName .. "' not found")
                print("Use 'list group' to see available groups")
                return
            end

            -- Check if any recipes are linked to this group
            local linkedRecipes = {}
            for recipeName, groupName in pairs(recipeLinks) do
                if groupName == itemName then
                    table.insert(linkedRecipes, recipeName)
                end
            end

            if #linkedRecipes > 0 then
                print("Cannot delete group '" .. itemName .. "' - it has linked recipes:")
                for i, recipeName in ipairs(linkedRecipes) do
                    print("  " .. i .. ". " .. recipeName)
                end
                print("Use 'unlink [recipe_name]' to unlink recipes first")
                return
            end

            -- Delete group
            groups[itemName] = nil
            saveGroups()
            print("Group '" .. itemName .. "' deleted successfully")
        elseif deleteType == "recipe" then
            -- Check if recipe exists locally
            local recipeIndex = nil
            for i, recipe in ipairs(recipes) do
                if recipe.name == itemName then
                    recipeIndex = i
                    break
                end
            end

            if not recipeIndex then
                print("Recipe '" .. itemName .. "' not found in local recipes")
                print("Use 'list recipe local' to see available recipes")
                return
            end

            -- Check if recipe is linked to any group
            if recipeLinks[itemName] then
                print("Cannot delete recipe '" ..
                    itemName .. "' - it is linked to group '" .. recipeLinks[itemName] .. "'")
                print("Use 'unlink " .. itemName .. "' to unlink the recipe first")
                return
            end

            -- Delete recipe
            table.remove(recipes, recipeIndex)
            saveRecipes()
            print("Recipe '" .. itemName .. "' deleted successfully")
        else
            print("Usage: delete [group|recipe] [name]")
            print("Available delete types: group, recipe")
        end
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end

        local numOfParts = #parts
        if (numOfParts == 0 or numOfParts == 1) and text:sub(-1) ~= " " then
            -- Provide completion for delete type: group or recipe
            local suggestions = {}
            local partial = text:match("%S+$") or ""
            local options = { "group", "recipe" }
            for _, option in ipairs(options) do
                if option:find(partial, 1, true) == 1 then
                    table.insert(suggestions, option:sub(#partial + 1))
                end
            end
            return suggestions
        elseif (numOfParts == 1 and text:sub(-1) == " ") or numOfParts == 2 then
            -- Provide completion based on delete type
            local deleteType = parts[1]
            local partial = text:match("%S+$") or ""
            local suggestions = {}

            if deleteType == "group" then
                -- Provide completion for group names
                for groupName, _ in pairs(groups) do
                    if groupName:find(partial, 1, true) == 1 then
                        table.insert(suggestions, groupName:sub(#partial + 1))
                    end
                end
            elseif deleteType == "recipe" then
                -- Provide completion for local recipe names
                for _, recipe in ipairs(recipes) do
                    if recipe.name and recipe.name:find(partial, 1, true) == 1 then
                        local suggestion = recipe.name:sub(#partial + 1)
                        table.insert(suggestions, suggestion)
                    end
                end
            end
            return suggestions
        end
        return {}
    end)

    -- Reboot command
    cli:addCommand("reboot", "Reboot the program", function(input)
        print("Rebooting...")
        os.reboot()
    end)

    return cli
end

-- Initialize recipes
loadRecipes()
local runCommandLine = function()
    local cli = createCommandLine()
    while true do
        local success, result = pcall(function() cli:run() end)
        if not success then
            print("Error: " .. tostring(result))
        end
    end
end

-- Main execution
if args ~= nil and #args > 0 then
    local side = args[1]
    local channel = tonumber(args[2])
    local secret = args[3]

    if side and channel and secret then
        -- Save communicator config
        saveCommunicatorConfig(side, channel, secret)

        -- Network mode
        Communicator.open(side, channel, "recipe", secret)
        local openChannel = Communicator.communicationChannels[side][channel]["recipe"]
        openChannel.addMessageHandler("getRecipesRes", function(eventCode, payload, senderId)
            remoteRecipes = payload or {}
        end)

        parallel.waitForAll(Communicator.listen,
            function()
                while next(remoteRecipes) == nil do
                    openChannel.send("getRecipesReq", "basin")
                    os.sleep(1) -- Wait for response
                end
            end,
            runCommandLine
        )
    end
end

PeripheralWrapper.reloadAll()
local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
local key = next(storages) -- Assuming only one storage is available
local storage = storages[key]



local linkedRecipes = {}
local init = function()
    local recipeMap = {}

    for name, recipe in pairs(recipes) do
        recipeMap[recipe.name] = recipe
    end

    -- Initialize LinkedRecipe with existing links
    for recipeName, groupName in pairs(recipeLinks) do
        linkedRecipes[recipeName] = {
            recipe = recipeMap[recipeName],
        }
        local group = {
            name = groupName,
            basins = {},
            blazeBurnerFeeders = {},
            redstones = {},
        }

        for _, basin in ipairs(groups[groupName].basins) do
            print("Wrapping basin: " .. basin)
            table.insert(group.basins, PeripheralWrapper.wrap(basin))
        end

        for _, blazeBurner in ipairs(groups[groupName].blazeBurners) do
            print("Wrapping blaze burner: " .. blazeBurner)
            local blazeBurner = PeripheralWrapper.wrap(blazeBurner)
            local fuelType    = nil;
            if recipeMap[recipeName].blazeBurner == StoreManager.BLAZE_BURN_TYPE.LAVA then
                fuelType = BlazeBurnerFeederFactory.Types.LAVA
            elseif recipeMap[recipeName].blazeBurner == StoreManager.BLAZE_BURN_TYPE.HELLFIRE then
                fuelType = BlazeBurnerFeederFactory.Types.HELLFIRE
            end
            local feeder = BlazeBurnerFeederFactory.getFeeder(storage, blazeBurner, fuelType)
            table.insert(group.blazeBurnerFeeders, feeder)
        end

        for _, redstone in ipairs(groups[groupName].redstones) do
            print("Wrapping redstone: " .. redstone)
            table.insert(group.redstones, PeripheralWrapper.wrap(redstone))
        end

        linkedRecipes[recipeName].group = group
    end
end

local getItemFromStorage = function(type, itemName)
    if type == "item" then
        return storage.getItem(itemName)
    elseif type == "fluid" then
        return storage.getFluid(itemName)
    end
    return nil
end

local runLink = function(link)
    local recipe = link.recipe
    local group = link.group
    for _, basin in ipairs(group.basins) do
        local input = recipe.input
        if input.items ~= nil then
            -- Transfer items to basin
            for _, itemName in ipairs(input.items) do
                local basinItem = basin.getItem(itemName)
                local count = basinItem and basinItem.count or 0
                if count < 16 then
                    storage.transferItemTo(basin, itemName, 16 - count)
                end
            end
        end
        if input.fluids ~= nil then
            for _, fluidName in ipairs(input.fluids) do
                local basinFluid = basin.getFluid(fluidName)
                local amount = basinFluid and basinFluid.amount or 0
                if amount < 1000 then
                    storage.transferFluidTo(basin, fluidName, 1000 - amount)
                end
            end
        end
        local output = recipe.output
        if output.items ~= nil then
            -- Transfer items from basin to storage
            for _, itemName in ipairs(output.items) do
                local itemKeepAmount = recipe.output.keepItemsAmount or 0
                local item = basin.getItem(itemName)
                if item ~= nil and item.count > itemKeepAmount then
                    storage.transferItemFrom(basin, itemName, item.count - itemKeepAmount)
                end
            end
        end
        if output.fluids ~= nil then
            -- Transfer fluids from basin to storage
            for _, fluidName in ipairs(output.fluids) do
                local fluidKeepAmount = recipe.output.keepFluidsAmount or 0
                local fluid = basin.getFluid(fluidName)
                if fluid ~= nil and fluid.amount > fluidKeepAmount then
                    storage.transferFluidFrom(basin, fluidName, fluid.amount - fluidKeepAmount)
                end
            end
        end
    end
end

local feedBlazeBurners = function(feeders)
    for _, feeder in ipairs(feeders) do
        feeder:feed()
    end
end

local checkAndRunRecipes = function()
    while true do
        for recipeName, link in pairs(linkedRecipes) do
            local isTriggered = Trigger.eval(link.recipe.trigger, getItemFromStorage)
            local redstones = link.group.redstones

            if redstones ~= nil then
                for _, red in ipairs(redstones) do
                    red.setOutputSignals(isTriggered)
                end
            end

            if (isTriggered) then
                runLink(link)
                feedBlazeBurners(link.group.blazeBurnerFeeders)
            end
        end
        os.sleep(1)
    end
end

init()

local runChannel = function()
    local config = loadCommunicatorConfig()
    if config and config.side and config.channel and config.secret then
        print("Found saved communicator config, attempting to connect...")
        Communicator.open(config.side, config.channel, "recipe", config.secret)
        local openChannel = Communicator.communicationChannels[config.side][config.channel]["recipe"]
        openChannel.addMessageHandler("getRecipesRes", function(eventCode, payload, senderId)
            remoteRecipes = payload or {}
        end)

        -- Add update event handler
        openChannel.addMessageHandler("update", function(eventCode, payload, senderId)
            if payload and type(payload) == "table" then
                updateRecipesByID(payload)
                -- Reinitialize linked recipes after update
                init()
                openChannel.send("getRecipesReq", "basin")
            end
        end)
        Communicator.listen()
    end
end

parallel.waitForAny(
    runChannel,
    checkAndRunRecipes,
    runCommandLine
)
