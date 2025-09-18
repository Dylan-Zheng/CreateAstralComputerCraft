local OSUtils = require("utils.OSUtils")
local Logger = require("utils.Logger")

local Manager = {
    settings = nil,
    recipes = {},
    shadowRecipes = nil,
    shouldUpdateShadowRecipes = false
}

Manager.getSettings = function()
    if not Manager.settings then
        Manager.settings = OSUtils.loadTable("crafterSettings") or {
            crafterSize = {
                width = 0,
                height = 0
            },
            recipesChestSize = {
                width = 0,
                height = 0
            },
            recipesChest = nil
        }
    end
    return Manager.settings
end

Manager.setSettings = function(newSettings)
    Manager.settings = newSettings
    OSUtils.saveTable("crafterSettings", Manager.settings)
end

local XYToIndex = function(x, y, width)
    return (y - 1) * width + x
end

Manager.readRecipesFromChest = function(recipesChest)
    Logger.debug("Reading recipes from chest: {}", recipesChest.getName())

    local settings = Manager.getSettings()

    local rWidth = settings.recipesChestSize.width
    local rHeight = settings.recipesChestSize.height

    local cHeight = settings.crafterSize.height
    local cWidth = settings.crafterSize.width

    if rWidth <= 0 or rHeight <= 0 then
        Logger.error("Invalid recipes chest dimensions: width={}, height={}", rWidth, rHeight)
        return nil
    end

    if cWidth <= 0 or cHeight <= 0 then
        Logger.error("Invalid crafter dimensions: width={}, height={}", cWidth, cHeight)
        return nil
    end

    local recipe = {
        input = {},
        output = nil
    }
    Logger.debug("Crafter size: {}x{}", cWidth, cHeight)
    for y = 1, cHeight do
        for x = 1, cWidth do
            local slotIndex = XYToIndex(x, y, rWidth)
            Logger.debug("Checking slot {}", slotIndex)
            local item = recipesChest.getItemDetail(slotIndex)
            if item then
                Logger.debug("Found item in recipes chest: {} at slot {}", item.name, slotIndex)
                table.insert(recipe.input, item.name)
            else
                Logger.debug("No item in slot {}", slotIndex)
                table.insert(recipe.input, false)
            end
        end
    end

    local output = recipesChest.getItemDetail(rWidth * rHeight)
    if output then
        recipe.output = output.name
    end
    Logger.debug("Output item in recipes chest: {}", recipe.output and recipe.output.name or "nil")

    return recipe
end

Manager._saveRecipes = function()
    Manager.shouldUpdateShadowRecipes = true
    OSUtils.saveTable("crafterRecipes", Manager.recipes)
end

Manager.loadRecipes = function()
    Manager.recipes = OSUtils.loadTable("crafterRecipes") or {}
    return Manager.recipes
end

local getRecipeAndIndexById = function(id)
    for idx, recipe in ipairs(Manager.recipes) do
        if recipe.id == id then
            return recipe, idx
        end
    end
    return nil
end

Manager.updateRecipe = function(recipe)
    if recipe.id == nil then
        recipe.id = OSUtils.timestampBaseIdGenerate()
        table.insert(Manager.recipes, recipe)
    else
        local existingRecipe, index = getRecipeAndIndexById(recipe.id)
        if existingRecipe and index then
            Manager.recipes[index] = recipe
        else
            table.insert(Manager.recipes, recipe)
        end
    end

    Logger.debug("Updating recipe ID: {}", recipe.id)
    recipe.inputItemCount = {}
    for _, itemName in ipairs(recipe.input) do
        Logger.debug("Processing input item: {}", itemName)
        if itemName then
            recipe.inputItemCount[itemName] = (recipe.inputItemCount[itemName] or 0) + 1
        end
    end

    Manager._saveRecipes()
end

Manager.deleteRecipeById = function(id)
    local _, index = getRecipeAndIndexById(id)
    if index then
        table.remove(Manager.recipes, index)
        Manager._saveRecipes()
    end
end

Manager.getRecipes = function()
    if Manager.shouldUpdateShadowRecipes or Manager.shadowRecipes == nil then
        Manager.shouldUpdateShadowRecipes = false
        Manager.shadowRecipes = textutils.unserialize(textutils.serialize(Manager.recipes))
    end
    return Manager.shadowRecipes
end

Manager.loadRecipes()
Manager.getSettings()

return Manager
