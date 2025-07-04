local StringUtils = require("utils.StringUtils")
local ContainerLoader = require("utils.ContainerLoader")
local OSUtils = require("utils.OSUtils")
local Logger = require("utils.Logger")

local MessageBox = require("elements.MessageBox")

local inputSlots = {1, 2, 3, 10, 11, 12, 19, 20, 21}

local CraftingListTab = {}

CraftingListTab.__index = CraftingListTab

function CraftingListTab:new(pframe)

    local instance = setmetatable({}, CraftingListTab)

    instance.recipes = {}

    instance.frame = pframe

    local _, patternChest = next(ContainerLoader.load.trapped_chests())
    instance.patternChest = patternChest

    instance.list = pframe:addList()
        :setPosition(2, 2)
        :setSize(15, pframe:getHeight() - 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onSelect(function(_, _, item) 
            if item and item.mark and item.mark.nbt then
                local displayText = textutils.serialize({
                    input = item.input,
                    output = item.output,
                    mark = item.mark,
                })
                instance.textBox:setText(displayText)
            else
                instance.textBox:setText("")
            end
        end)

    Logger.debug("CraftingListTab: List created")

    instance.textBox = pframe:addTextBox()
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setPosition(instance.list:getWidth() + instance.list:getX() + 2, 2)
        :setSize(pframe:getWidth() - instance.list:getWidth() - 4, pframe:getHeight() - 2)
        :setText("")


    instance.readBtn = pframe:addButton()
        :setText("Read")
        :setPosition(instance.list:getX(), pframe:getHeight() - 1)
        :setSize(4, 1)
        :setBackground(colors.lightBlue)
        :setForeground(colors.white)
        :onClick(function()
            local ok, result = pcall(function() 
                local input = {}
                local output = instance.patternChest.getItemDetail(4)
                if not output or not output.name then
                    instance.messageBox:open("Error", "No valid output item found in slot 4.")
                    return
                end
                local mark = instance.patternChest.getItemDetail(13)
                if not mark or not mark.name or not mark.nbt then
                    instance.messageBox:open("Error", "No valid mark item found in slot 13.")
                    return
                end
                for i = 1, 9 do
                    local slot = inputSlots[i]
                    local item = instance.patternChest.getItemDetail(slot)
                    if item and item.name then
                        table.insert(input, {
                            name = item.name,
                            displayName = item.displayName or StringUtils.getDisplayName(item.name),
                        })
                    else
                        table.insert(input, false)
                    end
                end
                local recipe = {
                    input = input,
                    output = {name = output.name, displayName = output.displayName, count = output.count or 1},
                    mark = {name=mark.name, displayName=mark.displayName, nbt=mark.nbt},
                }
                local displayText = textutils.serialize(recipe)
                instance.textBox:setText(displayText)
            end)
            if not ok then
                instance.messageBox:open("Error", "Failed to read recipe: " .. result)
                return
            end
            Logger.debug("CraftingListTab: Recipe read successfully")
        end)

    instance.saveBtn = pframe:addButton()
        :setText("Save")
        :setPosition(instance.readBtn:getX() + instance.readBtn:getWidth() + 2, pframe:getHeight() - 1)
        :setSize(4, 1)
        :setBackground(colors.green)
        :setForeground(colors.white)
        :onClick(function()
            local text = instance.textBox:getText()
            local ok, toAdd = pcall(textutils.unserialize, text)
            if not ok or type(toAdd) ~= "table" or not toAdd.mark or not toAdd.mark.nbt then
                instance.messageBox:open("Error", "Invalid recipe format!\n" .. text)
                return
            end
            local found = false
            for _, recipe in ipairs(instance.recipes) do
                if self:isMarkItemInRecipeInputAndOutput(toAdd.mark, recipe) then
                    instance.messageBox:open("Error", 
                        "Mark Item " .. (toAdd.mark.displayName or "?") ..
                        " is in recipe of " .. (recipe.output and recipe.output.displayName or "?") .. ". Change MarkItem to save the recipe")
                    return
                end
                if recipe.mark.nbt == toAdd.mark.nbt then
                    recipe.input = toAdd.input
                    recipe.output = toAdd.output
                    recipe.mark = toAdd.mark
                    instance:addToMarkTable(toAdd)
                    found = true
                    break
                end
            end
            if not found then
                table.insert(instance.recipes, toAdd)
            end
            instance:addToMarkTable(toAdd)
            instance:saveRecipes()
            instance:updateRcipesList()
        end)

    instance.DelBtn = pframe:addButton()
        :setText("Del")
        :setPosition(instance.saveBtn:getX() + instance.saveBtn:getWidth() + 2, pframe:getHeight() - 1)
        :setSize(3, 1)
        :setBackground(colors.red)
        :setForeground(colors.white)
        :onClick(function()
            local selectedItem = instance.list:getSelectedItem()
            if not selectedItem then
                instance.messageBox:open("Error", "No recipe selected to delete.")
                return
            end
            instance:removeRecipe(selectedItem)
            instance:updateRcipesList()
        end)

    instance.messageBox = MessageBox:new(pframe, 30, 10)

    return instance
end

function CraftingListTab:isMarkItemInRecipeInputAndOutput(markItem, recipe)
    if not markItem or not recipe then
        return false
    end

    -- Check if the mark item is in the input slots
    for _, input in ipairs(recipe.input) do
        if input and input.name == markItem.name then
            return true
        end
    end

    -- Check if the mark item is in the output slot
    if recipe.output and recipe.output.name == markItem.name then
        return true
    end

    return false
end


function CraftingListTab:loadRecipes()
    local recipes = OSUtils.loadTable("crafting_recipes.json")
    if not recipes then
        self.recipes = {}
        return
    end
    self.recipes = recipes
    for _, recipe in ipairs(self.recipes) do
        if recipe.mark and recipe.mark.name and recipe.mark.nbt then
            self:addToMarkTable(recipe)
        end
    end
end

function CraftingListTab:saveRecipes()
     OSUtils.saveTable("crafting_recipes.json", self.recipes)
end

function CraftingListTab:addToMarkTable(recipe)
    if self.markTables == nil then
        self.markTables = {}
    end
    if self.markTables[recipe.mark.name] == nil then
        self.markTables[recipe.mark.name] = {}
    end
    self.markTables[recipe.mark.name][recipe.mark.nbt] = recipe
end

function CraftingListTab:removeFromMarkTable(recipe)
    if self.markTables == nil or not self.markTables[recipe.mark.name] then
        return
    end
    if self.markTables[recipe.mark.name][recipe.mark.nbt] then
        self.markTables[recipe.mark.name][recipe.mark.nbt] = nil
    end
    if next(self.markTables[recipe.mark.name]) == nil then
        self.markTables[recipe.mark.name] = nil
    end
end

function CraftingListTab:removeRecipe(toRemove)
    for i, recipe in ipairs(self.recipes) do
        if recipe.mark.name == toRemove.mark.name and recipe.mark.nbt == toRemove.mark.nbt then
            table.remove(self.recipes, i)
            self:removeFromMarkTable(recipe)
            self:saveRecipes()
            return
        end
    end
end

function CraftingListTab:updateRcipesList()
    local displayList = {}
    for _, recipe in ipairs(self.recipes) do
        local displayRecipe  = {
            input = recipe.input,
            output = recipe.output,
            mark = recipe.mark,
            text = StringUtils.ellipsisMiddle(recipe.output.displayName, 11) .. "  " .. string.sub(recipe.mark.nbt, 1, 3)
        }
        Logger.debug("CraftingListTab: Adding recipe to display list: {}", displayRecipe.text )
        table.insert(displayList, displayRecipe)
    end
    self.list:setItems(displayList)
end

function CraftingListTab:getRecipeByMark(markItem)   
    if not self.markTables or not self.markTables[markItem.name] then
        return nil
    end
    return self.markTables[markItem.name][markItem.nbt]
end

function CraftingListTab:getRecipes()
    return self.recipes
end

function CraftingListTab:getMarkTables()
    return self.markTables
end

function CraftingListTab:init()
    self:loadRecipes()
    self:updateRcipesList()
    return self
end

return CraftingListTab