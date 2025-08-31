local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local CommandLine = require("programs.command.CommandLine")
local OSUtils = require("utils.OSUtils")
local Trigger = require("programs.common.Trigger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local TableUtils = require("utils.TableUtils")

Logger.useDefault()
Logger.currentLevel = Logger.levels.ERROR

local args = { ... }

-- Recipes storage
local recipes = {}

local remoteRecipes = {}

-- Load recipes from file
local function loadRecipes()
    local data = OSUtils.loadTable("cadepot_recipes")
    if data ~= nil then
        recipes = data
    end
end

-- Save recipes to file
local function saveRecipes()
    OSUtils.saveTable("cadepot_recipes", recipes)
end

-- Load communicator config from file
local function loadCommunicatorConfig()
    return OSUtils.loadTable("cadepot_communicator_config")
end

-- Save communicator config to file
local function saveCommunicatorConfig(side, channel, secret)
    local config = {
        side = side,
        channel = channel,
        secret = secret
    }
    OSUtils.saveTable("cadepot_communicator_config", config)
end

-- Update recipes by ID
local function updateRecipesByID(newRecipes)
    local recipeMap = {}
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
                recipes[existingIndex] = newRecipe
            end
        end
    end
    
    -- Save updated recipes
    saveRecipes()
end

-- Get recipe by input name
local function getRecipeByInput(inputName)
    for _, recipe in ipairs(recipes) do
        if recipe.input == inputName then
            return recipe
        end
    end
    return nil
end

-- Remove recipe by input name
local function removeRecipeByInput(inputName)
    for i, recipe in ipairs(recipes) do
        if recipe.input == inputName then
            table.remove(recipes, i)
            return true
        end
    end
    return false
end

-- Display recipes with pagination
local function displayRecipes(recipeList, page, pageSize)
    page = page or 1
    pageSize = pageSize or 5    

    if #recipeList == 0 then
        print("No recipes found.")
        return
    end

    local totalPages = math.ceil(#recipeList / pageSize)
    local startIdx = (page - 1) * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, #recipeList)

    print(string.format("=== Recipes (Page %d/%d) ===", page, totalPages))
    for i = startIdx, endIdx do
        local recipe = recipeList[i]
        local depotTypeName = ({ "none", "fire", "soul_fire", "lava", "water" })[recipe.depotType + 1] or "unknown"
        local outputStr = table.concat(recipe.output, ", ")
        print(string.format("%d. [%s] %s -> %s", i, depotTypeName, recipe.input, outputStr))
    end

    if totalPages > 1 then
        print(string.format("Showing %d-%d of %d recipes", startIdx, endIdx, #recipeList))
        if page < totalPages then
            print(string.format("Use 'list recipe local %d' for next page", page + 1))
        end
        if page > 1 then
            print(string.format("Use 'list recipe local %d' for previous page", page - 1))
        end
    end
end

-- Initialize recipes
loadRecipes()

-- Command line interface
local function createCommandLine()
    local cli = CommandLine:new("cadepot> ")

    -- List recipes command
    cli:addCommand("list", "List recipes", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 3 then
            print("Usage: list recipe [remote|local] [page]")
            return
        end

        local recipeType = parts[2]
        local location = parts[3]
        local page = tonumber(parts[4]) or 1

        if recipeType ~= "recipe" then
            print("Usage: list recipe [remote|local] [page]")
            return
        end

        if location == "local" then
            displayRecipes(recipes, page)
        elseif location == "remote" then
            if #remoteRecipes == 0 then
                print("No remote recipes available.")
                return
            end
            displayRecipes(remoteRecipes, page)
        else
            print("Usage: list recipe [remote|local] [page]")
        end
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts == 1 then
            -- 补全第二个参数 "recipe"
            local partial = text:match("%S+$") or ""
            local suggestions = {}
            if ("recipe"):find(partial, 1, true) == 1 then
                table.insert(suggestions, ("recipe"):sub(#partial + 1))
            end
            return suggestions
        elseif #parts == 2 then
            -- 补全第三个参数 "remote"/"local"
            local partial = text:match("%S+$") or ""
            local suggestions = {}
            local options = { "remote", "local" }
            for _, option in ipairs(options) do
                if option:find(partial, 1, true) == 1 then
                    table.insert(suggestions, option:sub(#partial + 1))
                end
            end
            return suggestions
        end
        return {}
    end)

    -- Add recipe command (from remote by depotType)
    cli:addCommand("add", "Add recipe(s) from remote by depotType", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: add [depotType] [input_name]")
            print("DepotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")
            print("Examples:")
            print("  add fire minecraft:iron_ore    - Add specific recipe")
            print("  add fire                       - Add all fire-type recipes")
            print("Use 'list recipe remote' to see available recipes")
            return
        end

        local depotTypeInput = parts[2]
        local inputItem = parts[3] -- Optional

        -- Parse depot type
        local targetDepotType = nil
        if depotTypeInput == "none" or depotTypeInput == "0" then
            targetDepotType = 0
        elseif depotTypeInput == "fire" or depotTypeInput == "1" then
            targetDepotType = 1
        elseif depotTypeInput == "soul_fire" or depotTypeInput == "2" then
            targetDepotType = 2
        elseif depotTypeInput == "lava" or depotTypeInput == "3" then
            targetDepotType = 3
        elseif depotTypeInput == "water" or depotTypeInput == "4" then
            targetDepotType = 4
        elseif tonumber(depotTypeInput) and tonumber(depotTypeInput) >= 0 and tonumber(depotTypeInput) <= 4 then
            targetDepotType = tonumber(depotTypeInput)
        else
            print("Invalid depotType: " .. depotTypeInput)
            print("Valid depotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")
            return
        end

        if inputItem then
            -- Add specific recipe with matching depotType
            local remoteRecipe = nil
            for _, recipe in ipairs(remoteRecipes) do
                if recipe.input == inputItem and recipe.depotType == targetDepotType then
                    remoteRecipe = recipe
                    break
                end
            end

            if not remoteRecipe then
                print("Remote recipe '" .. inputItem .. "' with depotType " .. targetDepotType .. " not found")
                print("Use 'list recipe remote' to see available remote recipes")
                return
            end

            -- Check if recipe already exists locally
            if getRecipeByInput(inputItem) then
                print("Recipe with input '" .. inputItem .. "' already exists locally")
                return
            end

            -- Copy the remote recipe to local
            local newRecipe = {
                id = remoteRecipe.id,
                input = remoteRecipe.input,
                output = remoteRecipe.output,
                depotType = remoteRecipe.depotType,
                trigger = remoteRecipe.trigger
            }

            table.insert(recipes, newRecipe)
            saveRecipes()
            print("Recipe added from remote successfully:")
            print("  Input: " .. newRecipe.input)
            print("  Output: " .. table.concat(newRecipe.output, ", "))
            local depotTypeName = ({ "none", "fire", "soul_fire", "lava", "water" })[newRecipe.depotType + 1] or
                "unknown"
            print("  DepotType: " .. newRecipe.depotType .. " (" .. depotTypeName .. ")")
        else
            -- Add all recipes with matching depotType
            local matchingRecipes = {}
            for _, recipe in ipairs(remoteRecipes) do
                if recipe.depotType == targetDepotType then
                    table.insert(matchingRecipes, recipe)
                end
            end

            if #matchingRecipes == 0 then
                local depotTypeName = ({ "none", "fire", "soul_fire", "lava", "water" })[targetDepotType + 1] or
                    "unknown"
                print("No remote recipes found with depotType " .. targetDepotType .. " (" .. depotTypeName .. ")")
                print("Use 'list recipe remote' to see available remote recipes")
                return
            end

            local addedCount = 0
            local skippedCount = 0

            for _, remoteRecipe in ipairs(matchingRecipes) do
                -- Check if recipe already exists locally
                if not getRecipeByInput(remoteRecipe.input) then
                    local newRecipe = {
                        id = remoteRecipe.id,
                        input = remoteRecipe.input,
                        output = remoteRecipe.output,
                        depotType = remoteRecipe.depotType,
                        trigger = remoteRecipe.trigger
                    }
                    table.insert(recipes, newRecipe)
                    addedCount = addedCount + 1
                else
                    skippedCount = skippedCount + 1
                end
            end

            saveRecipes()
            local depotTypeName = ({ "none", "fire", "soul_fire", "lava", "water" })[targetDepotType + 1] or "unknown"
            print("Batch add completed for depotType " .. targetDepotType .. " (" .. depotTypeName .. "):")
            print("  Added: " .. addedCount .. " recipes")
            if skippedCount > 0 then
                print("  Skipped: " .. skippedCount .. " recipes (already exist)")
            end
        end
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end

        -- First argument: provide depotType completion
        if #parts == 1 and text:sub(-1) ~= " " then
            local partial = text:match("%S+$") or ""
            local suggestions = {}
            local options = { "none", "fire", "soul_fire", "lava", "water", "0", "1", "2", "3", "4" }
            for _, option in ipairs(options) do
                if option:find(partial, 1, true) == 1 then
                    table.insert(suggestions, option:sub(#partial + 1))
                end
            end
            return suggestions
        elseif #parts == 2 then
            -- Second argument (optional): provide remote recipe inputs for the specified depotType
            local depotTypeInput = parts[2]
            local targetDepotType = nil

            -- Parse depot type
            if depotTypeInput == "none" or depotTypeInput == "0" then
                targetDepotType = 0
            elseif depotTypeInput == "fire" or depotTypeInput == "1" then
                targetDepotType = 1
            elseif depotTypeInput == "soul_fire" or depotTypeInput == "2" then
                targetDepotType = 2
            elseif depotTypeInput == "lava" or depotTypeInput == "3" then
                targetDepotType = 3
            elseif depotTypeInput == "water" or depotTypeInput == "4" then
                targetDepotType = 4
            elseif tonumber(depotTypeInput) and tonumber(depotTypeInput) >= 0 and tonumber(depotTypeInput) <= 4 then
                targetDepotType = tonumber(depotTypeInput)
            end

            if targetDepotType ~= nil then
                local suggestions = {}
                local partial = text:match("%S+$") or ""
                for _, recipe in ipairs(remoteRecipes) do
                    if recipe.depotType == targetDepotType and recipe.input:find(partial, 1, true) == 1 then
                        table.insert(suggestions, recipe.input:sub(#partial + 1))
                    end
                end
                return suggestions
            end
        end
        return {}
    end)

    -- Remove recipe command
    cli:addCommand("rm", "Remove recipe", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: rm [input]")
            return
        end

        local identifier = parts[2]

        -- Remove by input
        local removed = false
        local removedRecipe = nil

        for i, recipe in ipairs(recipes) do
            if recipe.input == identifier then
                removedRecipe = recipe
                table.remove(recipes, i)
                removed = true
                break
            end
        end

        if removed then
            saveRecipes()
            local depotTypeName = ({ "none", "fire", "soul_fire", "lava", "water" })[removedRecipe.depotType + 1] or
                "unknown"
            print("Recipe removed: [" .. depotTypeName .. "] " .. removedRecipe.input)
        else
            print("Recipe '" .. identifier .. "' not found")
        end
    end, function(text)
        -- Provide completion for recipe inputs
        local suggestions = {}
        local partial = text:match("%S+$") or ""

        for _, recipe in ipairs(recipes) do
            if recipe.input:find(partial, 1, true) == 1 then
                table.insert(suggestions, recipe.input:sub(#partial + 1))
            end
        end

        return suggestions
    end)

    -- Exit command
    cli:addCommand("reboot", "Exit the program", function(input)
        print("Goodbye!")
        os.reboot()
    end)

    return cli
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
        
        -- Add update event handler
        openChannel.addMessageHandler("update", function(eventCode, payload, senderId)
            if payload and type(payload) == "table" then
                updateRecipesByID(payload)
            end
        end)

        parallel.waitForAll(Communicator.listen,
            function()
                while next(remoteRecipes) == nil do
                    openChannel.send("getRecipesReq", "depot")
                    sleep(1) -- Wait for response
                end
            end,
            function()
                local cli = createCommandLine()
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

PeripheralWrapper.reloadAll()
local depots = PeripheralWrapper.getAllPeripheralsNameContains("depot")
local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
local key = next(storages) -- Assuming only one storage is available
local storage = storages[key]

local totalDepots = TableUtils.getLength(depots)



local marker = {
    recipeOnDepot = {},
    depotOnUse = {},
    lostTrackDepots = {},

    init = function(self)
        for _, recipe in ipairs(recipes) do
            self.recipeOnDepot[recipe.id] = {
                recipe = recipe,
                depots = {}
            }
        end
        for _, depot in pairs(depots) do
            self.depotOnUse[depot.getId()] = {
                onUse = false,
                depot = depot,
                recipe = nil
            }
        end
    end,

    set = function(self, recipe, depot)
        local depotOnUseInfo = self.depotOnUse[depot.getId()]
        depotOnUseInfo.onUse = true
        depotOnUseInfo.recipe = recipe

        local recipeOnDepotInfo = self.recipeOnDepot[recipe.id]
        recipeOnDepotInfo.depots[depot.getId()] = depot
        recipeOnDepotInfo.count = (recipeOnDepotInfo.count or 0) + 1
    end,

    remove = function(self, depot)
        local recipe = self.depotOnUse[depot.getId()].recipe
        self.depotOnUse[depot.getId()].onUse = false
        self.depotOnUse[depot.getId()].recipe = nil
        self.recipeOnDepot[recipe.id].depots[depot.getId()] = nil
        self.recipeOnDepot[recipe.id].count = math.max(0, (self.recipeOnDepot[recipe.id].count or 1) - 1)
    end,

    isUsing = function(self, depot)
        return self.depotOnUse[depot.getId()].onUse
    end,

    isCompleted = function(self, depot)
        if not self:isUsing(depot) then
            return false
        end
        local recipe = self.depotOnUse[depot.getId()].recipe
        local input = depot.getItem(recipe.input)
        if input == nil or input.count == 0 then
            return true
        end
    end,

    isLoseTrack = function(self, depot)
        if not self:isUsing(depot) and #depot.getItems() > 0 then
            return true
        end
        return false
    end,

    getOnUseDepotCountForRecipe = function(self, recipe)
        return self.recipeOnDepot[recipe.id].count or 0
    end,
}

marker:init()

local checkAndRunRecipe = function()
    while true do
        local triggeredRecipes = {}
        for _, recipe in ipairs(recipes) do
            if recipe.trigger then
                local triggered = Trigger.eval(recipe.trigger, function(type, itemName)
                    if type == "item" then
                        return storage.getItem(itemName)
                    elseif type == "fluid" then
                        return storage.getFluid(itemName)
                    end
                    return nil
                end)
                if triggered then
                    table.insert(triggeredRecipes, recipe)
                end
            end
        end
        
        local numOfDepotsForEachRecipe = totalDepots / math.max(1, #triggeredRecipes)

        for _, recipe in ipairs(triggeredRecipes) do
            local onUseDepotCount = marker:getOnUseDepotCountForRecipe(recipe)
            if onUseDepotCount < numOfDepotsForEachRecipe then
                local depotNeeded = numOfDepotsForEachRecipe - onUseDepotCount
                Logger.info("Need {} depots for recipe {}", depotNeeded, recipe.input)
                for _, depot in pairs(depots) do
                    if depotNeeded <= 0 then
                        break
                    end
                    if not marker:isUsing(depot) then
                        local transfered = storage.transferItemTo(depot, recipe.input, 64)
                        Logger.info("Transferred {} items to depot {}", transfered, depot.getId())
                        if transfered <= 0 then
                            if marker:isLoseTrack(depot) then
                                Logger.info("Lost track of depot {}", depot.getId())
                                table.insert(marker.lostTrackDepots, depot)
                            end
                        else
                            marker:set(recipe, depot)
                            depotNeeded = depotNeeded - 1
                        end
                    else 
                        Logger.info("Depot {} is already in use for recipe {}", depot.getId(), recipe.input)
                    end
                end
            end
        end
        os.sleep(1)
    end
end

local checkAndMoveCompletedRecipe = function()
    while true do
        for key, onUseDepotInfo in pairs(marker.depotOnUse) do
            local depot = onUseDepotInfo.depot
            if marker:isUsing(depot) then
                if marker:isCompleted(depot) then
                    local recipe = onUseDepotInfo.recipe
                    local items = depot.getItems(recipe.input)
                    local totalTransferred = 0

                    for _, item in ipairs(items) do
                        local transferred = storage.transferItemFrom(depot, item.name, item.count)
                        if transferred == item.count then
                            Logger.error("Transferred completed recipe " .. recipe.input .. " from depot " .. depot.getId())
                            marker:remove(depot)
                        else
                            Logger.error("Failed to transfer completed recipe {} from depot {}", recipe.input, depot.getId())
                        end
                    end
                end
            end
        end

        -- Handle lost track depots
        for _, depot in ipairs(marker.lostTrackDepots) do
            for _, item in ipairs(depot.getItems()) do
                local transfered = storage.transferItemFrom(depot, item.name, item.count)
                if transfered > 0 then
                    Logger.debug("Transferred lost item {} from depot {}", item.name, depot.getId())
                else
                    Logger.error("Failed to transfer lost item {} from depot {}", item.name, depot.getId())
                end
            end
        end
        os.sleep(1)
    end
end

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
            end
        end)
        
        Communicator.listen()
    end
end 

parallel.waitForAll(
    runChannel,
    checkAndRunRecipe,
    checkAndMoveCompletedRecipe
)
