local Logger = require("utils.Logger")
local Communicator = require("programs.common.Communicator")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")
local RecipeManager = require("programs.crafter.positive.RecipeManager")
local Trigger = require("programs.common.Trigger")
local RecipeInputStoreVerify = require("programs.crafter.positive.RecipeInputStoreVerify")


local TurtleStatus = {
    IDLE = "idle",
    BUSY = "busy",
    CONFIRMING = "confirming",
}

local MessageType = {
    ASSIGN_TASK = "AssignTask",
    RECEIVE_TASK = "ReceiveTask",
    TASK_COMPLETED = "TaskCompleted",
    TASK_FAILED = "TaskFailed",
    TASK_IN_PROGRESS_HEARTBEAT = "TaskInProgressHeartbeat",
}

local TaskDispatchMaster = {}

TaskDispatchMaster.openChannel = nil

TaskDispatchMaster.turtles = {}

TaskDispatchMaster.assignedTasks = {}

-- 观察者模式：存储需要通知的观察者
TaskDispatchMaster.observers = {}

local getModemSide = function()
    local sides = { "left", "right", "top", "bottom", "front", "back" }
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            return side
        end
    end
    return nil
end

local getItemFromStorage = function(type, itemName)
    if type == "item" then
        return TaskDispatchMaster.storage.getItem(itemName)
    elseif type == "fluid" then
        return TaskDispatchMaster.storage.getFluid(itemName)
    end
    return nil
end


TaskDispatchMaster.getOpenChannel = function()
    return TaskDispatchMaster.openChannel
end

-- 观察者模式：添加观察者
TaskDispatchMaster.addObserver = function(observer)
    if observer and observer.update then
        table.insert(TaskDispatchMaster.observers, observer)
        Logger.debug("Observer added to TaskDispatchMaster")
    end
end

-- 观察者模式：移除观察者
TaskDispatchMaster.removeObserver = function(observer)
    for i, obs in ipairs(TaskDispatchMaster.observers) do
        if obs == observer then
            table.remove(TaskDispatchMaster.observers, i)
            Logger.debug("Observer removed from TaskDispatchMaster")
            break
        end
    end
end

-- 观察者模式：通知所有观察者
TaskDispatchMaster.notifyObservers = function()
    for _, observer in ipairs(TaskDispatchMaster.observers) do
        if observer and observer.update then
            observer:update()
        end
    end
end

TaskDispatchMaster.assignTask = function(recipe)
    if not TaskDispatchMaster.openChannel then
        return false, "Communication channel not initialized"
    end
    
    for turtleId, turtle in pairs(TaskDispatchMaster.turtles) do
        if turtle.isOn() and turtle.status == TurtleStatus.IDLE then
            local payload = {
                recipe = recipe,
                turtleId = turtleId
            }
            TaskDispatchMaster.openChannel.send(MessageType.ASSIGN_TASK, payload, turtleId)
            turtle.status = TurtleStatus.CONFIRMING
            turtle.recipe = recipe
            TaskDispatchMaster.assignedTasks[recipe.output] = {
                turtleId = turtleId,
                timestamp = os.epoch("utc"),
            }
            -- 通知观察者状态已更新
            TaskDispatchMaster.notifyObservers()
            return true, "Task assigned successfully"
        end
    end
    return false, "No idle turtles available"
end

TaskDispatchMaster.getAssignedTurtle = function(recipeName)
    local assignedTask = TaskDispatchMaster.assignedTasks[recipeName]
    if not assignedTask then
        return nil, "No turtle assigned to this task"
    end
    local turtle = TaskDispatchMaster.turtles[assignedTask.turtleId]
    if not turtle then
        return nil, "Assigned turtle not found"
    end
    return turtle
end

TaskDispatchMaster.updateAssignedTasks = function(recipeName)
    local assignedTask = TaskDispatchMaster.assignedTasks[recipeName]
    if assignedTask then
        assignedTask.timestamp = os.epoch("utc")
    end
end

TaskDispatchMaster.taskBegin = function(turtleId, recipeName)
    local turtle = TaskDispatchMaster.turtles[turtleId]
    if not turtle then
        return false, "Turtle not found"
    end
    turtle.status = TurtleStatus.BUSY
    -- 通知观察者状态已更新
    TaskDispatchMaster.notifyObservers()
    return true
end

