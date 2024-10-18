local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local cFunctions = LuauCeption.wasm.cfns

return function(luaState: VMTypes.LuaState)
	VMMacros.lua_newtable(luaState)

	cFunctions.lua_setfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
end
