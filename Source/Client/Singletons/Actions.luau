--[[
	
]]

local HttpService = game:GetService("HttpService")

local Package = script.Parent.Parent.Parent

local Sift = require(Package.Parent.Sift)

local Interface = require(Package.Client.Singletons.Interface)

local Network = require(Package.Client.Network)

local clientSideActions = {}
local serverSideActions = {}

local updateActionsThread = nil

local Actions = {}

--[[
	
]]
function Actions.UpdateInterface(_: Actions)
	if updateActionsThread then
		task.cancel(updateActionsThread)
	end

	updateActionsThread = task.defer(function()
		Interface:SetActions(Sift.Dictionary.merge(clientSideActions, serverSideActions))
	end)
end

--[[
	
]]
function Actions.ExecuteClientAction(_: Actions, actionUuid: string, actionArguments: { any })
	clientSideActions[actionUuid].callback(table.unpack(actionArguments))
end

--[[
	
]]
function Actions.ExecuteServerAction(_: Actions, actionUuid: string, actionArguments: { any })
	local arguments = {}
	local serverSideAction = nil

	for _, serverSideActionObject in serverSideActions do
		if serverSideActionObject.uuid == actionUuid then
			serverSideAction = serverSideActionObject

			break
		end
	end

	if not serverSideAction then
		return
	end

	for index, argument in actionArguments do
		local argumentData = serverSideAction.arguments[index]

		table.insert(arguments, {
			type = argumentData.type,
			value = tostring(argument),
		})
	end

	Network.ExecuteServerActionRequested.Fire({
		actionUuid = actionUuid,
		arguments = arguments,
	})
end

--[[
	
]]
function Actions.RegisterClientAction(self: Actions, actionSettings: {
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

	clientSideActions[actionUuid] = {
		path = path,
		name = name,
		uuid = actionUuid,
		context = "Client",
		arguments = actionSettings.arguments,
		description = actionSettings.description,
		callback = actionSettings.callback,
	}

	self:UpdateInterface()
end

function Actions.OnStart(self: Actions)
	Interface.ExecuteActionRequested:Connect(function(actionUuid: string, actionArguments: { any })
		if clientSideActions[actionUuid] then
			self:ExecuteClientAction(actionUuid, actionArguments)
		else
			self:ExecuteServerAction(actionUuid, actionArguments)
		end
	end)

	Network.ServerReportingActions.On(function(actions)
		for _, object in actions do
			object.context = "Server"

			serverSideActions[object.uuid] = object
		end

		self:UpdateInterface()
	end)

	Network.FetchActionsRequested.Fire()
end

export type Actions = typeof(Actions)

return Actions