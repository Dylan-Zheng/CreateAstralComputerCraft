local basalt = require("libraries.basalt")
local Logger = require("utils.Logger")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local SnapShot = require("programs.common.SnapShot")
local TriggerView = require("programs.common.TriggerTurtleView")
local MessageBox = require("elements.MessageBox")
local ConfirmMessageBox = require("elements.ConfirmMessageBox")
local ScrollableFrame = require("elements.ScrollableFrame")
local RecipeManager = require("programs.crafter.positive.RecipeManager")

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

local RecipeTab = {}
RecipeTab.__index = RecipeTab

function RecipeTab:new(pframe, x, y, width, height)
    local this = setmetatable({}, RecipeTab)

    this.selectedRecipe = nil
    this._displayList = {}

    this.pframe = pframe

    this.selectedCrafting = nil
    this.onSelectedCallback = function() end
    this.onNewCallback = function() end
    this.getDisplayCraftingListFn = function() return {} end

    this.innerFrame = this.pframe:addFrame()
        :setPosition(x, y)
        :setSize(width, height)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.searchInput = this.innerFrame:addInput()
        :setPosition(2, 2)
        :setSize(12, 1)  -- Scaled down from 18 to 12 (39/51 ≈ 0.76)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setPlaceholderColor(colors.lightGray)
        :setPlaceholder("Search...")
        :onChange("text", function(self, text)
            this:refreshCraftingList(text)
        end)

    this.clearBtn = this.innerFrame:addButton()
        :setPosition(this.searchInput:getX() + this.searchInput:getWidth() + 1, this.searchInput:getY())
        :setSize(1, 1)
        :setText("C")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.searchInput:setText("")
            this:refreshCraftingList()
        end)

    this.craftingList = this.innerFrame:addList()
        :setPosition(2, this.searchInput:getY() + this.searchInput:getHeight() + 1)
        :setSize(14, this.innerFrame:getHeight() - (this.searchInput:getY() + this.searchInput:getHeight() + 3))  -- Scaled down from 20 to 14
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onSelect(function(_, _, item)
            if this.selectedRecipe and this.selectedRecipe.output == item.recipe.output then
                item.selected = false
                this.selectedRecipe = nil
                this:setDetails(nil)
                this.craftingList:render()
            else
                this:setDetails(item.recipe)
            end
        end)

    this.newButton = this.innerFrame:addButton()
        :setPosition(this.craftingList:getX(), this.craftingList:getY() + this.craftingList:getHeight() + 1)
        :setSize(5, 1)  -- Scaled down from 7 to 5
        :setText("New")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this:setDetails(nil)
        end)

    this.deleteButton = this.innerFrame:addButton()
        :setPosition(this.newButton:getX() + this.newButton:getWidth() + 1, this.newButton:getY())
        :setSize(5, 1)  -- Scaled down from 7 to 5
        :setText("Del")  -- Shortened text
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            if this.selectedRecipe then
                this.confirmMessageBox:open("Delete Recipe",
                "Are you sure you want to delete the selected recipe .. " ..
                (this.selectedRecipe.output or "empty") .. " ?", function()
                    RecipeManager.removeRecipe(this.selectedRecipe)
                    this.craftingList:setItems(this:refreshCraftingList(this.searchInput:getText()))
                    this:setDetails(nil)
                end)
            else
                this.messageBox:open("Error", "No recipe selected to delete.")
            end
        end)

    -- detail view

    this.detailFrame = this.innerFrame:addFrame()
        :setPosition(this.craftingList:getX() + this.craftingList:getWidth() + 1, 2)
        :setSize(this.innerFrame:getWidth() - (this.craftingList:getX() + this.craftingList:getWidth() + 1),
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
            this.itemListBox:open(getListDisplayItems(this.selectedRecipe and this.selectedRecipe.output or nil, SnapShot.items), false, {confirm = function(selectedItems)
                this.selectedRecipe = this.selectedRecipe or {}
                this.selectedRecipe.output = selectedItems[1].text
                this:setDetails(this.selectedRecipe)
            end})
        end)

    this.inputInvLabel = this.detailFrame:addLabel()
        :setPosition(2, this.outputValueLabel:getY() + this.outputValueLabel:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Input: ")

    local labelName = { "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9" }
    local prevYPos = this.inputInvLabel:getY() + this.inputInvLabel:getHeight() + 1
    for i = 1, 9 do
        this.detailFrame:addLabel()
            :setPosition(2, prevYPos)
            :setBackgroundEnabled(true)
            :setPosition(2, prevYPos)
            :setSize(this.detailFrame:getWidth() - 3, 1)
            :setBackground(colors.lightGray)
            :setForeground(colors.white)
            :setText(i .. ". ")

        this[labelName[i]] = this.detailFrame:addLabel()
            :setAutoSize(false)
            :setBackgroundEnabled(true)
            :setPosition(5, prevYPos)
            :setSize(this.detailFrame:getWidth() - 6, 1)
            :setBackground(colors.lightGray)
            :setForeground(colors.white)
            :setText("empty")
            :onClick(function()
                this.itemListBox:open(getListDisplayItems(this.selectedRecipe and this.selectedRecipe.inputs and this.selectedRecipe.inputs[i] or nil, SnapShot.items), false, {confirm = function(selectedItems)
                    this.selectedRecipe = this.selectedRecipe or {}
                    this.selectedRecipe.inputs = this.selectedRecipe.inputs or {}
                    if not selectedItems[1] or not selectedItems[1].text then
                        this.selectedRecipe.inputs[i] = false
                    else
                        this.selectedRecipe.inputs[i] = selectedItems[1].text and selectedItems[1].text or nil
                    end
                    this:setDetails(this.selectedRecipe)
                end})
            end)

        prevYPos = this[labelName[i]]:getY() + this[labelName[i]]:getHeight()
    end

    this.maxInputsLabel = this.detailFrame:addLabel()
        :setPosition(2, prevYPos + 1)
        :setForeground(colors.white)
        :setText("Max: ")  -- Shortened label

    this.maxInputBox = this.detailFrame:addInput()
        :setPosition(this.maxInputsLabel:getX() + this.maxInputsLabel:getWidth() + 1, this.maxInputsLabel:getY())
        :setSize(this.detailFrame:getWidth() - (this.maxInputsLabel:getX() + this.maxInputsLabel:getWidth() + 2), 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :setText("0")
        :setPattern("[0-9]")

    this.triggerLabel = this.detailFrame:addLabel()
        :setPosition(2, this.maxInputsLabel:getY() + this.maxInputBox:getHeight() + 1)
        :setText("Trigger:")
        :setForeground(colors.white)

    this.editTriggerBtn = this.detailFrame:addButton()
        :setPosition(this.triggerLabel:getX() + this.triggerLabel:getWidth() + 2, this.triggerLabel:getY())
        :setSize(4, 1)  -- Scaled down from 6 to 4
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
        :setSize(4, 1)  -- Scaled down from 7 to 4
        :setText("Clr")  -- Shortened text
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :onClick(function()
            if this.selectedRecipe then
                this.selectedRecipe.trigger = nil
            end
        end)

    this.saveBtn = this.detailFrame:addButton()
        :setPosition(this.detailFrame:getWidth() - 5, this.clearTriggerBtn:getY() + this.clearTriggerBtn:getHeight() + 1)  -- Adjusted position
        :setSize(4, 1)  -- Scaled down from 6 to 4
        :setText("Save")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :onClick(function()
            if this.selectedRecipe then
                local maxInputs = tonumber(this.maxInputBox:getText()) or 0
                if maxInputs < 0 or maxInputs > 64 then
                    this.messageBox:open("Error", "Max Inputs must be between 0 and 64.")
                    return
                end
                this.selectedRecipe.maxInputs = maxInputs
                local success, errMsg = RecipeManager.addRecipe(this.selectedRecipe)
                if success then
                    this:refreshCraftingList(this.searchInput:getText())
                    this.messageBox:open("Success", "Recipe saved successfully.")
                else
                    this.messageBox:open("Error", "Error saving recipe: " .. (errMsg or "unknown error"))
                end
            else
                this.messageBox:open("Error", "No recipe selected to save.")
            end
        end)

    this.detailFrame:addLabel()
        :setPosition(2, this.saveBtn:getY() + 1)
        :setText("")

    ScrollableFrame.setScrollable(this.detailFrame, true, colors.gray, colors.lightGray, colors.gray, colors.white)

    this.itemListBox = ItemSelectedListBox:new(this.pframe)
    this.triggerBox = TriggerView:new(this.pframe)
    this.messageBox = MessageBox:new(this.pframe)
    this.confirmMessageBox = ConfirmMessageBox:new(this.pframe)

    return this
end

function RecipeTab:getDisplayList()
    if RecipeManager.checkedUpdate() then
        local recipes = RecipeManager.getRecipes()
        self._displayList = {}
        for k, v in pairs(recipes) do
            table.insert(self._displayList, {
                text = removeBeforeColon(k),
                recipe = v
            })
        end
    end
    return self._displayList
end

function RecipeTab:refreshCraftingList(text)
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
    self.craftingList:setItems(filteredList)
end

function RecipeTab:setDetails(recipe)
    if recipe then
        self.selectedRecipe = recipe
        self.outputValueLabel:setText(recipe.output or "empty")
        local inputs = recipe.inputs or {}
        for i = 1, 9 do
            local itemLabel = self["i" .. i]
            local input = nil
            if inputs[i] then
                input = removeBeforeColon(inputs[i])
            end
            if itemLabel then
                itemLabel:setText(input or "empty")
            end
        end
        self.maxInputBox:setText(tostring(recipe.maxInputs or 0))
    else
        self.selectedRecipe = {
            inputs = {},
            output = nil,
            trigger = nil,
            maxInputs = 64
        }
        self.outputValueLabel:setText("empty")
        for i = 1, 9 do
            local itemLabel = self["i" .. i]
            if itemLabel then
                itemLabel:setText("empty")
            end
        end
        self.maxInputBox:setText("64")
    end
end

function RecipeTab:init()
    self:refreshCraftingList()
    self:setDetails(nil)
    return self
end

return RecipeTab
