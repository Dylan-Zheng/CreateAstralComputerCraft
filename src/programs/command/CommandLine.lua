local CommandLine = {}
CommandLine.__index = CommandLine

-- Helper function to filter suggestions and return only the untyped part
function CommandLine.filterSuggestions(candidates, partial)
    local filtered = {}
    local partialLower = string.lower(partial or "")
    
    for _, candidate in ipairs(candidates) do
        local candidateLower = string.lower(candidate)
        if candidateLower:find(partialLower, 1, true) == 1 then
            -- Return only the part that hasn't been typed yet
            local remaining = candidate:sub(#partial + 1)
            if remaining ~= "" then
                table.insert(filtered, remaining)
            end
        end
    end
    
    return filtered
end

function CommandLine:new(suffix)
    local instance = setmetatable({}, CommandLine)
    instance.suffix = suffix or "> "
    instance.commands = {
        help = {
            name = "help",
            description = "Display available commands",
            func = function(input)
                print("Available commands:")
                for cmdName, cmd in pairs(instance.commands) do
                    print(string.format(" - %s: %s", cmdName, cmd.description))
                end
            end
        }
    }
    return instance
end

local getUserInputCommandName = function(input)
    local firstSpace = string.find(input, " ")
    if firstSpace then
        return string.sub(input, 1, firstSpace - 1), true
    else
        return input, false
    end
end

local getCommands = function(commandLine, commandName)
    return commandLine.commands[commandName]
end

local getCommandSuggestion = function(commandLine, text)
    local suggestions = {}
    local commandName, isCompleted = getUserInputCommandName(text)
    if isCompleted then
        local command = getCommands(commandLine, commandName)
        if command and command.complete then
            local argsText = string.sub(text, #commandName + 2)
            suggestions = command.complete(argsText) or {}
        end
    else
        -- Collect all matching command names
        local candidates = {}
        for cmdName, cmd in pairs(commandLine.commands) do
            if cmdName:find(commandName) == 1 then
                table.insert(candidates, cmdName)
            end
        end
        -- Use filterSuggestions to return only the untyped part
        suggestions = CommandLine.filterSuggestions(candidates, commandName)
    end
    return suggestions
end

-- Calculate Levenshtein distance between two strings
local function levenshteinDistance(str1, str2)
    local len1, len2 = #str1, #str2
    local matrix = {}
    
    -- Initialize matrix
    for i = 0, len1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, len2 do
        matrix[0][j] = j
    end
    
    -- Fill matrix
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,      -- deletion
                matrix[i][j-1] + 1,      -- insertion
                matrix[i-1][j-1] + cost  -- substitution
            )
        end
    end
    
    return matrix[len1][len2]
end

local function findClosestCommand(commandLine, inputCommand)
    local closestCommand = nil
    local minDistance = math.huge
    local maxDistance = 3  -- Only suggest if distance is 3 or less
    
    for cmdName, cmd in pairs(commandLine.commands) do
        local distance = levenshteinDistance(inputCommand:lower(), cmdName:lower())
        if distance < minDistance and distance <= maxDistance then
            minDistance = distance
            closestCommand = cmdName
        end
    end
    
    return closestCommand
end

function CommandLine:addCommand(cmdName, description, cmdFunc, completeFunc)
    self.commands[cmdName] = {
        name = cmdName,
        description = description,
        func = cmdFunc,
        complete = completeFunc
    }
    return self
end

function CommandLine:run()
    write(self.suffix)
    local commandLineText = read(nil, nil, function(text)
        return getCommandSuggestion(self, text)
    end)
    local commandName, isCompleted = getUserInputCommandName(commandLineText)
    local command = getCommands(self, commandName)
    if command then
        return command.func(commandLineText)
    else
        local closestCommand = findClosestCommand(self, commandName)
        if closestCommand then
            print("Unknown command: " .. commandName)
            print("Do you mean \"" .. closestCommand .. "\"?")
        else
            print("Unknown command: " .. commandName)
        end
    end
end

function CommandLine:changeSuffix(newSuffix)
    self.suffix = newSuffix
end

return CommandLine