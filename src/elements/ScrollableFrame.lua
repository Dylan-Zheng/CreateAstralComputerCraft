local Logger = require("utils.Logger")

local ScrollableFrame = {}
ScrollableFrame.__index = ScrollableFrame

local function getChildrenHeight(container)
    local height = 0
    for _, child in ipairs(container.get("children")) do
        if(child.get("visible"))then
            local newHeight = child.get("y")
            if newHeight > height then
                height = newHeight
            end
        end
    end
    return height
end

local function scrollableFrame(container)
    container:onScroll(function(self, direction)
        local height = getChildrenHeight(self)
        local scrollOffset = self.get("offsetY")
        local maxScroll = height - self.get("height")
        scrollOffset = math.max(0, math.min(maxScroll, scrollOffset + direction))
        self.set("offsetY", scrollOffset)
    end)
end

function ScrollableFrame.setScrollable(frame, enableScrollBar, backgroundColor, foregroundColor, symbolColor, symbolBackgroundColor)
    scrollableFrame(frame)
    
    if enableScrollBar then
        -- 创建滚动条
        local scrollbar = frame:addScrollbar()
            :setPosition(frame:getWidth(), 1)
            :setSize(1, getChildrenHeight(frame))
            :setBackground(backgroundColor)
            :setForeground(foregroundColor)
            :setSymbolColor(symbolColor)
            :setSymbolBackgroundColor(symbolBackgroundColor)
            :setOrientation("vertical")
            :setStep(1)
        
        -- 将滚动条附加到frame的offsetY属性
        scrollbar:attach(frame, {
            property = "offsetY", 
            min = 0, 
            max = function()
                local contentHeight = getChildrenHeight(frame)
                local frameHeight = frame:getHeight()
                return math.max(0, contentHeight - frameHeight)
            end
        })
        
        -- 存储滚动条引用，便于后续操作
        frame._scrollbar = scrollbar
    end
    
    return frame
end

-- 更新滚动条的最大值，当内容发生变化时调用
function ScrollableFrame.updateScrollbarRange(frame)
    if frame._scrollbar then
        -- 重新计算最大滚动值
        local contentHeight = getChildrenHeight(frame)
        local frameHeight = frame:getHeight()
        local maxScroll = math.max(0, contentHeight - frameHeight)
        
        -- 更新滚动条的max值
        frame._scrollbar.set("maxValue", maxScroll)
    end
end

return ScrollableFrame