--[[
	
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local Interface = require(Package.Client.Singletons.Interface)

local VMContext = require(Package.Client.Singletons.VM.Context)
local VMBindings = require(Package.Client.Singletons.VM.Bindings)

local RobloxEnvironment = require(Package.Client.Singletons.VM.RobloxEnvironment)
local ExploitEnvironment = require(Package.Client.Singletons.VM.ExploitEnvironment)

local LUAU_OPTIMISATION_LEVEL = 1
local LUAU_DEBUG_LEVEL = 1
local LUAU_COVERAGE_LEVEL = 0
local LUAU_TYPE_INFO_LEVEL = 0

local cFunctions = LuauCeption.wasm.cfns

local luaRuntimes = {}

local VM = {}

VM.Priority = 0

function VM.LoadFunction(_: VM, luaState: number, source: string)
	local bytecode = LuauCeption.luau_compile(source, LUAU_OPTIMISATION_LEVEL, LUAU_DEBUG_LEVEL, LUAU_TYPE_INFO_LEVEL, LUAU_COVERAGE_LEVEL)

	local bytecodePointer = VMBindings:LoadCString(bytecode)
	local chunkNamePointer = VMBindings:LoadCString("SandboxChunk")

	local loadResult = cFunctions.luau_load(luaState, chunkNamePointer, bytecodePointer, #bytecode, 0)

	cFunctions.free(bytecodePointer)
	cFunctions.free(chunkNamePointer)

	if loadResult ~= 0 then
		cFunctions.lua_close(luaState)

		error(`Failed to load Luau bytecode`)
	end
end

function VM.PCallFunction(_: VM, luaState: number)
	local callResult = cFunctions.lua_pcall(luaState, 0, 0, 0)

	if callResult ~= 0 then
		local stringPointer = cFunctions.luaL_tolstring(luaState, 1, 0)
		local errorMessage = VMBindings:ReadCString(stringPointer)

		print("error:", errorMessage)
	end

	return callResult
end

function VM.Eval(self: VM, source: string, runtime: Runtime)
	local luaState = luaRuntimes[runtime]

	self:LoadFunction(luaState, source)

	if runtime == "Exploit" then
		ExploitEnvironment:WriteFunctionEnvironment(luaState)
	elseif runtime == "Roblox" then
		RobloxEnvironment:WriteFunctionEnvironment(luaState)
	end

	local callResult = self:PCallFunction(luaState)

	return callResult == 0
end

--[[
	
]]
function VM.CreateRuntime(_: VM, runtime: Runtime)
	local luaState = cFunctions.luaL_newstate()

	-- add luau libraries.
	cFunctions.luaL_openlibs(luaState)

	VMContext:NewContext(luaState)
	
	if runtime == "Exploit" then
		ExploitEnvironment:WriteEnvironment(luaState)
	elseif runtime == "Roblox" then
		RobloxEnvironment:WriteEnvironment(luaState)
	end
		
	-- cFunctions.luaL_sandbox(luaState)

	luaRuntimes[runtime] = luaState
end

--[[
	
]]
function VM.DestroyRuntime(_: VM, runtime: Runtime)
	local luaState = luaRuntimes[runtime]

	cFunctions.lua_close(luaState)

	VMContext:DestroyContext(luaState)
end

function VM.OnStart(self: VM)
	for _, runtime in Interface:GetAllRuntimes() do
		self:CreateRuntime(runtime)
	end
end

export type VM = typeof(VM)

export type Runtime = "Roblox" | "Exploit" | "Luau"

return VM