local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local CommandLine = require("programs.command.CommandLine")
local OSUtils = require("utils.OSUtils")
local Trigger = require("programs.common.Trigger")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local TableUtils = require("utils.TableUtils")

local args = { ... }

local recipes = OSUtils.loadTable("cacrusher_recipes") or {}

local loadCommunicatorConfig = function()
    return OSUtils.loadTable("cadepot_communicator_config")
end

-- Save communicator config to file
local saveCommunicatorConfig = function(side, channel, secret)
    local config = {
        side = side,
        channel = channel,
        secret = secret
    }
    OSUtils.saveTable("cadepot_communicator_config", config)
end

local setMesssageHandler = function(openChannel)
    openChannel.addMessageHandler("getRecipesRes", function(eventCode, payload, senderId)
        local newRecipes = {}
        local allRecipes = payload or {}
        for _, recipe in ipairs(allRecipes) do
            if recipe.name and recipe.name:lower():find("^TF") then
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
        OSUtils.saveTable("cacrusher_recipes", recipes)
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

local start = function()
    local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
    local storage = storages[next(storages)]

    local tcontrollers = PeripheralWrapper.getAllPeripheralsNameContains("tconstruct:foundry_controller")
    local tcontroller = tcontrollers[next(tcontrollers)]

    local drains = PeripheralWrapper.getAllPeripheralsNameContains("tconstruct:scorched_drain")
    local drain = drains[next(drains)]
    local waitTime = 1
    while true do
        waitTime = 1
        for _, recipe in ipairs(recipes) do
            if tcontroller.getItem(recipe.input[1]) and Trigger.eval(recipe.trigger, function(type, name)
                if type == "item" then
                    return storage.getItem(name)
                elseif type == "fluid" then
                    return storage.getFluid(name)
                end
            end) then
               waitTime = 0.5
               storage.transferItemTo(tcontroller, recipe.input[1], recipe.inputItemRate)
            end
            local fluids = drain.tanks()
            if fluids then
                for _, tank in pairs(fluids) do
                    storage.transferFluidFrom(drain, tank.name, tank.amount)
                end
            end
        end
        os.sleep(waitTime)
    end

end

if side and channel and secret then

    Communicator.open(side, channel, "recipe", secret)
    local openChannel = Communicator.communicationChannels[side][channel]["recipe"]
    setMesssageHandler(openChannel)

    parallel.waitForAll(Communicator.listen, start)
else
    print("Invalid arguments. Exiting...")
end
