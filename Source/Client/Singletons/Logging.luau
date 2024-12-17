--[[
	Logging handles the logic for the Logging tab on the Interface
]]

local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")

local Package = script.Parent.Parent.Parent

local Sift = require(Package.Parent.Sift)

local Interface = require(script.Parent.Interface)

local Network = require(Package.Client.Network)

local MAXIMUM_LOG_COUNT = 100

local logObjectsToSendToServer = {}

local serverLogs = {}
local clientLogs = {}

local updateInterfaceThread

local Logging = {}

--[[
	Creates a breakpoint in the console, useful for figuring out when something begins/ends.
]]
function Logging.Breakpoint(_: Logging)
	warn(`--[[ {string.rep(`-`, 65)} ]]--`)
end

--[[
	Responsible for updating the interface, has a delay of 0.05 to reduce large changes having an impact on performance.
]]
function Logging.UpdateInterface(_: Logging, noDelay: boolean?)
	if updateInterfaceThread then
		task.cancel(updateInterfaceThread)
	end

	updateInterfaceThread = task.delay(noDelay and 0 or 0.05, function()
		updateInterfaceThread = nil

		Interface:SetLogs(Sift.Dictionary.merge(serverLogs, clientLogs))
	end)
end

--[[
	Responsible for removing any excess events in the case we hit the maximum events we can log.
]]
function Logging.ReserveMemory(_: Logging)
	local totalCount = #serverLogs + #clientLogs

	if totalCount > MAXIMUM_LOG_COUNT then
		if #serverLogs == #clientLogs then
			local logTable = math.random() > 0.5 and clientLogs or serverLogs

			table.remove(logTable, #logTable)
		elseif #serverLogs > #clientLogs then
			table.remove(serverLogs, #serverLogs)
		else
			table.remove(clientLogs, #serverLogs)
		end
	end
end

--[[
	Invoked when the server logs are given to the player, will occur every second if there's server logs to be
	handed over.

	This method requires a time as we're offsetting when the genuine log occurs on the server so that we can
	bunch together a list of logs, for performance reasons - we don't want to spam the client with server
	logs.
]]
function Logging.OnServerLogReceived(self: Logging, message: string, type: string, time: number)
	local messageType = Enum.MessageType

	local lastLog = serverLogs[1]

	if lastLog and lastLog.message == message then
		lastLog.count += 1
	else
		table.insert(serverLogs, 1, {
			message = message,
			type = messageType[type],
			context = "Server",
			time = time,
			count = 1
		})
	end

	self:ReserveMemory()
	self:UpdateInterface()
end

--[[
	Called when the client logs are created.
]]
function Logging.OnClientLogReceived(self: Logging, message: string, type: Enum.MessageType)
	local logTime = DateTime.now().UnixTimestampMillis

	table.insert(logObjectsToSendToServer, {
		message = message,
		type = type.Name,
		time = logTime
	})

	local lastLog = clientLogs[1]

	if lastLog and lastLog.message == message then
		lastLog.count += 1
	else
		table.insert(clientLogs, 1, {
			message = message,
			type = type,
			context = "Client",
			time = logTime,
			count = 1
		})
	end

	self:ReserveMemory()
	self:UpdateInterface()
end

function Logging.OnStart(self: Logging)
	if not RunService:IsStudio() then
		LogService.MessageOut:Connect(function(message: string, type: Enum.MessageType)
			self:OnClientLogReceived(message, type)
		end)
	end

	Network.ServerReportingLogs.On(function(logs)
		for _, log in logs do
			self:OnServerLogReceived(log.message, log.type, log.time)
		end
	end)

	Interface.ClearLogsRequested:Connect(function()
		LogService:ClearOutput()

		clientLogs = {}
		serverLogs = {}

		self:UpdateInterface(true)
	end)

	Interface.ExportLogsRequested:Connect(function()
		
	end)

	Interface.BreakpointLogsRequested:Connect(function()
		self:Breakpoint()
	end)

	--[[
		Routinely send client logs to the server, we want the server to know all client logs so that if we want to
		export our logs, we can do so without sending the server the entire log history of both the server and 
		client.

		That would be a bad idea, so instead we just incremental update the server.
	]]
	while true do
		task.wait(1)

		if #logObjectsToSendToServer == 0 then
			continue
		end

		Network.ClientReportingLogs.Fire(logObjectsToSendToServer)
		logObjectsToSendToServer = {}
	end
end

export type ServerLogObject = {
	message: string,
	type: Enum.MessageType,
	time: number
}

export type Logging = typeof(Logging)

return Logging