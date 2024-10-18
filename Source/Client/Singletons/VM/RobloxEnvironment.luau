--[[
	
]]

local Package = script.Parent.Parent.Parent.Parent

local Macros = require(script.Parent.Macros)
local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local RobloxGlobals = require(Package.Client.Singletons.VM.Roblox.Globals)
local RobloxGlobalTable = require(Package.Client.Singletons.VM.Roblox.GlobalTable)
local RobloxSharedTable = require(Package.Client.Singletons.VM.Roblox.SharedTable)

local InstanceLibrary = require(Package.Client.Singletons.VM.Roblox.Libraries.Instance)

local cFunctions = LuauCeption.wasm.cfns

local RobloxEnvironment = {}

--[[
	
]]
function RobloxEnvironment.WriteEnvironment(_: RobloxEnvironment, luaState: VMTypes.LuaState)
	RobloxGlobalTable(luaState)
	RobloxSharedTable(luaState)

	RobloxGlobals(luaState)

	InstanceLibrary(luaState)
end

--[[
	
]]
function RobloxEnvironment.WriteFunctionEnvironment(_: RobloxEnvironment, luaState: VMTypes.LuaState)
	Macros.lua_newtable(luaState)
	Macros.lua_newtable(luaState)

	cFunctions.lua_pushstring(luaState, VMBindings:LoadCString("The metatable is locked"))
	cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString("__metatable"))

	cFunctions.lua_pushvalue(luaState, VMConstants.LUAU_GLOBALSINDEX)
	cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString("__index"))

	cFunctions.lua_setmetatable(luaState, -2)

	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString("_G"))

	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("shared"))
	cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString("shared"))

	cFunctions.lua_setfenv(luaState, -2)
end

export type RobloxEnvironment = typeof(RobloxEnvironment)

return RobloxEnvironment