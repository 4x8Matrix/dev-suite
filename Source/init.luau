--[[
	@class DevSuite 

	Summary
]]

local RunService = game:GetService("RunService")

local Package = script

local Sift = require(Package.Parent.Sift)
local Runtime = require(Package.Parent.Runtime)

--selene: allow(unused_variable)
local LuauCeption = require(Package.Vendor.LuauCeption)

local Client = RunService:IsClient() and require(Package.Client)
local Server = RunService:IsServer() and require(Package.Server)

local Authentication = Server and require(Package.Server.Singletons.Authentication)
local Settings = Server and require(Package.Server.Singletons.Settings)
local Interface = not Server and require(Package.Client.Singletons.Interface)

local ServerActions = Server and require(Package.Server.Singletons.Actions)
local ClientActions = not Server and require(Package.Client.Singletons.Actions)

local VM = not Server and require(Package.Client.Singletons.VM)

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

function DevSuite.Prototype.CreateAction(self: DevSuite, actionCallback: (...any) -> (), actionSettings: {
	name: string,
	description: string?,
	arguments: {
		type: "Number" | "String" | "Boolean" | "Player",
		name: string,
		default: any?
	}?,
})
	local object = Sift.Dictionary.copyDeep(actionSettings)

	object.description = object.description or ""
	object.arguments = object.arguments or {}
	object.callback = actionCallback

	for index, argument in object.arguments do
		argument.type = argument.type or "String"
		argument.name = argument.name or "Argument " .. index

		if argument.default then
			argument.default = tostring(argument.default)
		end
	end

	if self.isClient then
		ClientActions:RegisterClientAction(object)
	else
		ServerActions:RegisterServerAction(object)
	end
end

function DevSuite.Prototype.AddLibraryToVM(self: DevSuite, name: string, library: { [string]: (luauCeption: LuauCeption, luaState: number) -> number })
	assert(self.isClient, `Mutable VM is only available on client.`)
	
	VM:AddLibrary(name, library)
end

function DevSuite.Prototype.AddGlobalToVM(self: DevSuite, name: string, callback: (luauCeption: LuauCeption, luaState: number) -> number)
	assert(self.isClient, `Mutable VM is only available on client.`)
	
	VM:AddGlobal(name, callback)
end

function DevSuite.Prototype.HookVMMetamethod(self: DevSuite, name: string, callback: (luauCeption: LuauCeption, luaState: number) -> number)
	assert(self.isClient, `Mutable VM is only available on client.`)
	
	VM:HookMetamethod(name, callback)
end

function DevSuite.Prototype.AddPage(self: DevSuite, pageName: string, pageIcon: string?, renderCallback: () -> (), cleanupCallback: () -> ())
	assert(self.isClient, `AddPage is only available on client.`)

	Interface:AddCustomPage(pageName, pageIcon, renderCallback, cleanupCallback)
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
	if self.isClient then
		self.context = Client.new()
	else
		self.context = Server.new()
	end

	if not self.isClient then
		script:SetAttribute("ServerActive", true)
	end

	return self
end

Runtime:SetFFValue("Version", "0.0.6")
Runtime:SetFFValue("Branch", "Development")

export type LuauCeption = typeof(LuauCeption)
export type DevSuite = typeof(DevSuite.Prototype) & {
	isClient: boolean,
	context: any,
}

return DevSuite.Interface.new() :: DevSuite
