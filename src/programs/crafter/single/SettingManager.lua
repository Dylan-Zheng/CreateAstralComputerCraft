local OSUtils = require("utils.OSUtils")
local Logger = require("utils.Logger")

local SettingManager = {
    settings = nil,
}

SettingManager.getSettings = function()
    if not SettingManager.settings then
        SettingManager.settings = OSUtils.loadTable("Settings") or {
            storage = nil,
            buffer = nil
        }
    end
    return SettingManager.settings
end

SettingManager.setSettings = function(newSettings)
    SettingManager.settings = newSettings
    OSUtils.saveTable("Settings", SettingManager.settings)
end

return SettingManager