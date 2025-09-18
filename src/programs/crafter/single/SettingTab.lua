local Logger = require("utils.Logger")
local OSUtils = require("utils.OSUtils")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")
local SettingManager = require("programs.crafter.single.SettingManager")

---@diagnostic disable-next-line: undefined-global
local colors = colors

local SettingTab = {}
SettingTab.__index = SettingTab

function SettingTab:new(pframe)

    local this = setmetatable({}, SettingTab)
    this.pframe = pframe
    this.innerFrame = this.pframe:addFrame()
        :setPosition(1, 1)
        :setSize(this.pframe:getWidth(), this.pframe:getHeight())
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    this.recipesChestSettingFrame = this.innerFrame:addFrame()
        :setPosition(2, 2)
        :setSize(this.innerFrame:getWidth() - 2, 6)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.recipesChestTitleLabel = this.recipesChestSettingFrame:addLabel()
        :setText("Inventory Setting")
        :setPosition(2, 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.storageLabel = this.recipesChestSettingFrame:addLabel()
        :setText("Storage:")
        :setPosition(2, 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.storageValueLabel = this.recipesChestSettingFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(this.storageLabel:getX() + this.storageLabel:getWidth() + 1, this.storageLabel:getY())
        :setSize(this.recipesChestSettingFrame:getWidth() - (this.storageLabel:getX() + this.storageLabel:getWidth() + 1), 1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            this:openChestSelector("storage")
        end)
    
    this.bufferLabel = this.recipesChestSettingFrame:addLabel()
        :setText("Buffer:")
        :setPosition(2, this.storageLabel:getY() + this.storageLabel:getHeight())
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.bufferValueLabel = this.recipesChestSettingFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(this.bufferLabel:getX() + this.bufferLabel:getWidth() + 1, this.bufferLabel:getY())
        :setSize(this.recipesChestSettingFrame:getWidth() - (this.bufferLabel:getX() + this.bufferLabel:getWidth() + 1), 1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            this:openChestSelector("buffer")
        end)

    this.saveButton = this.innerFrame:addButton()
        :setText("Save")
        :setPosition(this.innerFrame:getWidth() - 7, this.innerFrame:getHeight() - 2)
        :setSize(6, 1)
        :setBackground(colors.green)
        :setForeground(colors.white)

    this.itemListBox = ItemSelectedListBox:new(this.pframe)

    return this
end

function SettingTab:init()
    local settings = SettingManager.getSettings()
    Logger.debug("Loaded settings: {}", settings)
    
    -- 设置选中的chest
    if settings.storage then
        self.storageValueLabel:setText(settings.storage)
    else
        self.storageValueLabel:setText("...")
    end

    if settings.buffer then
        self.bufferValueLabel:setText(settings.buffer)
    else
        self.bufferValueLabel:setText("...")
    end

    self.saveButton:onClick(function()
        SettingManager.setSettings({
            storage = self.storageValueLabel:getText() ~= "..." and self.storageValueLabel:getText() or nil,
            buffer = self.bufferValueLabel:getText() ~= "..." and self.bufferValueLabel:getText() or nil
        })
        os.reboot()
    end)
end

function SettingTab:openChestSelector(targetType)
    -- 重新加载peripherals以确保获取最新的列表
    PeripheralWrapper.reloadAll()
    
    local peripherals = PeripheralWrapper.getAll()
    
    -- 转换为ItemSelectedListBox需要的格式
    local items = {}
    local currentSelected
    
    if targetType == "storage" then
        currentSelected = self.storageValueLabel:getText()
    elseif targetType == "buffer" then
        currentSelected = self.bufferValueLabel:getText()
    end
    
    for name, peripheral in pairs(peripherals) do
        table.insert(items, {
            text = name,
            selected = (name == currentSelected and currentSelected ~= "...")
        })
    end
    
    -- 打开ItemSelectedListBox
    self.itemListBox:open(items, false, {
        confirm = function(selectedItems)
            if selectedItems and #selectedItems > 0 then
                if targetType == "storage" then
                    self.storageValueLabel:setText(selectedItems[1].text)
                elseif targetType == "buffer" then
                    self.bufferValueLabel:setText(selectedItems[1].text)
                end
            end
        end
    })
end


return SettingTab
