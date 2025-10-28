-- Services
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

-- Module
local GlobalAnnouncementServer = {
    Client = {},
    _topics = {}
}

function GlobalAnnouncementServer.Client.topicFired()
    return
end

function GlobalAnnouncementServer:Send(topic: string, data: {[any]: any}): boolean
    assert(typeof(data) == "table", "`message` must be a table")
    assert(typeof(topic) == "string", "`topic` must be a string")

    local success, err = pcall(function()
        MessagingService:PublishAsync(topic, data)
    end)

    return success
end

function GlobalAnnouncementServer:Listen(topic: string): RBXScriptSignal
    assert(typeof(topic) == "string", "`topic` must be a string")

    if self._topics[topic] then return self._topics[topic].Event end

    local bindable = Instance.new("BindableEvent")
    self._topics[topic] = bindable

    pcall(function()
        MessagingService:SubscribeAsync(topic, function(message)
            bindable:Fire(message.Data, message.Sent)
            for _, player in Players:GetPlayers() do
                self.Client.topicFired:Fire(player, topic, message.Data, message.Sent)
            end
        end)
    end)

    return bindable.Event
end

-- Example Usage
--    GlobalAnnouncementServer:Listen("Test")
--    GlobalAnnouncementServer:Send("Test", { message = "HEYY" })


return GlobalAnnouncementServer
