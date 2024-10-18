local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local cFunctions = LuauCeption.wasm.cfns

return function(luaState: VMTypes.LuaState)
	VMMacros.lua_newtable(luaState)

	cFunctions.lua_pushstring(luaState, VMBindings:LoadCString("new"))
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		local classNamePointer = VMMacros.lua_tostring(luaState, 1)
		local className = VMBindings:ReadCString(classNamePointer)
		local includesParent = cFunctions.lua_gettop(luaState) == 2

		local object = Instance.new(className)

		if includesParent then
			local parent = VMBindings:ToLuau(luaState, 2)

			object.Parent = parent
		end

		VMBindings:FromLuau(luaState, object)
		
		return 1
	end), VMBindings:LoadCString("new"))

	cFunctions.lua_settable(luaState, -3)

	cFunctions.lua_pushstring(luaState, VMBindings:LoadCString("fromExisting"))
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		local existingInstance = VMBindings:ToLuau(luaState, 1)

		-- selene: allow(incorrect_standard_library_use)
		VMBindings:FromLuau(luaState, Instance.fromExisting(existingInstance))
		
		return 1
	end), VMBindings:LoadCString("fromExisting"))

	cFunctions.lua_settable(luaState, -3)

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("Instance"))
end