TaskDispatchMaster.clearTask = function(turtleId, recipeName)
    local turtle = TaskDispatchMaster.turtles[turtleId]
    if turtle then
        turtle.status = TurtleStatus.IDLE
        turtle.recipe = nil
    end
    TaskDispatchMaster.assignedTasks[recipeName] = nil
    -- 通知观察者状态已更新
    TaskDispatchMaster.notifyObservers()
    return true
end

TaskDispatchMaster.isAssigned = function(recipeName)
    return TaskDispatchMaster.assignedTasks[recipeName] ~= nil
end


TaskDispatchMaster.initEvents = function()
    if not TaskDispatchMaster.openChannel then
        return false, "Open channel not initialized"
    end
    
    TaskDispatchMaster.openChannel.addMessageHandler(MessageType.RECEIVE_TASK, function(eventCode, payload, senderId)
        TaskDispatchMaster.taskBegin(senderId, payload.recipeName)
    end)
    TaskDispatchMaster.openChannel.addMessageHandler(MessageType.TASK_COMPLETED, function(eventCode, payload, senderId)
        TaskDispatchMaster.clearTask(senderId, payload.recipeName)
    end)
    TaskDispatchMaster.openChannel.addMessageHandler(MessageType.TASK_IN_PROGRESS_HEARTBEAT, function(eventCode, payload, senderId)
        local turtle = TaskDispatchMaster.getAssignedTurtle(payload.recipeName)
        if not turtle then
            local senderTurtle = TaskDispatchMaster.turtles[senderId]
            if senderTurtle then
                senderTurtle.reboot()
            end
            TaskDispatchMaster.clearTask(senderId, payload.recipeName)
            return
        end
        TaskDispatchMaster.updateAssignedTasks(payload.recipeName)
    end)
    TaskDispatchMaster.openChannel.addMessageHandler(MessageType.TASK_FAILED, function(eventCode, payload, senderId)
        TaskDispatchMaster.clearTask(senderId, payload.recipeName)
    end)
    
    return true
end

TaskDispatchMaster.checkAssignedTasks = function(timeout)
    local currentTime = os.epoch("utc")
    for recipeName, taskInfo in pairs(TaskDispatchMaster.assignedTasks) do
        if currentTime - taskInfo.timestamp > timeout then
            TaskDispatchMaster.turtles[taskInfo.turtleId].reboot()
            TaskDispatchMaster.clearTask(taskInfo.turtleId, recipeName)
        end
    end
end

TaskDispatchMaster.checkRecipesTrigger = function()
    if not RecipeManager.recipes then
        return
    end
    for _, recipe in pairs(RecipeManager.recipes) do
        if recipe and recipe.output and recipe.trigger then
            if not TaskDispatchMaster.isAssigned(recipe.output) then
                if Trigger.eval(recipe.trigger, getItemFromStorage) and RecipeInputStoreVerify.verify(recipe, TaskDispatchMaster.storage) then
                    local success, errMsg = TaskDispatchMaster.assignTask(recipe)
                    if not success then
                        Logger.error("Failed to assign task for recipe {}: {}", recipe.output, errMsg)
                    end
                end
            end
        end
    end
end

TaskDispatchMaster.init = function()
    local modemSide = getModemSide()
    if not modemSide then
        error("No modem peripheral found")
    end

    TaskDispatchMaster.openChannel = Communicator.open(modemSide, 123, "TaskDispatch", "default")
    
    TaskDispatchMaster.initEvents()

    local storages = PeripheralWrapper.getAllPeripheralsNameContains("crafting_storage")
    local key = next(storages) -- Assuming only one storage is available
    local storage = storages[key]

    if not storage then
        error("No crafting_storage peripheral found")
    end
    TaskDispatchMaster.storage = storage

    local turtles = PeripheralWrapper.getAllPeripheralsNameContains("turtle")
    for _, turtle in pairs(turtles) do
        if not turtle.isOn() then
            turtle.turnOn()
        end
        turtle.status = TurtleStatus.IDLE
        turtle.recipe = nil
        local turtleId = turtle.getID()
        TaskDispatchMaster.turtles[tonumber(turtleId) or turtleId] = turtle
    end
    
    -- 初始化完成后通知观察者
    TaskDispatchMaster.notifyObservers()
end


TaskDispatchMaster.run = function()
    TaskDispatchMaster.init()
    parallel.waitForAll(function()
        while true do
            TaskDispatchMaster.checkAssignedTasks(60000) -- 60 seconds timeout
            os.sleep(10)
        end
    end, function()
        while true do
            TaskDispatchMaster.checkRecipesTrigger()
            os.sleep(0.2)
        end
    end,
    Communicator.listen
)
end



return TaskDispatchMaster
