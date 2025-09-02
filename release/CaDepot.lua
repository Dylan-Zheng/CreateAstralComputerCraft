local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaDepot"] = function(...) local Logger = require("utils.Logger")
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

local runChannel = function()
    local config = loadCommunicatorConfig()
    if config and config.side and config.channel and config.secret then
        Logger.info("Found saved communicator config, attempting to connect...")
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
                trigger = remoteRecipe.trigger,
                maxMachine = remoteRecipe.maxMachine or -1
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
                        trigger = remoteRecipe.trigger,
                        maxMachine = remoteRecipe.maxMachine or -1
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

local setMesssageHandler = function(openChannel)
    openChannel.addMessageHandler("getRecipesRes", function(eventCode, payload, senderId)
        remoteRecipes = payload or {}
    end)

    -- Add update event handler
    openChannel.addMessageHandler("update", function(eventCode, payload, senderId)
        if payload and type(payload) == "table" then
            updateRecipesByID(payload)
            openChannel.send("getRecipesReq", "depot")
        end
    end)
end

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
        setMesssageHandler(openChannel)

        parallel.waitForAll(Communicator.listen,
            function()
                while next(remoteRecipes) == nil do
                    openChannel.send("getRecipesReq", "depot")
                    sleep(1) -- Wait for response
                end
            end,
            runCommandLine
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

        if self.recipeOnDepot[recipe.id] == nil then
            self.recipeOnDepot[recipe.id] = { recipe = recipe, depots = {}, count = 0 }
        end
        local recipeOnDepotInfo = self.recipeOnDepot[recipe.id]
        recipeOnDepotInfo.depots[depot.getId()] = depot
        recipeOnDepotInfo.count = (recipeOnDepotInfo.count or 0) + 1
    end,

    remove = function(self, depot)
        if depot == nil then
            return
        end
        local recipe = self.depotOnUse[depot.getId()].recipe
        self.depotOnUse[depot.getId()].onUse = false
        self.depotOnUse[depot.getId()].recipe = nil
        if self.recipeOnDepot[recipe.id] == nil then
            self.recipeOnDepot[recipe.id] = { recipe = recipe, depots = {}, count = 0 }
        end
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
        if self.recipeOnDepot[recipe.id] == nil then
            self.recipeOnDepot[recipe.id] = { recipe = recipe, depots = {}, count = 0 }
        end
        return self.recipeOnDepot[recipe.id].count or 0
    end,
}

marker:init()

local checkInputItem = function(recipe)
    local item = storage.getItem(recipe.input)
    if not item then
        return false
    end
    return true
end

