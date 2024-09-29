
local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local cFunctions = LuauCeption.wasm.cfns

local GLOBAL_NAME = VMBindings:LoadCString("warn")

return function(luaState: VMBindings.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		local numberOfArguments = cFunctions.lua_gettop(luaState)
		local source = ""

		for index = 1, numberOfArguments do
			local stringPointer = cFunctions.luaL_tolstring(luaState, index, 0)

			if index > 1 then
				source ..= `\t`
			end

			source ..= VMBindings:ReadCString(stringPointer)
			VMMacros.lua_pop(luaState, 1)
		end

		warn(source)

		return 0
	end), GLOBAL_NAME)

	VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
