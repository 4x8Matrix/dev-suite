local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local cFunctions = LuauCeption.wasm.cfns

local function elapsedTimeImpl(luaState: VMTypes.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		cFunctions.lua_pushinteger(luaState, elapsedTime())
		
		return 1
	end), VMBindings:LoadCString("elapsedTime"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("elapsedTime"))
end

local function pluginManagerImpl(luaState: VMTypes.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'PluginManager' (lacking capability Plugin)`))
		
		return 0
	end), VMBindings:LoadCString("PluginManager"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("PluginManager"))
end

local function settingsImpl(luaState: VMTypes.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'settings' (lacking capability Plugin)`))
		
		return 0
	end), VMBindings:LoadCString("settings"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("settings"))
end

local function tickImpl(luaState: VMTypes.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		cFunctions.lua_pushinteger(luaState, tick())
		
		return 1
	end), VMBindings:LoadCString("tick"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("tick"))
end

local function timeImpl(luaState: VMTypes.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		cFunctions.lua_pushinteger(luaState, time())
		
		return 1
	end), VMBindings:LoadCString("time"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("time"))
end

local function userSettingsImpl(luaState: VMTypes.LuaState)
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		VMBindings:FromLuau(luaState, UserSettings())
		
		return 1
	end), VMBindings:LoadCString("UserSettings"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("UserSettings"))
end

local function versionImpl(luaState: VMTypes.LuaState)
	-- selene: allow(undefined_variable)
	local versionPointer = VMBindings:LoadCString(version())

	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		cFunctions.lua_pushstring(luaState, versionPointer)
		
		return 1
	end), VMBindings:LoadCString("version"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("version"))
end

local function warnImpl(luaState: VMTypes.LuaState)
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
	end), VMBindings:LoadCString("warn"))

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("warn"))
end

local function _GImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("_G"))
end

local function sharedImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("shared"))
end

return function(luaState: VMTypes.LuaState)
	-- globals
	elapsedTimeImpl(luaState)
	pluginManagerImpl(luaState)
	settingsImpl(luaState)
	tickImpl(luaState)
	timeImpl(luaState)
	userSettingsImpl(luaState)
	versionImpl(luaState)
	warnImpl(luaState)
	_GImpl(luaState)
	sharedImpl(luaState)

	-- instances
	VMBindings:LoadInstance(luaState, workspace)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("workspace"))
	
	VMBindings:LoadInstance(luaState, game)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("game"))

	VMBindings:LoadInstance(luaState, Instance.new("Script"))
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("script"))
end
