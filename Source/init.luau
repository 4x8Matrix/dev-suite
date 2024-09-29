--[[
	@class DevSuite 

	Summary
]]

local RunService = game:GetService("RunService")

local Package = script

local Runtime = require(Package.Parent.Runtime)

local Client = RunService:IsClient() and require(Package.Client)
local Server = RunService:IsServer() and require(Package.Server)

local Authentication = Server and require(Package.Server.Singletons.Authentication)
local Settings = Server and require(Package.Server.Singletons.Settings)

local DevSuite = {}

DevSuite.Interface = {}
DevSuite.Prototype = {}

function DevSuite.Prototype.SetSettings(self: DevSuite, settings: { [string]: any })
	assert(not self.isClient, `Cannot set settings on client.`)

	Settings:UpdateServerSettings(settings)
end

function DevSuite.Prototype.SetAuthenticationCallback(self: DevSuite, callback: (Player) -> boolean)
	assert(not self.isClient, `Cannot set authentication callback on client.`)

	Authentication.AuthenticationCallback = callback
end

function DevSuite.Interface.new(): DevSuite
	local self = setmetatable({}, {
		__index = DevSuite.Prototype
	})

	if self.isClient then
		repeat
			task.wait()
		until script:GetAttribute("ServerActive")
	end

	self.isClient = RunService:IsClient()
	self.context = self.isClient and Client.new() or Server.new()

	if not self.isClient then
		script:SetAttribute("ServerActive", true)
	end

	return self
end

Runtime:SetFFValue("Version", "0.1.0")
Runtime:SetFFValue("Branch", "Development")

export type DevSuite = typeof(DevSuite.Prototype) & {
	isClient: boolean,
	context: any,
}

return DevSuite.Interface.new() :: DevSuite
