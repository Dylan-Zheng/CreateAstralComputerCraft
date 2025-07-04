local StringUtils = {}

StringUtils.split = function(input, delimiter)
    local result = {}
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

StringUtils.formatNumber = function(num)
    if num >= 1000 then
        return math.floor(num / 1000) .. "k"
    elseif num >= 1000000 then
        return math.floor(num / 1000000) .. "m"
    elseif num >= 100000000 then
        return math.floor(num / 1000000000) .. "b"
    elseif num >= 1000000000000 then
        return math.floor(num / 1000000000000) .. "t"
    end
    return tostring(num)
end

StringUtils.stringContainsIgnoreCase = function(str, substr)
    if str == nil or substr == nil then
        return false
    end
    return string.find(string.lower(str), string.lower(substr), 1, true) ~= nil
end

StringUtils.wrapText = function(text, width)
    local tempLines = {}
    local currentLine = ""
    for word in string.gmatch(text, "%S+") do
        if #currentLine + #word + 1 > width then
            table.insert(tempLines, currentLine)
            currentLine = word
        else
            if currentLine ~= "" then
                currentLine = currentLine .. " "
            end
            currentLine = currentLine .. word
        end
    end
    if currentLine ~= "" then
        table.insert(tempLines, currentLine)
    end

    return table.concat(tempLines, "\n")
end

StringUtils.ellipsisMiddle = function (text, maxLen)
    if #text <= maxLen then
        return text
    end
    if maxLen <= 3 then
        return string.sub(text, 1, maxLen)
    end
    local leftLen = math.floor((maxLen - 3) / 2)
    local rightLen = maxLen - 3 - leftLen
    return string.sub(text, 1, leftLen) .. "..." .. string.sub(text, -rightLen)
end

StringUtils.getAbbreviation = function(str)
    local abbr = ""
    for word in string.gmatch(str, "%a+") do
        abbr = abbr .. word:sub(1,1):upper()
    end
    return abbr
end

return StringUtils