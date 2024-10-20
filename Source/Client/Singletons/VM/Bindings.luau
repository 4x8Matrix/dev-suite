--# selene: allow(shadowing)

--[[
	Bindings provide utilities, or helpful functions for manipulating the Luau VM, from things such as reading/writing C
	strings, to creating CFunctions that act as functions we can define in Luau.

	It's also responsible for the creation of the Lua State.
]]

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMContext = require(Package.Client.Singletons.VM.Context)
local Types = require(Package.Client.Singletons.VM.Types)

local runtime = LuauCeption.wasm.rt
local store = runtime.store

local cFunctions = LuauCeption.wasm.cfns

local uuidCounter = 0

local Bindings = {}

--[[
	
]]
function Bindings.DebugStack(self: Bindings, luaState: Types.LuaState)
	local stackSize = cFunctions.lua_gettop(luaState)
	local cappedStackSize = math.clamp(stackSize, 1, 50)

	print(`STACK SIZE: {stackSize}\n{string.rep("-", 50)}{cappedStackSize < stackSize and "+" or ""}`)

	for index = 1, cappedStackSize do
		local type = self:ReadCString(cFunctions.luaL_typename(luaState, index))
		local value = self:ToLuau(luaState, index)

		print(`{index} - {type} - {value}`)
	end
end

--[[
	Responsible for loading a luau string, into the wasm llvm, will return a pointer.
]]
function Bindings.LoadCString(_: Bindings, source: string): Types.CPointer
	local stringLength = #source
    local stringPointer = cFunctions.malloc(stringLength + 1)

	store.string(LuauCeption.wasm.memory, stringPointer, source)
	store.i32_n8(LuauCeption.wasm.memory, stringPointer + stringLength, 0)

    return stringPointer
end

--[[
	Responsible for reading from a pointer, and returning the luau string at that offset.
]]
function Bindings.ReadCString(_: Bindings, pointer: Types.CPointer): string
	local stringLength = cFunctions.strlen(pointer)

	return buffer.readstring(LuauCeption.wasm.memory.data, pointer, stringLength)
end

--[[
	Responsible for wrapping a C function as a luau function, allowing you to create C functions in the Luau VM.
]]
function Bindings.LoadCFunction(self: Bindings, luaState: Types.LuaState, source: (state: Types.LuaState, currentIndex: number) -> ()): Types.CPointer
	local pointer = #LuauCeption.wasm.indirect_function_table.data + 1

	LuauCeption.wasm.indirect_function_table.data[pointer] = function(...)
		local status, result = pcall(source, ...)

		if not status then
			warn(result)
			self:Error(luaState, self:LoadCString(result))

			return 0
		end

		return result
	end

	return pointer
end

--[[
	Pops an instance, in the Roblox engine onto the top of the Luau VMs stack
]]
function Bindings.LoadInstance(self: Bindings, luaState: Types.LuaState, instance: any, deallocator: () -> ()?)
	cFunctions.lua_newuserdatadtor(luaState, 1, self:LoadCFunction(luaState, function()
		if deallocator then
			deallocator()
		end
	end))

	VMMacros.lua_newtable(luaState)

	cFunctions.lua_pushstring(luaState, self:LoadCString("The metatable is locked"))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__metatable"))

	cFunctions.lua_pushstring(luaState, self:LoadCString("Instance"))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__type"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		local methodNamePointer = cFunctions.lua_namecallatom(luaState, 0)
		local methodName = self:ReadCString(methodNamePointer)

		local arguments = {}

		for index = 1, cFunctions.lua_gettop(luaState) do
			table.insert(arguments, self:ToLuau(luaState, index))
		end

		local method = instance[methodName]
		local response = table.pack(method(instance, table.unpack(arguments)))
		local responseCount = table.maxn(response)

		if responseCount ~= 0 then
			for index = 1, responseCount do
				self:FromLuau(luaState, response[index])
			end

			return responseCount
		else
			return 0
		end
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__namecall"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		local indexPointer = VMMacros.lua_tostring(luaState, 2)
		local index = self:ReadCString(indexPointer)

		local object = instance[index]

		self:FromLuau(luaState, object)

		return 1
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__index"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		local indexPointer = VMMacros.lua_tostring(luaState, 2)
		local index = self:ReadCString(indexPointer)

		local value = self:ToLuau(luaState, 3)

		instance[index] = value

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__newindex"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		local arguments = {}

		for index = 1, cFunctions.lua_gettop(luaState) do
			table.insert(arguments, self:ToLuau(luaState, index))
		end

		local response = table.pack(instance(table.unpack(arguments)))

		if #response ~= 0 then
			for _, objectToReturn in response do
				self:FromLuau(luaState, objectToReturn)
			end

			return table.maxn(response)
		else
			return 0
		end
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__call"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__concat"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__unm"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__add"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__sub"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__mul"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__div"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__idiv"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__mod"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__pow"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		cFunctions.lua_pushstring(luaState, self:LoadCString(tostring(instance)))

		return 1
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__tostring"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__eq"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__lt"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__le"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__len"))

	VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, function(luaState)
		self:Error(luaState, self:LoadCString(`NOT_IMPLEMENTED`))

		return 0
	end))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__iter"))

	cFunctions.lua_pushstring(luaState, self:LoadCString(`{uuidCounter}`))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__uuid"))

	VMContext:SetValue(`userdata-{uuidCounter}`, instance)

	uuidCounter += 1

	cFunctions.lua_setmetatable(luaState, -2)
