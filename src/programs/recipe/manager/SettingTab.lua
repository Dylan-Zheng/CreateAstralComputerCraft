local Logger = require("utils.Logger")
local OSUtils = require("utils.OSUtils")
local ScrollableFrame = require("elements.ScrollableFrame")
local Communicator = require("programs.common.Communicator")

local peripheral = peripheral -- reference to global peripheral API

local SettingTab = {}
SettingTab.__index = SettingTab

local getAllModemSides = function ()
    local sides = {}
    for _, side in pairs(OSUtils.SIDES) do
        if peripheral.getType(side) == "modem" then
            table.insert(sides, side)
        end
    end
    return sides
end

local getModemSideDropDownDisplayItems = function (selectedSide)
    local items = {}
    local sides = getAllModemSides()
    Logger.debug("selectedSide: {}", selectedSide)
    for _, side in pairs(sides) do
        table.insert(items, {
            text = side,
            selected = side == selectedSide,
            value = side
        })
        Logger.debug("Modem side found: {} and is selected: {}", side, side == selectedSide)
    end
    return items
end

function SettingTab:new(pframe)
    local this = setmetatable({}, SettingTab)
    this.pframe = pframe

    this.innerFrame = this.pframe:addFrame()
        :setPosition(1, 1)
        :setSize(this.pframe:getWidth(), this.pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.modemLabel = this.innerFrame:addLabel()
        :setText("Modem Setting:")
        :setPosition(2, 2)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.sideLabel = this.innerFrame:addLabel()
        :setText("Side:")
        :setPosition(2, 4)
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
    
    this.sideDropdown = this.innerFrame:addDropdown() 
        :setPosition(this.sideLabel:getX() + this.sideLabel:getWidth() + 1, this.sideLabel:getY())
        :setSize(6, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.channelLabel = this.innerFrame:addLabel()
        :setText("Channel:")
        :setPosition(this.sideDropdown:getX() + this.sideDropdown:getWidth() + 2, this.sideDropdown:getY())
        :setForeground(colors.white)

    this.channelInput = this.innerFrame:addInput()
        :setPosition(this.channelLabel:getX() + this.channelLabel:getWidth() + 1, this.channelLabel:getY())
        :setSize(6, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.secretLabel = this.innerFrame:addLabel()
        :setText("Secret:")
        :setPosition(this.channelInput:getX() + this.channelInput:getWidth() + 2, this.channelLabel:getY())
        :setForeground(colors.white)

    this.secretInput = this.innerFrame:addInput()
        :setPosition(this.secretLabel:getX() + this.secretLabel:getWidth() + 1, this.secretLabel:getY())
        :setSize(8, 1)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.saveButton = this.innerFrame:addButton()
        :setText("Apply")
        :setPosition(this.innerFrame:getWidth() - 7, this.innerFrame:getHeight() - 1)
        :setSize(7, 1)
        :setBackground(colors.green)
        :setForeground(colors.white)
        :onClick(function()
            local side = this.sideDropdown:getSelectedItem() and this.sideDropdown:getSelectedItem().value
            local channel = tonumber(this.channelInput:getText())
            local secret = this.secretInput:getText()
            if side and channel and secret and peripheral.getType(side) == "modem" then
                Communicator.closeAllChannels()
                Logger.info(string.format("Modem setting saved: side=%s, channel=%d, secret=%s", side, channel, secret))
                Communicator.open(side, channel, "recipe", secret)
                Communicator.saveSettings()
            else
                Logger.error("Invalid modem settings. Please check your inputs.")
            end
        end)

    ScrollableFrame.setScrollable(this.innerFrame)

    return this
end

function SettingTab:init()
    local setting = Communicator.getSettings()
    if setting and #setting > 0 then
        local firstSetting = setting[1]
        self.sideDropdown:setItems(getModemSideDropDownDisplayItems(firstSetting.side))
        self.channelInput:setText(tostring(firstSetting.channel))
        self.secretInput:setText(firstSetting.secret)
    else
        self.sideDropdown:setItems(getModemSideDropDownDisplayItems()) 
    end
    return self
end

return SettingTab