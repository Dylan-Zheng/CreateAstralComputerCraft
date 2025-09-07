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
    local data = OSUtils.loadTable("cacrusher_recipes")
    if data ~= nil then
        recipes = data
    end
end

-- Save recipes to file
local function saveRecipes()
    OSUtils.saveTable("cacrusher_recipes", recipes)
end

-- Load communicator config from file
local function loadCommunicatorConfig()
    return OSUtils.loadTable("cacrusher_communicator_config")
end

-- Save communicator config to file
local function saveCommunicatorConfig(side, channel, secret)
    local config = {
        side = side,
        channel = channel,
        secret = secret
    }
    OSUtils.saveTable("cacrusher_communicator_config", config)
end

-- Get recipe by name
local function getRecipeByName(recipeName)
    for _, recipe in ipairs(recipes) do
        if recipe.name == recipeName then
            return recipe
        end
    end
    return nil
end

-- Remove recipe by name
local function removeRecipeByName(recipeName)
    for i, recipe in ipairs(recipes) do
        if recipe.name == recipeName then
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

    print(string.format("=== Crusher Recipes (Page %d/%d) ===", page, totalPages))
    for i = startIdx, endIdx do
        local recipe = recipeList[i]
        print(string.format("%d. %s", i, recipe.name or "Unnamed"))
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
    local cli = CommandLine:new("cacrusher> ")

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

    -- Add recipe command (from remote by name)
    cli:addCommand("add", "Add recipe(s) from remote", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: add [recipe_name] or add all")
            print("Examples:")
            print("  add 'Iron Ore Crushing'    - Add specific recipe")
            print("  add all                     - Add all remote recipes")
            print("Use 'list recipe remote' to see available recipes")
            return
        end

        local recipeName = table.concat(parts, " ", 2) -- Join all parts after "add"

        if recipeName == "all" then
            -- Add all remote recipes
            if #remoteRecipes == 0 then
                print("No remote recipes available.")
                print("Use 'list recipe remote' to see available remote recipes")
                return
            end

            local addedCount = 0
            local skippedCount = 0

            for _, remoteRecipe in ipairs(remoteRecipes) do
                -- Check if recipe already exists locally
                if not getRecipeByName(remoteRecipe.name) then
                    local newRecipe = {
                        id = remoteRecipe.id,
                        name = remoteRecipe.name,
                        input = remoteRecipe.input,
                        output = remoteRecipe.output,
                        trigger = remoteRecipe.trigger,
                        maxMachine = remoteRecipe.maxMachine or -1,
                        inputItemRate = remoteRecipe.inputItemRate or 1,
                        inputFluidRate = remoteRecipe.inputFluidRate or 1
                    }
                    table.insert(recipes, newRecipe)
                    addedCount = addedCount + 1
                else
                    skippedCount = skippedCount + 1
                end
            end

            saveRecipes()
            print("Batch add completed:")
            print("  Added: " .. addedCount .. " recipes")
            if skippedCount > 0 then
                print("  Skipped: " .. skippedCount .. " recipes (already exist)")
            end
        else
            -- Add specific recipe by name
            local remoteRecipe = nil
            for _, recipe in ipairs(remoteRecipes) do
                if recipe.name == recipeName then
                    remoteRecipe = recipe
                    break
                end
            end

            if not remoteRecipe then
                print("Remote recipe '" .. recipeName .. "' not found")
                print("Use 'list recipe remote' to see available remote recipes")
                return
            end

            -- Check if recipe already exists locally
            if getRecipeByName(recipeName) then
                print("Recipe '" .. recipeName .. "' already exists locally")
                return
            end

            -- Copy the remote recipe to local
            local newRecipe = {
                id = remoteRecipe.id,
                name = remoteRecipe.name,
                input = remoteRecipe.input,
                output = remoteRecipe.output,
                trigger = remoteRecipe.trigger,
                maxMachine = remoteRecipe.maxMachine or -1,
                inputItemRate = remoteRecipe.inputItemRate or 1,
                inputFluidRate = remoteRecipe.inputFluidRate or 1
            }

            table.insert(recipes, newRecipe)
            saveRecipes()
            print("Recipe added from remote successfully:")
            print("  Name: " .. newRecipe.name)
            local inputStr = newRecipe.input and newRecipe.input.items and table.concat(newRecipe.input.items, ", ") or
                "No input"
            local outputStr = newRecipe.output and newRecipe.output.items and table.concat(newRecipe.output.items, ", ") or
                "No output"
            print("  Input: " .. inputStr)
            print("  Output: " .. outputStr)
        end
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts >= 1 then
            -- Provide recipe name completion from remote recipes
            local partial = text:match("%S+$") or ""
            local suggestions = {}

            -- Add "all" option
            if ("all"):find(partial, 1, true) == 1 then
                table.insert(suggestions, ("all"):sub(#partial + 1))
            end

            -- Add remote recipe names
            for _, recipe in ipairs(remoteRecipes) do
                if recipe.name and recipe.name:lower():find(partial:lower(), 1, true) == 1 then
                    table.insert(suggestions, recipe.name:sub(#partial + 1))
                end
            end
            return suggestions
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
            print("Usage: rm [recipe_name]")
            return
        end

        local recipeName = table.concat(parts, " ", 2) -- Join all parts after "rm"

        -- Remove by name
        local removed = false
        local removedRecipe = nil

        for i, recipe in ipairs(recipes) do
            if recipe.name == recipeName then
                removedRecipe = recipe
                table.remove(recipes, i)
                removed = true
                break
            end
        end

        if removed and removedRecipe then
            saveRecipes()
            print("Recipe removed: " .. (removedRecipe.name or "Unknown"))
        else
            print("Recipe '" .. recipeName .. "' not found")
        end
    end, function(text)
        -- Provide completion for recipe names
        local suggestions = {}
        local partial = text:match("%S+$") or ""

        for _, recipe in ipairs(recipes) do
            if recipe.name and recipe.name:lower():find(partial:lower(), 1, true) == 1 then
                table.insert(suggestions, recipe.name:sub(#partial + 1))
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
            local allRecipes = payload or {}
            remoteRecipes = {}
            -- Filter recipes that start with "crush"
            for _, recipe in ipairs(allRecipes) do
                if recipe.name and recipe.name:lower():find("^crush") then
                    table.insert(remoteRecipes, recipe)
                end
            end
        end)

        parallel.waitForAll(Communicator.listen,
            function()
                while next(remoteRecipes) == nil do
                    openChannel.send("getRecipesReq", "common")
                    sleep(1) -- Wait for response
                end
            end,
            runCommandLine
        )
    end
end

PeripheralWrapper.reloadAll()

local crushers = PeripheralWrapper.getAllPeripheralsNameContains("create:crushing_wheel")
local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
local storage = storages[next(storages)]

local redrouters = PeripheralWrapper.getAllPeripheralsNameContains("redrouter")
local redrouter = redrouters[next(redrouters)]

local totalCrushers = TableUtils.getLength(crushers)

local marker = {
    recipeOnCrusher = {},
    crusherOnUse = {},
    lostTrackCrushers = {},

    init = function(self)
        for _, recipe in ipairs(recipes) do
            if self.recipeOnCrusher[recipe.id] == nil then
                self.recipeOnCrusher[recipe.id] = {
                    recipe = recipe,
                    crushers = {}
                }
            end
        end
        for _, crusher in pairs(crushers) do
            if self.crusherOnUse[crusher.getId()] == nil then
                self.crusherOnUse[crusher.getId()] = {
                    onUse = false,
                    crusher = crusher,
                    recipe = nil
                }
            end
        end
    end,

    set = function(self, recipe, crusher)
        local crusherOnUseInfo = self.crusherOnUse[crusher.getId()]
        crusherOnUseInfo.onUse = true
        crusherOnUseInfo.recipe = recipe
        if self.recipeOnCrusher[recipe.id] == nil then
            self.recipeOnCrusher[recipe.id] = {
                recipe = recipe,
                crushers = {},
                count = 0
            }
        end
        local recipeOnCrusherInfo = self.recipeOnCrusher[recipe.id]
        recipeOnCrusherInfo.crushers[crusher.getId()] = crusher
        recipeOnCrusherInfo.count = (recipeOnCrusherInfo.count or 0) + 1
    end,

    remove = function(self, crusher)
        local recipe = self.crusherOnUse[crusher.getId()].recipe
        self.crusherOnUse[crusher.getId()].onUse = false
        self.crusherOnUse[crusher.getId()].recipe = nil
        if self.recipeOnCrusher[recipe.id] == nil then
            self.recipeOnCrusher[recipe.id] = {
                recipe = recipe,
                crushers = {},
                count = 0
            }
        end
        self.recipeOnCrusher[recipe.id].crushers[crusher.getId()] = nil
        self.recipeOnCrusher[recipe.id].count = math.max(0, (self.recipeOnCrusher[recipe.id].count or 0) - 1)
    end,

    isUsing = function(self, crusher)
        return self.crusherOnUse[crusher.getId()].onUse
    end,

    getOnUseCrusherCountForRecipe = function(self, recipe)
        if not self.recipeOnCrusher[recipe.id] then
            self.recipeOnCrusher[recipe.id] = {
                recipe = recipe,
                crushers = {},
                count = 0
            }
        end
        return self.recipeOnCrusher[recipe.id].count or 0
    end,
}

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
                -- Update existing recipe
                recipes[existingIndex] = newRecipe
            end
        end
    end

    -- Save updated recipes
    saveRecipes()
    -- Reinitialize marker after recipe update
    marker:init()
end

marker:init()

local checkAndRunRecipe = function()
    while true do
        local triggeredRecipes = {}
        for _, recipe in ipairs(recipes) do
            if recipe.trigger  then
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
                else
                    local count = marker:getOnUseCrusherCountForRecipe(recipe)
                    if count > 0 then
                        for _, crusher in pairs(marker.recipeOnCrusher[recipe.id].crushers) do
                            marker:remove(crusher)
                        end
                    end
                end
            end
        end

        local waitTime = 1

        local currentTriggeredRecipeCount = #triggeredRecipes
        if currentTriggeredRecipeCount > 0 then
            waitTime = 0.2
            redrouter.setOutputSignals(true)
            local currentTotalCrushers = totalCrushers

            local numOfCrushersForEachRecipe = math.max(1,
                math.floor(currentTotalCrushers / math.max(1, currentTriggeredRecipeCount)))

            for _, recipe in ipairs(triggeredRecipes) do
                local usedCrushersCount = marker:getOnUseCrusherCountForRecipe(recipe)
                local maxMachineForRecipe

                if recipe.maxMachine and recipe.maxMachine > 0 then
                    maxMachineForRecipe = math.min(numOfCrushersForEachRecipe, recipe.maxMachine)
                else
                    maxMachineForRecipe = numOfCrushersForEachRecipe
                end

                if usedCrushersCount > maxMachineForRecipe then
                    local toRemove = usedCrushersCount - maxMachineForRecipe
                    for _, crusher in pairs(marker.recipeOnCrusher[recipe.id].crushers) do
                        if toRemove <= 0 then
                            break
                        end
                        marker:remove(crusher)
                        toRemove = toRemove - 1
                    end
                    usedCrushersCount = marker:getOnUseCrusherCountForRecipe(recipe) -- Update count after removal
                end

                if usedCrushersCount < maxMachineForRecipe then
                    local crusherNeeded = maxMachineForRecipe - usedCrushersCount
                    for _, crusher in pairs(crushers) do
                        if crusherNeeded <= 0 then
                            break
                        end
                        if not marker:isUsing(crusher) then
                            marker:set(recipe, crusher)
                            crusherNeeded = crusherNeeded - 1
                        end
                    end
                end

                -- Transfer items to all crushers assigned to this recipe
                if recipe.input and recipe.input.items and #recipe.input.items > 0 then
                    for _, crusher in pairs(marker.recipeOnCrusher[recipe.id].crushers) do
                        for _, inputItem in ipairs(recipe.input.items) do
                            local transferAmount = math.min(64, recipe.inputItemRate or 64)
                            storage.transferItemTo(crusher, inputItem, transferAmount)
                        end
                    end
                end
                -- Subtract the allocated crushers for this recipe (not just the ones currently in use)
                currentTotalCrushers = currentTotalCrushers - maxMachineForRecipe
                currentTriggeredRecipeCount = currentTriggeredRecipeCount - 1
                numOfCrushersForEachRecipe = math.max(1,
                    math.floor(currentTotalCrushers / math.max(1, currentTriggeredRecipeCount)))
            end
        else
            redrouter.setOutputSignals(false)
        end
        sleep(waitTime)
    end
end

local runChannel = function()
    local config = loadCommunicatorConfig()
    if config and config.side and config.channel and config.secret then
        Communicator.open(config.side, config.channel, "recipe", config.secret)
        local openChannel = Communicator.communicationChannels[config.side][config.channel]["recipe"]
        openChannel.addMessageHandler("getRecipesRes", function(eventCode, payload, senderId)
            local allRecipes = payload or {}
            remoteRecipes = {}
            -- Filter recipes that start with "crush"
            for _, recipe in ipairs(allRecipes) do
                if recipe.name and recipe.name:lower():find("^crush") then
                    table.insert(remoteRecipes, recipe)
                end
            end
        end)

        -- Add update event handler
        openChannel.addMessageHandler("update", function(eventCode, payload, senderId)
            if payload and type(payload) == "table" then
                -- Filter update payload for crush recipes only
                local crushRecipes = {}
                for _, recipe in ipairs(payload) do
                    if recipe.name and recipe.name:lower():find("^crush") then
                        table.insert(crushRecipes, recipe)
                    end
                end
                if #crushRecipes > 0 then
                    updateRecipesByID(crushRecipes)
                end
                openChannel.send("getRecipesReq", "common")
            end
        end)
        Communicator.listen()
    end
end

parallel.waitForAll(
    runChannel,
    checkAndRunRecipe,
    runCommandLine
)
