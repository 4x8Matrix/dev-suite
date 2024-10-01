--[[
	VMEnvironment when broken down is quite simple, it's primary job is to modify the environment of a Luau VM, it does
	this for various reasons, but most importantly;

	Roblox's Runtime compatibility, Luau is not going to have access to globals like `game`, `script` or `workspace`
	and thus, this Singleton is responsible for adding those globals.

	Additionally - it also has the power to emulate an exploit environment, allowing you to run malicious scripts on
	the client - which will be an incredible tool for game developers trying to break down how an exploiters code
	is manipulating their systems.
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local warnGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.warn)
local elapsedTimeGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.elapsedTime)
local pluginManagerGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.pluginManager)
local settingsGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.settings)
local sharedGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.shared)
local tickGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.tick)
local timeGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.time)
local userSettingsGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.userSettings)
local versionGlobal = require(Package.Utilities.Sandbox.Globals.Roblox.version)

local clonefunctionGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.clonefunction)
local getcallbackvalueGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.getcallbackvalue)
local getgcGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.getgc)
local getgenvGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.getgenv)
local getrenvGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.getrenv)
local gettenvGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.gettenv)
local hookfunctionGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.hookfunction)
local hookmetamethodGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.hookmetamethod)
local isfunctionhookedGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.isfunctionhooked)
local isrbxactiveGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.isrbxactive)
local loadstringGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.loadstring)
local newcclosureGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.newcclosure)
local restorefunctionGlobal = require(Package.Utilities.Sandbox.Globals.Exploit.restorefunction)

local proxyInstance = require(Package.Utilities.Sandbox.proxyInstance)

local cFunctions = LuauCeption.wasm.cfns

local VMEnvironment = {}

function VMEnvironment.WriteInstance(_: VMEnvironment, luaState: VMBindings.LuaState, name: string, instance: Instance)
	local _userdataPointer = proxyInstance(luaState, instance)

    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString(name))
end

function VMEnvironment.WriteRobloxEnvironment(self: VMEnvironment, luaState: VMBindings.LuaState)
	warnGlobal(luaState)
	elapsedTimeGlobal(luaState)
	pluginManagerGlobal(luaState)
	settingsGlobal(luaState)
	sharedGlobal(luaState)
	tickGlobal(luaState)
	timeGlobal(luaState)
	userSettingsGlobal(luaState)
	versionGlobal(luaState)
	
	self:WriteInstance(luaState, "game", game)
	self:WriteInstance(luaState, "workspace", workspace)
	self:WriteInstance(luaState, "script", Instance.new("Script"))
end

function VMEnvironment.WriteExploitEnvironment(_: VMEnvironment, luaState: VMBindings.LuaState)
	clonefunctionGlobal(luaState)
	getcallbackvalueGlobal(luaState)
	getgcGlobal(luaState)
	getgenvGlobal(luaState)
	getrenvGlobal(luaState)
	gettenvGlobal(luaState)
	hookfunctionGlobal(luaState)
	hookmetamethodGlobal(luaState)
	isfunctionhookedGlobal(luaState)
	isrbxactiveGlobal(luaState)
	loadstringGlobal(luaState)
	newcclosureGlobal(luaState)
	restorefunctionGlobal(luaState)
end

--[[
	Writes sandbox globals so that you can detect if you're in the sandbox or not.
]]
function VMEnvironment.WriteSandboxGlobs(_: VMEnvironment, luaState: VMBindings.LuaState)
	cFunctions.lua_pushstring(luaState, VMBindings:LoadCString(`{_VERSION}-SANDBOXED`))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("_VERSION"))

	cFunctions.lua_pushboolean(luaState, true)
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("_SANDBOXED"))
end

export type VMEnvironment = typeof(VMEnvironment)

return VMEnvironment