local OSUtils = require("utils.OSUtils")
local Logger = require("utils.Logger")

local StoreManager = {
    machines = {
        depot = {},
        basin = {},
        crafter = {},
        turtle = {}
    }
}

StoreManager.MACHINE_TYPES = {
    depot = "depot",
    basin = "basin",
    crafter = "crafter",
    turtle = "turtle"
}

StoreManager.BLAZE_BURN_TYPE = {
    NONE = 0,
    LAVA = 1,
    HELLFIRE = 2
}

StoreManager.saveTable = function(machineType)
    OSUtils.saveTable(machineType, StoreManager.machines[machineType])
end

StoreManager.loadTable = function(machineType)
    local data = OSUtils.loadTable(machineType)
    if data ~= nil then
        StoreManager.machines[machineType] = data
    end
end


local RecipeValidator = {
    depot = function(recipe)
        if recipe.input == nil or type(recipe.input) ~= "string" then
            return false, "Depot recipe input is invalid string: " .. tostring(recipe.input)
        end
        if recipe.output == nil or type(recipe.output) ~= "table" or #recipe.output == 0 then
            return false, "Depot recipe output is invalid table: " .. tostring(recipe.output)
        end
        return true
    end,
    basin = function(recipe)
        -- 检查recipe是否为table
        if type(recipe) ~= "table" then
            return false, "Basin recipe must be a table, got: " .. type(recipe)
        end
        
        -- 检查name字段
        if recipe.name == nil or type(recipe.name) ~= "string" or recipe.name == "" then
            return false, "Basin recipe name must be a non-empty string: " .. tostring(recipe.name)
        end
        
        -- 检查input字段
        if recipe.input == nil or type(recipe.input) ~= "table" then
            return false, "Basin recipe input must be a table: " .. tostring(recipe.input)
        end
        
        -- 检查input.items和input.fluids
        local hasInputItems = recipe.input.items and type(recipe.input.items) == "table" and #recipe.input.items > 0
        local hasInputFluids = recipe.input.fluids and type(recipe.input.fluids) == "table" and #recipe.input.fluids > 0
        
        if not hasInputItems and not hasInputFluids then
            return false, "Basin recipe must have at least one input item or fluid"
        end
        
        -- 验证input.items中的每个item都是字符串
        if hasInputItems then
            for i, item in ipairs(recipe.input.items) do
                if type(item) ~= "string" or item == "" then
                    return false, "Basin recipe input item at index " .. i .. " must be a non-empty string: " .. tostring(item)
                end
            end
        end
        
        -- 验证input.fluids中的每个fluid都是字符串
        if hasInputFluids then
            for i, fluid in ipairs(recipe.input.fluids) do
                if type(fluid) ~= "string" or fluid == "" then
                    return false, "Basin recipe input fluid at index " .. i .. " must be a non-empty string: " .. tostring(fluid)
                end
            end
        end
        
        -- 检查output字段
        if recipe.output == nil or type(recipe.output) ~= "table" then
            return false, "Basin recipe output must be a table: " .. tostring(recipe.output)
        end
        
        -- 检查output.items和output.fluids
        local hasOutputItems = recipe.output.items and type(recipe.output.items) == "table" and #recipe.output.items > 0
        local hasOutputFluids = recipe.output.fluids and type(recipe.output.fluids) == "table" and #recipe.output.fluids > 0
        
        if not hasOutputItems and not hasOutputFluids then
            return false, "Basin recipe must have at least one output item or fluid"
        end
        
        -- 验证output.items中的每个item都是字符串
        if hasOutputItems then
            for i, item in ipairs(recipe.output.items) do
                if type(item) ~= "string" or item == "" then
                    return false, "Basin recipe output item at index " .. i .. " must be a non-empty string: " .. tostring(item)
                end
            end
        end
        
        -- 验证output.fluids中的每个fluid都是字符串
        if hasOutputFluids then
            for i, fluid in ipairs(recipe.output.fluids) do
                if type(fluid) ~= "string" or fluid == "" then
                    return false, "Basin recipe output fluid at index " .. i .. " must be a non-empty string: " .. tostring(fluid)
                end
            end
        end
        
        -- 检查keepItemsAmount和keepFluidsAmount（可选字段）
        if recipe.output.keepItemsAmount ~= nil then
            if type(recipe.output.keepItemsAmount) ~= "number" or recipe.output.keepItemsAmount < 0 then
                return false, "Basin recipe keepItemsAmount must be a non-negative number: " .. tostring(recipe.output.keepItemsAmount)
            end
        end
        
        if recipe.output.keepFluidsAmount ~= nil then
            if type(recipe.output.keepFluidsAmount) ~= "number" or recipe.output.keepFluidsAmount < 0 then
                return false, "Basin recipe keepFluidsAmount must be a non-negative number: " .. tostring(recipe.output.keepFluidsAmount)
            end
        end
        
        -- trigger字段是可选的，如果存在则检查其为table
        if recipe.trigger ~= nil and type(recipe.trigger) ~= "table" then
            return false, "Basin recipe trigger must be a table if present: " .. tostring(recipe.trigger)
        end
        
        return true
    end,
}

local logIfNotValidMachineType = function(machineType)
    if not StoreManager.MACHINE_TYPES[machineType] then
        return false
    end
    return true
end

StoreManager.addRecipe = function(machineType, recipe)
    if not logIfNotValidMachineType(machineType) then
        return false, "Invalid machine type: " .. tostring(machineType)
    end
    local isValid, errMsg = RecipeValidator[machineType](recipe)
    if not isValid then
        return false, errMsg
    end

    local id = OSUtils.timestampBaseIdGenerate()

    recipe.id = id
    table.insert(StoreManager.machines[machineType], recipe)
    StoreManager.saveTable(machineType)
    return true, id
end

StoreManager.removeRecipe = function(machineType, recipeId)
    if not logIfNotValidMachineType(machineType) then
        return false, "Invalid machine type: " .. tostring(machineType)
    end
    for i, recipe in ipairs(StoreManager.machines[machineType]) do
        if recipe.id == recipeId then
            table.remove(StoreManager.machines[machineType], i)
            return true
        end
    end
    return false, "Recipe not found: " .. tostring(recipeId)
end

StoreManager.updateRecipe = function(machineType, newRecipe)
    if not logIfNotValidMachineType(machineType) then
        return false, "Invalid machine type: " .. tostring(machineType)
    end
    for i, recipe in ipairs(StoreManager.machines[machineType]) do
        if recipe.id == newRecipe.id then
            StoreManager.machines[machineType][i] = newRecipe
            StoreManager.saveTable(machineType)
            return true
        end
    end
    return false, "Recipe not found: " .. tostring(newRecipe.id)
end

StoreManager.getAllRecipesByType = function(machineType)
    if not logIfNotValidMachineType(machineType) then
        return {}
    end
    local text = textutils.serialize(StoreManager.machines[machineType])
    return textutils.unserialize(text)
end

StoreManager.getRecipeByTypeAndId = function(machineType, recipeId)
    if not logIfNotValidMachineType(machineType) then
        return {}
    end
    for _, recipe in ipairs(StoreManager.machines[machineType]) do
        if recipe.id == recipeId then
            return textutils.unserialize(textutils.serialize(recipe))
        end
    end
    return nil
end

StoreManager.init =function ()
    for machineType, _ in pairs(StoreManager.MACHINE_TYPES) do
        StoreManager.loadTable(machineType)
    end
end

return StoreManager
