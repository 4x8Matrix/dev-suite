--[[
	Debugger
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local Sift = require(Package.Parent.Sift)

local Interface = require(Package.Client.Singletons.Interface)

local VM = require(Package.Client.Singletons.VM)

local VMContext = require(Package.Client.Singletons.VM.Context)
local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMEnvironment = require(Package.Client.Singletons.VM.Environment)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)
local VMMacros = require(Package.Client.Singletons.VM.Macros)

local WASM_PAGE_SIZE = 65536

local cFunctions = LuauCeption.wasm.cfns

local threadList = {}
local threadHistory = {}
local threadStats = {}

local luauRegistry = {}
local vmStats = {
	memory = 0,
	threads = 0,
	instances = 0
}

local Debugger = {}

function Debugger.HookNamecall(_: Debugger)
	local callback
	
	callback = VMEnvironment:Hook("__namecall", function(luaState: VMTypes.LuaState)
		local methodName = VMBindings:ReadCString(cFunctions.lua_namecallatom(luaState, 0))
		local object = VMBindings:ToLuau(luaState, 1)
		
		local thread = VMBindings:GetCurrentThread(luaState)

		local scriptThread = VMScheduler:GetScriptThread(thread)
		local scriptThreadUuid = `Thread: {scriptThread}`

		local arguments = {}
		local response = {}

		for i = 2, cFunctions.lua_gettop(luaState) - 1 do
			table.insert(arguments, VMBindings:ToLuau(luaState, i))
		end

		local count = callback(luaState)
		local top = cFunctions.lua_gettop(luaState)

		for i = (top - count) + 1, top do
			table.insert(response, VMBindings:ReadCString(cFunctions.luaL_tolstring(luaState, i, 0)))
			VMMacros.lua_pop(luaState, 1)
		end

		threadStats[scriptThreadUuid].methodCallCount += 1
		table.insert(threadHistory[scriptThreadUuid], {
			type = "Function",
			message = `<b>{object}</b>:<b>{methodName}</b>({table.unpack(arguments)}) -> {table.unpack(response)}`,
		})

		return count
	end)
end

function Debugger.HookIndex(_: Debugger)
	local callback
	
	callback = VMEnvironment:Hook("__index", function(luaState: VMTypes.LuaState)
		local object = VMBindings:ToLuau(luaState, 1)
		local index = VMBindings:ToLuau(luaState, 2)

		local thread = VMBindings:GetCurrentThread(luaState)

		local scriptThread = VMScheduler:GetScriptThread(thread)
		local scriptThreadUuid = `Thread: {scriptThread}`

		local response = {}

		local count = callback(luaState)
		local top = cFunctions.lua_gettop(luaState)

		for i = (top - count) + 1, top do
			table.insert(response, VMBindings:ReadCString(cFunctions.luaL_tolstring(luaState, i, 0)))
			VMMacros.lua_pop(luaState, 1)
		end

		threadStats[scriptThreadUuid].indexCount += 1
		table.insert(threadHistory[scriptThreadUuid], {
			type = "Index",
			message = `<b>{object}</b>.<b>{index}</b> -> {table.unpack(response)}`,
		})

		return count
	end)
end

function Debugger.HookNewIndex(_: Debugger)
	local callback
	
	callback = VMEnvironment:Hook("__newindex", function(luaState: VMTypes.LuaState)
		local object = VMBindings:ToLuau(luaState, 1)
		local index = VMBindings:ToLuau(luaState, 2)
		local value = VMBindings:ToLuau(luaState, 3)

		local thread = VMBindings:GetCurrentThread(luaState)

		local scriptThread = VMScheduler:GetScriptThread(thread)
		local scriptThreadUuid = `Thread: {scriptThread}`

		table.insert(threadHistory[scriptThreadUuid], {
			type = "Index",
			message = `<b>{object}</b>.<b>{index}</b> = {value}`,
		})

		return callback(luaState)
	end)
end

function Debugger.PollVMStats(_: Debugger)
	local bufferData = buffer.tostring(LuauCeption.wasm.memory.data)
	local printableCount = 0

	for i = 1, #bufferData do
		local char = string.byte(bufferData, i)

		if i % 100000 == 0 then
			task.wait()
		end

		if char >= 32 and char <= 126 then
			printableCount = printableCount + 1
		end
	end

	local memoryUsage = math.round((printableCount / (LuauCeption.wasm.memory.max * WASM_PAGE_SIZE)) * 1000)

	vmStats.memory = memoryUsage / 1000
	vmStats.threads = VMContext:GetValue(`Scheduler.threadCount`)
	vmStats.instances = #Sift.Dictionary.keys(VMContext:GetValue("userdata-uuids", {}))
end

function Debugger.PollLuauRegistry(_: Debugger)
	local registryEval = VM:Eval([[
		local registry = {}

		for i, v in getreg() do
			registry[tostring(i)] = tostring(v)
		end

		return registry
	]], true)

	local newRegistry = {}

	for key, value in registryEval do
		local type = "unknown"

		if string.match(value, "function:") then
			type = "Function"
		elseif string.match(value, "table:") then
			type = "Table"
		end

		table.insert(newRegistry, {
			type = type,
			name = `{key}={value}`
		})
	end

	table.sort(luauRegistry, function(a, b)
		return a.name < b.name
	end)

	luauRegistry = newRegistry
end

function Debugger.UpdateInterface(_: Debugger)
	Interface:SetThreadHistory(threadHistory)
	Interface:SetThreadStats(threadStats)
	Interface:SetThreadList(threadList)

	Interface:SetVMStats(vmStats)
	Interface:SetLuauRegistry(luauRegistry)
end

function Debugger.OnStart(self: Debugger)
	self:HookNamecall()
	self:HookIndex()
	self:HookNewIndex()

	VMScheduler.ScriptThreadSpawned:Connect(function(thread: VMTypes.LuaThread)
		local threadUuid = `Thread: {thread}`

		table.insert(threadList, threadUuid)

		threadHistory[threadUuid] = {}
		threadStats[threadUuid] = {
			childThreadCount = 0,
			indexCount = 0,
			methodCallCount = 0,
			instanceRefCount = 0,
		}
	end)

	while true do
		task.wait(1)

		if Interface:GetSelectedPage() ~= "Debugger" then
			continue
		end

		self:PollVMStats()
		self:PollLuauRegistry()

		self:UpdateInterface()
	end
end

export type Debugger = typeof(Debugger)

return Debugger