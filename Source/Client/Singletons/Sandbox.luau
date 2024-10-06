--[[
	High level explanation of this Singleton is that it's job is to securely evaluate luau code on the client, with
	the environment of an emulated exploit.

	The goal is to provide an interactive luau VM that allows developers to execute "exploiter" code, in order to
	pen-test/validate that their game is secure.

	This singleton is responsible for all actions on the `Sandbox` tab in the Dev Suite UI.
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMEnvironment = require(Package.Client.Singletons.VMEnvironment)
local VMContext = require(Package.Client.Singletons.VMContext)

local Interface = require(Package.Client.Singletons.Interface)
local Logging = require(Package.Client.Singletons.Logging)

local LUAU_OPTIMISATION_LEVEL = 1
local LUAU_DEBUG_LEVEL = 1
local LUAU_COVERAGE_LEVEL = 0
local LUAU_TYPE_INFO_LEVEL = 0

local cFunctions = LuauCeption.wasm.cfns

local Sandbox = {}

--[[
	Function responsible for evaluating luau code, to summerise what it does;

	1. Loads the bytecode from the sourcecode provided, using LuauCeption as the compiler.
	2. Creates a lua state, using LuauCeption as the interpreter.
	3. calls 'luaL_openlibs' to apply standard luau libs.
	4. calls 'WriteSandboxGlobs' to apply a varaiety of globals to the sandbox.
		i. since this is just a luau vm, it doesn't have access to globals like `game` or `workspace.
			this step introduces those globals in a proxied variation.
	5. calls 'luaL_sandbox' to enable luau's sandboxing capabilities.
	6. pcalls the generated luau state, allowing the luau code to execute.
	7. returns if successful or not.
]]
function Sandbox.Eval(_: Sandbox, source: string, runtime: string)
	local bytecode = LuauCeption.luau_compile(source, LUAU_OPTIMISATION_LEVEL, LUAU_DEBUG_LEVEL, LUAU_TYPE_INFO_LEVEL, LUAU_COVERAGE_LEVEL)
	local luaState = VMBindings:LoadLuaState(bytecode)

	-- add luau libraries.
	cFunctions.luaL_openlibs(luaState)

	-- create vm context
	VMContext:NewContext(luaState)

	-- add/modify luau libraries
	VMEnvironment:WriteSandboxGlobs(luaState, runtime)

	-- sandbox luau environment
	cFunctions.luaL_sandbox(luaState)

	-- execute luau
	local callResult = cFunctions.lua_pcall(luaState, 0, 0, 0)

	if callResult ~= 0 then
		local stringPointer = cFunctions.luaL_tolstring(luaState, 1, 0)
		local errorMessage = VMBindings:ReadCString(stringPointer)

		print("error:", errorMessage)
	end

	cFunctions.lua_close(luaState)

	VMContext:DestroyContext(luaState)

	return callResult == 0
end

function Sandbox.OnStart(self: Sandbox)
	Interface.EvalClientCodeRequested:Connect(function(source: string)
		Logging:Breakpoint()
		Interface:SetSelectedPage("Logging")

		self:Eval(source, Interface:GetSelectedRuntime())
	end)
end

export type Sandbox = typeof(Sandbox)

return Sandbox