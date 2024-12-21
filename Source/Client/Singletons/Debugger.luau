--[[
	Debugger
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local Sift = require(Package.Parent.Sift)

local Interface = require(Package.Client.Singletons.Interface)

local VM = require(Package.Client.Singletons.VM)

local VMContext = require(Package.Client.Singletons.VM.Context)

local WASM_PAGE_SIZE = 65536

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
	]])

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
	Interface:SetThreadList(threadList)
	Interface:SetThreadHistory(threadHistory)
	Interface:SetThreadStats(threadStats)

	Interface:SetVMStats(vmStats)
	Interface:SetLuauRegistry(luauRegistry)
end

function Debugger.OnStart(self: Debugger)
	-- VMScheduler

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