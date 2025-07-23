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

TableUtils.getAllKeyValueAsTreeString = function(t, indent, visited)
    indent = indent or ""
    visited = visited or {}

    if visited[t] then
        return indent .. "<circular reference>\n"
    end
    visited[t] = true

    local result = indent .. "{\n"
    for k, v in pairs(t) do
        result = result .. indent .. "  [" .. tostring(k) .. "] = "
        if type(v) == "table" then
            result = result .. TableUtils.getAllKeyValueAsTreeString(v, indent .. "  ", visited)
        elseif type(v) == "function" then
            result = result .. "function\n"
        else
            result = result .. tostring(v) .. "\n"
        end
    end
    result = result .. indent .. "}\n"
    return result
end


return TableUtils
