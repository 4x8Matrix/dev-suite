--[[
	
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMEnvironment = require(Package.Client.Singletons.VM.Environment)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)
local VMContext = require(Package.Client.Singletons.VM.Context)

local SignalHook = require(Package.Client.Singletons.VM.Roblox.Hooks.Signal)
local ConnectionHook = require(Package.Client.Singletons.VM.Roblox.Hooks.Connection)

local CoreGuiHook = require(Package.Client.Singletons.VM.Exploit.Hooks.CoreGui)


local LUAU_OPTIMISATION_LEVEL = 1
local LUAU_DEBUG_LEVEL = 1
local LUAU_COVERAGE_LEVEL = 0
local LUAU_TYPE_INFO_LEVEL = 0

local cFunctions = LuauCeption.wasm.cfns

local VM = {}

VM.Priority = 0
VM.LuaState = nil

--[[
	
]]
function VM.Load(self: VM, source: string)
	local bytecode = LuauCeption.luau_compile(source, LUAU_OPTIMISATION_LEVEL, LUAU_DEBUG_LEVEL, LUAU_TYPE_INFO_LEVEL, LUAU_COVERAGE_LEVEL)

	local bytecodePointer = VMBindings:LoadCString(bytecode)
	local chunkNamePointer = VMBindings:LoadCString("SandboxChunk")

	local loadResult = cFunctions.luau_load(self.LuaState, chunkNamePointer, bytecodePointer, #bytecode, 0)

	cFunctions.free(bytecodePointer)
	cFunctions.free(chunkNamePointer)

	if loadResult ~= 0 then
		cFunctions.lua_close(self.LuaState)

		error(`Failed to load Luau bytecode`)
	end
end

--[[
	
]]
function VM.Run(self: VM)
	local thread = VMScheduler:Create(self.LuaState)

	VMMacros.lua_pop(self.LuaState, 1)
	cFunctions.lua_xmove(self.LuaState, thread, 1)

	VMScheduler:AddFunctionToQueue(function()
		VMScheduler:Resume(thread, self.LuaState)

		local status = VMScheduler:Status(thread, self.LuaState)

		while status == "running" do
			task.wait()
		end
	end)
end

--[[
	
]]
function VM.Eval(self: VM, source: string)
	self:Load(source)

	VMEnvironment:WriteFunctionEnvironment(self.LuaState)

	return self:Run()
end

function VM.OnStart(self: VM)
	self.LuaState = cFunctions.luaL_newstate()

	cFunctions.luaL_openlibs(self.LuaState)
	VMEnvironment:WriteEnvironment(self.LuaState)
	-- cFunctions.luaL_sandbox(luaState)

	SignalHook()
	ConnectionHook()
	CoreGuiHook()

	VMScheduler:StartScheduler()
	VMScheduler:SetErrorHandler(function(_, message)
		warn(`Thread Error:`, message)
	end)
end

export type VM = typeof(VM)

return VM