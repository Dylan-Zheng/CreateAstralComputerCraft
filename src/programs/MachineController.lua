local basalt = require("libraries.basalt")
local TabView = require("elements.TabView")

local basaltLogEnabled = true
basalt.LOGGER.setEnabled(basaltLogEnabled)
basalt.LOGGER.setLogToFile(true)

local main = basalt.getMainFrame()
basalt.LOGGER.debug("Starting MachineController...")

local tabView = TabView:new(main:addFrame(), 1, 1, main:getWidth(), main:getHeight())
tabView:createTab("Tab 1")
tabView:createTab("Tab 2")
tabView:createTab("Tab 3")
tabView:createTab("Tab 4")
tabView:createTab("Tab 5")
tabView:createTab("Tab 6")
tabView:createTab("Tab 7")
tabView:createTab("Tab 8")
tabView:createTab("Tab 9")


tabView:init()

basalt.run()
