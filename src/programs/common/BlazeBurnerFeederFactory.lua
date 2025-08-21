local BlazeBurnerFeederFactory = {}

BlazeBurnerFeederFactory.Types = {
    LAVA = "minecraft:lava",
    HELLFIRE = "kubejs:hellfire",
}


BlazeBurnerFeederFactory.getFeeder = function(from, to, type, refill_time_interval)
    if type == nil then
        type = BlazeBurnerFeederFactory.Types.LAVA
    end
    if refill_time_interval == nil then
        if type == BlazeBurnerFeederFactory.Types.LAVA then
            refill_time_interval = 2000000
        elseif type == BlazeBurnerFeederFactory.Types.HELLFIRE then
            refill_time_interval = 1000000
        end
    end
    return {
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
end

return BlazeBurnerFeederFactory