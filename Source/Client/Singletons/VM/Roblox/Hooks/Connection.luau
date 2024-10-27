local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMEnvironment = require(Package.Client.Singletons.VM.Environment)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMContext = require(Package.Client.Singletons.VM.Context)

local cFunctions = LuauCeption.wasm.cfns

local function disconnect(luaState: VMTypes.LuaState, connection: RBXScriptConnection)
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

	return 0
end

return function()
	local __namecall
	
	__namecall = VMEnvironment:Hook("__namecall", function(luaState: VMTypes.LuaState)
		local type = VMBindings:ReadCString(cFunctions.luaL_typename(luaState, 1))
		local methodNamePointer = cFunctions.lua_namecallatom(luaState, 0)

		local methodName = VMBindings:ReadCString(methodNamePointer)
		local connection = VMBindings:ToLuau(luaState, 1)

		if type == "RBXScriptConnection" then
			if methodName == "Disconnect" or methodName == "disconnect" then
				disconnect(luaState, connection)
			end
		end

		return __namecall(luaState)
	end)
end
