--[[
	
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Package = script.Parent.Parent.Parent

local decodeFromJSON = require(ReplicatedStorage.Packages.DevSuite.Utilities.Remotes.decodeFromJSON)
local Network = require(Package.Client.Network)

local Interface = require(Package.Client.Singletons.Interface)

local MAXIMUM_REMOTE_COUNT = 10000

local updateInterfaceThread

local remoteEventArray = {}
local remoteEventCallbacks = {}

local RemoteEvents = {}

function RemoteEvents.UpdateInterface(_: RemoteEvents, noDelay: boolean?)
	if updateInterfaceThread then
		task.cancel(updateInterfaceThread)
	end

	updateInterfaceThread = task.delay(noDelay and 0 or 0.05, function()
		updateInterfaceThread = nil

		Interface:SetInterceptedRemotes(remoteEventArray)
	end)
end

function RemoteEvents.ReserveMemory(_: RemoteEvents)
	local totalCount = #remoteEventArray

	if totalCount > MAXIMUM_REMOTE_COUNT then
		local object = table.remove(totalCount, #totalCount)

		if object.eventUUID and remoteEventCallbacks[object.eventUUID] then
			remoteEventCallbacks[object.eventUUID] = nil
		end
	end
end

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

function RemoteEvents.OnServerEventReceived(self: RemoteEvents, event: ServerEventObject)
	local arguments = decodeFromJSON(event.arguments, event.instances)
	local eventUuid = HttpService:GenerateGUID(false)
	local ancestorTree = {}

	local parent = event.event.Parent

	while parent ~= game do
		table.insert(ancestorTree, {
			name = parent.Name,
			class = parent.ClassName
		})

		parent = parent.Parent
	end

	remoteEventCallbacks[eventUuid] = function()
		local object = event.event
		
		object:FireServer(table.unpack(arguments))
	end

	table.insert(remoteEventArray, {
		eventType = event.event.ClassName,
		eventUUID = eventUuid,
		eventName = event.event.Name,
		eventData = event.arguments,
		eventSize = `{string.len(event.arguments) / 1000}kb`,
		ancestors = ancestorTree,
		context = "Server",
	})

	self:ReserveMemory()
	self:UpdateInterface()
end

function RemoteEvents.OnClientEventReceived(self: RemoteEvents, event: ClientEventObject)
	local ancestorTree = {}

	local parent = event.event.Parent

	while parent ~= game do
		table.insert(ancestorTree, {
			name = parent.Name,
			class = parent.ClassName
		})

		parent = parent.Parent
	end

	local encodedEventData = HttpService:JSONEncode(event.arguments)

	table.insert(remoteEventArray, {
		eventType = event.event.ClassName,
		eventUUID = HttpService:GenerateGUID(),
		eventName = event.event.Name,
		eventData = encodedEventData,
		eventSize = `{string.len(encodedEventData) / 1000}kb`,
		ancestors = ancestorTree,
		context = "Server",
	})

	self:ReserveMemory()
	self:UpdateInterface()
end

function RemoteEvents.OnStart(self: RemoteEvents)
	self:QueryRemoteEvents()

	ReplicatedStorage.DescendantAdded:Connect(function()
		self:QueryRemoteEvents()
	end)

	Interface.RepeatRemoteEventCallRequested:Connect(function(remoteUuid)
		if remoteEventCallbacks[remoteUuid] then
			remoteEventCallbacks[remoteUuid]()
		else
			warn(`Unable to find remote UUID for: '{remoteUuid}'`)
		end
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