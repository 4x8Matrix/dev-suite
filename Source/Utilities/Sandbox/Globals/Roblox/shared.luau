
local Package = script.Parent.Parent.Parent.Parent.Parent

-- local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
-- local VMMacros = require(Package.Client.Singletons.VMMacros)

-- local cFunctions = LuauCeption.wasm.cfns

-- local GLOBAL_NAME = VMBindings:LoadCString("shared")
-- local LUAI_MAXCSTACK = 8000
-- local LUAU_GLOBALSINDEX = -LUAI_MAXCSTACK - 2002

return function(_luaState: VMBindings.LuaState
)
	-- VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
	-- 	cFunctions.lua_gettable(luaState, LUAU_GLOBALSINDEX)
		
	-- 	return 1
	-- end), GLOBAL_NAME)

	-- VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
