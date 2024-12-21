local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMEnvironment = require(Package.Client.Singletons.VM.Environment)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local VMContext = require(Package.Client.Singletons.VM.Context)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMScheduler = require(Package.Client.Singletons.VM.Scheduler)

local cFunctions = LuauCeption.wasm.cfns

local function addFunctionRef(signal: RBXScriptSignal, connection: RBXScriptConnection, functionRef: number)
	VMContext:UpdateValue("RBXScriptSignal.functionRefs", function(refs)
		local refsTable = refs or {}

		refsTable[connection] = functionRef

		return refsTable
	end)

	VMContext:SetValue(connection, signal)
end

local function removeFunctionRef(luaState: VMTypes.LuaState, connection: RBXScriptConnection)
	VMContext:UpdateValue("RBXScriptSignal.functionRefs", function(refs)
		local refsTable = refs or {}
		local functionRef = refsTable[connection]

		if not functionRef then
			return refsTable
		end

		cFunctions.lua_unref(luaState, functionRef)
		refsTable[connection] = nil

		return refsTable
	end)

	VMContext:SetValue(connection, nil)
end

local function connect(luaState: VMTypes.LuaState, signal: RBXScriptSignal)
	local functionRef = cFunctions.lua_ref(luaState, 2)
	local connection = signal:Connect(function(...)
		local thread = VMScheduler:Spawn(luaState)

		VMMacros.lua_pop(luaState, 1)
		cFunctions.lua_rawgeti(luaState, VMConstants.LUA_REGISTRYINDEX, functionRef)
		cFunctions.lua_xmove(luaState, thread, 1)

		VMScheduler:Resume(thread, ...)

		while VMScheduler:Active(thread) do
			task.wait()
		end

		VMScheduler:Close(thread)
	end)

	VMBindings:FromLuau(luaState, connection)

	addFunctionRef(signal, connection, functionRef)

	return 1
end

local function once(luaState: VMTypes.LuaState, signal: RBXScriptSignal)
	local functionRef = cFunctions.lua_ref(luaState, 2)
	local connection
	
	connection = signal:Connect(function(...)
		local thread = VMScheduler:Spawn(luaState)

		VMMacros.lua_pop(luaState, 1)
		cFunctions.lua_rawgeti(luaState, VMConstants.LUA_REGISTRYINDEX, functionRef)
		cFunctions.lua_xmove(luaState, thread, 1)

		removeFunctionRef(luaState, connection)

		VMScheduler:Resume(luaState, ...)
	end)

	VMBindings:FromLuau(luaState, connection)
	addFunctionRef(signal, connection, functionRef)

	return 1
end

local function wait(luaState: VMTypes.LuaState, signal: RBXScriptSignal)
	signal:Once(function(...)
		VMScheduler:Resume(luaState, nil, ...)
	end)

	return VMScheduler:Yield(luaState)
end

return function()
	local __namecall
	
	__namecall = VMEnvironment:Hook("__namecall", function(luaState: VMTypes.LuaState)
		local type = VMBindings:ReadCString(cFunctions.luaL_typename(luaState, 1))
		local methodNamePointer = cFunctions.lua_namecallatom(luaState, 0)

		local methodName = VMBindings:ReadCString(methodNamePointer)
		local signal = VMBindings:ToLuau(luaState, 1)

		if type == "RBXScriptSignal" then
			if methodName == "connect" or methodName == "Connect" then
				return connect(luaState, signal)
			end

			if methodName == "Once" then
				return once(luaState, signal)
			end

			if methodName == "wait" or methodName == "Wait" then
				return wait(luaState, signal)
			end
		end

		return __namecall(luaState)
	end)
end
