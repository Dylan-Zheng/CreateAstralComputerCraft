-- Computer Craft script
-- pastebin get CunkAYSg constants.lua
-- https://pastebin.com/CunkAYSg


local CONTAINER_NAMES = {
    -- Minecraft
    chest_name = "minecraft:chest",
    barrel_name = "minecraft:barrel",
    hopper_name = "minecraft:hopper",
    dropper_name = "minecraft:dropper",
    dispenser_name = "minecraft:dispenser",
    trapped_chest_name = "minecraft:trapped_chest",

    -- Create
    basin_name = "create:basin",
    depot_name = "create:depot",
    belt_name = "create:belt",
    crushing_wheel_name = "create:crushing_wheel",
    tank_name = "create:fluid_tank",
    millstone_name = "create:millstone",
    deployer_name = "create:deployer",
    spout_name = "create:spout",
    item_vaults_name = "create:item_vault",
    mechanical_crafter_name = "create:mechanical_crafter",
    item_drain_name = "create:item_drain",

    -- Create Addition
    liquid_blaze_burner_name = "createaddition:liquid_blaze_burner",
    rolling_mill_name = "createaddition:rolling_mill",

    -- Extended Drawers
    double_drawers_name = "extended_drawers:double_drawer",
    quad_drawers_name = "extended_drawers:quad_drawer",
    single_drawers_name = "extended_drawers:single_drawer",

    -- Tinkers' Construct
    seared_basin_name = "tconstruct:seared_basin",
    seared_melter_name = "tconstruct:seared_melter",
    seared_ingot_tank_name = "tconstruct:seared_ingot_tank",
    seared_table_name = "tconstruct:seared_table",
    seared_heater_name = "tconstruct:seared_heater",
    scorched_drain_name = "tconstruct:scorched_drain",
    foundry_controller_name = "tconstruct:foundry_controller",
    scorched_fuel_tank_name = "tconstruct:scorched_fuel_tank",

    -- AE2
    ae2_interface_name = "ae2:interface",
    ae2_pattern_provider_name = "ae2:pattern_provider",
    ae2_1k_crafting_storage_name = "ae2:1k_crafting_storage",
    ae2_4k_crafting_storage_name = "ae2:4k_crafting_storage",

    -- Tech Reborn
    solid_canning_machine_name = "techreborn:solid_canning_machine",
    industrial_centrifuge_name = "techreborn:industrial_centrifuge",
    industrial_electrolyzer_name = "techreborn:industrial_electrolyzer",
    compressor_name = "techreborn:compressor",
    basic_tank_unit_name = "techreborn:basic_tank_unit",
    grinder_name = "techreborn:grinder",
    chemical_reactor_name = "techreborn:chemical_reactor",
    thermal_generator_name = "techreborn:thermal_generator",

    -- Ad Astra
    cryo_freezer_name = "ad_astra:cryo_freezer",

    -- Custom Machinery
    custom_machine_block_name = "custommachinery:custom_machine_block",

    --Reinfchest
    diamond_chest_name = "reinfchest:diamond_chest", 
    copper_cehst_name = "reinfchest:copper_chest",

    -- Miscellaneous
    transh_can_name = "trashcans:item_trash_can",
    redrouter_name = "redrouter",
    all_tank_unit_name = "tank_unit",

    -- yttr
    centrifuge = "yttr:centrifuge",
}

local ALL_PERIPHERAL_NAMES = peripheral.getNames()

local createItemFinder = function (container, item_name)
    local cacheIndex = nil
    return function() 
        local items = container.listItem()
        if not items or #items == 0 then
            return nil -- No items in the container
        end
        if cacheIndex ~= nil and items[cacheIndex] and items[cacheIndex].name == item_name then
            return items[cacheIndex], cacheIndex
        end
        -- If cache is invalid or not set, find the item in the list again
        for index, item in ipairs(items) do
            if item.name == item_name then
                cacheIndex = index -- Cache the index for future calls
                return item, cacheIndex -- Return the found item
            end
        end
        return nil
    end
