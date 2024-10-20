--[[
	
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)

local cFunctions = LuauCeption.wasm.cfns

local threadQueue: { { callback: () -> () } } = {}

local threads: { VMTypes.LuaThread } = { }
local threadCount = 0

local schedulerThread: thread

local errorHandler: (thread: VMTypes.LuaThread, from: VMTypes.LuaState?, message: string) -> ()

local Scheduler = {}

--[[

]]
function Scheduler.SetErrorHandler(_: Scheduler, handler: (thread: VMTypes.LuaThread, from: VMTypes.LuaState?, message: string) -> ())
	errorHandler = handler
end

--[[

]]
function Scheduler.GetAllThreads(_: Scheduler)
	return table.freeze(table.clone(threads))
end

--[[

]]
function Scheduler.AddThreadToQueue(self: Scheduler, thread: VMTypes.LuaThread, from: VMTypes.LuaThread?, ...)
	local args = table.pack(...)
	
	self:AddFunctionToQueue(function()
		local status = self:Status(thread, from)

		if status == "suspended" then
			self:Resume(thread, from, table.unpack(args))
		end
	end)
end

--[[

]]
function Scheduler.AddFunctionToQueue(_: Scheduler, callback: () -> ())
	table.insert(threadQueue, {
		callback = callback,
	})
end

--[[

]]
function Scheduler.Resume(_: Scheduler, thread: VMTypes.LuaThread, from: VMTypes.LuaState?, ...)
	local args = table.pack(...)
	
	for index = 1, #args do
		VMBindings:FromLuau(thread, args[index])
	end

	local resumeState = cFunctions.lua_resume(thread, from or 0, #args)

	if resumeState == VMConstants.lua_CoStatus.LUA_COERR then
		local stringPointer = cFunctions.luaL_tolstring(thread, 1, 0)
		local errorMessage = VMBindings:ReadCString(stringPointer)

		if errorHandler then
			errorHandler(thread, from, errorMessage)
		else
			error(errorMessage)
		end
	end

	return resumeState
end

--[[

]]
function Scheduler.Yield(_: Scheduler, thread: VMTypes.LuaThread, argCount: number?)
	return cFunctions.lua_yield(thread, argCount or 0)
end

--[[

]]
function Scheduler.Status(_: Scheduler, thread: VMTypes.LuaThread, from: VMTypes.LuaState?): ThreadStatus
	local threadStatus = cFunctions.lua_costatus(from or 0, thread)

	if threadStatus == VMConstants.lua_CoStatus.LUA_COSUS then
		return "suspended"
	elseif threadStatus == VMConstants.lua_CoStatus.LUA_CORUN then
 		return "running"
 	elseif threadStatus == VMConstants.lua_CoStatus.LUA_CONOR then
 		return "normal"
 	elseif threadStatus == VMConstants.lua_CoStatus.LUA_COFIN then
 		return "dead"
 	elseif threadStatus == VMConstants.lua_CoStatus.LUA_COERR then
 		return "error"
 	else
 		return "unknown"
 	end
end

--[[

]]
function Scheduler.Create(_: Scheduler, luaState: VMTypes.LuaState): VMTypes.LuaThread
	local thread = cFunctions.lua_newthread(luaState)

	threadCount += 1

	table.insert(threads, thread)

	return thread
end

--[[

]]
function Scheduler.Cycle(_: Scheduler)
	for _, callbackInformation in threadQueue do
		callbackInformation.callback()
	end

	threadQueue = {}
end

--[[

]]
function Scheduler.StartScheduler(self: Scheduler)
	assert(schedulerThread == nil, `Scheduler already started!`)

	schedulerThread = task.spawn(function()
		while true do
			if #threadQueue ~= 0 then
				self:Cycle()
			end

			RunService.Heartbeat:Wait()
		end
	end)
end

--[[

]]
function Scheduler.StopScheduler(_: Scheduler)
	assert(schedulerThread ~= nil, `Scheduler not started!`)

	task.cancel(schedulerThread)
end

export type Scheduler = typeof(Scheduler)
export type ThreadStatus = "suspended" | "running" | "normal" | "dead" | "error" | "unknown"
export type PackedArguments = { [number]: any, n: number, }

return Scheduler