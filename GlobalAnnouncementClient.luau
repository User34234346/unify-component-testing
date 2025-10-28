-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Packages = ReplicatedStorage.Packages

local Unify = require(Packages.Unify)

local GlobalAnnouncementServer

-- Module
local GlobalAnnouncementClient = {}

-- Example Usage
--    GlobalAnnouncementServer.topicFired:Connect(function(topic: string, data: {[any]: any}, timeSent: number)
--        if topic == "example" then
--            print(`Time Sent: {timeSent}`)
--            print("Data: \n")
--            table.foreach(data, print)
--        end
--    end)

do
    Unify:OnRan():andThen(function()
        GlobalAnnouncementServer = Unify:Get("AnnouncementServer")
    end)
end

return GlobalAnnouncementClient
