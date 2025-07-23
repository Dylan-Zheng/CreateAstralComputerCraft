local chunk, err = loadfile("tools/minify.lua")

if not chunk then
    print("Error loading file: " .. err)
    os.exit(1)
end

local shouldMinify = false

local minify = chunk()

local function readProgramFilter()
    local filters = {}
    local file = io.open("tools/program_filter.txt", "r")
    if file then
        for line in file:lines() do
            -- Trim whitespace and skip empty lines
            line = line:match("^%s*(.-)%s*$")
            if line and line ~= "" then
                filters[line] = true
            end
        end
        file:close()
    else
        print("Warning: build_filter.txt not found, no filters applied")
    end
    return filters
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

local function getPrograms(modules)
    local programs = {}
    local filter = readProgramFilter()
    if next(filter) then
        for name, module in pairs(modules) do
            if filter[name] then
                programs[name] = {
                    content = module.content,
                    minified = module.minified,
                    requires = module.requires
                }
            end
        end
    else
        for name, module in pairs(modules) do
            if name:match("^programs%.[^%.]+$") then
                programs[name] = {
                    content = module.content,
                    minified = module.minified,
                    requires = module.requires
                }
            end
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

local function bundle()
    local files = scanDir("src")
    local modules = getModulesAndRequire(files)
    local programs = getPrograms(modules)

    for name, program in pairs(programs) do
        local outputMinified = { 'local modules = {}\n', 'local loadedModules = {}\n', 'local baseRequire = require\n',
            'require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end\n' }
        local output = { 'local modules = {}\n', 'local loadedModules = {}\n', 'local baseRequire = require\n',
            'require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end\n' }
        local allRequires = collectAllRequires(modules, name)

        for _, req in ipairs(allRequires) do
            if modules[req] then
                table.insert(outputMinified,
                    string.format('modules["%s"] = function() %s end\n', req, modules[req].minified))
                table.insert(output, string.format('modules["%s"] = function() %s end\n', req, modules[req].content))
            end
        end
        table.insert(outputMinified, string.format('return modules["%s"]()', name))
        table.insert(output, string.format('return modules["%s"]()', name))

        local path = "build/" .. name:gsub("^programs%.", "") .. ".lua"
        local out = io.open(path, "w")
        local minifiedCode = table.concat(outputMinified)
        out:write(minifiedCode)
        out:close()
        print("Bundled program: " .. path)

        local unminifiedCode = table.concat(output)
        for path in io.lines("tools/build_path.txt") do
            local otherOutputPath = path .. name:gsub("^programs%.", "") .. ".lua"
            local otherOutFile = io.open(otherOutputPath, "w")
            if not otherOutFile then
                print("Error opening output file: " .. otherOutputPath)
                os.exit(1)
            else
                otherOutFile:write(unminifiedCode)
                otherOutFile:close()
                print("Write program: " .. otherOutputPath)
            end
        end
    end
end

bundle()
