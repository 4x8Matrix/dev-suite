--[[
	@class DevSuite.Server 

	Summary
]]

local Package = script.Parent

local Runtime = require(Package.Parent.Runtime)

local DevSuiteServer = {}

DevSuiteServer.Interface = {}
DevSuiteServer.Prototype = {}

function DevSuiteServer.Interface.new(): DevSuiteServer
	local self = setmetatable({} :: DevSuiteServer, {
		__index = DevSuiteServer.Prototype
	})

	local singletons = Runtime:RequireDescendants(script.Singletons)

	table.sort(singletons, function(singletonA: { Priority: number? }, singletonB: { Priority: number? })
		local priorityA = singletonA.Priority or 0
		local priorityB = singletonB.Priority or 0

		return priorityA > priorityB
	end)

	Runtime:CallSpawnedMethodOn(singletons, "OnStart")

	return self
end


export type DevSuiteServer = typeof(DevSuiteServer.Prototype)

return DevSuiteServer.Interface
