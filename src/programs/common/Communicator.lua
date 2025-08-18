local Logger = require("utils.Logger")
local OSUtils = require("utils.OSUtils")

local function xorCipher(text, secret)
    local encrypted = ""
    local key = secret
    for i = 1, #text do
        local char = text:sub(i, i)
        local keyChar = key:sub((i - 1) % #key + 1, (i - 1) % #key + 1)
        encrypted = encrypted .. string.char(bit.bxor(string.byte(char), string.byte(keyChar)))
    end
    return encrypted
end

local function decrypt(encryptedText, secret)
    return textutils.unserialize(xorCipher(encryptedText, secret))
end

local function encrypt(table, secret)
    return xorCipher(textutils.serialize(table), secret)
end


local CommunicationChannel = {}
CommunicationChannel.__index = CommunicationChannel

function CommunicationChannel:new(side, channel, protocol, secret)
    local this = setmetatable({}, CommunicationChannel)
    this.computerId = os.getComputerID()
    this.side = side
    this.secret = secret
    this.channel = channel
    this.protocol = protocol
    
    -- 验证调制解调器
    this.modem = peripheral.wrap(side)
    this.modem.open(channel)
    this.eventHandle = {}

    this.send = function(eventCode, data, receiverId)
        local message = {
            protocol = this.protocol,
            senderId = this.computerId,
            receiverId = receiverId,
            details = encrypt({
                eventCode = eventCode,
                payload = data
            }, this.secret)
        }
        this.modem.transmit(this.channel, this.channel, textutils.serialize(message))
    end

    this.addMessageHandler = function(eventCode, callback)
        this.eventHandle[eventCode] = callback
    end

    return this
end

local Communicator = {
    communicationChannels = {}
}

function Communicator.open(side, channel, protocol, secret)
    local channelInstance = CommunicationChannel:new(side, channel, protocol, secret)
    if not Communicator.communicationChannels[side] then
        Communicator.communicationChannels[side] = {}
    end
    if not Communicator.communicationChannels[side][channel] then
        Communicator.communicationChannels[side][channel] = {}
    end
    if Communicator.communicationChannels[side][channel][protocol] then
        return false, string.format("Channel already opened on side %s, channel %d, protocol %s", side, channel, protocol)  
    end
    Communicator.communicationChannels[side][channel][protocol] = channelInstance
    return channelInstance
end

local isOpened = function(side, channel)
    if Communicator.communicationChannels[side] and 
       Communicator.communicationChannels[side][channel] then
        return true
    end
    return false
end

local handleSerializedMessage = function(side, channel, serializedMessage)
    local message = textutils.unserialize(serializedMessage)
    if not message or not message.protocol then
        return  -- 如果消息格式无效，直接返回
    end
    
    local channelInstance = Communicator.communicationChannels[side][channel][message.protocol]
    if not channelInstance then
        return  -- 如果找不到对应的通道实例，直接返回
    end
    
    if message.receiverId ~= nil and message.receiverId ~= channelInstance.computerId then
        return
    end
    local details = decrypt(message.details, channelInstance.secret)
    local handler = channelInstance.eventHandle[details.eventCode]
    if handler then
        handler(details.eventCode, details.payload, message.senderId)
    end
end

function Communicator.listen()
    while true do
        local _, side, channel, _, serializedMessage, distance = os.pullEvent("modem_message")
        if isOpened(side, channel) then
            local success, err = pcall(function()
                handleSerializedMessage(side, channel, serializedMessage)
            end)
            if not success then
                Logger.error("Error handling serialized message: " .. err)
            end
        end
    end
end

function Communicator.close(side, channel, protocol)
    if Communicator.communicationChannels[side] and 
       Communicator.communicationChannels[side][channel] and
       Communicator.communicationChannels[side][channel][protocol] then
        local instance = Communicator.communicationChannels[side][channel][protocol]
        instance.modem.close(channel)
        Communicator.communicationChannels[side][channel][protocol] = nil
        if next(Communicator.communicationChannels[side][channel]) == nil then
            Communicator.communicationChannels[side][channel] = nil
        end
        if next(Communicator.communicationChannels[side]) == nil then
            Communicator.communicationChannels[side] = nil
        end
        return true
    else
        return false, string.format("No such channel to close on side %s, channel %d, protocol %s", side, channel, protocol)
    end
end

function Communicator.listencloseAllChannels()
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, instance in pairs(protocols) do
                instance.modem.close(channel)
            end
        end
    end
    Communicator.communicationChannels = {}
end

function Communicator.saveSettings()
    local settings = {}
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, instance in pairs(protocols) do
                table.insert(settings, {
                    side = side,
                    channel = channel,
                    protocol = protocol,
                    secret = instance.secret
                })
            end
        end
    end
    return OSUtils.saveTable("communicator_settings.dat", settings)
end

function Communicator.loadSettings()
    local settings = OSUtils.loadTable("communicator_settings.dat")
    if not settings or #settings == 0 then
        Logger.warn("No communicator settings found.")
        return false
    end
    for _, setting in ipairs(settings) do
        local side = setting.side
        local channel = setting.channel
        local protocol = setting.protocol
        local secret = setting.secret
        local channelInstance, err = Communicator.open(side, channel, protocol, secret)
        if not channelInstance then
            Logger.error("Failed to open communication channel: " .. err)
        end
    end
    return true
end

function Communicator.getSettings()
    local settings = {}
    for side, channels in pairs(Communicator.communicationChannels) do
        for channel, protocols in pairs(channels) do
            for protocol, instance in pairs(protocols) do
                table.insert(settings, {
                    side = side,
                    channel = channel,
                    protocol = protocol,
                    secret = instance.secret
                })
            end
        end
    end
    return settings
end

return Communicator

