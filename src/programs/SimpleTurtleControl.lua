local basalt = require("libraries.basalt")
local LogBox = require("elements.LogBox")
local Logger = require("utils.Logger")

-- Global references for ComputerCraft
---@diagnostic disable-next-line: undefined-global
local colors = colors
--- @diagnostic disable-next-line: undefined-global
local turtle = turtle
--- @diagnostic disable-next-line: undefined-global
local parallel = parallel


local main = basalt.getMainFrame():setBackground(colors.white)

local slotSelectFrame = main:addFrame()
    :setPosition(1, 1)
    :setSize(main:getWidth(), 9)
    :setBackground(colors.black)
    :setForeground(colors.white)

local slotBtnTable = {}
for i = 1, 16 do
    local x = ((i - 1) % 4) * 5 + 2
    local y = math.floor((i - 1) / 4) * 2 + 2

    local text = tostring(i)
    if i < 10 then
        text = "0" .. text
    end
    slotBtnTable[i] = slotSelectFrame:addButton()
        :setPosition(x, y)
        :setSize(4, 1)
        :setText(text)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            local currentSlot = turtle.getSelectedSlot()
            slotBtnTable[currentSlot]:setBackground(colors.gray)
            turtle.select(i)
            slotBtnTable[i]:setBackground(colors.green)
        end)
end

local refuelBtn = slotSelectFrame:addButton()
    :setPosition(22, 2)
    :setSize(8, 1)
    :setText("Refuel")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local currentSlot = turtle.getSelectedSlot()
        local success, message = turtle.refuel()
        if success then
            Logger.info("Refueled from slot {}, current fuel: {}", currentSlot, turtle.getFuelLevel())
        else
            Logger.error("Refuel failed from slot {}: {}", currentSlot, message or "unknown error")
        end
    end)

local dropBtn = slotSelectFrame:addButton()
    :setPosition(refuelBtn:getX() + refuelBtn:getWidth() + 1, refuelBtn:getY())
    :setSize(4, 1)
    :setText("Drop")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local currentSlot = turtle.getSelectedSlot()
        local success, message = turtle.drop()
        if success then
            Logger.info("Dropped items from slot {}.", currentSlot)
        else
            Logger.error("Drop failed from slot {}: {}", currentSlot, message or "unknown error")
        end
    end)

local digBtn = slotSelectFrame:addButton()
    :setPosition(22, 4)
    :setSize(4, 1)
    :setText("dF")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.dig()
        if success then
            Logger.info("Dug block in front.")
        else
            Logger.error("Dig failed: {}", message or "unknown error")
        end
    end)


local digUpBtn = slotSelectFrame:addButton()
    :setPosition(digBtn:getX() + digBtn:getWidth() + 1, digBtn:getY())
    :setSize(4, 1)
    :setText("dU")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.digUp()
        if success then
            Logger.info("Dug block above.")
        else
            Logger.error("Dig Up failed: {}", message or "unknown error")
        end
    end)

local digDownBtn = slotSelectFrame:addButton()
    :setPosition(digUpBtn:getX() + digUpBtn:getWidth() + 1, digUpBtn:getY())
    :setSize(4, 1)
    :setText("dD")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.digDown()
        if success then
            Logger.info("Dug block below.")
        else
            Logger.error("Dig Down failed: {}", message or "unknown error")
        end
    end)

local placeBtn = slotSelectFrame:addButton()
    :setPosition(22, 6)
    :setSize(4, 1)
    :setText("pF")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.place()
        if success then
            Logger.info("Placed block in front.")
        else
            Logger.error("Place failed: {}", message or "unknown error")
        end
    end)

local placeUpBtn = slotSelectFrame:addButton()
    :setPosition(placeBtn:getX() + placeBtn:getWidth() + 1, placeBtn:getY())
    :setSize(4, 1)
    :setText("pU")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.placeUp()
        if success then
            Logger.info("Placed block above.")
        else
            Logger.error("Place Up failed: {}", message or "unknown error")
        end
    end)

local placeDownBtn = slotSelectFrame:addButton()
    :setPosition(placeUpBtn:getX() + placeUpBtn:getWidth() + 1, placeUpBtn:getY())
    :setSize(4, 1)
    :setText("pD")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.placeDown()
        if success then
            Logger.info("Placed block below.")
        else
            Logger.error("Place Down failed: {}", message or "unknown error")
        end
    end)

local suckBtn = slotSelectFrame:addButton()
    :setPosition(22, 8)
    :setSize(4, 1)
    :setText("sF")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.suck()
        if success then
            Logger.info("Sucked item from front.")
        else
            Logger.error("Suck failed: {}", message or "unknown error")
        end
    end)

local suckUpBtn = slotSelectFrame:addButton()
    :setPosition(suckBtn:getX() + suckBtn:getWidth() + 1, suckBtn:getY())
    :setSize(4, 1)
    :setText("sU")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.suckUp()
        if success then
            Logger.info("Sucked item from above.")
        else
            Logger.error("Suck Up failed: {}", message or "unknown error")
        end
    end)

local suckDownBtn = slotSelectFrame:addButton()
    :setPosition(suckUpBtn:getX() + suckUpBtn:getWidth() + 1, suckUpBtn:getY())
    :setSize(4, 1)
    :setText("sD")
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :onClick(function()
        local success, message = turtle.suckDown()
        if success then
            Logger.info("Sucked item from below.")
        else
            Logger.error("Suck Down failed: {}", message or "unknown error")
        end
    end)

local logFrame = main:addFrame()
    :setPosition(1, slotSelectFrame:getY() + slotSelectFrame:getHeight())
    :setSize(main:getWidth(), main:getHeight() - 9)
    :setBackground(colors.lightGray)
    :setForeground(colors.white)

local logBox = LogBox:new(
    logFrame, 2, 1,
    logFrame:getWidth() -2,
    logFrame:getHeight(),
    colors.white, 
    colors.gray)

Logger.addPrintFunction(function(_, _, _, message)
    logBox:addLog(message)
end)

local onKeyPress = function()
    while true do
        local event, key = os.pullEvent("key")
        local directionText = ""
        local isMoveKeyPressed = false
        if key == 87 then
            turtle.forward()
            directionText = "Forward"
            isMoveKeyPressed = true
        elseif key == 83 then
            turtle.back()
            directionText = "Back"
            isMoveKeyPressed = true
        elseif key == 65 then
            turtle.turnLeft()
            directionText = "Turn Left"
            isMoveKeyPressed = true
        elseif key == 68 then
            turtle.turnRight()
            directionText = "Turn Right"
            isMoveKeyPressed = true
        elseif key == 81 then
            turtle.up()
            directionText = "Up"
            isMoveKeyPressed = true
        elseif key == 69 then
            turtle.down()
            directionText = "Down"
            isMoveKeyPressed = true
        end
        if isMoveKeyPressed then
            local currentFuel = turtle.getFuelLevel()
            local maxFuel = turtle.getFuelLimit()
            Logger.info("Turtle {}, Fuel: {}/{}", directionText, currentFuel, maxFuel == "unlimited" and "unlimited" or tostring(maxFuel))
        end
    end
end

parallel.waitForAll(basalt.run, onKeyPress)