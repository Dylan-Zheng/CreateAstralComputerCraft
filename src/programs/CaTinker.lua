local Communicator = require("programs.common.Communicator")
local OSUtils = require("utils.OSUtils")
local Trigger = require("programs.common.Trigger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")

PeripheralWrapper.reloadAll()

local args = { ... }

local recipes = OSUtils.loadTable("catinker_recipes") or {}

local loadCommunicatorConfig = function()
    return OSUtils.loadTable("catinker_communicator_config")
end

-- Save communicator config to file
local saveCommunicatorConfig = function(side, channel, secret)
    local config = {
        side = side,
        channel = channel,
        secret = secret
    }
    OSUtils.saveTable("catinker_communicator_config", config)
end

local setMessageHandler = function(openChannel)
    openChannel.addMessageHandler("getRecipesRes", function(eventCode, payload, senderId)
        local newRecipes = {}
        local allRecipes = payload or {}
        for _, recipe in ipairs(allRecipes) do
            if recipe.name and recipe.name:lower():find("^tf") then
                table.insert(newRecipes, {
                    id = recipe.id,
                    name = recipe.name,
                    input = recipe.input,
                    output = recipe.output,
                    trigger = recipe.trigger,
                    maxMachine = recipe.maxMachine or -1,
                    inputItemRate = recipe.inputItemRate or 1,
                    inputFluidRate = recipe.inputFluidRate or 1
                })
            end
        end
        recipes = newRecipes
        OSUtils.saveTable("catinker_recipes", recipes)
    end)

    -- Add update event handler
    openChannel.addMessageHandler("update", function(eventCode, payload, senderId)
        openChannel.send("getRecipesReq", "common")
    end)
end

local side, channel, secret = (function()
    if args ~= nil and #args == 3 then
        local side = args[1]
        local channel = tonumber(args[2])
        local secret = args[3]
        saveCommunicatorConfig(side, channel, secret)
        return side, channel, secret
    else
        local config = loadCommunicatorConfig()
        if config ~= nil then
            return config.side, config.channel, config.secret
        else
            print("Usage: CaTinker <side> <channel> <secret>")
            print("Example: CaTinker top 1234 mysecret")
            return nil, nil, nil
        end
    end
end)()

local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
local storage = storages[next(storages)]

local tcontrollers = PeripheralWrapper.getAllPeripheralsNameContains("tconstruct:foundry_controller")
local tcontroller = tcontrollers[next(tcontrollers)]

local drains = PeripheralWrapper.getAllPeripheralsNameContains("tconstruct:scorched_drain")
local drain = drains[next(drains)]

local tFuelTanks = PeripheralWrapper.getAllPeripheralsNameContains("tconstruct:scorched_fuel_tank")
local fuelTank = tFuelTanks[next(tFuelTanks)]

local start = function()
    while true do
        local waitTime = 1
        for _, recipe in ipairs(recipes) do
            -- Check if recipe has valid input
            if recipe.input and recipe.input[1] then
                local inputItem = recipe.input[1]
                local currentItem = tcontroller.getItem(inputItem)
                local hasItem = currentItem ~= nil
                
                -- Only transfer if we DON'T have the item and trigger conditions are met
                if not hasItem and Trigger.eval(recipe.trigger, function(type, name)
                        if type == "item" then
                            return storage.getItem(name)
                        elseif type == "fluid" then
                            return storage.getFluid(name)
                        end
                    end) then
                    waitTime = 0.5
                    storage.transferItemTo(tcontroller, inputItem, recipe.inputItemRate or 1)
                end
            end
            
            -- Collect fluids from drain
            local fluids = drain.tanks()
            if fluids then
                for _, fluid in pairs(fluids) do
                    if fluid.amount and fluid.amount > 0 then
                        storage.transferFluidFrom(drain, fluid.name, fluid.amount)
                    end
                end
            end
        end
        os.sleep(waitTime)
    end
end

local refillLava = function()
    while true do
        local lava = fuelTank.getFluid("minecraft:lava")
        local lavaAmount = lava and lava.amount or 0
        if lavaAmount < 3000 then
            storage.transferFluidTo(fuelTank, "minecraft:lava", 4000 - lavaAmount)
        end
        os.sleep(5)
    end
end

if side and channel and secret then
    Communicator.open(side, channel, "recipe", secret)
    local openChannel = Communicator.communicationChannels[side][channel]["recipe"]
    setMessageHandler(openChannel)

    parallel.waitForAll(Communicator.listen, start, refillLava)
else
    print("Invalid arguments. Exiting...")
end
