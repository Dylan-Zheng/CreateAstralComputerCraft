local basalt = require("libraries.basalt")
local Logger = require("utils.Logger")
local StoreManager = require("programs.recipe.manager.StoreManager")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local SnapShot = require("programs.common.SnapShot")
local TriggerView = require("programs.recipe.manager.TriggerView")
local MessageBox = require("elements.MessageBox")
local ConfirmMessageBox = require("elements.ConfirmMessageBox")
local RecipeList = require("programs.recipe.manager.RecipeList")
local Utils = require("programs.recipe.manager.Utils")
local ScrollableFrame = require("elements.ScrollableFrame")

local CommonRecipeTab = {}
CommonRecipeTab.__index = CommonRecipeTab

local getDisplayRecipeList = function(filterText)
    local recipes = StoreManager.getAllRecipesByType(StoreManager.MACHINE_TYPES.common)
    local displayList = {}

    if recipes == nil then
        return displayList
    end
    for _, recipe in ipairs(recipes) do
        local searchText = recipe.name or ""
        if not filterText or searchText:lower():find(filterText:lower()) then
            table.insert(displayList, {
                text = recipe.name,
                id = recipe.id
            })
        end
    end
    return displayList
end

function CommonRecipeTab:new(pframe)
    local this = setmetatable({}, CommonRecipeTab)

    this.selectedRecipe = nil

    this.pframe = pframe

    this.innerFrame = this.pframe:addFrame()
        :setPosition(1, 1)
        :setSize(this.pframe:getWidth(), this.pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.recipeListBox = RecipeList:new(this.innerFrame, 1, 1, 22, this.innerFrame:getHeight())
        :setOnSelected(function(recipe)
            this.selectedRecipe = StoreManager.getRecipeByTypeAndId(StoreManager.MACHINE_TYPES.common, recipe.id)
            if this.selectedRecipe then
                this.nameInput:setText(this.selectedRecipe.name or "")
                this.inputItemLabel:setText("Input Item: " .. (this.selectedRecipe.input and this.selectedRecipe.input.items and #this.selectedRecipe.input.items or 0))
                this.inputFluidLabel:setText("Input Fluid: " .. (this.selectedRecipe.input and this.selectedRecipe.input.fluids and #this.selectedRecipe.input.fluids or 0))
                this.outputItemLabel:setText("Output Item: " .. (this.selectedRecipe.output and this.selectedRecipe.output.items and #this.selectedRecipe.output.items or 0))
                this.outputFluidLabel:setText("Output Fluid: " .. (this.selectedRecipe.output and this.selectedRecipe.output.fluids and #this.selectedRecipe.output.fluids or 0))
            else
                this.nameInput:setText("")
                this.inputItemLabel:setText("Input Item:")
                this.inputFluidLabel:setText("Input Fluid:")
                this.outputItemLabel:setText("Output Item:")
                this.outputFluidLabel:setText("Output Fluid:")
            end
        end)
        :setOnNew(function()
            this.selectedRecipe = nil
            this.nameInput:setText("")
            this.inputItemLabel:setText("Input Item:")
            this.inputFluidLabel:setText("Input Fluid:")
            this.outputItemLabel:setText("Output Item:")
            this.outputFluidLabel:setText("Output Fluid:")
        end)
        :setOnDel(function(recipe)
            if this.selectedRecipe == nil or this.selectedRecipe.id == nil then
                this.messageBox:open("Error", "No recipe selected to delete!")
                return
            end
            this.confirmMessageBox:open("Confirm", "Are you sure to delete the selected recipe: " .. this.selectedRecipe.name .. "?", function()
                local success, errMsg = StoreManager.removeRecipe(StoreManager.MACHINE_TYPES.common, this.selectedRecipe.id)
                if not success then
                    this.messageBox:open("Error", "Failed to delete recipe! " .. tostring(errMsg))
                    return
                end
                this.selectedRecipe = nil
                this.nameInput:setText("")
                this.inputItemLabel:setText("Input Item:")
                this.inputFluidLabel:setText("Input Fluid:")
                this.outputItemLabel:setText("Output Item:")
                this.outputFluidLabel:setText("Output Fluid:")
                this.recipeListBox:refreshRecipeList()
            end)
        end)
        :setGetDisplayRecipeListFn(getDisplayRecipeList)

    this.detailsFrame = this.innerFrame:addFrame()
        :setPosition(this.recipeListBox.innerFrame:getX() + this.recipeListBox.innerFrame:getWidth(), 2)
        :setSize(this.innerFrame:getWidth() - this.recipeListBox.innerFrame:getWidth() - 1, this.innerFrame:getHeight() - 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.nameLabel = this.detailsFrame:addLabel()
        :setText("Name:")
        :setPosition(2, 2)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.nameInput = this.detailsFrame:addInput()
        :setPosition(this.nameLabel:getX() + this.nameLabel:getWidth() + 1, this.nameLabel:getY())
        :setSize(this.detailsFrame:getWidth() - this.nameLabel:getWidth() - 4, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.inputItemLabel = this.detailsFrame:addLabel()
        :setText("Input Item:")
        :setPosition(2, 4)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.InputItemEditBtn = this.detailsFrame:addButton()
        :setText("...")
        :setPosition(this.detailsFrame:getWidth() - 4, this.inputItemLabel:getY())
        :setSize(3, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedInputs =  nil
            if this.selectedRecipe and this.selectedRecipe.input and this.selectedRecipe.input.items then
                selectedInputs = {}
                for _, input in ipairs(this.selectedRecipe.input.items) do
                    selectedInputs[input] = true
                end
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedInputs, SnapShot.items), true, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local inputsItems = {}
                    for _, item in ipairs(selectedItems) do
                        table.insert(inputsItems, item.text)
                    end
                    this.inputItemLabel:setText("Input Item: " .. #inputsItems)
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    if not this.selectedRecipe.input then
                        this.selectedRecipe.input = {}
                    end
                    this.selectedRecipe.input.items = inputsItems
                end
                this.itemListBox:close()
            end})
        end)
        
    this.inputFluidLabel = this.detailsFrame:addLabel()
        :setText("Input Fluid:")
        :setPosition(2, this.inputItemLabel:getY() + this.inputItemLabel:getHeight() + 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.inputFluidEditBtn = this.detailsFrame:addButton()
        :setText("...")
        :setPosition(this.detailsFrame:getWidth() - 4, this.inputFluidLabel:getY())
        :setSize(3, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedInputs = nil
            if this.selectedRecipe and this.selectedRecipe.input and this.selectedRecipe.input.fluids then
                selectedInputs = {}
                for _, input in ipairs(this.selectedRecipe.input.fluids) do
                    selectedInputs[input] = true
                end
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedInputs, SnapShot.fluids), true, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local inputsFluids = {}
                    for _, item in ipairs(selectedItems) do
                        table.insert(inputsFluids, item.text)
                    end
                    this.inputFluidLabel:setText("Input Fluid: " .. #inputsFluids)
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    if not this.selectedRecipe.input then
                        this.selectedRecipe.input = {}
                    end
                    this.selectedRecipe.input.fluids = inputsFluids
                end
                this.itemListBox:close()
            end})
        end)

    this.outputItemLabel = this.detailsFrame:addLabel()
        :setText("Output Item:")
        :setPosition(2, this.inputFluidLabel:getY() + this.inputFluidLabel:getHeight() + 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.outputItemEditBtn = this.detailsFrame:addButton()
        :setText("...")
        :setPosition(this.detailsFrame:getWidth() - 4, this.outputItemLabel:getY())
        :setSize(3, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedOutputs = nil
            if this.selectedRecipe and this.selectedRecipe.output and this.selectedRecipe.output.items then
                selectedOutputs = {}
                for _, output in ipairs(this.selectedRecipe.output.items) do
                    selectedOutputs[output] = true
                end
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedOutputs, SnapShot.items), true, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local outputsItems = {}
                    for _, item in ipairs(selectedItems) do
                        table.insert(outputsItems, item.text)
                    end
                    this.outputItemLabel:setText("Output Item: " .. #outputsItems)
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    if not this.selectedRecipe.output then
                        this.selectedRecipe.output = {}
                    end
                    this.selectedRecipe.output.items = outputsItems
                end
                this.itemListBox:close()
            end})
        end)

    this.outputFluidLabel = this.detailsFrame:addLabel()
        :setText("Output Fluid:")
        :setPosition(2, this.outputItemLabel:getY() + this.outputItemLabel:getHeight() + 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.outputFluidEditBtn = this.detailsFrame:addButton()
        :setText("...")
        :setPosition(this.detailsFrame:getWidth() - 4, this.outputFluidLabel:getY())
        :setSize(3, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local selectedOutputs = nil
            if this.selectedRecipe and this.selectedRecipe.output and this.selectedRecipe.output.fluids then
                selectedOutputs = {}
                for _, output in ipairs(this.selectedRecipe.output.fluids) do
                    selectedOutputs[output] = true
                end
            end
            this.itemListBox:open(Utils.getListDisplayItems(selectedOutputs, SnapShot.fluids), true, {confirm = function(selectedItems)
                if selectedItems and next(selectedItems) ~= nil then
                    local outputsFluids = {}
                    for _, item in ipairs(selectedItems) do
                        table.insert(outputsFluids, item.text)
                    end
                    this.outputFluidLabel:setText("Output Fluid: " .. #outputsFluids)
                    if this.selectedRecipe == nil then
                        this.selectedRecipe = {}
                    end
                    if not this.selectedRecipe.output then
                        this.selectedRecipe.output = {}
                    end
                    this.selectedRecipe.output.fluids = outputsFluids
                end
                this.itemListBox:close()
            end})
        end)

    local setTriggerBtnText = "Set Trigger"
    this.setTriggerBtn = this.detailsFrame:addButton()
        :setPosition(2, this.outputFluidLabel:getY() + this.outputFluidLabel:getHeight() + 1)
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

    local saveBtn = this.detailsFrame:addButton()
        :setPosition(this.detailsFrame:getWidth() - 9, this.setTriggerBtn:getY() + 2)
        :setSize(8, 1)
        :setText("Save")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            if this.selectedRecipe == nil then
                this.messageBox:open("Error", "No recipe to save!")
                return
            end
            this.selectedRecipe.name = this.nameInput:getText()

            if this.selectedRecipe.id == nil then
                -- New recipe
                local success, errMsg = StoreManager.addRecipe(StoreManager.MACHINE_TYPES.common, this.selectedRecipe)
                if not success then
                    this.messageBox:open("Error", "Failed to add recipe! " .. tostring(errMsg))
                    return
                end
            else
                -- Existing recipe
                local success, errMsg = StoreManager.updateRecipe(StoreManager.MACHINE_TYPES.common, this.selectedRecipe)
                if not success then
                    this.messageBox:open("Error", "Failed to update recipe! " .. tostring(errMsg))
                    return
                end
            end
            this.recipeListBox:refreshRecipeList()
            this.messageBox:open("Success", "Recipe saved successfully.")
        end)

    this.detailsFrame:addLabel():setPosition(1, saveBtn:getY() + 1):setText("")

    ScrollableFrame.setScrollable(this.detailsFrame, true, colors.gray, colors.lightGray, colors.gray, colors.white)
    this.itemListBox = ItemSelectedListBox:new(this.pframe)
    this.trigger = TriggerView:new(this.pframe)
    this.messageBox = MessageBox:new(this.pframe)
    this.confirmMessageBox = ConfirmMessageBox:new(this.pframe)

    return this
end

function CommonRecipeTab:init()
    self.recipeListBox:refreshRecipeList()
end

return CommonRecipeTab
