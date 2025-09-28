local BlazeBurnerFeederFactory = {}

BlazeBurnerFeederFactory.Types = {
    LAVA = "minecraft:lava",
    HELLFIRE = "kubejs:hellfire",
}

local feeders = {}


BlazeBurnerFeederFactory.getFeeder = function(from, to, type, refill_time_interval)

    if type == nil then
        type = BlazeBurnerFeederFactory.Types.LAVA
    elseif type ~= BlazeBurnerFeederFactory.Types.LAVA and type  ~= BlazeBurnerFeederFactory.Types.HELLFIRE then
            type = BlazeBurnerFeederFactory.Types.LAVA
    end

    local key = to.getName() .. type
    if feeders[key] ~= nil then
        return feeders[key]
    end

    if refill_time_interval == nil then
        if type == BlazeBurnerFeederFactory.Types.LAVA then
            refill_time_interval = 2000000
        elseif type == BlazeBurnerFeederFactory.Types.HELLFIRE then
            refill_time_interval = 1000000
        end
    end
    local feeder = {
        start_timestamp = 0,
        reset = function(self)
            self.start_timestamp = os.epoch()
        end,
        feed = function(self)
            local curr_timestamp = os.epoch()
            if curr_timestamp - self.start_timestamp >= refill_time_interval then
                from.transferFluidTo(to, type, 49)
                self:reset()
            end
        end
    }
    feeders[key] = feeder
    return feeder
end

return BlazeBurnerFeederFactory