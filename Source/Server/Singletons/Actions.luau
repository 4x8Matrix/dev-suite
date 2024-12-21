--[[
	
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Package = script.Parent.Parent.Parent

local Network = require(Package.Server.Network)

local Authentication = require(Package.Server.Singletons.Authentication)

local serverSideActions = {}

local Actions = {}

--[[
	
]]
function Actions.UpdateClients(_: Actions)
	Network.ServerReportingActions.FireList(Authentication:GetListOfAuthenticatedPlayers(), serverSideActions)
end

--[[
	
]]
function Actions.ExecuteServerAction(_: Actions, player:Player, actionUuid: string, actionArguments: { any })
	for _, action in serverSideActions do
		if action.uuid == actionUuid then
			action.callback(player, table.unpack(actionArguments))
		end
	end
end

--[[
	
]]
function Actions.RegisterServerAction(self: Actions, actionSettings: {
	name: string,
	description: string,
	arguments: {
		type: "Number" | "String" | "Boolean" | "Player",
		name: string,
		default: any
	},
	callback: (...any) -> ()
})
	local actionUuid = HttpService:GenerateGUID(false)
	local path = string.split(actionSettings.name, ".")
	local name = table.remove(path, #path)

	table.insert(serverSideActions, {
		path = path,
		name = name,
		uuid = actionUuid,
		arguments = actionSettings.arguments,
		description = actionSettings.description,
		callback = actionSettings.callback,
	})

	self:UpdateClients()
end

function Actions.OnStart(self: Actions)
	Network.FetchActionsRequested.On(function(player)
		Authentication:Validate(player)

		Network.ServerReportingActions.Fire(player, serverSideActions)
	end)

	Network.ExecuteServerActionRequested.On(function(player, object)
		Authentication:Validate(player)

		local arguments = {}

		for _, argument in object.arguments do
			if argument.type == "Player" then
				table.insert(arguments, Players:FindFirstChild(argument.value))
			elseif argument.type == "Boolean" then
				table.insert(arguments, argument.value == "true")
			elseif argument.type == "Number" then
				table.insert(arguments, tonumber(argument.value))
			else
				table.insert(arguments, argument.value)
			end
		end

		self:ExecuteServerAction(player, object.actionUuid, arguments)
	end)
end

export type Actions = typeof(Actions)

return Actions