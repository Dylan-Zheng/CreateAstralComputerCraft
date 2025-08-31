local basalt = require("libraries.basalt")
local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local StoreManager = require("programs.recipe.manager.StoreManager")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local SnapShot = require("programs.common.SnapShot")
local StringUtils = require("utils.StringUtils")
local TriggerView = require("programs.recipe.manager.TriggerView")
local MessageBox = require("elements.MessageBox")
local ConfirmMessageBox = require("elements.ConfirmMessageBox")
local RecipeList = require("programs.recipe.manager.RecipeList")
local Utils = require("programs.recipe.manager.Utils")

---@diagnostic disable-next-line: undefined-global
local colors = colors

local DepotTypeName = {
    [StoreManager.DEPOT_TYPES.NONE] = "None",
    [StoreManager.DEPOT_TYPES.FIRE] = "Fire",
    [StoreManager.DEPOT_TYPES.SOUL_FIRE] = "Soul Fire",
    [StoreManager.DEPOT_TYPES.LAVA] = "Lava",
    [StoreManager.DEPOT_TYPES.WATER] = "Water",
}

local getDepotTypeDisplayItems = function(selectedValue)
    local items = {}
    for key, value in pairs(StoreManager.DEPOT_TYPES) do
        table.insert(items, {
            text = DepotTypeName[value],
            value = value,
            selected = value == selectedValue,
        })
    end
    return items
end


DepotRecipeTab = {}
DepotRecipeTab.__index = DepotRecipeTab

local function getDisplayName(fullName)
    if not fullName then return "" end
    local colonPos = fullName:find(":")
    if colonPos then
        return fullName:sub(colonPos + 1)  -- Return everything after the colon
    end
    return fullName  -- Return as-is if no colon found
end

local getDisplayRecipeList = function(filterText)
    local recipes = StoreManager.getAllRecipesByType(StoreManager.MACHINE_TYPES.depot)
    local displayList = {}

    for _, recipe in ipairs(recipes) do
        if not filterText or recipe.input:lower():find(filterText:lower()) then
            table.insert(displayList, {
                text = getDisplayName(recipe.input),
                id = recipe.id
            })
        end
    end

    return displayList
end

