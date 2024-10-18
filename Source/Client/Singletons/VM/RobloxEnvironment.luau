--[[
	
]]

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local RobloxGlobals = require(Package.Client.Singletons.VM.Roblox.Globals)

local InstanceLibrary = require(Package.Client.Singletons.VM.Roblox.Libraries.Instance)

local cFunctions = LuauCeption.wasm.cfns

local RobloxEnvironment = {}

--[[
	
]]
function RobloxEnvironment.WriteEnvironment(_: RobloxEnvironment, luaState: VMTypes.LuaState)
	RobloxGlobals(luaState)

	InstanceLibrary(luaState)
end

--[[
	
]]
function RobloxEnvironment.WriteFunctionEnvironment(_: RobloxEnvironment, _luaState: VMTypes.LuaState)
	
end

export type RobloxEnvironment = typeof(RobloxEnvironment)

return RobloxEnvironment