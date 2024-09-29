
local Package = script.Parent.Parent.Parent.Parent.Parent

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local GLOBAL_NAME = VMBindings:LoadCString("settings")

return function(luaState: VMBindings.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'settings' (lacking capability Plugin)`))
		
		return 0
	end), GLOBAL_NAME)

	VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
