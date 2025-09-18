local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local RecipeInputStoreVerify = require("programs.crafter.positive.RecipeInputStoreVerify")
local Trigger = require("programs.common.Trigger")

local CRAFTING_SLOT = { 1, 2, 3, 5, 6, 7, 9, 10, 11 }

local TurtleCraft = {}


local storage = PeripheralWrapper.wrap("front")
local buffer = PeripheralWrapper.wrap("bottom")

TurtleCraft.setStorage = function(newStorage)
    storage = newStorage
end

TurtleCraft.setBuffer = function(newBuffer)
    buffer = newBuffer
end

local clearBuffer = function()
    local items = buffer.getItems()
    if items then
        for _, item in ipairs(items) do
            storage.transferItemFrom(buffer, item.name, item.count)
        end
    end
end

local clearTurtle = function()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item ~= nil then
            turtle.select(i)
            turtle.dropDown()
            storage.transferItemFrom(buffer, item.name, item.count)
        end
    end
end

local getItemToSlot = function(itemName, count, slot)
    storage.transferItemTo(buffer, itemName, count)
    turtle.select(slot)
    turtle.suckDown()
end

local getAllInputItem = function(recipe)
    for i, itemName in pairs(recipe.inputs) do
        getItemToSlot(itemName, recipe.maxInputs, CRAFTING_SLOT[i])
    end
end

local verifyCraftingSlot = function(recipe)
    for index, slot in ipairs(CRAFTING_SLOT) do
        local expectedItemName = recipe.inputs[index]
        local turtleItem = turtle.getItemDetail(slot)
        local turtleItemName = nil
        if turtleItem ~= nil then
            turtleItemName = turtleItem.name
        end
        if turtleItemName ~= expectedItemName then
            return false
        end
    end
    return true
end

TurtleCraft.storeVerify = function(recipe)
    return RecipeInputStoreVerify.verify(recipe, storage)
end

TurtleCraft.triggerEval = function(recipe)
    return Trigger.eval(recipe.trigger, function(type, itemName)
        if type == "item" then
            return storage.getItem(itemName)
        elseif type == "fluid" then
            return storage.getFluid(itemName)
        end
        return nil
    end)
end

TurtleCraft.craft = function(recipe)
    clearBuffer()
    clearTurtle()

    getAllInputItem(recipe)
    local verified = verifyCraftingSlot(recipe)
    if verified then
        turtle.craft()
    end
    clearBuffer()
    clearTurtle()
    return verified
end

return TurtleCraft
