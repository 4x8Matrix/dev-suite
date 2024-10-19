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
local awaitingStatus: { HookInfo } = {}

local errorHandler: (luaState: VMTypes.LuaState, thread: VMTypes.LuaThread, message: string) -> ()

local Scheduler = {}

function Scheduler.SetErrorHandler(_: Scheduler, handler: (luaState: VMTypes.LuaState, thread: VMTypes.LuaThread, message: string) -> ())
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

function Scheduler.ResumeThread(_: Scheduler, luaState: VMTypes.LuaState, thread: VMTypes.LuaThread, args: PackedArguments)
	local argSize = table.maxn(args)
	
	for index = 1, argSize do
		VMBindings:FromLuau(luaState, args[index])
	end
	
	local resumeState = cFunctions.lua_resume(thread, luaState, table.maxn(args))

	if resumeState ~= VMConstants.lua_CoStatus.LUA_CORUN then
		local stringPointer = cFunctions.luaL_tolstring(thread, 1, 0)
		local errorMessage = VMBindings:ReadCString(stringPointer)

		if errorHandler then
			errorHandler(luaState, thread, errorMessage)
		else
			error(errorMessage)
		end
	end
end

function Scheduler.Cycle(self: Scheduler, luaState: VMTypes.LuaState)
	local awaitingThreadsRemoved = 0
	local threadStatuses = {}

	for _, threadInformation in threadQueue do
		local thread = threadInformation.thread
		local args = threadInformation.args

		local threadStatus = cFunctions.lua_costatus(luaState, thread)

		threadStatuses[thread] = threadStatus

		if threadStatus == VMConstants.lua_CoStatus.LUA_COSUS then
			self:ResumeThread(luaState, thread, args)
		end
	end

	for index, hookInformation in awaitingStatus do
		local waitingThread = hookInformation.thread
		local targetThread = hookInformation.targetThread
		local statuses = hookInformation.statuses

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