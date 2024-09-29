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

local proxyInstance = require(Package.Utilities.Sandbox.proxyInstance)

local cFunctions = LuauCeption.wasm.cfns

local VMEnvironment = {}

function VMEnvironment.WriteGlobalInstance(_: VMEnvironment, luaState: VMBindings.LuaState, name: string, instance: Instance)
	local userdataPointer = proxyInstance(luaState, instance)

    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString(name))
end

function VMEnvironment.WriteRobloxEnvironment(self: VMEnvironment, luaState: VMBindings.LuaState)
	warnGlobal(luaState)
	
	self:WriteGlobalInstance(luaState, "game", game)
	self:WriteGlobalInstance(luaState, "workspace", workspace)
	self:WriteGlobalInstance(luaState, "script", Instance.new("Script"))
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