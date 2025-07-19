local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")
local Logger = require("utils.Logger")


local main = basalt.getMainFrame()
local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())

local craftingListTab = tabView:createTab("Crafting List")

