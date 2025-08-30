local RecipeInputStoreVerify = {}

RecipeInputStoreVerify.verify = function(recipe, storage)

    local itemCounts = {}

    for _, itemName in pairs(recipe.inputs) do
        if not itemCounts[itemName] then
            itemCounts[itemName] = 0
        end
        itemCounts[itemName] = itemCounts[itemName] + recipe.maxInputs
    end

    for itemName, count in pairs(itemCounts) do
        local item = storage.getItem(itemName)
        if item == nil or item.count < count then
            return false
        end
    end
    return true
end

return RecipeInputStoreVerify