local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")
local Logger = require("utils.Logger")
local SnapShot = require("programs.common.SnapShot")
local RecipeManager = require("programs.crafter.positive.RecipeManager")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local RecipeTab = require("programs.crafter.single.RecipeTab")
local SettingTab = require("programs.crafter.single.SettingTab")
local TurtleCraft = require("programs.crafter.positive.TurtleCraft")
local SettingManager = require("programs.crafter.single.SettingManager")

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

local recipesTab = tabView:createTab("RecipesTab")
RecipeTab:new(recipesTab.frame, 1, 1, recipesTab.frame:getWidth(), recipesTab.frame:getHeight()):init()

local settingTab = tabView:createTab("Settings")
SettingTab:new(settingTab.frame):init()

tabView:init()

local recipes = RecipeManager.getRecipes()

local executeRecipes = function()
    local waitTime = 1
    while true do
        if RecipeManager.checkedUpdate() then
            recipes = RecipeManager.getRecipes()
        end
        for _, recipe in pairs(recipes) do
            if TurtleCraft.triggerEval(recipe) and TurtleCraft.storeVerify(recipe) then
                if TurtleCraft.craft(recipe) then
                    waitTime = 0.2
                end
            end
        end
        os.sleep(waitTime)
    end
end

pcall(function()
    TurtleCraft.setStorage(PeripheralWrapper.getByName(SettingManager.getSettings().storage))
    TurtleCraft.setBuffer(PeripheralWrapper.getByName(SettingManager.getSettings().buffer))
end)

parallel.waitForAll(
    basalt.run,
    executeRecipes
)
