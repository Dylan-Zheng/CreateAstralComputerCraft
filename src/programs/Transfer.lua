local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")
local transferTab = require("programs.transfer.TransferTab")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local TransferJobManager = require("programs.transfer.TransferJobManager")
local Logger = require("utils.Logger")
local LogBox = require("elements.LogBox")

-- LOGGER
local basaltLogEnabled = true
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
-- LOGGER

PeripheralWrapper.reloadAll()
TransferJobManager.load()

local main = basalt.getMainFrame()

local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())



local transfers = tabView:createTab("Transfers")
local transferTab = transferTab:new(transfers.frame, tabView)

local logTab = tabView:createTab("Log")
local logBox = LogBox:new(logTab.frame, 2, 2, logTab.frame:getWidth() -2, logTab.frame:getHeight() -2, colors.white, colors.gray)

transferTab:init()
tabView:init()

Logger.addPrintFunction(function(level, src, currentline, message)
    logBox:addLog(string.format("[%d] %s", currentline, message))
end)


parallel.waitForAll(basalt.run,
    function()
        while true do
            TransferJobManager.exec()
            os.sleep(0.2)
        end
    end
)
