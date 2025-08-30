local TaskDispatchSlave = require("programs.crafter.positive.TaskDispatchSlave")
local TurtleCraft = require("programs.crafter.positive.TurtleCraft")
local Logger = require("utils.Logger")

Logger.currentLevel = Logger.levels.ERROR
Logger.useDefault()

print("ID: " .. os.getComputerID())

parallel.waitForAll(
    TaskDispatchSlave.run,
    function()
        local waitTime = 0.2
        while true do
            local recipe = TaskDispatchSlave.recipe
            local triggered = false
            local verified = false

            if recipe then
                triggered = TurtleCraft.triggerEval(recipe)
                if not triggered then
                    TaskDispatchSlave.TaskCompleted()
                    TaskDispatchSlave.recipe = nil
                end

                verified = TurtleCraft.storeVerify(recipe)
                if not verified then
                    TaskDispatchSlave.TaskFailed("Input items not available in storage")
                    TaskDispatchSlave.recipe = nil
                end
            end

            if triggered and verified then
                TurtleCraft.craft(recipe)
            else
                waitTime = 1
            end
            os.sleep(waitTime)
        end
    end
)
