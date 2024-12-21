--[[
	
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMEnvironment = require(Package.Client.Singletons.VM.Environment)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)

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
function VM.AddLibrary(self: VM, name: string, lib: { [string]: (luauCeption: {}, luaState: number) -> number })
	local library = {}

	for i, v in lib do
		library[i] = function(luaState: number)
			return v(LuauCeption, luaState)
		end
	end

	VMEnvironment:Implement(self.LuaState, name, library)
end

--[[
	
]]
function VM.AddGlobal(self: VM, name: string, value: (luauCeption: {}, luaState: number) -> number)
	VMMacros.lua_pushcfunction(self.LuaState, VMBindings:LoadCFunction(self.LuaState, function(luaState)
		return value(LuauCeption, luaState)
	end), VMBindings:LoadCString(name))

	VMMacros.lua_setglobal(self.LuaState, VMBindings:LoadCString(name))
end

--[[
	
]]
function VM.HookMetamethod(self: VM, metamethod: string, caller: (luauCeption: {}, luaState: number) -> number)
	return VMEnvironment:Hook(metamethod, function()
		return caller(LuauCeption, self.LuaState)
	end)
end

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
	local thread = VMScheduler:Spawn(self.LuaState, true)

	VMMacros.lua_pop(self.LuaState, 1)
	cFunctions.lua_xmove(self.LuaState, thread, 1)

	VMScheduler:Resume(thread)
	
	while VMScheduler:Active(thread) do
		task.wait(0.5)
	end

	local results = cFunctions.lua_gettop(thread)
	local response = {}

	for i = 1, results do
		table.insert(response, VMBindings:ToLuau(thread, i))
	end

	VMScheduler:Close(thread)

	return table.unpack(response)
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
end

export type VM = typeof(VM)
export type LuauCeption = typeof(LuauCeption)

return VM