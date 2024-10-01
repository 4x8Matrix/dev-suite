
local Package = script.Parent.Parent.Parent.Parent.Parent

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local GLOBAL_NAME = VMBindings:LoadCString("getrenv")

return function(luaState: VMBindings.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		VMMacros.lua_newtable(luaState)
		
		return 1
	end), GLOBAL_NAME)

	VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
