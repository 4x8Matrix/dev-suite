
local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local cFunctions = LuauCeption.wasm.cfns

local GLOBAL_NAME = VMBindings:LoadCString("loadstring")

return function(luaState: VMBindings.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		local value = VMMacros.lua_tostring(luaState, -1)
		local chunkname = VMMacros.lua_tostring(luaState, -2)

		local bytecode = cFunctions.luau_compile(value, #VMBindings:ReadCString(value), 0, 0)
		local load = cFunctions.luau_load(luaState, chunkname, bytecode, #VMBindings:ReadCString(bytecode), 0)

		if load == 0 then
			return 1
		end

		cFunctions.lua_pushnil(luaState)
		cFunctions.lua_insert(luaState, -2)

		return 2
	end), GLOBAL_NAME)

	VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
