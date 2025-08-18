Utils = {}

Utils.getListDisplayItems = function(selectedItems, items)
    local list = {}
    if selectedItems then
        for name, _ in pairs(selectedItems) do
            table.insert(list, {
                text = name,
                selected = true
            })
        end
    end
    
    for name, _  in pairs(items) do
        local isSelected = selectedItems and selectedItems[name] == true
        if not isSelected then
            table.insert(list, {
                text = name,
                selected = isSelected
            })
        end
    end
    return list
end

return Utils
