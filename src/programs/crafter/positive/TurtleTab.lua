local basalt = require("libraries.basalt")
local Logger = require("utils.Logger")
local ScrollableFrame = require("elements.ScrollableFrame")
local TaskDispatchMaster = require("programs.crafter.positive.TaskDispatchMaster")

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

local TurtleTab = {}
TurtleTab.__index = TurtleTab

function TurtleTab:new(pframe, x, y, width, height)
    local this = setmetatable({}, TurtleTab)

    this.selectedTurtle = nil
    this.selectedTurtleId = nil
    this._displayList = {}

    this.pframe = pframe

    this.innerFrame = this.pframe:addFrame()
        :setPosition(x, y)
        :setSize(width, height)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.searchInput = this.innerFrame:addInput()
        :setPosition(2, 2)
        :setSize(18, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setPlaceholderColor(colors.lightGray)
        :setPlaceholder("Search...")
        :onChange("text", function(self, text)
            this:refreshTurtleList(text)
        end)

    this.clearBtn = this.innerFrame:addButton()
        :setPosition(this.searchInput:getX() + this.searchInput:getWidth() + 1, this.searchInput:getY())
        :setSize(1, 1)
        :setText("C")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            this.searchInput:setText("")
            this:refreshTurtleList()
        end)

    this.turtleList = this.innerFrame:addList()
        :setPosition(2, this.searchInput:getY() + this.searchInput:getHeight() + 1)
        :setSize(20, this.innerFrame:getHeight() - (this.searchInput:getY() + this.searchInput:getHeight() + 1))
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onSelect(function(_, _, item)
            if this.selectedTurtleId and this.selectedTurtleId == item.turtleId then
                item.selected = false
                this.selectedTurtle = nil
                this.selectedTurtleId = nil
                this:setDetails(nil, nil)
                this.turtleList:render()
            else
                this:setDetails(item.turtleId, item.turtle)
            end
        end)

    -- detail view
    this.detailFrame = this.innerFrame:addFrame()
        :setPosition(this.turtleList:getX() + this.turtleList:getWidth() + 1, 2)
        :setSize(this.innerFrame:getWidth() - (this.turtleList:getX() + this.turtleList:getWidth() + 1),
            this.innerFrame:getHeight() - 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.turtleIdLabel = this.detailFrame:addLabel()
        :setPosition(2, 2)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Turtle ID: ")

    this.turtleIdValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.turtleIdLabel:getY() + 2)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("None selected")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.nameLabel = this.detailFrame:addLabel()
        :setPosition(2, this.turtleIdValueLabel:getY() + this.turtleIdValueLabel:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Name: ")

    this.nameValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.nameLabel:getY() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("N/A")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.statusLabel = this.detailFrame:addLabel()
        :setPosition(2, this.nameValueLabel:getY() + this.nameValueLabel:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Status: ")

    this.statusValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.statusLabel:getY() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("N/A")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.isOnLabel = this.detailFrame:addLabel()
        :setPosition(2, this.statusValueLabel:getY() + this.statusValueLabel:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Power Status: ")

    this.isOnValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.isOnLabel:getY() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("N/A")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.recipeLabel = this.detailFrame:addLabel()
        :setPosition(2, this.isOnValueLabel:getY() + this.isOnValueLabel:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Current Recipe: ")

    this.recipeValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.recipeLabel:getY() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("None")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.recipeOutputLabel = this.detailFrame:addLabel()
        :setPosition(2, this.recipeValueLabel:getY() + this.recipeValueLabel:getHeight() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :setText("Recipe Output: ")

    this.recipeOutputValueLabel = this.detailFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(2, this.recipeOutputLabel:getY() + 1)
        :setSize(this.detailFrame:getWidth() - 3, 1)
        :setText("None")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.detailFrame:addLabel()
        :setPosition(2, this.recipeOutputValueLabel:getY() + 1)
        :setText("")

    ScrollableFrame.setScrollable(this.detailFrame, true, colors.gray, colors.lightGray, colors.gray, colors.white)

    return this
end

function TurtleTab:getDisplayList()
    local turtles = TaskDispatchMaster.turtles or {}
    self._displayList = {}
    
    for turtleId, turtle in pairs(turtles) do
        local statusText = turtle.status or "unknown"
        local powerStatus = "unknown"
        
        -- 检查电源状态
        if turtle.isOn then
            powerStatus = turtle.isOn() and "ON" or "OFF"
        end
        
        local displayName = string.format("ID: %s (%s)", tostring(turtleId), statusText)
        if powerStatus ~= "unknown" then
            displayName = displayName .. " [" .. powerStatus .. "]"
        end
        
        table.insert(self._displayList, {
            text = displayName,
            turtleId = turtleId,
            turtle = turtle
        })
    end
    
    return self._displayList
end

function TurtleTab:refreshTurtleList(text)
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
    
    self.turtleList:setItems(filteredList)
end

function TurtleTab:setDetails(turtleId, turtle)
    if turtle and turtleId then
        self.selectedTurtle = turtle
        self.selectedTurtleId = turtleId
        
        -- 设置 Turtle ID
        self.turtleIdValueLabel:setText(tostring(turtleId))
        
        -- 设置名称
        local name = "N/A"
        if turtle.getName then
            name = turtle.getName()
        end
        self.nameValueLabel:setText(name)
        
        -- 设置状态
        local status = turtle.status or "unknown"
        local statusColor = colors.lightGray
        if status == "idle" then
            statusColor = colors.green
        elseif status == "busy" then
            statusColor = colors.yellow
        elseif status == "confirming" then
            statusColor = colors.orange
        else
            statusColor = colors.red
        end
        self.statusValueLabel:setText(status):setBackground(statusColor)
        
        -- 设置电源状态
        local powerStatus = "N/A"
        local powerColor = colors.lightGray
        if turtle.isOn then
            local isOn = turtle.isOn()
            powerStatus = isOn and "ON" or "OFF"
            powerColor = isOn and colors.green or colors.red
        end
        self.isOnValueLabel:setText(powerStatus):setBackground(powerColor)
        
        -- 设置当前配方
        local hasRecipe = turtle.recipe ~= nil
        self.recipeValueLabel:setText(hasRecipe and "Yes" or "None")
        self.recipeValueLabel:setBackground(hasRecipe and colors.green or colors.lightGray)
        
        -- 设置配方输出
        local recipeOutput = "None"
        if turtle.recipe and turtle.recipe.output then
            recipeOutput = removeBeforeColon(turtle.recipe.output)
        end
        self.recipeOutputValueLabel:setText(recipeOutput)
        
    else
        self.selectedTurtle = nil
        self.selectedTurtleId = nil
        
        self.turtleIdValueLabel:setText("None selected")
        self.nameValueLabel:setText("N/A")
        self.statusValueLabel:setText("N/A"):setBackground(colors.lightGray)
        self.isOnValueLabel:setText("N/A"):setBackground(colors.lightGray)
        self.recipeValueLabel:setText("None"):setBackground(colors.lightGray)
        self.recipeOutputValueLabel:setText("None")
    end
end

function TurtleTab:init()
    self:refreshTurtleList()
    self:setDetails(nil, nil)
    
    -- 自动注册到 TaskDispatchMaster 作为观察者
    TaskDispatchMaster.addObserver(self)
    Logger.debug("TurtleTab registered as observer to TaskDispatchMaster")
    
    return self
end

function TurtleTab:destroy()
    -- 清理：从 TaskDispatchMaster 移除观察者
    TaskDispatchMaster.removeObserver(self)
    Logger.debug("TurtleTab unregistered from TaskDispatchMaster")
end

function TurtleTab:update()
    -- 更新列表显示（保持当前搜索条件）
    self:refreshTurtleList(self.searchInput:getText())
    
    -- 如果有选中的turtle，更新其详情
    if self.selectedTurtleId and TaskDispatchMaster.turtles then
        local turtle = TaskDispatchMaster.turtles[self.selectedTurtleId]
        if turtle then
            self:setDetails(self.selectedTurtleId, turtle)
        else
            -- turtle已不存在，清空详情
            self:setDetails(nil, nil)
        end
    end
end

return TurtleTab