--[[
	A scheduler for managing Lua threads in the VM.
]]

local Package = script.Parent.Parent.Parent.Parent

local Signal = require(Package.Parent.Signal)

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMContext = require(Package.Client.Singletons.VM.Context)

local LUA_STATUS_MAP = table.freeze({
	[VMConstants.lua_Status.LUA_OK] = "OK",
	[VMConstants.lua_Status.LUA_YIELD] = "YIELD",
	[VMConstants.lua_Status.LUA_ERRRUN] = "ERRRUN",
	[VMConstants.lua_Status.LUA_ERRSYNTAX] = "ERRSYNTAX", 
	[VMConstants.lua_Status.LUA_ERRMEM] = "ERRMEM",
	[VMConstants.lua_Status.LUA_ERRERR] = "ERRERR",
	[VMConstants.lua_Status.LUA_BREAK] = "BREAK"
})

local cFunctions = LuauCeption.wasm.cfns

local Scheduler = {}

Scheduler.ScriptThreadSpawned = Signal.new()
Scheduler.ThreadSpawned = Signal.new()

--[[
	Yields the execution of a thread.
]]
function Scheduler.Yield(_: Scheduler, thread: VMTypes.LuaThread)
	return cFunctions.lua_yield(thread, -1)
end

--[[
	Resumes a suspended thread with optional arguments.
]]
function Scheduler.Resume(self: Scheduler, thread: VMTypes.LuaThread, ...)
	local args = table.pack(...)
	
	for index = 1, #args do
		VMBindings:FromLuau(thread, args[index])
	end

	local parentThread = self:GetParentThread(thread)
	local resumeState = cFunctions.lua_resume(thread, parentThread, #args)

	return LUA_STATUS_MAP[resumeState]
end

--[[
	Gets the current status of a thread.
]]
function Scheduler.Status(_: Scheduler, thread: VMTypes.LuaThread)
	local threadStatus = cFunctions.lua_status(thread)

	return LUA_STATUS_MAP[threadStatus]
end

--[[
	Checks if a thread or any of its child threads are yielding.
]]
function Scheduler.Active(self: Scheduler, thread: VMTypes.LuaThread)
	local threadStats = VMContext:GetValue(`Scheduler.threads.stats.{thread}`)
	local threadStatus = self:Status(thread)

	if threadStatus == "YIELD" then
		return true
	end

	if threadStats.isScriptThread then
		for _, childThread in threadStats.childThreads do
			local childThreadStatus = self:Status(childThread)

			if childThreadStatus == "YIELD" then
				return true
			end
		end
	end

	return false
end

--[[
	Closes a thread and all its child threads, cleaning up resources.
]]
function Scheduler.Close(self: Scheduler, thread: VMTypes.LuaThread)
	local stats = VMContext:GetValue(`Scheduler.threads.stats.{thread}`)

	if stats.isScriptThread then
		for _, childThread in stats.childThreads do
			self:Close(childThread)
		end
	end

	VMContext:UpdateValue(`Scheduler.threads.refs.{thread}`, function(ref)
		cFunctions.lua_unref(thread, ref)
		cFunctions.lua_resetthread(thread)

		VMContext:SetValue(`Scheduler.threads.stats.{thread}`, nil)
	end)

	VMContext:UpdateValue(`Scheduler.threadCount`, function(value)
		local count = value or 0

		return count - 1
	end)
end

--[[
	Creates a new thread with an optional parent thread and script thread flag.
]]
function Scheduler.Spawn(self: Scheduler, parentThread: VMTypes.LuaThread, isScriptThread: boolean?, quiet: boolean?)
	local thread = cFunctions.lua_newthread(parentThread)
	local ref = cFunctions.lua_ref(thread, 1)

	VMContext:UpdateValue(`Scheduler.threadCount`, function(value)
		local count = value or 0

		return count + 1
	end)

	VMContext:SetValue(`Scheduler.threads.refs.{thread}`, ref)
	VMContext:SetValue(`Scheduler.threads.stats.{thread}`, {
		childThreads = isScriptThread and {} or nil,
		refs = isScriptThread and {} or nil,
		isScriptThread = isScriptThread or false,

		parent = parentThread,
	})

	if isScriptThread then
		if not quiet then
			self.ScriptThreadSpawned:Fire(thread)
		end
	else
		local scriptThread = self:GetScriptThread(thread)
		local stats = VMContext:GetValue(`Scheduler.threads.stats.{scriptThread}`)
	
		table.insert(stats.childThreads, thread)

		if not quiet then
			self.ThreadSpawned:Fire(thread, scriptThread)
		end
	end

	return thread
end

--[[
	Gets the script thread associated with a given thread.
]]
function Scheduler.GetScriptThread(_: Scheduler, thread: VMTypes.LuaThread)
	local targetThread = thread
	local threadStats = VMContext:GetValue(`Scheduler.threads.stats.{targetThread}`)

	while not threadStats.isScriptThread do
		targetThread = threadStats.parent
		threadStats = VMContext:GetValue(`Scheduler.threads.stats.{targetThread}`)
	end

	return targetThread
end

--[[
	Gets the parent thread of a given thread.
]]
function Scheduler.GetParentThread(_: Scheduler, thread: VMTypes.LuaThread)
	local threadStats = VMContext:GetValue(`Scheduler.threads.stats.{thread}`)

	return threadStats.parent
end

export type Scheduler = typeof(Scheduler)

return Scheduler