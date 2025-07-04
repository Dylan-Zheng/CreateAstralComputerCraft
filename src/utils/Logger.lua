local Logger = {
    currentLevel = 1, -- Default to DEBUG
    printFunctions = {}
}

Logger.levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

Logger.addPrintFunction = function(func)
    table.insert(Logger.printFunctions, func)
end

Logger.print = function(level, src, currentline, message, ...)
    if level >= Logger.currentLevel then
        local completeMessage = Logger.formatBraces(message, ...)
        for _, func in ipairs(Logger.printFunctions) do
            func(level, src, currentline, completeMessage)
        end
    end
end

Logger.custom = function(level, message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(level, src, currentline, message, ...)
end

Logger.debug = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.DEBUG, src, currentline, message, ...)
end 

Logger.info = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.INFO, src, currentline, message, ...)
end

Logger.warn = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.WARN, src, currentline, message, ...)
end

Logger.error = function(message, ...)
    local currentline = debug.getinfo(2, "l").currentline
    local src = debug.getinfo(2, "S").short_src
    Logger.print(Logger.levels.ERROR, src, currentline, message, ...)
end

Logger.formatBraces = function(message, ...)
    local args = {...}
    local i = 1
    local formatted = tostring(message):gsub("{}", function()
        local arg = args[i]
        i = i + 1
        return tostring(arg)
    end)
    return formatted
end

return Logger