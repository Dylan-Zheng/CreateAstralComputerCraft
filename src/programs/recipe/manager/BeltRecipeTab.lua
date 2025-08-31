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
local ScrollableFrame = require("elements.ScrollableFrame")

local BeltRecipeTab = {}
BeltRecipeTab.__index = BeltRecipeTab

local function getDisplayName(fullName)
    if not fullName then return "" end
    local colonPos = fullName:find(":")
    if colonPos then
        return fullName:sub(colonPos + 1)  -- Return everything after the colon
    end
    return fullName  -- Return as-is if no colon found
end

local getDisplayRecipeList = function(filterText)
    local recipes = StoreManager.getAllRecipesByType(StoreManager.MACHINE_TYPES.belt)
    local displayList = {}

    for _, recipe in ipairs(recipes) do
        local searchText = recipe.output or ""
        if not filterText or searchText:lower():find(filterText:lower()) then
            table.insert(displayList, {
                text = getDisplayName(recipe.output),
                id = recipe.id
            })
        end
    end

    return displayList
end

function BeltRecipeTab:new(pframe)
    local this = setmetatable({}, BeltRecipeTab)

    this.selectedRecipe = nil

    this.pframe = pframe

    this.innerFrame = this.pframe:addFrame()
        :setPosition(1, 1)
        :setSize(this.pframe:getWidth(), this.pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.recipeListBox = RecipeList:new(this.innerFrame, 1, 1, 22, this.innerFrame:getHeight())
        :setOnSelected(function(recipe)
            if recipe then
                this.selectedRecipe = StoreManager.getRecipeByTypeAndId(StoreManager.MACHINE_TYPES.belt, recipe.id)
                if this.selectedRecipe then
                    local maxWidth = this.inputLabel:getWidth() - 4  -- Reserve space for "In: " prefix
                    this.inputLabel:setText("In: " .. StringUtils.ellipsisMiddle(getDisplayName(this.selectedRecipe.input or ""), maxWidth))
                    this.incompleteLabel:setText("Incomplete: " .. StringUtils.ellipsisMiddle(getDisplayName(this.selectedRecipe.incomplete or ""), maxWidth - 7))  -- Reserve space for "Incomplete: " prefix
                    this.outputLabel:setText("Out: " .. StringUtils.ellipsisMiddle(getDisplayName(this.selectedRecipe.output or ""), maxWidth - 1))  -- Reserve space for "Out: " prefix
                else
                    this.messageBox:open("Error", "Recipe not found!")
                end
            else
                this.selectedRecipe = nil
                this.inputLabel:setText("In: ")
                this.incompleteLabel:setText("Incomplete: ")
                this.outputLabel:setText("Out: ")
            end
        end)
        :setOnNew(function()
            this.selectedRecipe = nil
            this.inputLabel:setText("In: ")
            this.incompleteLabel:setText("Incomplete: ")
            this.outputLabel:setText("Out: ")
        end)
        :setOnDel(function(recipe)
            if this.selectedRecipe == nil or this.selectedRecipe.id == nil then
                this.messageBox:open("Error", "No recipe selected to delete!")
                return
            end
            this.confirmMessageBox:open("Confirm", "Are you sure to delete the selected recipe: " .. (this.selectedRecipe.input or "Unknown") .. "?", function()
                local success, errMsg = StoreManager.removeRecipe(StoreManager.MACHINE_TYPES.belt, this.selectedRecipe.id)
                if not success then
                    this.messageBox:open("Error", "Failed to delete recipe! " .. tostring(errMsg))
                    return
                end
                this.selectedRecipe = nil
                this.inputLabel:setText("In: ")
                this.incompleteLabel:setText("Incomplete: ")
                this.outputLabel:setText("Out: ")
                this.recipeListBox:refreshRecipeList()
                this.messageBox:open("Success", "Recipe deleted successfully!")
            end)
        end)
        :setGetDisplayRecipeListFn(getDisplayRecipeList)
        :setOnUpdate(function()
            -- Send all belt recipes via Communicator
            local allRecipes = StoreManager.getAllRecipesByType(StoreManager.MACHINE_TYPES.belt)
            if Communicator and Communicator.communicationChannels then
                for side, channels in pairs(Communicator.communicationChannels) do
                    for channel, topics in pairs(channels) do
                        for topic, openChannel in pairs(topics) do
                            if topic == "recipe" then
                                openChannel.send("update", allRecipes)
                                Logger.info("Sent {} belt recipes via update event", #allRecipes)
                            end
                        end
                    end
                end
            else
                Logger.warn("Communicator not available for sending updates")
            end
        end)

    this.detailsFrame = this.innerFrame:addFrame()
        :setPosition(this.recipeListBox.innerFrame:getX() + this.recipeListBox.innerFrame:getWidth(), 2)
        :setSize(this.innerFrame:getWidth() - this.recipeListBox.innerFrame:getWidth() - 1, this.innerFrame:getHeight() - 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.inputLabel = this.detailsFrame:addLabel()
        :setPosition(2,2)
        :setAutoSize(false)
        :setWidth(this.detailsFrame:getWidth() - 6)
        :setText("In: ")
        :setBackground(colors.black)
        :setForeground(colors.white)

    this.inputEditBtn = this.detailsFrame:addButton()
        :setPosition(this.detailsFrame:getWidth() - 3, this.inputLabel:getY())
        :setSize(3,1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedInputs = nil
            if this.selectedRecipe ~= nil and this.selectedRecipe.input ~= nil then
                selectedInputs = {[this.selectedRecipe.input] = true}
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedInputs, SnapShot.items), false, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local inputName = selectedItems[1].text
                    local maxWidth = this.inputLabel:getWidth() - 4  -- Reserve space for "In: " prefix
                    this.inputLabel:setText("In: " .. StringUtils.ellipsisMiddle(getDisplayName(inputName), maxWidth))
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.input = inputName
                else
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.input = nil   
                    this.inputLabel:setText("In: ")
                end
                this.itemListBox:close()
            end})
        end)

    this.incompleteLabel = this.detailsFrame:addLabel()
        :setPosition(2, this.inputLabel:getY() + this.inputLabel:getHeight() + 1)
        :setAutoSize(false)
        :setWidth(this.detailsFrame:getWidth() - 6)
        :setText("Incomplete: ")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.incompleteEditBtn = this.detailsFrame:addButton()
        :setPosition(this.detailsFrame:getWidth() - 3, this.incompleteLabel:getY())
        :setSize(3,1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedIncomplete = nil
            if this.selectedRecipe ~= nil and this.selectedRecipe.incomplete ~= nil then
                selectedIncomplete = {[this.selectedRecipe.incomplete] = true}
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedIncomplete, SnapShot.items), false, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local incompleteItem = selectedItems[1].text
                    local maxWidth = this.incompleteLabel:getWidth() - 12  -- Reserve space for "Incomplete: " prefix
                    this.incompleteLabel:setText("Incomplete: " .. StringUtils.ellipsisMiddle(getDisplayName(incompleteItem), maxWidth))
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.incomplete = incompleteItem
                else
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.incomplete = nil   
                    this.incompleteLabel:setText("Incomplete: ")
                end
                this.itemListBox:close()
            end})
        end)

    this.outputLabel = this.detailsFrame:addLabel()
        :setPosition(2, this.incompleteLabel:getY() + this.incompleteLabel:getHeight() + 1)
        :setAutoSize(false)
        :setWidth(this.detailsFrame:getWidth() - 6)
        :setText("Out: ")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.outputEditBtn = this.detailsFrame:addButton()
        :setPosition(this.detailsFrame:getWidth() - 3, this.outputLabel:getY())
        :setSize(3,1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedOutputs = nil
            if this.selectedRecipe ~= nil and this.selectedRecipe.output ~= nil then
                selectedOutputs = {[this.selectedRecipe.output] = true}
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedOutputs, SnapShot.items), false, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local outputItem = selectedItems[1].text
                    local maxWidth = this.outputLabel:getWidth() - 5  -- Reserve space for "Out: " prefix
                    this.outputLabel:setText("Out: " .. StringUtils.ellipsisMiddle(getDisplayName(outputItem), maxWidth))
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.output = outputItem
                else
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    this.selectedRecipe.output = nil   
                    this.outputLabel:setText("Out: ")
                end
                this.itemListBox:close()
            end})
        end)

    local setTriggerBtnText = "Set Trigger"
    this.addTriggerBtn = this.detailsFrame:addButton()
        :setPosition(2, this.outputLabel:getY() + this.outputLabel:getHeight() + 1)
        :setSize(#setTriggerBtnText, 1)
        :setText(setTriggerBtnText)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            this.trigger:open(this.selectedRecipe and this.selectedRecipe.trigger or nil, function(trigger) 
                this.selectedRecipe = this.selectedRecipe or {}
                this.selectedRecipe.trigger = trigger
            end)
        end)

    local clearTriggerBtnText = "Clr Trigger"
    this.clearTriggerBtn = this.detailsFrame:addButton()
        :setPosition(this.addTriggerBtn:getX() + this.addTriggerBtn:getWidth() + 4, this.addTriggerBtn:getY())
        :setSize(#clearTriggerBtnText, 1)
        :setText(clearTriggerBtnText)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            if this.selectedRecipe then
                this.selectedRecipe.trigger = nil
            end
        end)

    this.saveBtn = this.detailsFrame:addButton()
        :setPosition(this.detailsFrame:getWidth() - 6, this.detailsFrame:getHeight() - 1)
        :setSize(6, 1)
        :setText("Save")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :onClick(function()
            if this.selectedRecipe == nil then
                this.messageBox:open("Error", "No recipe selected to save!")
                return
            end
            
            if this.selectedRecipe.id ~= nil then
                -- 更新现有配方
                local success, errMsg = StoreManager.updateRecipe(StoreManager.MACHINE_TYPES.belt, this.selectedRecipe)
                if not success then
                    this.messageBox:open("Error", "Failed to update recipe! " .. tostring(errMsg))
                    return
                end
                this.recipeListBox:refreshRecipeList()
                this.messageBox:open("Success", "Recipe updated successfully!")
            else 
                -- 添加新配方
                local success, id = StoreManager.addRecipe(StoreManager.MACHINE_TYPES.belt, this.selectedRecipe)
                if not success then
                    this.messageBox:open("Error", "Failed to add recipe! " .. tostring(id))
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

function BeltRecipeTab:init()
    self.recipeListBox:refreshRecipeList()
    return self
end

return BeltRecipeTab
