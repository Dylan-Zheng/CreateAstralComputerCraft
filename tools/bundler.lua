-- Load minifier
local chunk, err = loadfile("tools/minify.lua")
if not chunk then
    print("Error loading file: " .. err)
    os.exit(1)
end
local minify = chunk()

-- Load build configuration
local configChunk, configErr = loadfile("tools/BuildProgramsAndPaths.lua")
if not configChunk then
    print("Error loading build configuration: " .. configErr)
    os.exit(1)
end
local buildConfig = configChunk()
if not buildConfig then
    print("Error: BuildProgramsAndPaths.lua did not return configuration")
    os.exit(1)
end

-- Create filesystem utilities
local function ensureDirExists(path)
    local sep = package.config:sub(1, 1)
    local command
    if sep == "\\" then
        -- Windows
        command = 'if not exist "' .. path .. '" mkdir "' .. path .. '"'
    else
        -- Linux/macOS  
        command = 'mkdir -p "' .. path .. '"'
    end
    os.execute(command)
end

local function getDirectoryFromPath(filepath)
    local sep = package.config:sub(1, 1)
    return filepath:match("^(.*)" .. sep .. "[^" .. sep .. "]*$") or ""
end

local function scanDir(dir)
    local files = {}
    local sep = package.config:sub(1, 1)
    local command
    if sep == "\\" then
        -- Windows
        command = 'dir "' .. dir .. '\\*.lua" /b /s'
    else
        -- Linux/macOS
        command = 'find "' .. dir .. '" -type f -name "*.lua"'
    end

    for file in io.popen(command):lines() do
        table.insert(files, {
            path = file:gsub("^src[\\/]", ""), -- 支持正反斜杠
            requirePath = file:match("src[\\/](.+)%.lua$"):gsub("[/\\]", "."),
            fullPath = file
        })
    end
    return files
end

local function getModulesAndRequire(files)
    local modules = {}

    for _, file in ipairs(files) do
        local content = io.open(file.fullPath, "r"):read("*a")
        local moduleName = file.requirePath

        local success, minified = minify(content)
        if not success then
            print("Error minifying file " .. file.fullPath .. ": " .. minified)
            os.exit(1)
        end

        modules[moduleName] = {
            content = content,
            minified = minified,
            requires = {}
        }

        for line in content:gmatch("[^\n]+") do
            local _, req = line:match('require%s*%((["\'])(.-)%1%)')
            if req then
                table.insert(modules[moduleName].requires, req)
            end
        end
    end

    return modules
end

local function getPrograms(modules, buildProgramsList)
    local programs = {}
    
    -- Convert build programs list to a lookup table
    local buildFilter = {}
    for _, programName in ipairs(buildProgramsList) do
        buildFilter[programName] = true
    end
    
    for name, module in pairs(modules) do
        if buildFilter[name] then
            programs[name] = {
                content = module.content,
                minified = module.minified,
                requires = module.requires
            }
        end
    end
    
    return programs
end

local function collectAllRequires(modules, startModule)
    local visited = {}
    local result = {}
    local queue = { startModule }

    while #queue > 0 do
        local current = table.remove(queue, 1)
        if not visited[current] and modules[current] then
            visited[current] = true
            table.insert(result, current)
            for _, req in ipairs(modules[current].requires) do
                if not visited[req] then
                    table.insert(queue, req)
                end
            end
        end
    end

    return result
end

local function copyFileToPath(content, targetPath, rename)
    local sep = package.config:sub(1, 1)
    local finalPath = targetPath
    
    -- Remove trailing separators from target path
    while finalPath:sub(-1) == "/" or finalPath:sub(-1) == "\\" do
        finalPath = finalPath:sub(1, -2)
    end
    
    -- Ensure target directory exists
    ensureDirExists(finalPath)
    
    -- Add filename if rename is specified
    if rename then
        finalPath = finalPath .. sep .. rename
    end
    
    local file = io.open(finalPath, "w")
    if not file then
        print("Error: Cannot open output file: " .. finalPath)
        return false
    end
    
    file:write(content)
    file:close()
    print("Copied program to: " .. finalPath)
    return true
end

local function bundle()
    local files = scanDir("src")
    local modules = getModulesAndRequire(files)
    local programs = getPrograms(modules, buildConfig.buildPrograms)

    -- Ensure output directories exist
    ensureDirExists("build")
    ensureDirExists("build/unminified")

    for name, program in pairs(programs) do
        local outputMinified = { 'local modules = {}\n', 'local loadedModules = {}\n', 'local baseRequire = require\n',
            'require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end\n' }
        local output = { 'local modules = {}\n', 'local loadedModules = {}\n', 'local baseRequire = require\n',
            'require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end\n' }
        local allRequires = collectAllRequires(modules, name)

        for _, req in ipairs(allRequires) do
            if modules[req] then
                table.insert(outputMinified,
                    string.format('modules["%s"] = function(...) %s end\n', req, modules[req].minified))
                table.insert(output, string.format('modules["%s"] = function(...) %s end\n', req, modules[req].content))
            end
        end
        table.insert(outputMinified, string.format('return modules["%s"](...)\n', name))
        table.insert(output, string.format('return modules["%s"](...)\n', name))

        -- Generate minified and unminified content
        local minifiedCode = table.concat(outputMinified)
        local unminifiedCode = table.concat(output)
        
        -- Get the program filename (remove "programs." prefix)
        local filename = name:gsub("^programs%.", "") .. ".lua"
        
        -- Write minified version to build/
        local minifiedPath = "build/" .. filename
        local minFile = io.open(minifiedPath, "w")
        if not minFile then
            print("Error: Cannot open minified output file: " .. minifiedPath)
            os.exit(1)
        end
        minFile:write(minifiedCode)
        minFile:close()
        print("Bundled minified program: " .. minifiedPath)
        
        -- Write unminified version to build/unminified/
        local unminifiedPath = "build/unminified/" .. filename
        local unminFile = io.open(unminifiedPath, "w")
        if not unminFile then
            print("Error: Cannot open unminified output file: " .. unminifiedPath)
            os.exit(1)
        end
        unminFile:write(unminifiedCode)
        unminFile:close()
        print("Bundled unminified program: " .. unminifiedPath)
        
        -- Copy to specific paths as defined in ProgramsAndPaths
        for _, pathConfig in ipairs(buildConfig.programsAndPaths) do
            if pathConfig.program == name and not pathConfig.disabled then
                for _, pathInfo in ipairs(pathConfig.paths) do
                    copyFileToPath(unminifiedCode, pathInfo.path, pathInfo.rename)
                end
            end
        end
    end
end

bundle()
