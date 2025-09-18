local Trigger = require("programs.common.Trigger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local Manager = require("programs.crafter.create.Manager")
local Logger = require("utils.Logger")

local Executor = {}

local storages = PeripheralWrapper.getAllPeripheralsNameContains("1k_crafting_storage")
local storage = storages[next(storages)]

local quad_drawers = PeripheralWrapper.getAllPeripheralsNameContains("quad_drawer")
local quad_drawer = quad_drawers[next(quad_drawers)]

local redrouters = PeripheralWrapper.getAllPeripheralsNameContains("redrouter")
local redrouter = redrouters[next(redrouters)]

local crafters = (function()
    local map = PeripheralWrapper.getAllPeripheralsNameContains("create:mechanical_crafter")

    local array = {}
    for name, peripheral in pairs(map) do
        table.insert(array, peripheral)
    end

    table.sort(array, function(a, b)
        local numA = tonumber(string.match(a.getName(), "(%d+)$"))
        local numB = tonumber(string.match(b.getName(), "(%d+)$"))
        return numA < numB
    end)

    return array
end)()

local checkInputItemInStorage = function(input)
    for itemName, count in pairs(input) do
        local item = storage.getItem(itemName)
        if not item or item.count < count then
            return false
        end
    end
    return true
end

local getItemFluid = function(type, itemName)
    if type == "item" then
        return storage.getItem(itemName)
    elseif type == "fluid" then
        return storage.getFluid(itemName)
    end
    return nil
end

local waitUntilCraftingComplete = function(outputName)
    local total_sleep = 0
    while true do
        local items = quad_drawer.items()
        if items ~= nil and #items > 0 then
            items[1].name = outputName
            return true
        end
        os.sleep(0.5)
        total_sleep = total_sleep + 0.5
        if total_sleep >= 30 then
            return false
        end
    end
end


Executor.runRecipe = function(recipe)

    if recipe.isDisabled then
        return false, "Recipe is disabled"
    end

    if Trigger.eval(recipe.trigger, getItemFluid) == false then
        return false, "Trigger condition not met"
    end

    if not checkInputItemInStorage(recipe.inputItemCount) then
        return false, "Insufficient input items in storage"
    end

    -- 从storage中取出物品
    for idx, itemName in ipairs(recipe.input) do
        local crafter = crafters[idx]
        local items = crafter.list()
        if #items ~= 0 then
            storage.transferItemFrom(crafter, items[1].name, items[1].count)
        end
        if itemName ~= false then
            storage.transferItemTo(crafter, itemName, 1)
        end
    end
    redrouter.setOutputSignals(true)
    if not waitUntilCraftingComplete(recipe.output.name) then
        redrouter.setOutputSignals(false)
        recipe.isDisabled = true
        return false, "Crafting timed out"
    end
    storage.transferItemFrom(quad_drawer, recipe.output.name, 64)
    redrouter.setOutputSignals(false)
    return true
end

Executor.run = function()
    while true do
        local waitTime = 1
        local recipes = Manager.getRecipes()
        for _, recipe in ipairs(recipes) do
            local success, err = Executor.runRecipe(recipe)
            if not success then
                Logger.error("Failed to run recipe ID: {} Error: {}", recipe.id, err)
            else
                waitTime = 0.1
                Logger.info("Successfully ran recipe ID: {}", recipe.id)
            end
        end
        os.sleep(waitTime)
    end
end

return Executor
