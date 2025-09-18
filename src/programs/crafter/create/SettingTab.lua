local Logger = require("utils.Logger")
local OSUtils = require("utils.OSUtils")
local Manager = require("programs.crafter.create.Manager")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local ItemSelectedListBox = require("elements.ItemSelectedListBox")

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
        :setText("Recipes Chest Setting")
        :setPosition(2, 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.chestLabel = this.recipesChestSettingFrame:addLabel()
        :setText("Chest:")
        :setPosition(2, 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.chestValueLabel = this.recipesChestSettingFrame:addLabel()
        :setAutoSize(false)
        :setBackgroundEnabled(true)
        :setPosition(this.chestLabel:getX() + this.chestLabel:getWidth() + 1, this.chestLabel:getY())
        :setSize(this.recipesChestSettingFrame:getWidth() - (this.chestLabel:getX() + this.chestLabel:getWidth() + 1), 1)
        :setText("...")
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :onClick(function()
            this:openChestSelector()
        end)

    this.widthLabel = this.recipesChestSettingFrame:addLabel()
        :setText("Width:")
        :setPosition(2, this.chestLabel:getY() + this.chestLabel:getHeight())
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.widthInput = this.recipesChestSettingFrame:addInput()
        :setPosition(this.widthLabel:getX() + this.widthLabel:getWidth() + 1, this.widthLabel:getY())
        :setSize(4, 1)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setPattern("^[0-9]*$")
        :setText("0")

    this.heightLabel = this.recipesChestSettingFrame:addLabel()
        :setText("Height:")
        :setPosition(this.widthInput:getX() + this.widthInput:getWidth() + 2, this.widthLabel:getY())
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.heightInput = this.recipesChestSettingFrame:addInput()
        :setPosition(this.heightLabel:getX() + this.heightLabel:getWidth() + 1, this.heightLabel:getY())
        :setSize(4, 1)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setPattern("^[0-9]*$")
        :setText("0")

    this.crafterSettingFrame = this.innerFrame:addFrame()
        :setPosition(2, this.recipesChestSettingFrame:getY() + this.recipesChestSettingFrame:getHeight() + 1)
        :setSize(this.innerFrame:getWidth() - 2, 5)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.crafterTitleLabel = this.crafterSettingFrame:addLabel()
        :setText("Crafter Setting")
        :setPosition(2, 2)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.crafterWidthLabel = this.crafterSettingFrame:addLabel()
        :setText("Width:")
        :setPosition(2, 4)
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.crafterWidthInput = this.crafterSettingFrame:addInput()
        :setPosition(this.crafterWidthLabel:getX() + this.crafterWidthLabel:getWidth() + 1, this.crafterWidthLabel:getY())
        :setSize(4, 1)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setPattern("^[0-9]*$")
        :setText("0")

    this.crafterHeightLabel = this.crafterSettingFrame:addLabel()
        :setText("Height:")
        :setPosition(this.crafterWidthInput:getX() + this.crafterWidthInput:getWidth() + 2, this.crafterWidthLabel:getY())
        :setBackground(colors.gray)
        :setForeground(colors.white)

    this.crafterHeightInput = this.crafterSettingFrame:addInput()
        :setPosition(this.crafterHeightLabel:getX() + this.crafterHeightLabel:getWidth() + 1, this.crafterHeightLabel:getY())
        :setSize(4, 1)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setPattern("^[0-9]*$")
        :setText("0")

    this.saveButton = this.innerFrame:addButton()
        :setText("Save")
        :setPosition(2, this.crafterSettingFrame:getY() + this.crafterSettingFrame:getHeight() + 1)
        :setSize(10, 3)
        :setBackground(colors.green)
        :setForeground(colors.white)

    this.itemListBox = ItemSelectedListBox:new(this.pframe)

    return this
end

function SettingTab:init()
    local settings = Manager.getSettings()
    Logger.debug("Loaded settings: {}", settings)

    self.widthInput:setText(tostring(settings.recipesChestSize and settings.recipesChestSize.width or 0))
    self.heightInput:setText(tostring(settings.recipesChestSize and settings.recipesChestSize.height or 0))
    self.crafterWidthInput:setText(tostring(settings.crafterSize and settings.crafterSize.width or 0))
    self.crafterHeightInput:setText(tostring(settings.crafterSize and settings.crafterSize.height or 0))
    
    -- 设置选中的chest
    if settings.recipesChest and settings.recipesChest ~= "" then
        self.chestValueLabel:setText(settings.recipesChest)
    end

    self.saveButton:onClick(function()
        local recipesChestWidth = tonumber(self.widthInput:getText()) or 0
        local recipesChestHeight = tonumber(self.heightInput:getText()) or 0
        local crafterWidth = tonumber(self.crafterWidthInput:getText()) or 0
        local crafterHeight = tonumber(self.crafterHeightInput:getText()) or 0
        local selectedChest = self.chestValueLabel:getText()
        
        Manager.setSettings({
            crafterSize = {
                width = crafterWidth,
                height = crafterHeight
            },
            recipesChestSize = {
                width = recipesChestWidth,
                height = recipesChestHeight
            },
            recipesChest = selectedChest ~= "..." and selectedChest or nil
        })
        os.reboot()
    end)
end

function SettingTab:openChestSelector()
    -- 重新加载peripherals以确保获取最新的列表
    PeripheralWrapper.reloadAll()
    
    -- 获取包含"chest"的peripherals
    local chestPeripherals = PeripheralWrapper.getAllPeripheralsNameContains("chest")
    
    -- 转换为ItemSelectedListBox需要的格式
    local items = {}
    local currentSelected = self.chestValueLabel:getText()
    
    for name, peripheral in pairs(chestPeripherals) do
        table.insert(items, {
            text = name,
            selected = (name == currentSelected and currentSelected ~= "...")
        })
    end
    
    -- 打开ItemSelectedListBox
    self.itemListBox:open(items, false, {
        confirm = function(selectedItems)
            if selectedItems and #selectedItems > 0 then
                self.chestValueLabel:setText(selectedItems[1].text)
            end
        end
    })
end


return SettingTab
