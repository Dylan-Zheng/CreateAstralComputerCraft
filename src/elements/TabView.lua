local basalt = require("libraries.basalt")

local LOGGER = basalt.LOGGER

local Direction = {
    LEFT = 1,
    RIGHT = 2,
}

local TabView = {}

TabView.__index = TabView

function TabView:new(pframe, x, y, width, height, tabBg, tabFg, bottomFrameBg, bottomFrameFg)
    local instance = setmetatable({}, TabView)

    instance.frame = pframe

    self.selectedTab = nil

    self.firstTab = nil
    self.lastTab = nil
    
    instance.leftIcon = "\17"
    instance.rightIcon = "\16"
    instance.vSep = "|"

    instance.tabs = {}
    instance.vSepLabel = {}

    instance.firstTabidx = 1

    instance.tabBg = tabBg or colors.black
    instance.tabFg = tabFg or colors.white
    instance.bottomFrameBg = bottomFrameBg or colors.lightGray
    instance.bottomFrameFg = bottomFrameFg or colors.white

    instance.frame:setPosition(x, y)
        :setSize(width, height)
        :setBackground(instance.tabBg)
        :setForeground(instance.tabFg)

    instance.topFrame = instance.frame:addFrame()
        :setPosition(1, 1)
        :setSize(pframe:getWidth(), 1)
        :setBackground(instance.tabBg)
        :setForeground(instance.tabFg)

    instance.leftIconLabel = instance.topFrame:addLabel()
        :setText(instance.leftIcon)
        :setPosition(1, 1)
        :setBackground(instance.tabBg)
        :setForeground(instance.tabFg)
        :setBackgroundEnabled(true)
        :setAutoSize(true)
        :onClick(function()
            instance:updateTabBar(instance.lastTab and instance.lastTab.idx or 0, Direction.LEFT)
        end)

    instance.rightIconLabel = instance.topFrame:addLabel()
        :setText(instance.rightIcon)
        :setPosition(instance.topFrame:getWidth(), 1)
        :setBackground(instance.tabBg)
        :setForeground(instance.tabFg)
        :setAutoSize(true)
        :setBackgroundEnabled(true)
        :onClick(function()
            instance:updateTabBar(instance.firstTab and instance.firstTab.idx or 0, Direction.RIGHT)
        end)

    instance.bottomFrame = instance.frame:addFrame()
        :setPosition(1, 2)
        :setSize(pframe:getWidth(), pframe:getHeight() - 1)
        :setBackground(instance.bottomFrameBg)
        :setForeground(instance.bottomFrameFg)

    return instance
end

function TabView:selectTab (tab) 
    if tab.selected then
        LOGGER.debug("Tab " .. tab.name .. " is already selected.")
        return
    end
    for _, t in ipairs(self.tabs) do
        if t.selected then
            t.selected = false
            t.label:setBackground(self.tabBg)
            t.label:setForeground(self.tabFg)
            t.frame:setVisible(false)
        end
    end
    if tab then
        self.selectedTab = tab
        tab.selected = true
        tab.label:setBackground(self.bottomFrameBg)
        tab.label:setForeground(self.bottomFrameFg)
        tab.frame:setVisible(true)
    end
end