end

local createFluidFinder = function (container, fluid_name)
    local cacheIndex = nil
    return function() 
        local fluids = container.tanks()
        if not fluids or #fluids == 0 then
            return nil -- No items in the container
        end
        if cacheIndex ~= nil and fluids[cacheIndex] and fluids[cacheIndex].name == fluid_name then
            return fluids[cacheIndex], cacheIndex
        end
        -- If cache is invalid or not set, find the item in the list again
        for index, fluid in ipairs(fluids) do
            if fluid.name == fluid_name then
                cacheIndex = index -- Cache the index for future calls
                return fluid , cacheIndex -- Return the found item
            end
        end
        return nil
    end
end

local createCraftingStorageItemFinder = function (container, item_name)
    local cacheIndex = nil
    return function() 
        local items = container.items()
        if not items or #items == 0 then
            return nil -- No items in the container
        end
        if cacheIndex ~= nil and items[cacheIndex] and items[cacheIndex].technicalName == item_name then
            local item, index = items[cacheIndex], cacheIndex
            item.displayName = item.name
            item.name = item.technicalName
            return item, index
        end
        -- If cache is invalid or not set, find the item in the list again
        for index, item in ipairs(items) do
            if item.technicalName == item_name then
                cacheIndex = index -- Cache the index for future calls
                item.displayName = item.name
                item.name = item.technicalName
                return item, cacheIndex -- Return the found item
            end
        end
        return nil
    end
end

local addListItemsMethod = function(container)
    if string.find(container.name, "crafting_storage") then
        container.listItem = function() 
            local nameIdxMap = {}
            local items = {}
            for _, item in ipairs(container.items()) do
                item.displayName = item.name
                item.name = item.technicalName
                local itemName = item.name
                if not nameIdxMap[itemName] then
                    nameIdxMap[itemName] = #items + 1
                    table.insert(items, item)
                else
                    local idx = nameIdxMap[itemName]
                    items[idx].count = items[idx].count + item.count
                end
            end
            return items
        end
    elseif container.items then
        container.listItem = function() 
            return container.items()
        end
    elseif container.list then
        container.listItem = function() 
            local nameIdxMap = {}
            local items = {}
            for _, item in ipairs(container.list()) do
                local itemName = item.name
                if not nameIdxMap[itemName] then
                    nameIdxMap[itemName] = #items + 1
                    table.insert(items, item)
                else
                    local idx = nameIdxMap[itemName]
                    items[idx].count = items[idx].count + item.count
                end
            end
            return items
        end
    end
end

local addMoveTakeItemMehod = function(container)
    if container.list then
        container.moveItem = function(targetContainer, itemName, amount) 
            if amount == nil then
                amount = 64
            end
            if targetContainer.list then
                local amountMoved = 0
                for i = 1, container.size() do
                    local item = container.getItemDetail(i)
                    if item and item.name == itemName then
                        local amountToMove = math.min(amount - amountMoved, item.count)
                        local thisMovedAmount = container.pushItems(targetContainer.id, i, amountToMove)
                        if thisMovedAmount == 0 then 
                            break
                        else
                            amountMoved = amountMoved + thisMovedAmount
                        end
                    end
                end
                return amountMoved
            end
            if targetContainer.items then
                return targetContainer.pullItem(container.name, itemName, amount)
            end
        end
        container.takeItem = function(targetContainer, itemName, amount) 
            if amount == nil then
                amount = 64
            end
            if targetContainer.list then
                local amountTaken = 0
                for i = 1, targetContainer.size() do
                    local item = targetContainer.getItemDetail(i)
                    if item and item.name == itemName then
                        local amountToTake = math.min(amount - amountTaken, item.count)
                        local thisTakeAmount = container.pullItems(container.id, i, amountToTake)
                        if thisTakeAmount == 0 then 
                            break
                        else
                            amountTaken = amountTaken + thisTakeAmount
                        end
                    end
                end
                return amountTaken
            end
            if targetContainer.items then
                return targetContainer.pushItem(container.name, itemName, amount)
            end
        end
    end
    if container.items then
        container.moveItem = function (targetContainer, itemName, amount) 
            if amount == nil then
                amount = 64
            end
            return container.pushItem(targetContainer.name, itemName, amount)
        end
        container.takeItem = function (targetContainer, itemName, amount) 
            if amount == nil then
                amount = 64
            end
            return container.pullItem(targetContainer.name, itemName, amount)
        end
    end