end

--[[
	Pulls the last object on the VM's lua stack, and translates it from the C datatype into a value
	we can use in luau.
]]
function Bindings.ToLuau<T>(self: Bindings, luaState: Types.LuaState, position: number): T
	local typeNamePointer = cFunctions.luaL_typename(luaState, position)
	local typeName = self:ReadCString(typeNamePointer)

	if typeName == "number" then
		local number = VMMacros.lua_tonumber(luaState, position)

		return number :: any
	elseif typeName == "string" then
		local stringPointer = VMMacros.lua_tostring(luaState, position)
		local string = self:ReadCString(stringPointer)

		return string :: any
	elseif typeName == "Instance" then
		cFunctions.lua_getmetatable(luaState, position)
		cFunctions.lua_getfield(luaState, -1, self:LoadCString("__uuid"))

		local instanceUuidPointer = VMMacros.lua_tostring(luaState, position + 2)
		local instanceUuid = self:ReadCString(instanceUuidPointer)

		return VMContext:GetValue(`userdata-{instanceUuid}`) :: any
	elseif typeName == "table" then
		local content = {}

		cFunctions.lua_pushnil(luaState)

		while cFunctions.lua_next(luaState, position) ~= 0 do
			local key = self:ToLuau(luaState, -2)
			local value = self:ToLuau(luaState, -1)

			content[key] = value

			VMMacros.lua_pop(luaState, 1)
		end

		return content :: any
	elseif typeName == "nil" then
		return nil :: any
	elseif typeName == "boolean" then
		local boolValue = cFunctions.lua_toboolean(luaState, position)

		return (boolValue == 1 and true or false) :: any
	elseif typeName == "function" or typeName == "thread" then
		local functionName = VMMacros.lua_tostring(luaState, position)

		return Bindings:ReadCString(functionName) :: any
	elseif typeName == "no value" then
		return nil :: any
	else
		error(`critical: cannot convert {typeName} to value`)
	end
end

--[[
	Pops a value from luau, into any c datatype, and pushes it onto the top of the lua stack.
]]
function Bindings.FromLuau(self: Bindings, luaState: Types.LuaState, value: any): ()
	local valueType = typeof(value)

	if valueType == "number" then
		cFunctions.lua_pushnumber(luaState, value)
	elseif valueType == "string" then
		cFunctions.lua_pushstring(luaState, self:LoadCString(value :: any))
	elseif valueType == "boolean" then
		cFunctions.lua_pushboolean(luaState, value and 1 or 0)
	elseif valueType == "Instance" then
		self:LoadInstance(luaState, value)
	elseif valueType == "table" then
		VMMacros.lua_newtable(luaState)

		for key, object in value :: any do
			Bindings.FromLuau(self, luaState, key)
			Bindings.FromLuau(self, luaState, object)

			cFunctions.lua_settable(luaState, -3)
		end
	else
		error(`critical: cannot push value of type {valueType}`)
	end
end

--[[
	Errors the Luau VM
]]
function Bindings.Error(_: Bindings, luaState: Types.LuaState, errorPointer: Types.CPointer)
	cFunctions.lua_pushstring(luaState, errorPointer)
	cFunctions.lua_error(luaState)
end

export type Bindings = typeof(Bindings)

return Bindings