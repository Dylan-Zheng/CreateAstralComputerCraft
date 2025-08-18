local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")
local DepotRecipeTab = require("programs.recipe.manager.DepotRecipeTab")
local StoreManager = require("programs.recipe.manager.StoreManager")
local SnapShot = require("programs.common.SnapShot")
local Logger = require("utils.Logger")
local SettringTab = require("programs.recipe.manager.SettingTab")
local Communicator = require("programs.common.Communicator")
local BasinRecipeTab = require("programs.recipe.manager.BasinRecipeTab")

-- LOGGER SETUP
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

-- END LOGGER SETUP

StoreManager.init()
SnapShot.takeSnapShot()
Communicator.loadSettings()

local main = basalt.getMainFrame()

local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())

local depotTab = tabView:createTab("Depot")
local basinTab = tabView:createTab("Basin")
local beltTab = tabView:createTab("Belt")

local settingTab = tabView:createTab("Settings")

DepotRecipeTab:new(depotTab.frame):init()
BasinRecipeTab:new(basinTab.frame):init()
SettringTab:new(settingTab.frame):init()

tabView:init()

basalt.run()
