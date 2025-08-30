local Logger = require("utils.Logger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")

local barrel = nil

local RecipeBarrelLoader = {}

local inputIndexes = {1,2,3, 10,11,12, 19,20,21}
local outputIndex = 4

RecipeBarrelLoader.load = function()

    if not barrel then
        local barrels = PeripheralWrapper.getAllPeripheralsNameContains("barrel")
        local barrelName = next(barrels)
        barrel = barrels[barrelName]
        if not barrel then
            return false, "No barrel found"
        end
    end

    -- Load recipes from the barrel
    local recipe = {
        output = nil,
        inputs = {},
        maxInputs = 64
    }
    for i, slot in pairs(inputIndexes) do
        local item = barrel.getItemDetail(slot)
        if item and item.name then
            recipe.inputs[i] = item.name
        end
    end
    local outputItem = barrel.getItemDetail(outputIndex)
    recipe.output = outputItem and outputItem.name
    return recipe
end

return RecipeBarrelLoader