local TableUtils = {}


TableUtils.findInArray = function(array, predicate)
    if array == nil or predicate == nil then
        return nil
    end
    for i, v in ipairs(array) do
        if predicate(v) then
            return i  -- return index
        end
    end
    return nil  -- not found
end


TableUtils.getLength = function(t)
    if t == nil then
        return 0
    end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

return TableUtils
