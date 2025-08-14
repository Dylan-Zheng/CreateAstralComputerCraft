local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local CommandLine = require("programs.command.CommandLine")
local ListCommand = require("programs.command.transfer.ListCommand")
local JobCommand = require("programs.command.transfer.JobCommand")
local JobDataManager = require("programs.command.transfer.JobDataManager")
local JobExecutor = require("programs.command.transfer.JobExecutor")
local Logger = require("utils.Logger")
local SnapShot = require("programs.command.transfer.SnapShot")

-- Set logger level
Logger.currentLevel = Logger.levels.DEBUG
Logger.addPrintFunction(function(level, src, currentline, message)
    message = string.format("[%s:%d] %s", src, currentline, message)
    if level == Logger.levels.DEBUG then
        print("DEBUG: " .. message)
    elseif level == Logger.levels.INFO then
        print("INFO: " .. message)
    elseif level == Logger.levels.WARN then
        print("WARN: " .. message)
    elseif level == Logger.levels.ERROR then
        print("ERROR: " .. message)
    end
end)

-- Initialize all peripherals and load job data
PeripheralWrapper.reloadAll()
SnapShot.takeSnapShot()
JobDataManager:load()

-- Add commands
local mainCommandLine = CommandLine:new()
mainCommandLine:addCommand("list", 
    "List system components. Usage: list <inventory|tank|item|fluid|reload> [page]",
    ListCommand.execute, ListCommand.complete)
mainCommandLine:addCommand("job", 
    "Manage transfer jobs. Usage: job <list|create|edit|save|delete> [name]",
    JobCommand.execute, JobCommand.complete)
mainCommandLine:addCommand("log", 
    "Manage logging level. Usage: log set <debug|info|warn|error>",
    function(input)
        local args = {}
        for arg in string.gmatch(input, "%S+") do
            table.insert(args, arg)
        end
        
        if #args < 2 then
            -- Show current log level
            local currentLevelName = "unknown"
            for name, level in pairs(Logger.levels) do
                if level == Logger.currentLevel then
                    currentLevelName = string.lower(name)
                    break
                end
            end
            print("Current log level: " .. currentLevelName)
            print("Usage: log set <debug|info|warn|error>")
            return
        end
        
        local action = string.lower(args[2])
        if action == "set" then
            if #args < 3 then
                print("Usage: log set <debug|info|warn|error>")
                return
            end
            
            local levelName = string.upper(args[3])
            if Logger.levels[levelName] then
                Logger.currentLevel = Logger.levels[levelName]
                print("Log level set to: " .. string.lower(levelName))
            else
                print("Invalid log level. Use: debug, info, warn, or error")
            end
        else
            print("Usage: log set <debug|info|warn|error>")
        end
    end,
    function(argsText)
        local args = {}
        for arg in string.gmatch("log " .. argsText, "%S+") do
            table.insert(args, arg)
        end
        
        if #args == 2 then
            return CommandLine.filterSuggestions({"set"}, args[2])
        elseif #args == 3 and args[2] == "set" then
            return CommandLine.filterSuggestions({"debug", "info", "warn", "error"}, args[3])
        end
        
        return {}
    end)


-- Start the command line interface
parallel.waitForAll(
    function()
        while true do
            mainCommandLine:run()
        end
    end,
    function()
        -- Periodically execute jobs every 10 seconds
        while true do
            JobExecutor.run()
            os.sleep(0.2)
        end
    end
)
