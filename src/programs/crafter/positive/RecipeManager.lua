local OSUtils = require("utils.OSUtils")
local TableUtils = require("utils.TableUtils")
local Logger = require("utils.Logger")

local RecipeManager = {}

RecipeManager.recipes = {}

RecipeManager._hasUpdated = true

RecipeManager.recipeCloneCache = {}

local clone = function(recipe)
    return textutils.unserialize(textutils.serialize(recipe))
end

local validateRecipe = function(recipe)
    if type(recipe) ~= "table" then
        return false, "Recipe must be a table"
    end
    if type(recipe.output) ~= "string" or recipe.output == "" then
        return false, "Recipe output must be a non-empty string"
    end
    if type(recipe.inputs) ~= "table" then
        return false, "Recipe inputs must be a table"
    end
    if next(recipe.inputs) == nil then
        return false, "Recipe inputs must not be empty"
    end
    if recipe.trigger == nil then
        return false, "Recipe trigger must be defined"
    end
    if recipe.maxInputs ~= nil and (type(recipe.maxInputs) ~= "number" or recipe.maxInputs < 1 or recipe.maxInputs > 64) then
        return false, "Recipe maxInputs must be a number between 1 and 64"
    end
    return true
end

function RecipeManager.addRecipe(recipe)
    local isValid, errMsg = validateRecipe(recipe)
    Logger.debug("isValid: {}, errMsg: {}", tostring(isValid), tostring(errMsg))
    if not isValid then
        return false, errMsg
    end
    local newRecipe = clone(recipe)
    RecipeManager.recipes[recipe.output] = newRecipe
    RecipeManager.save()
    return true
end

function RecipeManager.getRecipes()
    return clone(RecipeManager.recipes)
end

function RecipeManager.getRecipe(output)
    return clone(RecipeManager.recipes[output])
end

function RecipeManager.removeRecipe(recipe)
    RecipeManager.recipes[recipe.output] = nil
    RecipeManager.save()
end

function RecipeManager.size()
    return TableUtils.getLength(RecipeManager.recipes)
end

function RecipeManager.hasUpdate()
    return RecipeManager._hasUpdated
end

function RecipeManager.checkedUpdate()
    if RecipeManager._hasUpdated then
        RecipeManager._hasUpdated = false
        return true
    end
    return false
end

function RecipeManager.save()
    RecipeManager._hasUpdated = true
    OSUtils.saveTable("recipes.dat", RecipeManager.recipes)
end

function RecipeManager.load()
    local data = OSUtils.loadTable("recipes.dat")
    if data then
        RecipeManager.recipes = data
    else
        RecipeManager.recipes = {}
    end
end

return RecipeManager
