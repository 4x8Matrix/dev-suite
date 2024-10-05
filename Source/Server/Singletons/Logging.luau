--[[
	
]]

local LogService = game:GetService("LogService")
local Players = game:GetService("Players")

local Package = script.Parent.Parent.Parent

local Network = require(Package.Server.Network)

local Authentication = require(Package.Server.Singletons.Authentication)

local logObjectsToSendToClient = {}

local serverLogs = {}
local playerLogs = {}

local Logging = {}

function Logging.OnServerLogReceived(_: Logging, message: string, type: Enum.MessageType)
	local logTime = DateTime.now().UnixTimestampMillis

	table.insert(logObjectsToSendToClient, {
		message = message,
		type = type.Name,
		time = logTime
	})

	table.insert(serverLogs, {
		message = message,
		type = type,
		time = logTime
	})
end

function Logging.OnClientLogReceived(_: Logging, player: Player, message: string, type: Enum.MessageType, time: number)
	local playerLogArray = playerLogs[player] or {}

	table.insert(playerLogArray, {
		message = message,
		type = type,
		time = time,
	})

	playerLogs[player] = playerLogArray
end

function Logging.OnStart(self: Logging)
	LogService.MessageOut:Connect(function(message: string, type: Enum.MessageType)
		self:OnServerLogReceived(message, type)
	end)

	Network.ClientReportingLogs.On(function(player, logs)
		for _, log in logs do
			local messageType = Enum.MessageType

			self:OnClientLogReceived(player, log.message, messageType[log.type], log.time)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerLogs[player] = nil
	end)

	while true do
		task.wait(1)

		if #logObjectsToSendToClient == 0 then
			continue
		end

		Network.ServerReportingLogs.FireList(Authentication:GetListOfAuthenticatedPlayers(), logObjectsToSendToClient)
		logObjectsToSendToClient = {}
	end
end

export type Logging = typeof(Logging)

return Logging