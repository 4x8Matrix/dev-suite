local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)

local cFunctions = LuauCeption.wasm.cfns

local function spawn(luaState: VMTypes.LuaState)
	local numberOfArguments = cFunctions.lua_gettop(luaState) - 1
	local arguments = { n = numberOfArguments }

	-- + 1, because we want to skip the first argument, which is the function to call
	for index = 1, numberOfArguments do
		arguments[index] = VMBindings:ToLuau(luaState, index + 1)
	end

	local thread = VMScheduler:Spawn(luaState)

	cFunctions.lua_pushvalue(luaState, 1)
	cFunctions.lua_xmove(luaState, thread, 1)

	VMScheduler:Resume(thread, table.unpack(arguments))

	return 1
end

local function defer(luaState: VMTypes.LuaState)
	local numberOfArguments = cFunctions.lua_gettop(luaState) - 1
	local arguments = { n = numberOfArguments }

	-- + 1, because we want to skip the first argument, which is the function to call
	for index = 1, numberOfArguments do
		arguments[index] = VMBindings:ToLuau(luaState, index + 1)
	end

	local thread = VMScheduler:Spawn(luaState)

	cFunctions.lua_pushvalue(luaState, 1)
	cFunctions.lua_xmove(luaState, thread, 1)

	VMScheduler:Resume(thread, table.unpack(arguments))

	return 1
end

local function delay(luaState: VMTypes.LuaState)
	local timeToWait = cFunctions.luaL_checknumber(luaState, 1)
	local numberOfArguments = cFunctions.lua_gettop(luaState) - 2
	local arguments = { n = numberOfArguments }

	-- + 1, because we want to skip the first argument, which is the function to call
	for index = 1, numberOfArguments do
		arguments[index] = VMBindings:ToLuau(luaState, index + 2)
	end

	local thread = VMScheduler:Spawn(luaState)

	cFunctions.lua_pushvalue(luaState, 2)
	cFunctions.lua_xmove(luaState, thread, 1)

	task.delay(timeToWait, function()
		VMScheduler:Resume(thread, table.unpack(arguments))
	end)

	return 1
end

local function desynchronize(_: VMTypes.LuaState)
	return 0
end

local function synchronize(_: VMTypes.LuaState)
	return 0
end

local function wait(luaState: VMTypes.LuaState)
	local timeToWait = cFunctions.luaL_checknumber(luaState, 1)
	local clockStart = os.clock()

	task.delay(timeToWait, function()
		VMScheduler:Resume(luaState, os.clock() - clockStart)
	end)

	return VMScheduler:Yield(luaState)
end

local function cancel(luaState: VMTypes.LuaState)
	local thread = cFunctions.lua_tothread(luaState, 1)

	cFunctions.lua_resetthread(thread)

	return 0
end

local callbacks = table.freeze({
	spawn = spawn,
	defer = defer,
	delay = delay,
	desynchronize = desynchronize,
	synchronize = synchronize,
	wait = wait,
	cancel = cancel,
})

return function(luaState: VMTypes.LuaState)
	VMMacros.lua_newtable(luaState)

	for name, callback in callbacks do
		VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, callback), VMBindings:LoadCString(name))
		cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString(name))
	end

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("task"))
end