end

local addMoveAndTakeLiquidMehod = function(container)
    container.moveFluid = function(targetContainer, amount, fluidName)
        return container.pushFluid(targetContainer.name, amount, fluidName)
    end
    container.takeFluid = function(targetContainer, amount, fluidName)
        return container.pullFluid(targetContainer.name, amount, fluidName)
    end
end

local addGetItemMethod = function(container)
    local finderCache = {}
    if string.find(container.name, "crafting_storage") then
        container.getItem = function(name) 
            if not finderCache[name] then
                local itemFinder = createCraftingStorageItemFinder(container, name)
                finderCache[name] = itemFinder
            end
            local item = finderCache[name]()
            return item
        end
        return
    end
    container.getItem = function(name) 
        if not finderCache[name] then
            finderCache[name] = createItemFinder(container, name)
        end
        return finderCache[name]()
    end
end

local addGetFluidMethod = function(container)
    local finderCache = {}
    container.getFluid = function(name) 
        if not finderCache[name] then
            finderCache[name] = createFluidFinder(container, name)
        end
        return finderCache[name]()
    end
end

local addCommonContainerPropsAndMethods = function(name, container)
    container.id = name
    container.name = name
    if container.list or container.items then
        addListItemsMethod(container)
        addMoveTakeItemMehod(container)
        addGetItemMethod(container)
    end
    if container.tanks then
        addMoveAndTakeLiquidMehod(container)
        addGetFluidMethod(container)
    end
end



local loadContainers = function(targetName) 
    local containers = {}
    for _, name in ipairs(ALL_PERIPHERAL_NAMES) do
        if string.find(name, targetName) then
            local container = peripheral.wrap(name)
            containers[name] = container
            addCommonContainerPropsAndMethods(name, container)
        end
    end
    return containers
end

