local OSUtils = require("utils.OSUtils")
local JobExecutor = require("programs.command.transfer.JobExecutor")
local Logger = require("utils.Logger")

-- Job component type constants
local JOB_COMPONENT_TYPES = {
    INPUT_INVENTORY = "inputInventory",
    OUTPUT_INVENTORY = "outputInventory", 
    INPUT_TANK = "inputTank",
    OUTPUT_TANK = "outputTank",
    FILTER = "filter"
}

-- Field name mapping
local FIELD_NAMES = {
    [JOB_COMPONENT_TYPES.INPUT_INVENTORY] = "inputInventories",
    [JOB_COMPONENT_TYPES.OUTPUT_INVENTORY] = "outputInventories",
    [JOB_COMPONENT_TYPES.INPUT_TANK] = "inputTanks",
    [JOB_COMPONENT_TYPES.OUTPUT_TANK] = "outputTanks",
    [JOB_COMPONENT_TYPES.FILTER] = "filters"
}

local JobManager = {
    jobs = {},
    JOB_COMPONENT_TYPES = JOB_COMPONENT_TYPES  -- Expose constants for external use
}

function JobManager:addJob(name, job)
    self.jobs[name] = job
end

function JobManager:getJob(name)
    return self.jobs[name]
end

function JobManager:removeJob(name)
    self.jobs[name] = nil
end

function JobManager:save()
    OSUtils.saveTable("jobs.data", self.jobs)
    JobExecutor.load(self.jobs)
end

function JobManager:load()
    local loadedJobs = OSUtils.loadTable("jobs.data")
    if loadedJobs then
        self.jobs = loadedJobs
        JobExecutor.load(self.jobs)
    end
end

function JobManager:addComponentToJob(jobName, componentType, ...)
    local job = self:getJob(jobName)
    if not job then return end
    
    local fieldName = FIELD_NAMES[componentType]
    if not fieldName then
        error("Invalid component type: " .. tostring(componentType))
    end
    
    job[fieldName] = job[fieldName] or {}
    
    -- Add all component names using varargs
    for _, componentName in ipairs({...}) do
        table.insert(job[fieldName], componentName)
    end
end

function JobManager:removeComponentFromJob(jobName, componentType, ...)
    local job = self:getJob(jobName)
    if not job then return 0 end
    
    local fieldName = FIELD_NAMES[componentType]
    if not fieldName then
        error("Invalid component type: " .. tostring(componentType))
    end
    
    if not job[fieldName] then return 0 end
    
    local removedCount = 0
    -- Remove all specified component names
    for _, componentName in ipairs({...}) do
        -- Find and remove the component
        for i = #job[fieldName], 1, -1 do  -- Iterate backwards to avoid index issues
            if job[fieldName][i] == componentName then
                table.remove(job[fieldName], i)
                removedCount = removedCount + 1
                break  -- Only remove first match of each name
            end
        end
    end
    
    return removedCount
end

function JobManager:getJobDetail(jobName, componentType)
    local job = self:getJob(jobName)
    if not job then return nil end
    
    local fieldName = FIELD_NAMES[componentType]
    if not fieldName then
        error("Invalid component type: " .. tostring(componentType))
    end
    
    return job[fieldName] or {}
end

function JobManager:setBlacklist(jobName, isBlacklist)
    local job = self:getJob(jobName)
    if not job then return end
    
    job.isFilterBlacklist = isBlacklist
end

function JobManager:disableJob(jobName)
    local job = self:getJob(jobName)
    if not job then return end
    job.enabled = false
    self:save()
end

function JobManager:enableJob(jobName)
    local job = self:getJob(jobName)
    if not job then return end
    job.enabled = true
    self:save()
end

function JobManager:setRate(jobName, rateType, rateValue)
    local job = self:getJob(jobName)
    if not job then return false end
    
    local numericValue = tonumber(rateValue)
    if not numericValue or numericValue < 0 then
        return false
    end
    
    if rateType == "item" then
        job.itemRate = numericValue
    elseif rateType == "fluid" then
        job.fluidRate = numericValue
    else
        return false
    end
    
    return true
end


return JobManager