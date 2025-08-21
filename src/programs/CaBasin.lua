local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local CommandLine = require("programs.command.CommandLine")
local OSUtils = require("utils.OSUtils")
local Trigger = require("programs.recipe.manager.Trigger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local TableUtils = require("utils.TableUtils")

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

local getAllBasinAndBlazeBurnerNames = function()
    local names = peripheral.getNames()
    local basins = {}
    local blazeBurners = {}
    for _, name in pairs(names) do 
        if name:find("basin") then
            table.insert(basins, name)
        end
        if name:find("blaze_burner") then
            table.insert(blazeBurners, name)
        end
    end
    return basins, blazeBurners
end

-- Display recipes with pagination
local function displayRecipes(recipeList, page, pageSize, location)
    page = page or 1
    pageSize = pageSize or 5
    location = location or "local"  -- Default to local for backward compatibility

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
    for name, group in pairs(groups) do
        print(string.format("%s:", name))
        print(string.format("  Basins: %d", #group.basins))
        for i, basin in ipairs(group.basins) do
            print(string.format("    %d. %s", i, basin))
        end
        print(string.format("  Blaze Burners: %d", #group.blazeBurners))
        for i, burner in ipairs(group.blazeBurners) do
            print(string.format("    %d. %s", i, burner))
        end
        print()
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
    print(string.format("Total: %d links", linkCount))
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
        local basins, blazeBurners = getAllBasinAndBlazeBurnerNames()
        
        -- Create group entry
        groups[groupName] = {
            name = groupName,
            basins = basins,
            blazeBurners = blazeBurners
        }
        
        -- Save to file
        saveGroups()
        
        print("Group '" .. groupName .. "' created successfully:")
        print("  Name: " .. groupName)
        print("  Basins: " .. #basins .. " found")
        for i, basin in ipairs(basins) do
            print("    " .. i .. ". " .. basin)
        end
        print("  Blaze Burners: " .. #blazeBurners .. " found")
        for i, burner in ipairs(blazeBurners) do
            print("    " .. i .. ". " .. burner)
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

        if #parts == 1 then
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
        elseif #parts == 2 then
            -- 如果第二个参数是 "recipe"，补全第三个参数 "remote"/"local" (CADepot order)
            if parts[2] == "recipe" then
                local partial = text:match("%S+$") or ""
                local suggestions = {}
                local options = { "remote", "local" }  -- CADepot order: remote first
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

    -- Reboot command
    cli:addCommand("reboot", "Reboot the program", function(input)
        print("Rebooting...")
        os.reboot()
    end)

    return cli
end

-- Initialize recipes
loadRecipes()

-- Main execution
if args ~= nil and #args > 0 then
    local side = args[1]
    local channel = tonumber(args[2])
    local secret = args[3]

    if side and channel and secret then
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
            function()
                local cli = createCommandLine()
                print("CaBasin Manager - Network Mode")
                print("Connected to channel " .. channel .. " on " .. side)
                print("Type 'help' for available commands or 'exit' to quit")
                
                while true do
                    local success, result = pcall(function() cli:run() end)
                    if not success then
                        print("Error: " .. tostring(result))
                    end
                end
            end
        )
    end
end


