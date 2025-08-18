local SnapShot = require("programs.common.SnapShot")
local JobDataManager = require("programs.command.transfer.JobDataManager")
local CommandLine = require("programs.command.CommandLine")

local JobCommand = {}

-- Utility function to parse arguments
local function parseArgs(input)
    local args = {}
    for arg in string.gmatch(input, "%S+") do
        table.insert(args, arg)
    end
    return args
end

-- Get all job names for auto-completion
local function getJobNames()
    local names = {}
    for jobName, _ in pairs(JobDataManager.jobs) do
        table.insert(names, jobName)
    end
    table.sort(names)
    return names
end

-- Shared subcommand instance that can be reused
local sharedSubCommandLine = nil
local currentJobName = nil

-- Initialize the shared subcommand if not already created
local function getOrCreateSubCommand()
    if sharedSubCommandLine then
        sharedSubCommandLine:changeSuffix(currentJobName .. ">")
        return sharedSubCommandLine
    end
    
    
    sharedSubCommandLine = CommandLine:new()
    sharedSubCommandLine:changeSuffix(currentJobName .. ">")
    
    -- Helper function to get component type from arguments
    local function getComponentTypeFromArgs(direction, componentClass)
        if direction == "input" and componentClass == "inventory" then
            return JobDataManager.JOB_COMPONENT_TYPES.INPUT_INVENTORY
        elseif direction == "output" and componentClass == "inventory" then
            return JobDataManager.JOB_COMPONENT_TYPES.OUTPUT_INVENTORY
        elseif direction == "input" and componentClass == "tank" then
            return JobDataManager.JOB_COMPONENT_TYPES.INPUT_TANK
        elseif direction == "output" and componentClass == "tank" then
            return JobDataManager.JOB_COMPONENT_TYPES.OUTPUT_TANK
        elseif direction == "filter" then
            return JobDataManager.JOB_COMPONENT_TYPES.FILTER
        end
        return nil
    end
    
    -- List command
    sharedSubCommandLine:addCommand("list", "List job components. Usage: list <input|output|filter|blacklist> [inventory|tank]", function(input)
        local args = parseArgs(input)
        if #args < 2 then
            print("Usage: list <input|output|filter|blacklist> [inventory|tank]")
            return
        end
        
        local direction = string.lower(args[2])
        local componentClass = args[3] and string.lower(args[3])
        
        if direction == "filter" then
            local filters = JobDataManager:getJobDetail(currentJobName, JobDataManager.JOB_COMPONENT_TYPES.FILTER) or {}
            print("=== Filters ===")
            for _, filter in ipairs(filters) do
                print("- " .. filter)
            end
        elseif direction == "blacklist" then
            local job = JobDataManager:getJob(currentJobName)
            local isBlacklist = job and job.isFilterBlacklist or false
            print("=== Blacklist Setting ===")
            print("Enabled: " .. tostring(isBlacklist))
        elseif (direction == "input" or direction == "output") and componentClass then
            local componentType = getComponentTypeFromArgs(direction, componentClass)
            if componentType then
                local components = JobDataManager:getJobDetail(currentJobName, componentType) or {}
                print(string.format("=== %s %s ===", direction:gsub("^%l", string.upper), componentClass:gsub("^%l", string.upper)))
                for _, component in ipairs(components) do
                    print("- " .. component)
                end
            else
                print("Invalid component type")
            end
        else
            print("Usage: list <input|output|filter|blacklist> [inventory|tank]")
        end
    end, function(argsText)
        local args = parseArgs("list " .. argsText)
        local suggestions = {}
        
        if #args == 2 then
            local directions = {"input", "output", "filter", "blacklist"}
            return CommandLine.filterSuggestions(directions, args[2])
        elseif #args == 3 and (args[2] == "input" or args[2] == "output") then
            local types = {"inventory", "tank"}
            return CommandLine.filterSuggestions(types, args[3])
        end
        
        return suggestions
    end)
    
    -- Describe command
    sharedSubCommandLine:addCommand("describe", "Show detailed component information. Usage: describe <input|output|filter|blacklist|status> [inventory|tank]", function(input)
        local args = parseArgs(input)
        if #args < 2 then
            print("Usage: describe <input|output|filter|blacklist|status> [inventory|tank]")
            return
        end
        
        local direction = string.lower(args[2])
        local componentClass = args[3] and string.lower(args[3])
        
        if direction == "filter" then
            local filters = JobDataManager:getJobDetail(currentJobName, JobDataManager.JOB_COMPONENT_TYPES.FILTER) or {}
            print(string.format("=== Filters for job '%s' ===", currentJobName))
            print("Total filters: " .. #filters)
            for i, filter in ipairs(filters) do
                print(string.format("%d. %s", i, filter))
            end
        elseif direction == "blacklist" then
            local job = JobDataManager:getJob(currentJobName)
            local isBlacklist = job and job.isFilterBlacklist or false
            print(string.format("=== Blacklist setting for job '%s' ===", currentJobName))
            print("Blacklist enabled: " .. tostring(isBlacklist))
            if isBlacklist then
                print("Filters are treated as blacklist (items matching filters are excluded)")
            else
                print("Filters are treated as whitelist (only items matching filters are included)")
            end
        elseif direction == "status" then
            local job = JobDataManager:getJob(currentJobName)
            local isEnabled = job and job.enabled ~= false
            print(string.format("=== Status for job '%s' ===", currentJobName))
            print("Job enabled: " .. tostring(isEnabled))
            if isEnabled then
                print("This job will be executed when the system runs")
            else
                print("This job is disabled and will be skipped during execution")
            end
        elseif (direction == "input" or direction == "output") and componentClass then
            local componentType = getComponentTypeFromArgs(direction, componentClass)
            if componentType then
                local components = JobDataManager:getJobDetail(currentJobName, componentType) or {}
                print(string.format("=== %s %s for job '%s' ===", 
                    direction:gsub("^%l", string.upper), 
                    componentClass:gsub("^%l", string.upper), 
                    currentJobName))
                print("Total components: " .. #components)
                for i, component in ipairs(components) do
                    print(string.format("%d. %s", i, component))
                end
            else
                print("Invalid component type")
            end
        else
            print("Usage: describe <input|output|filter|blacklist|status> [inventory|tank]")
        end
    end, function(argsText)
        local args = parseArgs("describe " .. argsText)
        local suggestions = {}
        
        if #args == 2 then
            local directions = {"input", "output", "filter", "blacklist", "status"}
            return CommandLine.filterSuggestions(directions, args[2])
        elseif #args == 3 and (args[2] == "input" or args[2] == "output") then
            local types = {"inventory", "tank"}
            return CommandLine.filterSuggestions(types, args[3])
        end
        
        return suggestions
    end)
    
    -- Add command
    sharedSubCommandLine:addCommand("add", "Add components to job. Usage: add <input|output> <inventory|tank> <name1> [name2]... OR add filter <name1> [name2]...", function(input)
        local args = parseArgs(input)
        if #args < 3 then
            print("Usage: add <input|output|filter> [inventory|tank] <name1> [name2] ...")
            return
        end
        
        local direction = string.lower(args[2])
        
        if direction == "filter" then
            local filters = {}
            for i = 3, #args do
                table.insert(filters, args[i])
            end
            JobDataManager:addComponentToJob(currentJobName, JobDataManager.JOB_COMPONENT_TYPES.FILTER, table.unpack(filters))
            print("Added " .. #filters .. " filter(s)")
        elseif direction == "input" or direction == "output" then
            if #args < 4 then
                print("Usage: add <input|output> <inventory|tank> <name1> [name2] ...")
                return
            end
            
            local componentClass = string.lower(args[3])
            local componentType = getComponentTypeFromArgs(direction, componentClass)
            
            if componentType then
                local components = {}
                for i = 4, #args do
                    table.insert(components, args[i])
                end
                JobDataManager:addComponentToJob(currentJobName, componentType, table.unpack(components))
                print("Added " .. #components .. " " .. componentClass .. "(s)")
            else
                print("Invalid component type")
            end
        else
            print("Usage: add <input|output|filter> [inventory|tank] <name1> [name2] ...")
        end
    end, function(argsText)
        local args = parseArgs("add " .. argsText)
        local suggestions = {}
        
        if #args == 2 then
            local directions = {"input", "output", "filter"}
            return CommandLine.filterSuggestions(directions, args[2])
        elseif #args == 3 and (args[2] == "input" or args[2] == "output") then
            local types = {"inventory", "tank"}
            return CommandLine.filterSuggestions(types, args[3])
        elseif #args >= 4 then
            -- For the last argument, suggest available peripherals or items from snapshot
            local lastArg = args[#args]
            if args[2] == "input" or args[2] == "output" then
                if args[3] == "inventory" then
                    local inventoryArray = {}
                    for name, _ in pairs(SnapShot.inventories) do
                        table.insert(inventoryArray, name)
                    end
                    return CommandLine.filterSuggestions(inventoryArray, lastArg)
                elseif args[3] == "tank" then
                    local tankArray = {}
                    for name, _ in pairs(SnapShot.tanks) do
                        table.insert(tankArray, name)
                    end
                    return CommandLine.filterSuggestions(tankArray, lastArg)
                end
            elseif args[2] == "filter" then
                local itemArray = {}
                for name, _ in pairs(SnapShot.items) do
                    table.insert(itemArray, name)
                end
                return CommandLine.filterSuggestions(itemArray, lastArg)
            end
        end
        
        return suggestions
    end)
    
    -- Remove command
    sharedSubCommandLine:addCommand("remove", "Remove components from job. Usage: remove <input|output> <inventory|tank> <name1> [name2]... OR remove filter <name1> [name2]...", function(input)
        local args = parseArgs(input)
        if #args < 3 then
            print("Usage: remove <input|output|filter> [inventory|tank] <name1> [name2] ...")
            return
        end
        
        local direction = string.lower(args[2])
        
        if direction == "filter" then
            local filters = {}
            for i = 3, #args do
                table.insert(filters, args[i])
            end
            local removed = JobDataManager:removeComponentFromJob(currentJobName, JobDataManager.JOB_COMPONENT_TYPES.FILTER, table.unpack(filters))
            print("Removed " .. removed .. " filter(s)")
        elseif direction == "input" or direction == "output" then
            if #args < 4 then
                print("Usage: remove <input|output> <inventory|tank> <name1> [name2] ...")
                return
            end
            
            local componentClass = string.lower(args[3])
            local componentType = getComponentTypeFromArgs(direction, componentClass)
            
            if componentType then
                local components = {}
                for i = 4, #args do
                    table.insert(components, args[i])
                end
                local removed = JobDataManager:removeComponentFromJob(currentJobName, componentType, table.unpack(components))
                print("Removed " .. removed .. " " .. componentClass .. "(s)")
            else
                print("Invalid component type")
            end
        else
            print("Usage: remove <input|output|filter> [inventory|tank] <name1> [name2] ...")
        end
    end, function(argsText)
        local args = parseArgs("remove " .. argsText)
        local suggestions = {}
        
        if #args == 2 then
            local directions = {"input", "output", "filter"}
            return CommandLine.filterSuggestions(directions, args[2])
        elseif #args == 3 and (args[2] == "input" or args[2] == "output") then
            local types = {"inventory", "tank"}
            return CommandLine.filterSuggestions(types, args[3])
        elseif #args >= 4 then
            -- For the last argument, suggest existing components in the job
            local lastArg = args[#args]
            if args[2] == "filter" then
                local existingFilters = JobDataManager:getJobDetail(currentJobName, JobDataManager.JOB_COMPONENT_TYPES.FILTER) or {}
                return CommandLine.filterSuggestions(existingFilters, lastArg)
            elseif args[2] == "input" or args[2] == "output" then
                local componentType = getComponentTypeFromArgs(args[2], args[3])
                if componentType then
                    local existingComponents = JobDataManager:getJobDetail(currentJobName, componentType) or {}
                    return CommandLine.filterSuggestions(existingComponents, lastArg)
                end
            end
        end
        
        return suggestions
    end)
    
    -- Delete command
    sharedSubCommandLine:addCommand("delete", "Delete this job permanently. Usage: delete", function(input)
        print("Are you sure you want to delete job '" .. currentJobName .. "'? (y/N)")
        local response = io.read()
        if string.lower(response) == "y" or string.lower(response) == "yes" then
            JobDataManager:removeJob(currentJobName)
            print("Job '" .. currentJobName .. "' deleted.")
            return "exit"  -- Signal to exit subcommand
        else
            print("Job deletion cancelled.")
        end
    end)
    
    -- Blacklist command
    sharedSubCommandLine:addCommand("blacklist", "Manage blacklist setting. Usage: blacklist set <true|false>", function(input)
        local args = parseArgs(input)
        if #args < 3 then
            print("Usage: blacklist set <true|false>")
            local job = JobDataManager:getJob(currentJobName)
            local currentSetting = job and job.isFilterBlacklist or false
            print("Current blacklist setting: " .. tostring(currentSetting))
            return
        end
        
        local action = string.lower(args[2])
        if action == "set" then
            local value = string.lower(args[3])
            if value == "true" then
                JobDataManager:setBlacklist(currentJobName, true)
                print("Blacklist enabled for job '" .. currentJobName .. "'")
            elseif value == "false" then
                JobDataManager:setBlacklist(currentJobName, false)
                print("Blacklist disabled for job '" .. currentJobName .. "'")
            else
                print("Invalid value. Use 'true' or 'false'")
            end
        else
            print("Usage: blacklist set <true|false>")
        end
    end, function(argsText)
        local args = parseArgs("blacklist " .. argsText)
        local suggestions = {}
        
        if #args == 2 then
            local actions = {"set"}
            return CommandLine.filterSuggestions(actions, args[2])
        elseif #args == 3 and args[2] == "set" then
            local values = {"true", "false"}
            return CommandLine.filterSuggestions(values, args[3])
        end
        
        return suggestions
    end)
    
    -- Exit command
    sharedSubCommandLine:addCommand("exit", "Exit job editing mode. Usage: exit", function(input)
        sharedSubCommandLine:changeSuffix(">")
        return "exit"  -- Signal to exit subcommand
    end)
    
    return sharedSubCommandLine
end

-- Set the current job for the shared subcommand
local function setCurrentJob(jobName)
    currentJobName = jobName
end

-- Main job command implementation
function JobCommand.execute(input)
    local args = parseArgs(input)
    
    if #args < 2 then
        print("Usage: job <list|create|edit|save|enable|disable|delete> [name]")
        return
    end
    
    local action = string.lower(args[2])
    
    if action == "list" then
        print("=== Jobs ===")
        local jobNames = getJobNames()
        if #jobNames == 0 then
            print("No jobs found.")
        else
            for _, name in ipairs(jobNames) do
                local job = JobDataManager:getJob(name)
                local status = (job and job.enabled) and "enabled" or "disabled"
                print(string.format("- %s (%s)", name, status))
            end
        end
        
    elseif action == "create" then
        if #args < 3 then
            print("Usage: job create <name>")
            return
        end
        
        local jobName = args[3]
        if JobDataManager:getJob(jobName) then
            print("Job '" .. jobName .. "' already exists.")
            return
        end
        
        JobDataManager:addJob(jobName, {})
        print("Created job '" .. jobName .. "'")
        print("Entering job editing mode...")
        
        setCurrentJob(jobName)
        local subCommandLine = getOrCreateSubCommand()
        while true do
            local result = subCommandLine:run()
            if result == "exit" then
                JobDataManager:save()
                break
            end
        end
        
    elseif action == "edit" then
        if #args < 3 then
            print("Usage: job edit <name>")
            return
        end
        
        local jobName = args[3]
        if not JobDataManager:getJob(jobName) then
            print("Job '" .. jobName .. "' not found.")
            return
        end
        
        print("Editing job '" .. jobName .. "'...")
        
        setCurrentJob(jobName)
        local subCommandLine = getOrCreateSubCommand()
        while true do
            local result = subCommandLine:run()
            if result == "exit" then
                break
            end
        end
        
    elseif action == "save" then
        JobDataManager:save()
        print("All jobs saved.")
        
    elseif action == "enable" then
        if #args < 3 then
            print("Usage: job enable <name>")
            return
        end
        
        local jobName = args[3]
        local job = JobDataManager:getJob(jobName)
        if not job then
            print("Job '" .. jobName .. "' not found.")
            return
        end
        
        job.enabled = true
        JobDataManager:save()
        print("Job '" .. jobName .. "' enabled.")
        
    elseif action == "disable" then
        if #args < 3 then
            print("Usage: job disable <name>")
            return
        end
        
        local jobName = args[3]
        local job = JobDataManager:getJob(jobName)
        if not job then
            print("Job '" .. jobName .. "' not found.")
            return
        end
        
        job.enabled = false
        JobDataManager:save()
        print("Job '" .. jobName .. "' disabled.")
        
    elseif action == "delete" then
        if #args < 3 then
            print("Usage: job delete <name>")
            return
        end
        
        local jobName = args[3]
        if not JobDataManager:getJob(jobName) then
            print("Job '" .. jobName .. "' not found.")
            return
        end
        
        print("Are you sure you want to delete job '" .. jobName .. "'? (y/N)")
        local response = io.read()
        if string.lower(response) == "y" or string.lower(response) == "yes" then
            JobDataManager:removeJob(jobName)
            print("Job '" .. jobName .. "' deleted.")
        else
            print("Job deletion cancelled.")
        end
        
    else
        print("Invalid action. Use: list, create, edit, save, enable, disable, or delete")
        print("Usage: job <list|create|edit|save|enable|disable|delete> [name]")
    end
end

-- Auto-completion for job command
function JobCommand.complete(argsText)
    local args = parseArgs("job " .. argsText)
    local suggestions = {}
    
    if #args == 2 then
        -- Suggest actions
        local actions = {"list", "create", "edit", "save", "enable", "disable", "delete"}
        return CommandLine.filterSuggestions(actions, args[2])
    elseif #args == 3 and (args[2] == "edit" or args[2] == "delete" or args[2] == "enable" or args[2] == "disable") then
        -- Suggest job names for edit, delete, enable and disable
        local jobNames = getJobNames()
        return CommandLine.filterSuggestions(jobNames, args[3])
    end
    
    return suggestions
end

return JobCommand



