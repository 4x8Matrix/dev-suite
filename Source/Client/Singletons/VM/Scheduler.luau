--[[
	
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local cFunctions = LuauCeption.wasm.cfns

local threadQueue: { ThreadInfo } = {}
local threadFlags: { [VMTypes.LuaThread]: { [string]: boolean } } = {}
local awaitingStatus: { HookInfo } = {}

local errorHandler: (thread: VMTypes.LuaThread, from: VMTypes.LuaState?, message: string) -> ()

local Scheduler = {}

function Scheduler.SetErrorHandler(_: Scheduler, handler: (thread: VMTypes.LuaThread, from: VMTypes.LuaState?, message: string) -> ())
	errorHandler = handler
end

function Scheduler.FromFunction(_: Scheduler, luaState: VMTypes.LuaState, ...)
	local thread = cFunctions.lua_newthread(luaState)

	VMMacros.lua_pop(luaState, 1)

	cFunctions.lua_xmove(luaState, thread, 1)
	
	VMMacros.lua_pop(luaState, 1)

	table.insert(threadQueue, {
		thread = thread,
		args = table.pack(...)
	})

	return thread
end

function Scheduler.ResumeThread(_: Scheduler, thread: VMTypes.LuaThread, from: VMTypes.LuaState?, args: PackedArguments?)
	local argSize = args and table.maxn(args)
	
	if args and argSize then
		for index = 1, argSize do
			VMBindings:FromLuau(thread, args[index])
		end
	end

	local resumeState = cFunctions.lua_resume(thread, from or 0, argSize or 0)

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

function Scheduler.YieldThread(_: Scheduler, thread: VMTypes.LuaThread, numberOfResults: number?)
	cFunctions.lua_yield(thread, numberOfResults or 0)
end

function Scheduler.SetThreadFlag(_: Scheduler, thread: VMTypes.LuaThread, flag: string, enabled: boolean?)
	if not threadFlags[thread] then
		threadFlags[thread] = {}
	end

	if enabled then
		threadFlags[thread][flag] = true
	else
		threadFlags[thread][flag] = nil
	end
end

function Scheduler.Cycle(self: Scheduler, luaState: VMTypes.LuaState)
	local awaitingThreadsRemoved = 0
	local threadStatuses = {}

	for _, threadInformation in threadQueue do
		local thread = threadInformation.thread
		local args = threadInformation.args

		if threadFlags[thread] and threadFlags[thread].IGNORED then
			continue
		end

		local threadStatus = cFunctions.lua_costatus(luaState, thread)

		threadStatuses[thread] = threadStatus

		if threadStatus == VMConstants.lua_CoStatus.LUA_COSUS then
			self:ResumeThread(thread, luaState, args)
		end
	end

	for index, hookInformation in awaitingStatus do
		local waitingThread = hookInformation.thread
		local targetThread = hookInformation.targetThread
		local statuses = hookInformation.statuses

		if not threadStatuses[targetThread] then
			continue
		end

		if table.find(statuses, threadStatuses[targetThread]) then
			table.remove(awaitingStatus, index - awaitingThreadsRemoved)

			awaitingThreadsRemoved += 1

			coroutine.resume(waitingThread, threadStatuses[targetThread])
		end
	end
end

function Scheduler.Await(_: Scheduler, thread: VMTypes.LuaThread, ...)
	table.insert(awaitingStatus, {
		thread = coroutine.running(),
		targetThread = thread,
		statuses = { ... }
	})

	return coroutine.yield()
end

function Scheduler.Run(self: Scheduler, luaState: VMTypes.LuaState)
	task.spawn(function()
		while true do
			self:Cycle(luaState)

			RunService.Heartbeat:Wait()
		end
	end)
end

export type Scheduler = typeof(Scheduler)
export type PackedArguments = { [number]: any, n: number, }
export type ThreadInfo = {
	thread: VMTypes.LuaThread,
	args: PackedArguments,
}
export type HookInfo = {
	thread: thread,
	targetThread: VMTypes.LuaThread,
	statuses: { number },
}

return Scheduler