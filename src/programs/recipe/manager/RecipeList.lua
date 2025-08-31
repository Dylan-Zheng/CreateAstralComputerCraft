local Logger = require("utils.Logger")

local RecipeList = {}
RecipeList.__index = RecipeList

function RecipeList:new(pframe, x, y, width, height)
    
    local this = setmetatable({}, RecipeList)

    this.pframe = pframe

    this.selectedRecipe = nil

    this.innerFrame = this.pframe:addFrame()
        :setPosition(x, y)
        :setSize(width, height)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.searchInput = this.innerFrame:addInput()
        :setPosition(2,2)
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
        :setSize(1,1)
        :setText("C")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.searchInput:setText("")
            this.recipeList:setItems(this.getDisplayRecipeListFn())
        end)

    this.recipeList = this.innerFrame:addList()
        :setPosition(2, this.searchInput:getY() + this.searchInput:getHeight() + 1)
        :setSize(20, this.innerFrame:getHeight() - (this.searchInput:getY() + this.searchInput:getHeight() + 3))
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onSelect(function(_, _, item)
            this.onSelectedCallback(item)
        end)

    this.newButton = this.innerFrame:addButton()
        :setPosition(this.recipeList:getX(), this.recipeList:getY() + this.recipeList:getHeight() + 1)
        :setSize(5,1)
        :setText("New")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.onNewCallback()
        end)

    this.updateButton = this.innerFrame:addButton()
        :setPosition(this.newButton:getX() + this.newButton:getWidth() + 1, this.newButton:getY())
        :setSize(8,1)
        :setText(" Update ")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.onUpdateCallback()
        end)

    this.deleteButton = this.innerFrame:addButton()
        :setPosition(this.updateButton:getX() + this.updateButton:getWidth() + 1, this.updateButton:getY())
        :setSize(5,1)
        :setText("Del")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.onDelCallback()
        end)
    return this
end

function RecipeList:setOnSelected(callback)
    self.onSelectedCallback = callback
    return self
end
function RecipeList:setOnNew(callback)
    self.onNewCallback = callback
    return self
end

function RecipeList:setOnUpdate(callback)
    self.onUpdateCallback = callback
    return self
end

function RecipeList:setOnDel(callback)
    self.onDelCallback = callback
    return self
end

function RecipeList:setGetDisplayRecipeListFn(fn)
    self.getDisplayRecipeListFn = fn
    return self
end

function RecipeList:refreshRecipeList(filterText)
    local searchText = filterText or self.searchInput:getText():lower()
    self.recipeList:setItems(self.getDisplayRecipeListFn(searchText))
end

function RecipeList:init()
    self:refreshRecipeList()
    return self
end

return RecipeList