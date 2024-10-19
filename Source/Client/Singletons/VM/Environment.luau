--[[
	
]]

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)

local RobloxGlobals = require(Package.Client.Singletons.VM.Roblox.Globals)
local RobloxGlobalTable = require(Package.Client.Singletons.VM.Roblox.GlobalTable)
local RobloxSharedTable = require(Package.Client.Singletons.VM.Roblox.SharedTable)
local RobloxEnvironmentTable = require(Package.Client.Singletons.VM.Roblox.EnvironmentTable)

local InstanceLibrary = require(Package.Client.Singletons.VM.Roblox.Libraries.Instance)

local cFunctions = LuauCeption.wasm.cfns

local Environment = {}

--[[
	
]]
function Environment.WriteEnvironment(_: Environment, luaState: VMTypes.LuaState)
	RobloxGlobalTable(luaState)
	RobloxSharedTable(luaState)
	RobloxEnvironmentTable(luaState)

	RobloxGlobals(luaState)

	InstanceLibrary(luaState)
end

--[[
	
]]
function Environment.WriteFunctionEnvironment(_: Environment, luaState: VMTypes.LuaState)
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("script.environment"))

	cFunctions.lua_setfenv(luaState, -2)
end

export type Environment = typeof(Environment)

return Environment