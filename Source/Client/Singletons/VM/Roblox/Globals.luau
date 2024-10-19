--# selene: allow(shadowing)

local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local cFunctions = LuauCeption.wasm.cfns

local function delayImpl(_luaState: VMTypes.LuaState)
	return 0
end

local function waitImpl(_luaState: VMTypes.LuaState)
	return 0
end

local function elapsedTimeImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_pushnumber(luaState, elapsedTime())

	return 1
end

local function pluginManagerImpl(luaState: VMTypes.LuaState)
	VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'PluginManager' (lacking capability Plugin)`))
		
	return 0
end

local function settingsImpl(luaState: VMTypes.LuaState)
	VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'settings' (lacking capability Plugin)`))
		
	return 0
end

local function tickImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_pushnumber(luaState, tick())
		
	return 1
end

local function timeImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_pushnumber(luaState, time())
		
	return 1
end

local function userSettingsImpl(luaState: VMTypes.LuaState)
	VMBindings:FromLuau(luaState, UserSettings())
		
	return 1
end

local function versionImpl(luaState: VMTypes.LuaState)
	-- selene: allow(undefined_variable)
	local versionPointer = VMBindings:LoadCString(version())

	cFunctions.lua_pushstring(luaState, versionPointer)
		
	return 1
end

local function warnImpl(luaState: VMTypes.LuaState)
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
end

local globals = table.freeze({
	delay = delayImpl,
	wait = waitImpl,
	ElapsedTime = elapsedTimeImpl,
	elapsedTime = elapsedTimeImpl,
	PluginManager = pluginManagerImpl,
	settings = settingsImpl,
	UserSettings = userSettingsImpl,
 	version = versionImpl,
 	warn = warnImpl,
 	tick = tickImpl,
 	time = timeImpl,
})

return function(luaState: VMTypes.LuaState)
	for globalName, global in globals do
		VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, global), VMBindings:LoadCString(globalName))
		VMMacros.lua_setglobal(luaState, VMBindings:LoadCString(globalName))
	end

	-- weird globals
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("_G"))
	
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("shared"))

	-- instances
	VMBindings:LoadInstance(luaState, workspace)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("workspace"))
	
	VMBindings:LoadInstance(luaState, game)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("game"))

	VMBindings:LoadInstance(luaState, Instance.new("Script"))
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("script"))
end
