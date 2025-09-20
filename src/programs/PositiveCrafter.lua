local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")
local Logger = require("utils.Logger")
local CraftingListTab = require("programs.crafter.positive.CraftingListTab")
local SnapShot = require("programs.common.SnapShot")
local RecipeManager = require("programs.crafter.positive.RecipeManager")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local TurtleTab = require("programs.crafter.positive.TurtleTab")
local TaskDispatchMaster = require("programs.crafter.positive.TaskDispatchMaster")


-- LOGGER
local basaltLogEnabled = false
basalt.LOGGER.setEnabled(basaltLogEnabled)
basalt.LOGGER.setLogToFile(basaltLogEnabled)

if basaltLogEnabled then
    Logger.addPrintFunction(function(level, src, currentline, message)
        message = string.format("[%s:%d] %s", src, currentline, message)
        if level == Logger.levels.DEBUG then
            basalt.LOGGER.debug(message)
        elseif level == Logger.levels.INFO then
            basalt.LOGGER.info(message)
        elseif level == Logger.levels.WARN then
            basalt.LOGGER.warn(message)
        elseif level == Logger.levels.ERROR then
            basalt.LOGGER.error(message)
        end
    end)
end
Logger.currentLevel = Logger.levels.ERROR
--

PeripheralWrapper.reloadAll()
RecipeManager.load()
SnapShot.takeSnapShot()


local main = basalt.getMainFrame()

local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())

local craftingListTab = tabView:createTab("List")
CraftingListTab:new(craftingListTab.frame, 1, 1, craftingListTab.frame:getWidth(), craftingListTab.frame:getHeight()):init()

local turtlesTab = tabView:createTab("Turtles")
TurtleTab:new(turtlesTab.frame, 1, 1, turtlesTab.frame:getWidth(), turtlesTab.frame:getHeight()):init()

tabView:init()

parallel.waitForAll(
    basalt.run,
    TaskDispatchMaster.run
)