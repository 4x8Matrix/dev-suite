local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)

local cFunctions = LuauCeption.wasm.cfns

local function spawn(luaState: VMTypes.LuaState)
	local thread = VMScheduler:FromFunction(luaState, 1)
	local numberOfArguments = cFunctions.lua_gettop(luaState)
	local arguments = { n = numberOfArguments }

	for index = 1, numberOfArguments do
		arguments[index] = VMBindings:ToLuau(luaState, index)
	end

	VMScheduler:SetThreadFlag(thread, "IGNORED", true)

	task.spawn(function()
		VMScheduler:SetThreadFlag(thread, "IGNORED", nil)

		VMScheduler:ResumeThread(thread, luaState, arguments)
	end)

	cFunctions.lua_pushthread(thread)

	return 1
end

local callbacks = table.freeze({
	spawn = spawn
})

return function(luaState: VMTypes.LuaState)
	VMMacros.lua_newtable(luaState)

	for name, callback in callbacks do
		VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, callback), VMBindings:LoadCString(name))
		cFunctions.lua_setfield (luaState, -2, VMBindings:LoadCString(name))
	end

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString("task"))
end
