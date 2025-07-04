local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")
local CraftingListTab = require("programs.ae2.crafter.CraftingListTab")
local Logger = require("utils.Logger")
local TurtleCraft = require("programs.ae2.crafter.TurtleCraft")
local LogBox = require("elements.LogBox")

-- LOGGER
local basaltLogEnabled = true
basalt.LOGGER.setEnabled(basaltLogEnabled)
basalt.LOGGER.setLogToFile(true)

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

--

local main = basalt.getMainFrame()
basalt.LOGGER.debug("Starting MachineController...")

local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())
local craftingListTab = tabView:createTab("Crafting List")
local logTab = tabView:createTab("Log")
local settingsTab = tabView:createTab("Settings")
local craftingListFrame = CraftingListTab:new(craftingListTab.frame):init()
local logBox = LogBox:new(logTab.frame, 2, 2, logTab.frame:getWidth() -2, logTab.frame:getHeight() -2, colors.white, colors.gray)

tabView:init()

basalt.run()