function DepotRecipeTab:new(pframe)
    local this = setmetatable({}, DepotRecipeTab)
    
    this.pframe = pframe

    this.selectedRecipe = nil

    this.innerFrame = this.pframe:addFrame()
        :setPosition(1,1)
        :setSize(this.pframe:getWidth(), this.pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    
    this.recipeListBox = RecipeList:new(this.innerFrame, 1, 1, 22, this.innerFrame:getHeight())
        :setOnSelected(function(recipe)
            if recipe then
                this.selectedRecipe = StoreManager.getRecipeByTypeAndId(StoreManager.MACHINE_TYPES.depot, recipe.id)
                if this.selectedRecipe then
                    this.inputLabel:setText("In: " .. StringUtils.ellipsisMiddle(this.selectedRecipe.input, this.inputLabel:getWidth() - 4))
                    this.outputLabel:setText("Out: " .. #this.selectedRecipe.output)
                    this.depotTypeDropdown:setItems(getDepotTypeDisplayItems(this.selectedRecipe.depotType))
                else
                    this.messageBox:open("Error", "Recipe not found!")
                end
            else
                this.selectedRecipe = nil
                this.inputLabel:setText("In: ")
                this.outputLabel:setText("Out: ")
                this.depotTypeDropdown:setItems(getDepotTypeDisplayItems())
            end
            this.recipeListBox:refreshRecipeList()
        end)
        :setOnNew(function()
            this:addNewRecipe()
        end)
        :setOnDel(function()
            if this.selectedRecipe == nil or this.selectedRecipe.id == nil then
                this.messageBox:open("Error", "No recipe selected to delete!")
                return
            end
            this.confirmMessageBox:open("Confirm", "Are you sure to delete the selected recipe: " .. getDisplayName(this.selectedRecipe.input) .. "?", function()
                    local success, errMsg = StoreManager.removeRecipe(StoreManager.MACHINE_TYPES.depot, this.selectedRecipe.id)
                    if not success then
                        this.messageBox:open("Error", "Failed to delete recipe! " .. tostring(errMsg))
                        return
                    end
                    this.selectedRecipe = nil
                    this.inputLabel:setText("In: ")
                    this.outputLabel:setText("Out: ")
                    this.recipeListBox:refreshRecipeList()
                    this.messageBox:open("Success", "Recipe deleted successfully!")
            end)
            
        end)
        :setGetDisplayRecipeListFn(getDisplayRecipeList)
        :setOnUpdate(function()
            -- Send all depot recipes via Communicator
            local allRecipes = StoreManager.getAllRecipesByType(StoreManager.MACHINE_TYPES.depot)
            if Communicator and Communicator.communicationChannels then
                for side, channels in pairs(Communicator.communicationChannels) do
                    for channel, topics in pairs(channels) do
                        for topic, openChannel in pairs(topics) do
                            if topic == "recipe" then
                                openChannel.send("update", allRecipes)
                                Logger.info("Sent {} depot recipes via update event", #allRecipes)
                            end
                        end
                    end
                end
            else
                Logger.warn("Communicator not available for sending updates")
            end
        end)

    this.detailFrame = this.innerFrame:addFrame()
        :setPosition(this.recipeListBox.innerFrame:getX() + this.recipeListBox.innerFrame:getWidth() + 1, 2)
        :setSize(this.innerFrame:getWidth() - (this.recipeListBox.innerFrame:getX() + this.recipeListBox.innerFrame:getWidth() + 1), this.innerFrame:getHeight() - 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.inputLabel = this.detailFrame:addLabel()
        :setPosition(2,2)
        :setAutoSize(false)
        :setWidth(this.detailFrame:getWidth() - 6)
        :setText("In: ")
        :setBackground(colors.black)
        :setForeground(colors.white)

    this.inputEditBtn = this.detailFrame:addButton()
        :setPosition(this.detailFrame:getWidth() - 3, this.inputLabel:getY())
        :setSize(3,1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedInputs = nil
            if this.selectedRecipe ~=nil and this.selectedRecipe.input ~= nil then
                selectedInputs = {[this.selectedRecipe.input]=true}
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedInputs, SnapShot.items), false, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local inputName = selectedItems[1].text
                    this.inputLabel:setText("In: " .. StringUtils.ellipsisMiddle(inputName, this.inputLabel:getWidth() - 4))
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.input = inputName
                else
                    this.inputLabel:setText("In: ")
                    if this.selectedRecipe then
                        this.selectedRecipe.input = nil
                    end
                end
                this.itemListBox:close()
            end})
        end)

    this.outputLabel = this.detailFrame:addLabel()
        :setPosition(2, this.inputLabel:getY() + this.inputLabel:getHeight() + 1)
        :setAutoSize(false)
        :setWidth(this.detailFrame:getWidth() - 6)
        :setText("Out: ")
        :setBackground(colors.black)
        :setForeground(colors.white)

    this.outputEditBtn = this.detailFrame:addButton()
        :setPosition(this.detailFrame:getWidth() - 3, this.outputLabel:getY())
        :setSize(3,1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedOutputs = nil
            if this.selectedRecipe ~=nil and this.selectedRecipe.output ~= nil then
                selectedOutputs = {}
                for _, output in ipairs(this.selectedRecipe.output) do
                    selectedOutputs[output] = true
                end
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedOutputs, SnapShot.items), true, {confirm = function(selectedItems)
                if selectedItems then
                    local outputNames = {}
                    for _, item in ipairs(selectedItems) do
                        table.insert(outputNames, item.text)
                    end
                    this.outputLabel:setText("Out: " .. #outputNames)
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.output = outputNames
                else
                    this.outputLabel:setText("Out: ")
                    if this.selectedRecipe then
                        this.selectedRecipe.output = nil
                    end
                end
                this.itemListBox:close()
            end})
        end)

    this.typeLabel = this.detailFrame:addLabel()
        :setPosition(2, this.outputLabel:getY() + this.outputLabel:getHeight() + 1)
        :setText("Type: ")
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.depotTypeDropdown = this.detailFrame:addDropdown()
        :setPosition(this.typeLabel:getX() + this.typeLabel:getWidth() + 1, this.typeLabel:getY())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setSize(10, 1)
        :setItems(getDepotTypeDisplayItems())
        :onSelect(function(_, _, item)
            this.selectedRecipe = this.selectedRecipe or {}
            this.selectedRecipe.depotType = item.value
        end)

    local setTiggerBtnText = "Set Trigger"
    this.setTriggerBtn = this.detailFrame:addButton()
        :setPosition(2, this.depotTypeDropdown:getY() + this.depotTypeDropdown:getHeight() + 1)
        :setSize(#setTiggerBtnText, 1)
        :setText(setTiggerBtnText)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            this.trigger:open(this.selectedRecipe and this.selectedRecipe.trigger or nil, function(trigger) 
                this.selectedRecipe = this.selectedRecipe or {}
                this.selectedRecipe.trigger = trigger
            end)
        end)

    local clearTriggerBtnText = "Clr Trigger"
    this.clearTriggerBtn = this.detailFrame:addButton()
        :setPosition(this.setTriggerBtn:getX() + this.setTriggerBtn:getWidth() + 3, this.setTriggerBtn:getY())
        :setSize(#clearTriggerBtnText, 1)
        :setText(clearTriggerBtnText)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            if this.selectedRecipe then
                this.selectedRecipe.trigger = nil
            end
        end)

    this.saveBtn = this.detailFrame:addButton()
        :setPosition(this.detailFrame:getWidth() - 6, this.detailFrame:getHeight() - 1)
        :setSize(6,1)
        :setText("Save")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :onClick(function()
            if this.selectedRecipe == nil then
                this.messageBox:open("Error", "No recipe selected to save!")
                return
            end
            
            if this.selectedRecipe.id ~= nil then
                local success = StoreManager.updateRecipe(StoreManager.MACHINE_TYPES.depot, textutils.unserialize(textutils.serialize(this.selectedRecipe))   )
                if not success then
                    this.messageBox:open("Error", "Failed to update recipe!")
                    return
                end
                this.recipeListBox:refreshRecipeList()
                this.messageBox:open("Success", "Recipe updated successfully!")
                return
            else 
                local success, id = StoreManager.addRecipe(StoreManager.MACHINE_TYPES.depot, textutils.unserialize(textutils.serialize(this.selectedRecipe)))
                if not success then
                    this.messageBox:open("Error", "Failed to add recipe!")
                    return
                end
                this.selectedRecipe.id = id
                this.recipeListBox:refreshRecipeList()
                this.messageBox:open("Success", "Recipe added successfully!")
            end
        end)

    this.itemListBox = ItemSelectedListBox:new(this.pframe)
    this.trigger = TriggerView:new(this.pframe)
    this.messageBox = MessageBox:new(this.pframe)
    this.confirmMessageBox = ConfirmMessageBox:new(this.pframe)
    
    return this
end

function DepotRecipeTab:addNewRecipe()
    self.selectedRecipe = nil
    self.inputLabel:setText("In: ")
    self.outputLabel:setText("Out: ")
end

function DepotRecipeTab:init()
    self.recipeListBox:refreshRecipeList()
    return self
end

return DepotRecipeTab