local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local TurtleCraft = require("programs.crafter.positive.TurtleCraft")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local RecipeManager = require("programs.crafter.positive.RecipeManager")
local Trigger = require("programs.common.Trigger")


local openChannel = Communicator.open("left", 123, "TaskDispatch", "default")

local MessageType = {
    ASSIGN_TASK = "AssignTask",
    RECEIVE_TASK = "ReceiveTask",
    TASK_COMPLETED = "TaskCompleted",
    TASK_FAILED = "TaskFailed",
    TASK_IN_PROGRESS_HEARTBEAT = "TaskInProgressHeartbeat",
}

TaskDispatchSlave = {}

TaskDispatchSlave.recipe = nil

TaskDispatchSlave.initEvents = function()
    if not openChannel then
        return false, "No open communication channel"
    end
    
    openChannel.addMessageHandler(MessageType.ASSIGN_TASK, function(eventCode, payload, senderId)
        Logger.debug("Received task assignment: {}", textutils.serialize(payload))
        if not payload or not payload.recipe then
            Logger.error("Invalid task assignment payload")
            return
        end
        
        if payload.turtleId and payload.turtleId ~= os.getComputerID() then
            Logger.debug("Task assigned to different turtle: {} (current: {})", payload.turtleId, os.getComputerID())
            return
        end
        
        TaskDispatchSlave.recipe = payload.recipe
        openChannel.send(MessageType.RECEIVE_TASK, { recipeName = payload.recipe.output }, senderId)
    end)

    return true
end

TaskDispatchSlave.TaskFailed = function(reason)
    if not openChannel then
        return false, "No open communication channel"
    end
    if not TaskDispatchSlave.recipe then
        return false, "No task assigned"
    end
    openChannel.send(MessageType.TASK_FAILED, { recipeName = TaskDispatchSlave.recipe.output, reason = reason })
    TaskDispatchSlave.recipe = nil
    return true
end

TaskDispatchSlave.TaskInProgressHeartbeat = function()
    if not openChannel then
        return false, "No open communication channel"
    end
    if not TaskDispatchSlave.recipe then
        return false, "No task assigned"
    end
    openChannel.send(MessageType.TASK_IN_PROGRESS_HEARTBEAT, { recipeName = TaskDispatchSlave.recipe.output })
    return true
end

TaskDispatchSlave.TaskCompleted = function()
    if not openChannel then
        return false, "No open communication channel"
    end
    if not TaskDispatchSlave.recipe then
        return false, "No task assigned"
    end
    openChannel.send(MessageType.TASK_COMPLETED, { recipeName = TaskDispatchSlave.recipe.output })
    TaskDispatchSlave.recipe = nil
    return true
end

TaskDispatchSlave.run = function()
    TaskDispatchSlave.initEvents()
    
    parallel.waitForAll(
        Communicator.listen,
        function()
            while TaskDispatchSlave.recipe do
                TaskDispatchSlave.TaskInProgressHeartbeat()
                os.sleep(10)  -- 每10秒发送心跳
            end
        end
    )
end

return TaskDispatchSlave