local load = {
    -- Minecraft
    chests = function() return loadContainers(CONTAINER_NAMES.chest_name) end,
    barrels = function() return loadContainers(CONTAINER_NAMES.barrel_name) end,
    hoppers = function() return loadContainers(CONTAINER_NAMES.hopper_name) end,
    droppers = function() return loadContainers(CONTAINER_NAMES.dropper_name) end,
    dispensers = function() return loadContainers(CONTAINER_NAMES.dispenser_name) end,
    trapped_chests = function() return loadContainers(CONTAINER_NAMES.trapped_chest_name) end,

    -- Create
    basins = function() return loadContainers(CONTAINER_NAMES.basin_name) end,
    depots = function() return loadContainers(CONTAINER_NAMES.depot_name) end,
    belts = function() return loadContainers(CONTAINER_NAMES.belt_name) end,
    crushing_wheels = function() return loadContainers(CONTAINER_NAMES.crushing_wheel_name) end,
    tanks = function() return loadContainers(CONTAINER_NAMES.tank_name) end,
    millstones = function() return loadContainers(CONTAINER_NAMES.millstone_name) end,
    deployers = function() return loadContainers(CONTAINER_NAMES.deployer_name) end,
    spouts = function() return loadContainers(CONTAINER_NAMES.spout_name) end,
    item_vaults = function() return loadContainers(CONTAINER_NAMES.item_vaults_name) end,
    mechanical_crafters = function() return loadContainers(CONTAINER_NAMES.mechanical_crafter_name) end,
    item_drain = function() return loadContainers(CONTAINER_NAMES.item_drain_name) end,

    -- Create Addition
    liquid_blaze_burners = function() return loadContainers(CONTAINER_NAMES.liquid_blaze_burner_name) end,
    rolling_mills = function() return loadContainers(CONTAINER_NAMES.rolling_mill_name) end,

    -- Extended Drawers
    double_drawers = function() return loadContainers(CONTAINER_NAMES.double_drawers_name) end,
    single_drawers = function() return loadContainers(CONTAINER_NAMES.single_drawers_name) end,
    quad_drawers = function() return loadContainers(CONTAINER_NAMES.quad_drawers_name) end,

    -- Tinkers' Construct
    seared_basins = function() return loadContainers(CONTAINER_NAMES.seared_basin_name) end,
    seared_melters = function() return loadContainers(CONTAINER_NAMES.seared_melter_name) end,
    seared_ingot_tanks = function() return loadContainers(CONTAINER_NAMES.seared_ingot_tank_name) end,
    seared_tables = function() return loadContainers(CONTAINER_NAMES.seared_table_name) end,
    seared_heaters = function() return loadContainers(CONTAINER_NAMES.seared_heater_name) end,
    scorched_drains = function() return loadContainers(CONTAINER_NAMES.scorched_drain_name) end,
    foundry_controllers = function() return loadContainers(CONTAINER_NAMES.foundry_controller_name) end,
    scorched_fuel_tanks = function() return loadContainers(CONTAINER_NAMES.scorched_fuel_tank_name) end,

    -- AE2
    ae2_interfaces = function() return loadContainers(CONTAINER_NAMES.ae2_interface_name) end,
    ae2_1k_crafting_storages = function() return loadContainers(CONTAINER_NAMES.ae2_1k_crafting_storage_name) end,
    ae2_4k_crafting_storages = function() return loadContainers(CONTAINER_NAMES.ae2_4k_crafting_storage_name) end,
    ae2_pattern_providers = function() return loadContainers(CONTAINER_NAMES.ae2_pattern_provider_name) end,

    -- Tech Reborn
    solid_canning_machines = function() return loadContainers(CONTAINER_NAMES.solid_canning_machine_name) end,
    industrial_centrifuges = function() return loadContainers(CONTAINER_NAMES.industrial_centrifuge_name) end,
    industrial_electrolyzers = function() return loadContainers(CONTAINER_NAMES.industrial_electrolyzer_name) end,
    compressors = function() return loadContainers(CONTAINER_NAMES.compressor_name) end,
    basic_tank_units = function() return loadContainers(CONTAINER_NAMES.basic_tank_unit_name) end,
    grinders = function() return loadContainers(CONTAINER_NAMES.grinder_name) end,
    chemical_reactors = function() return loadContainers(CONTAINER_NAMES.chemical_reactor_name) end,
    thermal_generators = function() return loadContainers(CONTAINER_NAMES.thermal_generator_name) end,

    -- Ad Astra
    cryo_freezers = function() return loadContainers(CONTAINER_NAMES.cryo_freezer_name) end,

    -- Custom Machinery
    custom_machine_blocks = function() return loadContainers(CONTAINER_NAMES.custom_machine_block_name) end,

    -- Reinfchest
    diamond_chests = function() return loadContainers(CONTAINER_NAMES.diamond_chest_name) end,
    copper_chests = function() return loadContainers(CONTAINER_NAMES.copper_cehst_name) end,

    -- Miscellaneous
    redrouters = function() return loadContainers(CONTAINER_NAMES.redrouter_name) end,
    all_tank_units = function() return loadContainers(CONTAINER_NAMES.all_tank_unit_name) end,

    -- yttr
    centrifuges = function() return loadContainers(CONTAINER_NAMES.centrifuge) end,
}

return {
    load = load,
    CONTAINER_NAMES = CONTAINER_NAMES,
    addCommonContainerPropsAndMethods = addCommonContainerPropsAndMethods,
}