function TabView:createTab(name)

    LOGGER.debug("Creating tab: " .. name)

    local singleTabView = {}

    singleTabView.name = name
    singleTabView.idx = #self.tabs + 1
    singleTabView.selected = false

    singleTabView.label = self.topFrame:addLabel()
        :setText(" " .. name .. " ")
        :setBackground(self.tabBg)
        :setForeground(self.tabFg)
        :setAutoSize(true)
        :setBackgroundEnabled(true)
        :setVisible(false)
        :onClick(function()
            self:selectTab(singleTabView)
        end)

    singleTabView.frame = self.bottomFrame:addFrame()
        :setPosition(1, 1)
        :setSize(self.bottomFrame:getWidth(), self.bottomFrame:getHeight())
        :setBackground(self.bottomFrameBg)
        :setForeground(self.bottomFrameFg)
        :setVisible(false)

    table.insert(self.tabs, singleTabView)

    return self.tabs[#self.tabs]
end

function TabView:getVSepLabel(idx)
    if not self.vSepLabel[idx] then
        self.vSepLabel[idx] = self.topFrame:addLabel()
            :setText(self.vSep)
            :setBackground(self.tabBg)
            :setForeground(self.tabFg)
            :setAutoSize(true)
            :setBackgroundEnabled(true)
    end
    return self.vSepLabel[idx]
end

function TabView:nextTab(idx)
    local nextIdx = idx + 1
    if nextIdx > #self.tabs then
        nextIdx = 1
    end
    return self.tabs[nextIdx]
end

function TabView:prevTab(idx)
    local prevIdx = idx - 1
    if prevIdx < 1 then
        prevIdx = #self.tabs
    end
    return self.tabs[prevIdx]
end

function TabView:displayTopFrameLabel(prevLabel, label, direction)
    local x
    if direction == Direction.LEFT then
        x = prevLabel:getX() - label:getWidth()
    else
        x = prevLabel:getX() + prevLabel:getWidth()
    end
    local y = prevLabel:getY()
    LOGGER.debug("Setting label position to: " .. x .. ", " .. y)
    label:setPosition(x, y)
    label:setVisible(true)
end

function TabView:updateTabBar(currentIdx, direction)
    LOGGER.debug("==================================================")

    if #self.tabs == 0 then
        return
    end

    -- Hide all tab labels and vSepLabels first
    for _, tab in ipairs(self.tabs) do
        tab.label:setVisible(false)
    end
    for _, vlabel in pairs(self.vSepLabel) do
        vlabel:setVisible(false)
    end

    local vSepIdx = 1
    local vSepLabel = self:getVSepLabel(vSepIdx)

    local arrowLabel = (direction == Direction.LEFT) and self.rightIconLabel or self.leftIconLabel
    self:displayTopFrameLabel(arrowLabel, vSepLabel, direction)

    local totalWidth = 0
    local idx = currentIdx
    local maxWidth = self.topFrame:getWidth() - 2
    local displayedTabs = {}

    -- Collect tabs to display within maxWidth
    for i = 1, #self.tabs do
        local currTab = (direction == Direction.LEFT) and self:prevTab(idx) or self:nextTab(idx)
        if i == 1 then
            if direction == Direction.RIGHT then
                self.firstTab = currTab
            else
                self.lastTab = currTab
            end
        end
        local tabWidth = currTab.label:getWidth() + vSepLabel:getWidth()
        if totalWidth + tabWidth <= maxWidth then
            table.insert(displayedTabs, currTab)
            totalWidth = totalWidth + tabWidth
            if direction == Direction.LEFT then
                self.firstTab = currTab
            else
                self.lastTab = currTab
            end
        else
            LOGGER.debug("Tab bar is full, hiding tab: " .. currTab.name)
            currTab.label:setVisible(false)
        end
        idx = currTab.idx
    end

    -- Actually display the collected tabs and separators
    vSepIdx = 1
    vSepLabel = self:getVSepLabel(vSepIdx)
    local prevLabel = arrowLabel
    for _, tab in ipairs(displayedTabs) do
        tab.label:setVisible(true)
        self:displayTopFrameLabel(prevLabel, vSepLabel, direction)
        self:displayTopFrameLabel(vSepLabel, tab.label, direction)
        vSepIdx = vSepIdx + 1
        prevLabel = tab.label
        vSepLabel = self:getVSepLabel(vSepIdx)
    end
    
    -- Place the last separator and arrow
    self:displayTopFrameLabel(prevLabel, vSepLabel, direction)
    self:displayTopFrameLabel(vSepLabel, (direction == Direction.LEFT) and self.leftIconLabel or self.rightIconLabel, direction)

    LOGGER.debug("firstTab: " .. (self.firstTab and self.firstTab.name or "nil") .. " LastTab: " .. (self.lastTab and self.lastTab.name or "nil"))
end

function TabView:init()
    self:updateTabBar(0 , Direction.RIGHT)
    if #self.tabs > 0 then
        self:selectTab(self.tabs[1])
    end
end

function TabView:getTabByName(name)
    for _, tab in ipairs(self.tabs) do
        if tab.name == name then
            return tab
        end
    end
    return nil
end

function TabView:getTabByIndex(idx)
    if idx < 1 or idx > #self.tabs then
        return nil
    end
    return self.tabs[idx]
end

return TabView