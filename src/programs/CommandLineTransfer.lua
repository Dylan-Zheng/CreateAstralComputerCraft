local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local CommandLine = require("programs.command.CommandLine")
local ListCommand = require("programs.command.transfer.ListCommand")
local JobCommand = require("programs.command.transfer.JobCommand")
local JobDataManager = require("programs.command.transfer.JobDataManager")
local JobExecutor = require("programs.command.transfer.JobExecutor")
local Logger = require("utils.Logger")

-- Set logger level
Logger.currentLevel = Logger.levels.ERROR
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
JobDataManager:load()

-- Add commands
local mainCommandLine = CommandLine:new()
mainCommandLine:addCommand("list", 
    "List system components. Usage: list <inventory|tank|item|fluid|reload> [page]",
    ListCommand.execute, ListCommand.complete)
mainCommandLine:addCommand("job", 
    "Manage transfer jobs. Usage: job <list|create|edit|save|delete> [name]",
    JobCommand.execute, JobCommand.complete)


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
