local chunk, err = loadfile("tools/minify.lua")

if not chunk then
    print("Error loading file: " .. err)
    os.exit(1)
end

local shouldMinify = false

local minify = chunk()

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

        local success, minified

        if shouldMinify then
            success, minified = minify(content)
            if not success then
                print("Error minifying file " .. file.fullPath .. ": " .. minified)
                os.exit(1)
            end
        else
            minified = content
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
    for name, module in pairs(modules) do
        if name:match("^programs%.[^%.]+$") then
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

local function clean()
    local sep = package.config:sub(1, 1)
    local command
    if sep == "\\" then
        -- Windows
        command = 'del /Q /F "release\\*.lua"'
    else
        -- Linux/macOS
        command = 'rm -f release/*.lua'
    end

    os.execute(command)
end

local function bundle()
    local files = scanDir("src")
    local modules = getModulesAndRequire(files)
    local programs = getPrograms(modules)

    for name, program in pairs(programs) do
        local output = { 'local modules = {}\n', 'local loadedModules = {}\n', 'local baseRequire = require\n',
            'require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end\n' }
        local allRequires = collectAllRequires(modules, name)

        for _, req in ipairs(allRequires) do
            if modules[req] then
                table.insert(output, string.format('modules["%s"] = function() %s end\n', req, modules[req].minified))
            end
        end
        table.insert(output, string.format('return modules["%s"]()', name))

        local path = "release/" .. name:gsub("^programs%.", "") .. ".lua"
        local out = io.open(path, "w")
        local content = table.concat(output)
        out:write(content)
        out:close()
        print("Bundled program: " .. path)

        for path in io.lines("tools/build_path.txt") do
            local otherOutputPath = path .. name:gsub("^programs%.", "") .. ".lua"
            local otherOutFile = io.open(otherOutputPath, "w")
            if not otherOutFile then
                print("Error opening output file: " .. otherOutputPath)
                os.exit(1)
            else
                otherOutFile:write(content)
                otherOutFile:close()
                print("Write program: " .. otherOutputPath)
            end
        end
    end
end

clean()
bundle()
