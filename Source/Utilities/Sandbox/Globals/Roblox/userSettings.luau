
local Package = script.Parent.Parent.Parent.Parent.Parent

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local GLOBAL_NAME = VMBindings:LoadCString("UserSettings")

return function(luaState: VMBindings.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`USERSETTINGS HAS NOT BEEN IMPLEMENTED`))
		
		return 1
	end), GLOBAL_NAME)

	VMMacros.lua_setglobal(luaState, GLOBAL_NAME)
end
