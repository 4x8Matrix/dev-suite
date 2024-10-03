--[[
	
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Package = script.Parent.Parent.Parent

local Network = require(Package.Client.Network)

local decodeFromJSON = require(Package.Utilities.Remotes.decodeFromJSON)

local Interface = require(Package.Client.Singletons.Interface)

local RemoteEvents = {}

function RemoteEvents.HookRemoteEvent(self: RemoteEvents, event: RemoteEvent)
	if RemoteEvents[event] then
		return
	end

	RemoteEvents[event] = true

	local connection = event.OnClientEvent:Connect(function(...)
		self:OnClientEventReceived({
			event = event,
			arguments = { ... }
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

function RemoteEvents.OnServerEventReceived(_: RemoteEvents, event: ServerEventObject)
	local arguments = decodeFromJSON(event.arguments, event.instances)
	
	Interface:AddRemoteEventInvoke({
		arguments = arguments,
		event = event.event,
		context = "Server",
		callbackFunction = function()
			if event.event:IsA("RemoteEvent") or event.event:IsA("UnreliableRemoteEvent") then
				local eventObject = event.event

				eventObject:FireServer(table.unpack(arguments))
			else
				warn(`Unknown event type: '{event.event}'`)
			end
		end
	})
end

function RemoteEvents.OnClientEventReceived(_: RemoteEvents, event: ClientEventObject)
	Interface:AddRemoteEventInvoke({
		event = event.event,
		arguments = event.arguments,
		context = "Client",
	})
end

function RemoteEvents.OnStart(self: RemoteEvents)
	self:QueryRemoteEvents()

	ReplicatedStorage.DescendantAdded:Connect(function()
		self:QueryRemoteEvents()
	end)

	Network.ServerRemotesFired.On(function(object)
		self:OnServerEventReceived(object)
	end)
end

export type ServerEventObject = {
	event: RemoteEvent | UnreliableRemoteEvent,
	arguments: string,
	instances: { Instance }
}

export type ClientEventObject = {
	event: RemoteEvent | UnreliableRemoteEvent,
	arguments: { any }
}

export type RemoteEvents = typeof(RemoteEvents)

return RemoteEvents