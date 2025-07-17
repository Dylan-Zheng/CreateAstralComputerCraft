local OSUtils = require("utils.OSUtils")
local PeripheralWrapper = require("wrapper.PeripheralWrapper")

local TransferJobManager = {}

local Logger = require("utils.Logger")

TransferJobManager.transfers = {}
-- {
--     id = OSUtils.timestampBaseIdGenerate(),
--     name = "unnamed",
--     inputInv = {},
--     outputInv = {},
--     itemFilter = {},
--     isBlackList = false,
--     isDisabled = false
-- }

TransferJobManager.load = function()
    local transfers = OSUtils.loadTable("transfers")
    if transfers ~= nil then
        TransferJobManager.transfers = transfers
    end
end

TransferJobManager.save = function()
    OSUtils.saveTable("transfers", TransferJobManager.transfers)
end

TransferJobManager.addTransfer = function(transfer)
    TransferJobManager.transfers[transfer.id] = transfer
    TransferJobManager.save()
end

TransferJobManager.removeTransfer = function(transferId)
    TransferJobManager.transfers[transferId] = nil
    TransferJobManager.save()
end

TransferJobManager.getTransfer = function(transferId)
    return textutils.unserialize(textutils.serialize(TransferJobManager.transfers[transferId]))
end

TransferJobManager.getAllTransfers = function()
    return textutils.unserialize(textutils.serialize(TransferJobManager.transfers))
end

TransferJobManager.exec = function()
    local jobs = TransferJobManager.buildJobsFns()
    if #jobs > 0 then
        local ok, err = pcall(function()
            parallel.waitForAll(table.unpack(jobs))
        end)
        if not ok then
            Logger.error("Error executing transfer jobs: " .. tostring(err))
        end
    end
end

TransferJobManager.buildJobsFns = function()
    local jobs = {}
    for _, transfer in pairs(TransferJobManager.transfers) do
        if not transfer.isDisabled then
            table.insert(jobs, function()
                local ok, err = pcall(function()
                    Logger.info("Starting transfer job: " .. transfer.name .. " (ID: " .. transfer.id .. ")")
                    for name, _ in pairs(transfer.inputInv) do
                        local transferred, items = TransferJobManager.transferItem(name, transfer.outputInv, transfer.itemFilter, transfer.isBlackList)
                        if transferred > 0 then
                            Logger.info("Transfer job '" .. transfer.name .. "' transferred " .. transferred .. " items from " .. name)
                        end
                    end
                    Logger.info("Completed transfer job: " .. transfer.name)
                end)
                if not ok then
                    Logger.error("Error executing transfer job '" .. transfer.name .. "' (ID: " .. transfer.id .. "): " .. tostring(err))
                end
            end)
        end
    end
    return jobs
end

TransferJobManager.transferItem = function(inputName, outputInvNames, itemFilter, isBlackList)
    local inv = PeripheralWrapper.getByName(inputName)
    if inv == nil then
        error("Input inventory '" .. inputName .. "' not found")
    end
    local items = inv:getItems()
    if items == nil or #items == 0 then
        return 0
    end
    local overallTransferred = 0
    local transferredItems = {}
    for _, item in ipairs(items) do
        local shouldTransfer = false
        
        -- Check if item should be transferred based on filter
        if itemFilter == nil or next(itemFilter) == nil then
            -- Empty filter behavior depends on list type
            if isBlackList then
                -- Black list with empty filter: transfer all items
                shouldTransfer = true
            else
                -- White list with empty filter: transfer no items
                shouldTransfer = false
            end
        else
            -- Apply filter logic
            local itemInFilter = itemFilter[item.name] ~= nil
            if isBlackList then
                -- Black list: transfer items NOT in filter
                shouldTransfer = not itemInFilter
            else
                -- White list: transfer items IN filter
                shouldTransfer = itemInFilter
            end
        end
        
        if shouldTransfer then
            local total = item.count
            local transferred = 0
            for outputName, _  in pairs(outputInvNames) do
                local outputInv = PeripheralWrapper.getByName(outputName)
                if outputInv == nil then
                    error("Output inventory '" .. outputName .. "' not found")
                end
                while total > transferred do
                    local moved = inv.transferItemTo(outputInv, item.name, total)
                    if moved == 0 then
                        break
                    end
                    transferred = transferred + moved
                    overallTransferred = overallTransferred + moved
                end
                if transferred >= total then
                    break
                end
            end
            if transferred > 0 then
                table.insert(transferredItems, {name = item.name, count = transferred})
            end
        end
    end
    return overallTransferred, transferredItems
end

return TransferJobManager


