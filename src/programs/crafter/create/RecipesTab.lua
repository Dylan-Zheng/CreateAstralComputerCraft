local basalt = require("libraries.basalt")
local Logger = require("utils.Logger")
local OSUtils = require("utils.OSUtils")
local Manager = require("programs.crafter.create.Manager")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local SnapShot = require("programs.common.SnapShot")
local TriggerView = require("programs.recipe.manager.TriggerView")
local MessageBox = require("elements.MessageBox")
local ConfirmMessageBox = require("elements.ConfirmMessageBox")
local ScrollableFrame = require("elements.ScrollableFrame")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")

---@diagnostic disable-next-line: undefined-global
local colors = colors

local function removeBeforeColon(str)
    if not str then
        return str
    end

    local colonPos = string.find(str, ":")
    if colonPos then
        return string.sub(str, colonPos + 1)
    else
        return str
    end
end

local getListDisplayItems = function(selectedItem, items)
    local list = {}
    if selectedItem then
        table.insert(list, {
            text = selectedItem,
            selected = true
        })
    end

    for name, _ in pairs(items) do
        if selectedItem ~= name then
            table.insert(list, {
                text = name,
            })
        end
    end
    return list
end

local RecipesTab = {}
RecipesTab.__index = RecipesTab

function RecipesTab:new(pframe)
    local this = setmetatable({}, RecipesTab)

    this.selectedRecipe = nil
    this._displayList = {}

    this.pframe = pframe

    this.innerFrame = this.pframe:addFrame()
        :setPosition(1, 1)
        :setSize(this.pframe:getWidth(), this.pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    -- Recipe list section
    this.searchInput = this.innerFrame:addInput()
        :setPosition(2, 2)
        :setSize(18, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setPlaceholderColor(colors.lightGray)
        :setPlaceholder("Search...")
        :onChange("text", function(self, text)
            this:refreshRecipeList(text)
        end)

    this.clearBtn = this.innerFrame:addButton()
        :setPosition(this.searchInput:getX() + this.searchInput:getWidth() + 1, this.searchInput:getY())
        :setSize(1, 1)
        :setText("C")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.searchInput:setText("")
            this:refreshRecipeList()
        end)

    this.recipeList = this.innerFrame:addList()
        :setPosition(2, this.searchInput:getY() + this.searchInput:getHeight() + 1)
        :setSize(20, this.innerFrame:getHeight() - (this.searchInput:getY() + this.searchInput:getHeight() + 3))
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onSelect(function(_, _, item)
            if this.selectedRecipe and this.selectedRecipe.id == item.recipe.id then
                item.selected = false
                this.selectedRecipe = nil
                this:setDetails(nil)
                this.recipeList:render()
            else
                this:setDetails(item.recipe)
            end
        end)

    this.newButton = this.innerFrame:addButton()
        :setPosition(this.recipeList:getX(), this.recipeList:getY() + this.recipeList:getHeight() + 1)
        :setSize(7, 1)
        :setText("New")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this:setDetails(nil)
        end)

    this.deleteButton = this.innerFrame:addButton()
        :setPosition(this.newButton:getX() + this.newButton:getWidth() + 1, this.newButton:getY())
        :setSize(7, 1)
        :setText("Delete")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            if this.selectedRecipe then
                this.confirmMessageBox:open("Delete Recipe",
                "Are you sure you want to delete the selected recipe with ID " ..
                (this.selectedRecipe.id or "unknown") .. " ?", function()
                    Manager.deleteRecipeById(this.selectedRecipe.id)
                    this.recipeList:setItems(this:refreshRecipeList(this.searchInput:getText()))
                    this:setDetails(nil)
                end)
            else
                this.messageBox:open("Error", "No recipe selected to delete.")
            end
        end)

    -- Detail view
    this.detailFrame = this.innerFrame:addFrame()
        :setPosition(this.recipeList:getX() + this.recipeList:getWidth() + 1, 2)
        :setSize(this.innerFrame:getWidth() - (this.recipeList:getX() + this.recipeList:getWidth() + 1),
            this.innerFrame:getHeight() - 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.outputLabel = this.detailFrame:addLabel()
        :setPosition(2, 2)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Output: ")

    this.outputValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.outputLabel:getY() + 2)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("empty")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            local currentOutput = nil
            if this.selectedRecipe and this.selectedRecipe.output then
                if type(this.selectedRecipe.output) == "table" and this.selectedRecipe.output.name then
                    currentOutput = this.selectedRecipe.output.name
                elseif type(this.selectedRecipe.output) == "string" then
                    currentOutput = this.selectedRecipe.output
                end
            end
            this.itemListBox:open(getListDisplayItems(currentOutput, SnapShot.items), false, {confirm = function(selectedItems)
                this.selectedRecipe = this.selectedRecipe or {}
                this.selectedRecipe.output = {name = selectedItems[1].text}
                this:setDetails(this.selectedRecipe)
            end})
        end)

    this.triggerLabel = this.detailFrame:addLabel()
        :setPosition(2, this.outputValueLabel:getY() + this.outputValueLabel:getHeight() + 1)
        :setText("Trigger:")
        :setForeground(colors.white)

    this.editTriggerBtn = this.detailFrame:addButton()
        :setPosition(this.triggerLabel:getX() + this.triggerLabel:getWidth() + 3, this.triggerLabel:getY())
        :setSize(6, 1)
        :setText("Edit")
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :onClick(function()
            this.triggerBox:open(this.selectedRecipe and this.selectedRecipe.trigger or nil, function(trigger)
                this.selectedRecipe = this.selectedRecipe or {}
                this.selectedRecipe.trigger = trigger
            end)
        end)

    this.clearTriggerBtn = this.detailFrame:addButton()
        :setPosition(this.editTriggerBtn:getX() + this.editTriggerBtn:getWidth() + 1, this.editTriggerBtn:getY())
        :setSize(7, 1)
        :setText("Clear")
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :onClick(function()
            if this.selectedRecipe then
                this.selectedRecipe.trigger = nil
            end
        end)

    this.isDisabledCheckBox = this.detailFrame:addCheckbox()
        :setSize(1, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("[ ] Disabled")
        :setCheckedText("[x] Disabled")
        :setChecked(false)
        :setPosition(2, this.clearTriggerBtn:getY() + this.clearTriggerBtn:getHeight() + 1)

    this.loadBtn = this.detailFrame:addButton()
        :setPosition(this.detailFrame:getWidth() - 14, this.isDisabledCheckBox:getY() + this.isDisabledCheckBox:getHeight() + 1)
        :setSize(6, 1)
        :setText("Load")
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :onClick(function()
            local chest = Manager.getSettings().recipesChest
            if not chest or chest == "" then
                this.messageBox:open("Error", "No recipes chest configured in settings.")
                return
            end
            local wrappedChest = PeripheralWrapper.getByName(chest)
            if not wrappedChest then
                this.messageBox:open("Error", "Could not find peripheral: " .. chest)
                return
            end
            local recipe = Manager.readRecipesFromChest(wrappedChest)
            if recipe then
                this:setDetails(recipe)
                this.messageBox:open("Success", "Recipe loaded from chest successfully.")
            else
                this.messageBox:open("Error", "Failed to load recipe from chest. Check chest contents and settings.")
            end
        end)

    this.saveBtn = this.detailFrame:addButton()
        :setPosition(this.detailFrame:getWidth() - 7, this.loadBtn:getY())
        :setSize(6, 1)
        :setText("Save")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :onClick(function()
            if this.selectedRecipe then
                local success, errMsg = this:saveRecipe()
                if success then
                    this:refreshRecipeList(this.searchInput:getText())
                    this.messageBox:open("Success", "Recipe saved successfully.")
                else
                    this.messageBox:open("Error", "Error saving recipe: " .. (errMsg or "unknown error"))
                end
            else
                this.messageBox:open("Error", "No recipe selected to save.")
            end
        end)

    this.inputLabel = this.detailFrame:addLabel()
        :setPosition(2, this.saveBtn:getY() + this.saveBtn:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Input: ")

    -- Dynamic input labels based on crafter size
    this.inputLabels = {}
    this.inputSlots = {}

    this.itemListBox = ItemSelectedListBox:new(this.pframe)
    this.triggerBox = TriggerView:new(this.pframe)
    this.messageBox = MessageBox:new(this.pframe)
    this.confirmMessageBox = ConfirmMessageBox:new(this.pframe)

    -- Initialize input slots based on crafter size
    
    this.emptyLabel = this.detailFrame:addLabel():setText("")

    this:createInputSlots()

    ScrollableFrame.setScrollable(this.detailFrame, true, colors.gray, colors.lightGray, colors.gray, colors.white)


    return this
end

function RecipesTab:createInputSlots()
    local settings = Manager.getSettings()
    local crafterWidth = 3
    local crafterHeight = 3
    
    if settings and settings.crafterSize then
        crafterWidth = settings.crafterSize.width or 3
        crafterHeight = settings.crafterSize.height or 3
    end
    
    local totalSlots = crafterWidth * crafterHeight

    -- Clear existing input slots
    for i = 1, #self.inputSlots do
        if self.inputSlots[i] then
            self.inputSlots[i]:remove()
        end
    end
    self.inputSlots = {}

    -- Create new input slots
    local prevYPos = self.inputLabel:getY() + self.inputLabel:getHeight() + 1
    for i = 1, totalSlots do
        local slotLabel = self.detailFrame:addLabel()
            :setPosition(2, prevYPos)
            :setBackgroundEnabled(true)
            :setSize(self.detailFrame:getWidth() - 3, 1)
            :setBackground(colors.lightGray)
            :setForeground(colors.white)
            :setText(i .. ". ")

        local inputLabel = self.detailFrame:addLabel()
            :setAutoSize(false)
            :setBackgroundEnabled(true)
            :setPosition(5, prevYPos)
            :setSize(self.detailFrame:getWidth() - 6, 1)
            :setBackground(colors.lightGray)
            :setForeground(colors.white)
            :setText("empty")
            :onClick(function()
                self.itemListBox:open(getListDisplayItems(self.selectedRecipe and self.selectedRecipe.input and self.selectedRecipe.input[i] or nil, SnapShot.items), false, {confirm = function(selectedItems)
                    self.selectedRecipe = self.selectedRecipe or {}
                    self.selectedRecipe.input = self.selectedRecipe.input or {}
                    self.selectedRecipe.input[i] = selectedItems[1].text
                    self:setDetails(self.selectedRecipe)
                end})
            end)

        self.inputSlots[i] = inputLabel
        prevYPos = inputLabel:getY() + inputLabel:getHeight()
    end

    -- Update empty label position
    self.emptyLabel:setPosition(2, prevYPos + 1)
end

function RecipesTab:getDisplayList()
    local recipes = Manager.getRecipes()
    self._displayList = {}
    if recipes then
        for _, recipe in ipairs(recipes) do
            local displayText = "Recipe " .. (recipe.id or "unknown")
            if recipe.output then
                if type(recipe.output) == "table" and recipe.output.name then
                    displayText = removeBeforeColon(recipe.output.name)
                elseif type(recipe.output) == "string" then
                    displayText = removeBeforeColon(recipe.output)
                end
            end
            table.insert(self._displayList, {
                text = displayText,
                recipe = recipe
            })
        end
    end
    return self._displayList
end

function RecipesTab:refreshRecipeList(text)
    local displayList = self:getDisplayList()
    local filteredList = {}

    if text and text ~= "" then
        local lowerText = string.lower(text)
        for _, item in ipairs(displayList) do
            if string.find(string.lower(item.text), lowerText, 1, true) then
                table.insert(filteredList, item)
            end
        end
    else
        for _, item in ipairs(displayList) do
            table.insert(filteredList, item)
        end
    end
    self.recipeList:setItems(filteredList)
    return filteredList
end

function RecipesTab:setDetails(recipe)
    if recipe then
        self.selectedRecipe = recipe
        local outputName = "empty"
        if recipe.output then
            if type(recipe.output) == "table" and recipe.output.name then
                outputName = removeBeforeColon(recipe.output.name)
            elseif type(recipe.output) == "string" then
                outputName = removeBeforeColon(recipe.output)
            end
        end
        self.outputValueLabel:setText(outputName)
        
        local inputs = recipe.input or {}
        for i = 1, #self.inputSlots do
            local inputLabel = self.inputSlots[i]
            local input = nil
            if inputs[i] then
                input = removeBeforeColon(inputs[i])
            end
            if inputLabel then
                inputLabel:setText(input or "empty")
            end
        end
        
        -- Set checkbox state
        self.isDisabledCheckBox:setChecked(recipe.isDisabled or false)
    else
        self.selectedRecipe = {
            input = {},
            output = nil,
            trigger = nil,
            isDisabled = false
        }
        self.outputValueLabel:setText("empty")
        for i = 1, #self.inputSlots do
            local inputLabel = self.inputSlots[i]
            if inputLabel then
                inputLabel:setText("empty")
            end
        end
        
        -- Set checkbox state
        self.isDisabledCheckBox:setChecked(false)
    end
end

function RecipesTab:saveRecipe()
    if not self.selectedRecipe then
        return false, "No recipe to save"
    end

    -- Validate that output is set
    if not self.selectedRecipe.output then
        return false, "Output must be specified"
    end

    -- Save checkbox state
    self.selectedRecipe.isDisabled = self.isDisabledCheckBox:getChecked()

    Manager.updateRecipe(self.selectedRecipe)
    return true
end

function RecipesTab:init()
    self:refreshRecipeList()
    self:setDetails(nil)
    return self
end



return RecipesTab