local checkAndRunRecipe = function()
    while true do
        local triggeredRecipes = {}
        for _, recipe in ipairs(recipes) do
            if checkInputItem(recipe) and recipe.trigger then
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

        local currentTotalDepots = totalDepots
        local currentTriggeredRecipeCount = #triggeredRecipes

        local numOfDepotsForEachRecipe = math.max(1,
            math.floor(currentTotalDepots / math.max(1, currentTriggeredRecipeCount)))

        for _, recipe in ipairs(triggeredRecipes) do
            local usedDepotsCount = marker:getOnUseDepotCountForRecipe(recipe)
            local maxMachineForRecipe

            if recipe.maxMachine and recipe.maxMachine > 0 then
                -- If average allocation exceeds maxMachine limit, use maxMachine
                -- Otherwise use average allocation
                maxMachineForRecipe = math.min(numOfDepotsForEachRecipe, recipe.maxMachine)
            else
                -- Use fair share allocation (maxMachine = -1 means unlimited)
                maxMachineForRecipe = numOfDepotsForEachRecipe
            end

            Logger.debug("recipe " ..
            (recipe.input or "Unnamed") ..
            " usedDepotsCount: " .. usedDepotsCount .. ", maxMachineForRecipe: " .. maxMachineForRecipe)
            if usedDepotsCount > maxMachineForRecipe then
                Logger.info("Releasing depots for recipe: " .. (recipe.input or "Unnamed"))
                local toRemove = usedDepotsCount - maxMachineForRecipe
                for _, depot in pairs(marker.recipeOnDepot[recipe.id].depots) do
                    if toRemove <= 0 then
                        break
                    end
                    marker:remove(depot)
                    toRemove = toRemove - 1
                end
                usedDepotsCount = marker:getOnUseDepotCountForRecipe(recipe) -- Update count after removal
            end

            if usedDepotsCount < maxMachineForRecipe then
                local depotNeeded = maxMachineForRecipe - usedDepotsCount
                Logger.info("Need {} depots for recipe {} (max: {})", depotNeeded, recipe.input, maxMachineForRecipe)
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

            -- Subtract the allocated depots for this recipe (not just the ones currently in use)
            currentTotalDepots = currentTotalDepots - maxMachineForRecipe
            currentTriggeredRecipeCount = currentTriggeredRecipeCount - 1
            numOfDepotsForEachRecipe = math.max(1,
                math.floor(currentTotalDepots / math.max(1, currentTriggeredRecipeCount)))
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
                    for _, item in ipairs(items) do
                        local transferred = storage.transferItemFrom(depot, item.name, item.count)
                        if transferred == item.count then
                            Logger.debug("Transferred completed recipe " ..
                            recipe.input .. " from depot " .. depot.getId())
                        else
                            Logger.error("Failed to transfer completed recipe {} from depot {}", recipe.input,
                                depot.getId())
                        end
                    end
                    marker:remove(depot)
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
        Logger.info("Found saved communicator config, attempting to connect...")
        Communicator.open(config.side, config.channel, "recipe", config.secret)
        local openChannel = Communicator.communicationChannels[config.side][config.channel]["recipe"]
        setMesssageHandler(openChannel)
        Communicator.listen()
    end
end


parallel.waitForAll(
    runChannel,
    checkAndRunRecipe,
    checkAndMoveCompletedRecipe,
    runCommandLine
)
 end
modules["utils.Logger"] = function(...) local Logger = {
    currentLevel = 1, -- Default to DEBUG
    printFunctions = {}
}

Logger.useDefault = function()
    Logger.addPrintFunction(function(level, src, currentline, message)
        print(string.format("[%s][%s:%d] %s", level, src, currentline, message))
    end)
end

Logger.levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

Logger.addPrintFunction = function(func)
    table.insert(Logger.printFunctions, func)
end

Logger.print = function(level, src, currentline, message, ...)
    if level >= Logger.currentLevel then
        local completeMessage = Logger.formatBraces(message, ...)
        for _, func in ipairs(Logger.printFunctions) do
            func(level, src, currentline, completeMessage)
        end
    end
end

Logger.custom = function(level, message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(level, src, currentline, message, ...)
end

Logger.debug = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.DEBUG, src, currentline, message, ...)
end 

Logger.info = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.INFO, src, currentline, message, ...)
end

Logger.warn = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.WARN, src, currentline, message, ...)
end

Logger.error = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.ERROR, src, currentline, message, ...)
end

Logger.formatBraces = function(message, ...)
    local args = {...}
    local i = 1
    local formatted = tostring(message):gsub("{}", function()
        local arg = args[i]
        i = i + 1
        return tostring(arg)
    end)
    return formatted
end

return Logger end
modules["programs.common.Communicator"] = function(...) local Logger = require("utils.Logger")
local OSUtils = require("utils.OSUtils")

