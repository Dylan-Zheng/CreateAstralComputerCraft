local Logger = require("utils.Logger")

local OSUtils = {}

OSUtils.timestampBaseIdGenerate = function()
    local timestamp = os.epoch("utc")
    local random = math.random(1000, 9999)
    return tostring(timestamp) .. "-" .. tostring(random)
end

OSUtils.loadTable = function(file_name)
    local obj = {}
    local file = fs.open(file_name, "r")
    if file then
        local text = file.readAll()
        obj = textutils.unserialize(text)
        file.close()
    else
        return nil
    end
    return obj
end

OSUtils.saveTable = function(file_name, obj)
    local serialized
    local success, err = xpcall(function()
        serialized = textutils.serialize(obj)
    end, function(error)
        return error
    end)
    
    if not success then
        Logger.error("Failed to serialize table for {}, error: {}", file_name, err)
        return
    end
    
    local file = fs.open(file_name, "w")
    if file then
        file.write(serialized)
        file.close()
    else
        Logger.error("Failed to open file for writing: {}", file_name)
    end
end

return OSUtils