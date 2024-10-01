local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local cFunctions = LuauCeption.wasm.cfns

local GLOBAL_NAME = VMBindings:LoadCString("newcclosure")

return function(luaState: VMBindings.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		cFunctions.lua_pushvalue(luaState, 1)

		VMMacros.lua_pushcclosure(luaState, VMBindings:LoadCFunction(luaState, function()
			cFunctions.lua_pushvalue(luaState, VMMacros.lua_upvalueindex(1))
			
			local numArgs = cFunctions.lua_gettop(luaState) - 1

			if numArgs > 0 then
				for i = 1, numArgs do
					cFunctions.lua_pushvalue(luaState, i)
				end
			end

			cFunctions.lua_pcall(luaState, numArgs, -1, 0)

			return cFunctions.lua_gettop(luaState)
		end), 1)

		return 1
	end), GLOBAL_NAME)

	VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