local function xorCipher(text, secret)
    local encrypted = ""
    local key = secret
    for i = 1, #text do
        local char = text:sub(i, i)
        local keyChar = key:sub((i - 1) % #key + 1, (i - 1) % #key + 1)
        encrypted = encrypted .. string.char(bit.bxor(string.byte(char), string.byte(keyChar)))
    end
    return encrypted
end

local function decrypt(encryptedText, secret)
    return textutils.unserialize(xorCipher(encryptedText, secret))
end

local function encrypt(table, secret)
    return xorCipher(textutils.serialize(table), secret)
end


local CommunicationChannel = {}
CommunicationChannel.__index = CommunicationChannel

function CommunicationChannel:new(side, channel, protocol, secret)
    local this = setmetatable({}, CommunicationChannel)
    this.computerId = os.getComputerID()
    this.side = side
    this.secret = secret
    this.channel = channel
    this.protocol = protocol
    
    -- 验证调制解调器
    this.modem = peripheral.wrap(side)
    this.modem.open(channel)
    this.eventHandle = {}

    this.send = function(eventCode, data, receiverId)
        local message = {
            protocol = this.protocol,
            senderId = this.computerId,
            receiverId = receiverId,
            details = encrypt({
                eventCode = eventCode,
                payload = data
            }, this.secret)
        }
        Logger.debug("Sending message on side {}, channel {}: {}", this.side, this.channel, textutils.serialize(message))
        this.modem.transmit(this.channel, this.channel, textutils.serialize(message))
    end

    this.addMessageHandler = function(eventCode, callback)
        this.eventHandle[eventCode] = callback
    end

    return this
end

local Communicator = {
    communicationChannels = {}
}

function Communicator.open(side, channel, protocol, secret)
    local channelInstance = CommunicationChannel:new(side, channel, protocol, secret)
    if not Communicator.communicationChannels[side] then
        Communicator.communicationChannels[side] = {}
    end
    if not Communicator.communicationChannels[side][channel] then
        Communicator.communicationChannels[side][channel] = {}
    end
    if Communicator.communicationChannels[side][channel][protocol] then
        return false, string.format("Channel already opened on side %s, channel %d, protocol %s", side, channel, protocol)  
    end
    Communicator.communicationChannels[side][channel][protocol] = channelInstance
    return channelInstance
end

local isOpened = function(side, channel)
    if Communicator.communicationChannels[side] and 
       Communicator.communicationChannels[side][channel] then
        return true
    end
    return false
end

local handleSerializedMessage = function(side, channel, serializedMessage)
    local message = textutils.unserialize(serializedMessage)
    if not message or not message.protocol then
        return  -- 如果消息格式无效，直接返回
    end
    
    local channelInstance = Communicator.communicationChannels[side][channel][message.protocol]
    if not channelInstance then
        return  -- 如果找不到对应的通道实例，直接返回
    end
    
    if message.receiverId ~= nil and message.receiverId ~= channelInstance.computerId then
        return
    end
    local details = decrypt(message.details, channelInstance.secret)
    local handler = channelInstance.eventHandle[details.eventCode]
    if handler then
        handler(details.eventCode, details.payload, message.senderId)
    end
end

function Communicator.listen()
    while true do
        local _, side, channel, _, serializedMessage, distance = os.pullEvent("modem_message")
        Logger.debug("Received message on side {}, channel {}, distance {}: {}", side, channel, distance, serializedMessage)
        if isOpened(side, channel) then
            local success, err = pcall(function()
                handleSerializedMessage(side, channel, serializedMessage)
            end)
            if not success then
                Logger.error("Error handling serialized message: " .. err)
            end
        end
    end
end

function Communicator.close(side, channel, protocol)
    if Communicator.communicationChannels[side] and 
       Communicator.communicationChannels[side][channel] and
       Communicator.communicationChannels[side][channel][protocol] then
        local instance = Communicator.communicationChannels[side][channel][protocol]
        instance.modem.close(channel)
        Communicator.communicationChannels[side][channel][protocol] = nil
        if next(Communicator.communicationChannels[side][channel]) == nil then
            Communicator.communicationChannels[side][channel] = nil
        end
        if next(Communicator.communicationChannels[side]) == nil then
            Communicator.communicationChannels[side] = nil
        end
        return true
    else
        return false, string.format("No such channel to close on side %s, channel %d, protocol %s", side, channel, protocol)
    end
end

function Communicator.closeAllChannels()
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, instance in pairs(protocols) do
                instance.modem.close(channel)
            end
        end
    end
    Communicator.communicationChannels = {}
end

function Communicator.saveSettings()
    local settings = {}
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, instance in pairs(protocols) do
                table.insert(settings, {
                    side = side,
                    channel = channel,
                    protocol = protocol,
                    secret = instance.secret
                })
            end
        end
    end
    return OSUtils.saveTable("communicator_settings.dat", settings)
end

function Communicator.loadSettings()
    local settings = OSUtils.loadTable("communicator_settings.dat")
    if not settings or #settings == 0 then
        Logger.warn("No communicator settings found.")
        return false
    end
    for _, setting in ipairs(settings) do
        local side = setting.side
        local channel = setting.channel
        local protocol = setting.protocol
        local secret = setting.secret
        local channelInstance, err = Communicator.open(side, channel, protocol, secret)
        if not channelInstance then
            Logger.error("Failed to open communication channel: " .. err)
        end
    end
    return true
end

function Communicator.getSettings()
    local settings = {}
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, instance in pairs(protocols) do
                table.insert(settings, {
                    side = side,
                    channel = channel,
                    protocol = protocol,
                    secret = instance.secret
                })
            end
        end
    end
    return settings
end


function Communicator.getOpenChannels()
    local openChannels = {}
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, _ in pairs(protocols) do
                table.insert(openChannels, Communicator.communicationChannels[side][channel][protocol])
            end
        end
    end
    return openChannels
end



return Communicator

 end
modules["programs.command.CommandLine"] = function(...) local CommandLine = {}
CommandLine.__index = CommandLine

-- Helper function to filter suggestions and return only the untyped part
function CommandLine.filterSuggestions(candidates, partial)
    local filtered = {}
    partial = partial or ""
    local partialLower = string.lower(partial)
    
    for _, candidate in ipairs(candidates) do
        local candidateLower = string.lower(candidate)
        if candidateLower:find(partialLower, 1, true) == 1 then
            -- Return only the part that hasn't been typed yet
            local remaining = candidate:sub(#partial + 1)
            if remaining ~= "" then
                table.insert(filtered, remaining)
            end
        end
    end
    
    return filtered
end

function CommandLine:new(suffix)
    local instance = setmetatable({}, CommandLine)
    instance.suffix = suffix or "> "
    instance.commands = {
        help = {
            name = "help",
            description = "Display available commands",
            func = function(input)
                print("Available commands:")
                for cmdName, cmd in pairs(instance.commands) do
                    print(string.format(" - %s: %s", cmdName, cmd.description))
                end
            end
        }
    }
    return instance
end

local getUserInputCommandName = function(input)
    local firstSpace = string.find(input, " ")
    if firstSpace then
        return string.sub(input, 1, firstSpace - 1), true
    else
        return input, false
    end
end

local getCommands = function(commandLine, commandName)
    return commandLine.commands[commandName]
end

local getCommandSuggestion = function(commandLine, text)
    local suggestions = {}
    local commandName, isCompleted = getUserInputCommandName(text)
    if isCompleted then
        local command = getCommands(commandLine, commandName)
        if command and command.complete then
            local argsText = string.sub(text, #commandName + 2)
            suggestions = command.complete(argsText) or {}
        end
    else
        -- Collect all matching command names
        local candidates = {}
        for cmdName, cmd in pairs(commandLine.commands) do
            if cmdName:find(commandName) == 1 then
                table.insert(candidates, cmdName)
            end
        end
        -- Use filterSuggestions to return only the untyped part
        suggestions = CommandLine.filterSuggestions(candidates, commandName)
    end
    return suggestions
end

-- Calculate Levenshtein distance between two strings
local function levenshteinDistance(str1, str2)
    local len1, len2 = #str1, #str2
    local matrix = {}
    
    -- Initialize matrix
    for i = 0, len1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, len2 do
        matrix[0][j] = j
    end
    
    -- Fill matrix
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,      -- deletion
                matrix[i][j-1] + 1,      -- insertion
                matrix[i-1][j-1] + cost  -- substitution
            )
        end
    end
    
    return matrix[len1][len2]
end

local function findClosestCommand(commandLine, inputCommand)
    local closestCommand = nil
    local minDistance = math.huge
    local maxDistance = 3  -- Only suggest if distance is 3 or less
    
    for cmdName, cmd in pairs(commandLine.commands) do
        local distance = levenshteinDistance(inputCommand:lower(), cmdName:lower())
        if distance < minDistance and distance <= maxDistance then
            minDistance = distance
            closestCommand = cmdName
        end
    end
    
    return closestCommand
end

function CommandLine:addCommand(cmdName, description, cmdFunc, completeFunc)
    self.commands[cmdName] = {
        name = cmdName,
        description = description,
        func = cmdFunc,
        complete = completeFunc
    }
    return self
end

function CommandLine:run()
    write(self.suffix)
    local commandLineText = read(nil, nil, function(text)
        return getCommandSuggestion(self, text)
    end)
    local commandName, isCompleted = getUserInputCommandName(commandLineText)
    local command = getCommands(self, commandName)
    if command then
        return command.func(commandLineText)
    else
        local closestCommand = findClosestCommand(self, commandName)
        if closestCommand then
            print("Unknown command: " .. commandName)
            print("Do you mean \"" .. closestCommand .. "\"?")
        else
            print("Unknown command: " .. commandName)
        end
    end
end

function CommandLine:changeSuffix(newSuffix)
    self.suffix = newSuffix
end

return CommandLine end
modules["utils.OSUtils"] = function(...) local Logger = require("utils.Logger")

local OSUtils = {}

OSUtils.SIDES = {
    TOP = "top",
    BOTTOM = "bottom",
    LEFT = "left",
    RIGHT = "right",
    FRONT = "front",
    BACK = "back"
}

OSUtils.timestampBaseIdGenerate = function()
    local timestamp = os.epoch("utc")
    local random = math.random(1000, 9999)
    return tostring(timestamp) .. "-" .. tostring(random)
end

OSUtils.loadTable = function(file_name)
    local obj = {}
    local file = fs.open(file_name, "r")
    if file then
        local text = file.readAll()
        obj = textutils.unserialize(text)
        file.close()
    else
        return nil
    end
    return obj
end

OSUtils.saveTable = function(file_name, obj)
    local serialized
    local success, err = xpcall(function()
        serialized = textutils.serialize(obj)
    end, function(error)
        return error
    end)
    
    if not success then
        Logger.error("Failed to serialize table for {}, error: {}", file_name, err)
        return
    end
    
    local file = fs.open(file_name, "w")
    if file then
        file.write(serialized)
        file.close()
    else
        Logger.error("Failed to open file for writing: {}", file_name)
    end
end

return OSUtils end
modules["programs.common.Trigger"] = function(...) local Logger = require("utils.Logger")
local Triggers = {}

Triggers.TYPES = {
    FLUID_COUNT = "fluid_count",
    ITEM_COUNT = "item_count",
    REDSTONE_SIGNAL = "redstone_signal",
}

Triggers.CONDITION_TYPES = {
    COUNT_GREATER = "count_greater",
    COUNT_LESS = "count_less",
    COUNT_EQUAL = "count_equal"
}

Triggers.eval = function(triggerStatement, getFn)
    -- If no trigger statement or invalid structure, return true (no restrictions)
    if not triggerStatement or not triggerStatement.children then
        return true
    end
    
    for _, childNode in ipairs(triggerStatement.children) do
        if Triggers.evalTriggerNode(childNode, getFn) then
            return true
        end
    end
    
    return false -- All children passed
end

-- Evaluate a single trigger node and its children
Triggers.evalTriggerNode = function(node, getFn)
    if not node or not node.data then
        return true -- Invalid node, skip
    end
    
    local data = node.data
    local nodeResult = false
    
    -- Evaluate current node based on its trigger type
    if data.triggerType == Triggers.TYPES.ITEM_COUNT then
        nodeResult = Triggers.evalItemCountTrigger(data, getFn)
    elseif data.triggerType == Triggers.TYPES.FLUID_COUNT then
        nodeResult = Triggers.evalFluidCountTrigger(data, getFn)
    elseif data.triggerType == Triggers.TYPES.REDSTONE_SIGNAL then
        nodeResult = Triggers.evalRedstoneSignalTrigger(data, getFn)
    else
        return true -- Unknown type, skip
    end
    
    -- Evaluate children with OR logic
    local childrenResult = true
    if node.children and #node.children > 0 then
        childrenResult = false -- Start with false for OR logic
        for _, childNode in ipairs(node.children) do
            if Triggers.evalTriggerNode(childNode, getFn) then
                childrenResult = true -- If any child passes, children pass (OR logic)
                break
            end
        end
    end
    
    -- Return AND of parent node and children result
    return nodeResult and childrenResult
end

-- Evaluate ITEM_COUNT trigger using getFn
Triggers.evalItemCountTrigger = function(data, getFn)
    if not data.itemName or not getFn then
        return false
    end
    
    local currentCount = 0
    local item = getFn("item", data.itemName)
    if item then
        currentCount = item.count or 0
    end
    return Triggers.evalCondition(currentCount, data.amount, data.triggerConditionType)
end

-- Evaluate FLUID_COUNT trigger using getFn
Triggers.evalFluidCountTrigger = function(data, getFn)
    if not data.itemName or not getFn then
        return false
    end

    local currentAmount = 0
    local fluid = getFn("fluid", data.itemName)
    if fluid then
        currentAmount = fluid.amount or 0
    end
    return Triggers.evalCondition(currentAmount, data.amount, data.triggerConditionType)
end

-- Evaluate REDSTONE_SIGNAL trigger (placeholder implementation)
Triggers.evalRedstoneSignalTrigger = function(data, getFn)
    -- TODO: Implement redstone signal evaluation
    -- For now, always return true as placeholder
    return true
end

-- Helper function to evaluate condition based on condition type
Triggers.evalCondition = function(currentValue, targetValue, conditionType)
    if conditionType == Triggers.CONDITION_TYPES.COUNT_GREATER then
        return currentValue > targetValue
    elseif conditionType == Triggers.CONDITION_TYPES.COUNT_LESS then
        return currentValue < targetValue
    elseif conditionType == Triggers.CONDITION_TYPES.COUNT_EQUAL then
        return currentValue == targetValue
    else
        return false
    end
end

return Triggers end
modules["wrapper.PeripheralWrapper"] = function(...) local Logger = require("utils.Logger")

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

        peripheral.transferItemFrom = function(fromPeripheral, itemName, amount)
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
                    cacheIndex = index    -- Cache the index for future calls
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

    peripheral.transferFluidTo = function(toPeripheral, fluidName, amount)
        if toPeripheral.isTank() == false then
            error(string.format("Peripheral '%s' is not a tank", toPeripheral.getName()))
        end
        local totalTransferred = 0
        while totalTransferred < amount do
            local transferred = peripheral.pushFluid(toPeripheral.getName(), amount - totalTransferred, fluidName)
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
        local sides = {...}
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
        local sides = {...}
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
        local sides = {...}
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
 end
modules["utils.TableUtils"] = function(...) local TableUtils = {}


TableUtils.findInArray = function(array, predicate)
    if array == nil or predicate == nil then
        return nil
    end
    for i, v in ipairs(array) do
        if predicate(v) then
            return i  -- return index
        end
    end
    return nil  -- not found
end


TableUtils.getLength = function(t)
    if t == nil then
        return 0
    end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

TableUtils.getAllKeyValueAsTreeString = function(t, indent, visited)
    indent = indent or ""
    visited = visited or {}

    if visited[t] then
        return indent .. "<circular reference>\n"
    end
    visited[t] = true

    local result = indent .. "{\n"
    for k, v in pairs(t) do
        result = result .. indent .. "  [" .. tostring(k) .. "] = "
        if type(v) == "table" then
            result = result .. TableUtils.getAllKeyValueAsTreeString(v, indent .. "  ", visited)
        elseif type(v) == "function" then
            result = result .. "function\n"
        else
            result = result .. tostring(v) .. "\n"
        end
    end
    result = result .. indent .. "}\n"
    return result
end


return TableUtils
 end
return modules["programs.CaDepot"](...)
