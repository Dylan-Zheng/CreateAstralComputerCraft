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
        obj = textutils.unserialize(file.readAll())
        file.close()
    else
        return nil
    end
    return obj
end

OSUtils.saveTable = function(file_name, obj)
    local file = fs.open(file_name, "w")
    if file then
        xpcall(function()
            local serialized = textutils.serialize(obj)
            file.write(serialized)
        end, function(err)
            Logger.error("Failed to save table to {}, error: {}", file_name, err)
        end)
        file.close()
    end
end

return OSUtils