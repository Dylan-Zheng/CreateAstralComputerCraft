local basalt = require("libraries.basalt")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
PeripheralWrapper.reloadAll()

local TabView = require("elements.TabView")
local Logger = require("utils.Logger")
local SnapShot = require("programs.common.SnapShot")
local SettingTab = require("programs.crafter.create.SettingTab")
local RecipesTab = require("programs.crafter.create.RecipesTab")
local Executor = require("programs.crafter.create.Executor")


-- LOGGER SETUP
local basaltLogEnabled = true

Logger.level = Logger.levels.DEBUG
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

SnapShot.loadFromFilesOnly()

local main = basalt.getMainFrame()

local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())

local recipes = tabView:createTab("Recipes")
RecipesTab:new(recipes.frame):init()

local settingTab = tabView:createTab("Settings")
SettingTab:new(settingTab.frame):init()

tabView:init()

parallel.waitForAll(
    Executor.run,
    basalt.run
)