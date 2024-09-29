--[[
	@class DevSuite.Client 

	Summary
]]

local Package = script.Parent

local Console = require(Package.Parent.Console)
local Runtime = require(Package.Parent.Runtime)

local Authentication = require(Package.Client.Singletons.Authentication)

local reporter = Console.new(script.Name)

local DevSuiteClient = {}

DevSuiteClient.Interface = {}
DevSuiteClient.Prototype = {}

function DevSuiteClient.Interface.new(): DevSuiteClient
	local self = setmetatable({} :: DevSuiteClient, {
		__index = DevSuiteClient.Prototype
	})

	if not Authentication:IsAuthenticated() then
		reporter:Debug(`Local-Player not authenticated, not initializing Developer Suite!`)
		
		return
	end

	local singletons = Runtime:RequireDescendants(script.Singletons)

	table.sort(singletons, function(singletonA: { Priority: number? }, singletonB: { Priority: number? })
		local priorityA = singletonA.Priority or 0
		local priorityB = singletonB.Priority or 0

		return priorityA > priorityB
	end)

	Runtime:CallSpawnedMethodOn(singletons, "OnStart")

	return self
end

export type DevSuiteClient = typeof(DevSuiteClient.Prototype)

return DevSuiteClient.Interface
