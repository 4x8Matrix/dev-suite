--[[
	
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Package = script.Parent.Parent.Parent

local Network = require(Package.Server.Network)

local encodeToJSON = require(Package.Utilities.Remotes.encodeToJSON)

local Authentication = require(Package.Server.Singletons.Authentication)

local RemoteEvents = {}

function RemoteEvents.HookRemoteEvent(_: RemoteEvents, event: RemoteEvent)
	if RemoteEvents[event] then
		return
	end

	RemoteEvents[event] = true

	local connection = event.OnServerEvent:Connect(function(player, ...)
		if not Authentication:IsAuthenticated(player) then
			return
		end

		local json, instances = encodeToJSON(...)

		Network.ServerRemotesFired.Fire(player, {
			event = event,
			arguments = json,
			instances = instances
		})
	end)

	event.Destroying:Once(function()
		connection:Disconnect()
	end)
end

function RemoteEvents.QueryRemoteEvents(self: RemoteEvents)
	for _, object in ReplicatedStorage:GetDescendants() do
		if object:IsA("RemoteEvent") or object:IsA("UnreliableRemoteEvent") then
			if object.Name == "DEBUG_REMOTES_RELIABLE" or object.Name == "DEBUG_REMOTES_UNRELIABLE" then
				continue
			end

			self:HookRemoteEvent(object)
		end
	end
end

function RemoteEvents.OnStart(self: RemoteEvents)
	self:QueryRemoteEvents()

	ReplicatedStorage.DescendantAdded:Connect(function()
		self:QueryRemoteEvents()
	end)
end

export type RemoteEvents = typeof(RemoteEvents)

return RemoteEvents