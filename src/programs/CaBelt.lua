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
    local data = OSUtils.loadTable("cabelt_recipes")
    if data ~= nil then
        recipes = data
    end
end

-- Save recipes to file
local function saveRecipes()
    OSUtils.saveTable("cabelt_recipes", recipes)
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

    print(string.format("=== Belt Recipes (Page %d/%d) ===", page, totalPages))
    for i = startIdx, endIdx do
        local recipe = recipeList[i]
        -- Display recipe output since belt recipes don't have name field
        local recipeOutput = recipe.output or "No Output"
        print(string.format("%d. %s", i, recipeOutput))
    end

    if totalPages > 1 then
        print(string.format("Showing %d-%d of %d recipes", startIdx, endIdx, #recipeList))
        if page < totalPages then
            print(string.format("Use 'list %s %d' for next page", location, page + 1))
        end
        if page > 1 then
            print(string.format("Use 'list %s %d' for previous page", location, page - 1))
        end
    end
end

-- Command line interface
local function createCommandLine()
    local cli = CommandLine:new("cabelt> ")

    -- List command
    cli:addCommand("list", "List recipes", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: list [remote|local] [page]")
            print("Examples:")
            print("  list remote             - List remote recipes")
            print("  list local              - List local recipes")
            print("  list local 2            - List local recipes page 2")
            return
        end

        local location = parts[2]
        local page = tonumber(parts[3]) or 1

        if location == "local" then
            displayRecipes(recipes, page, nil, "local")
        elseif location == "remote" then
            if #remoteRecipes == 0 then
                print("No remote recipes available.")
                return
            end
            displayRecipes(remoteRecipes, page, nil, "remote")
        else
            print("Usage: list [remote|local] [page]")
        end
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end
        local numOfParts = #parts
        if (numOfParts == 0 or numOfParts == 1) and text:sub(-1) ~= " " then
            -- 补全第一个参数 "remote" or "local"
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

    -- Set command
    cli:addCommand("set", "Set belt recipe", function(input)
        local parts = {}
        for word in input:gmatch("%S+") do
            table.insert(parts, word)
        end

        if #parts < 2 then
            print("Usage: set [recipe_output]")
            print("Examples:")
            print("  set minecraft:iron_ingot    - Set recipe with iron_ingot output")
            return
        end

        local recipeOutput = parts[2]

        -- Find recipe by output in remote recipes
        local foundRecipe = nil
        for _, recipe in ipairs(remoteRecipes) do
            if recipe.output == recipeOutput then
                foundRecipe = recipe
                break
            end
        end

        if not foundRecipe then
            print("Recipe with output '" .. recipeOutput .. "' not found in remote recipes.")
            print("Use 'list remote' to see available recipes.")
            return
        end

        -- Set the recipe (for belt, one computer has one recipe)
        recipes = { foundRecipe } -- Replace with single recipe
        saveRecipes()

        print("Recipe set successfully: " .. (foundRecipe.output or "Unknown"))
    end, function(text)
        local parts = {}
        for word in text:gmatch("%S+") do
            table.insert(parts, word)
        end
        local numOfParts = #parts
        if (numOfParts == 0 or numOfParts == 1) and text:sub(-1) ~= " " then
            -- 补全recipe output
            local partial = text:match("%S+$") or ""
            local suggestions = {}
            for _, recipe in ipairs(remoteRecipes) do
                if recipe.output and recipe.output:find(partial, 1, true) == 1 then
                    table.insert(suggestions, recipe.output:sub(#partial + 1))
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

-- Main execution
if args ~= nil and #args >= 3 then
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
                    openChannel.send("getRecipesReq", "belt")
                    os.sleep(1) -- Wait for response
                end
            end,
            function()
                local cli = createCommandLine()
                print("CaBelt Manager - Network Mode")
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
    else
        print("Error: Invalid network parameters")
        print("Usage: cabelt [side] [channel] [secret]")
        print("Example: cabelt top 100 mySecret")
    end
end

PeripheralWrapper.reloadAll()
local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
local key = next(storages) -- Assuming only one storage is available
local storage = storages[key]

local blets = PeripheralWrapper.getAllPeripheralsNameContains("belt")
key = next(blets) -- Assuming only one belt is available
local belt = blets[key]
local drawers = PeripheralWrapper.getAllPeripheralsNameContains("drawer")
key = next(drawers) -- Assuming only one drawer is available
local drawer = drawers[key]

local recipe = recipes[1] -- Assuming only one recipe is set for the belt

parallel.waitForAll(
    function()
        while true do
            local waitTime = 0.2
            if Trigger.eval(recipe.trigger, function(type, name)
                    if type == "item" then
                        return storage.getItem(name)
                    elseif type == "fluid" then
                        return storage.getFluid(name)
                    end
                    return nil
                end) then
                local item = drawer.getItem(recipe.incomplete)
                if item then
                    drawer.transferItemTo(belt, item.name, item.count)
                else
                    storage.transferItemTo(belt, recipe.input, 4)
                end
            else
                waitTime = 1
            end

            os.sleep(waitTime) -- Wait before next execution
        end
    end,
    function()
        while true do
            for _, item in ipairs(drawer.getItems()) do
                if item.name ~= recipe.incomplete and item.name ~= recipe.input then
                    storage.transferItemFrom(drawer, item.name, item.count)
                end
            end
            os.sleep(1)
        end
    end
)
