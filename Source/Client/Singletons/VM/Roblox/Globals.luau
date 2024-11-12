--# selene: allow(shadowing)

local Package = script.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)

local cFunctions = LuauCeption.wasm.cfns

local function delayImpl(luaState: VMTypes.LuaState)
	local timeToWait = cFunctions.luaL_checknumber(luaState, 1)
	local thread = VMScheduler:Create(luaState)

	VMMacros.lua_pop(luaState, 1)
	cFunctions.lua_xmove(luaState, thread, 1)

	task.delay(timeToWait, function()
		VMScheduler:AddThreadToQueue(thread, luaState)
	end)

	return 0
end

local function spawnImpl(luaState: VMTypes.LuaState)
	local thread = VMScheduler:Create(luaState)

	VMMacros.lua_pop(luaState, 1)
	cFunctions.lua_xmove(luaState, thread, 1)

	VMScheduler:AddFunctionToQueue(function()
		VMScheduler:Resume(thread, luaState)
	end)

	return 0
end

local function waitImpl(luaState: VMTypes.LuaState)
	local timeToWait = VMMacros.lua_tonumber(luaState, 1)
	local clockStart = os.clock()

	task.delay(timeToWait, function()
		VMScheduler:AddFunctionToQueue(function()
			VMScheduler:Resume(luaState, nil, os.clock() - clockStart)
		end)
	end)

	return VMScheduler:Yield(luaState, 1)
end

local function elapsedTimeImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_pushnumber(luaState, elapsedTime())

	return 1
end

local function pluginManagerImpl(luaState: VMTypes.LuaState)
	VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'PluginManager' (lacking capability Plugin)`))
		
	return 0
end

local function debuggerManagerImpl(luaState: VMTypes.LuaState)
	VMBindings:Error(luaState, VMBindings:LoadCString(`The current thread cannot call 'settings' (lacking capability Plugin)`))
		
	return 0
end

local function printidentityImpl(_: VMTypes.LuaState)
	print("Current identity is 2")
		
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

local function statsImpl(luaState: VMTypes.LuaState)
	VMBindings:FromLuau(luaState, game:GetService("Stats"))
		
	return 1
end

local function versionImpl(luaState: VMTypes.LuaState)
	-- selene: allow(undefined_variable)
	local versionPointer = VMBindings:LoadCString(version())

	cFunctions.lua_pushstring(luaState, versionPointer)
		
	return 1
end

local function typeofImpl(luaState: VMTypes.LuaState)
	cFunctions.lua_pushstring(luaState, cFunctions.luaL_typename(luaState, 1))
		
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
	elapsedTime = elapsedTimeImpl,
	ElapsedTime = elapsedTimeImpl,
	PluginManager = pluginManagerImpl,
	DebuggerManager = debuggerManagerImpl,
	settings = settingsImpl,
	UserSettings = userSettingsImpl,
 	version = versionImpl,
 	warn = warnImpl,
 	tick = tickImpl,
 	time = timeImpl,
	spawn = spawnImpl,
	printidentity = printidentityImpl,
	stats = statsImpl,
	typeof = typeofImpl,
})

return function(luaState: VMTypes.LuaState)
	for globalName, global in globals do
		VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, global), VMBindings:LoadCString(globalName))
		VMMacros.lua_setglobal(luaState, VMBindings:LoadCString(globalName))
	end

	-- weird globals
	VMMacros.lua_getglobal(luaState, VMBindings:LoadCString("pcall"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("ypcall"))

	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("_G"))
	
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("global"))
	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("shared"))

	-- instances
	VMBindings:LoadInstance(luaState, workspace, true)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("workspace"))

	VMBindings:LoadInstance(luaState, game, true)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("game"))

	VMBindings:LoadInstance(luaState, Instance.new("Script"), true)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("script"))

	VMBindings:LoadInstance(luaState, Enum, true)
    VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("Enum"))
end
