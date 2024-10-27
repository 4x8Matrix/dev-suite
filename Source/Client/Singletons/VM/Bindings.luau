--# selene: allow(shadowing)

--[[
	Bindings provide utilities, or helpful functions for manipulating the Luau VM, from things such as reading/writing C
	strings, to creating CFunctions that act as functions we can define in Luau.

	It's also responsible for the creation of the Lua State.
]]

local Package = script.Parent.Parent.Parent.Parent

local Macros = require(script.Parent.Macros)
local LuauCeption = require(Package.Vendor.LuauCeption)

local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMContext = require(Package.Client.Singletons.VM.Context)
local VMConstants = require(Package.Client.Singletons.VM.Constants)
local Types = require(Package.Client.Singletons.VM.Types)

local runtime = LuauCeption.wasm.rt
local store = runtime.store

local cFunctions = LuauCeption.wasm.cfns

local uuidCounter = 0

local Bindings = {}

--[[
	
]]
function Bindings.DebugStack(self: Bindings, luaState: Types.LuaState, dontToLuau: boolean?)
	local stackSize = cFunctions.lua_gettop(luaState)
	local cappedStackSize = math.clamp(stackSize, 1, 50)

	warn(string.rep(`-`, 50))
	warn(string.rep(`-`, 50))
	print(`STACK SIZE: {stackSize}`)

	for index = 1, cappedStackSize do
		local type = self:ReadCString(cFunctions.luaL_typename(luaState, index))
		local value = "<no 'toLuau'!>"

		if not dontToLuau then
			value = self:ToLuau(luaState, index)
		end
		

		print(`{index} - {type} - {value}`)
	end

	warn(string.rep(`-`, 50))
	warn(string.rep(`-`, 50))
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
function Bindings.LoadCFunction(self: Bindings, luaState: Types.LuaState, source: (Types.LuaState) -> number): Types.CPointer
	local pointer = #LuauCeption.wasm.indirect_function_table.data + 1

	LuauCeption.wasm.indirect_function_table.data[pointer] = function(...)
		local status, result = pcall(source, ...)

		if not status then
			self:Error(luaState, self:LoadCString(result))

			return 0
		end

		return result
	end

	return pointer
end

--[[
	
]]
function Bindings.OverwriteCFunction(_: Bindings, cPointer: Types.CPointer, source: (Types.LuaState) -> number)
	local oldSource = LuauCeption.wasm.indirect_function_table.data[cPointer]
	
	LuauCeption.wasm.indirect_function_table.data[cPointer] = source

	return oldSource
end

--[[
	Pops an instance, in the Roblox engine onto the top of the Luau VMs stack
]]
function Bindings.LoadInstance(self: Bindings, luaState: Types.LuaState, instance: any, deallocator: () -> ()?)
	local instanceTable = VMContext:GetValue(`instance.source`, {})
	local instanceRef = instanceTable[instance]

	if instanceRef then
		cFunctions.lua_rawgeti(luaState, VMConstants.LUA_REGISTRYINDEX, instanceRef)

		return
	end

	cFunctions.lua_newuserdatadtor(luaState, 16, self:LoadCFunction(luaState, function()
		cFunctions.lua_unref(luaState, instanceRef) -- set a few lines down!

		instanceTable[instance] = nil
		
		if deallocator then
			deallocator()
		end
	end))

	VMMacros.lua_newtable(luaState)

	local metamethods = VMContext:GetValue(`metatable.methods.source`)

	if not metamethods then
		local notImplemented = function(method)
			self:LoadCFunction(luaState, function(luaState)
				self:Error(luaState, self:LoadCString(`'{method}' - NOT_IMPLEMENTED`))
		
				return 0
			end)
		end

		local metatableSource = {
			__namecall = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)

				local methodNamePointer = cFunctions.lua_namecallatom(luaState, 0)
				local methodName = self:ReadCString(methodNamePointer)
		
				local arguments = {}
		
				for index = 2, cFunctions.lua_gettop(luaState) do
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
			end),
			__index = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)

				local indexPointer = VMMacros.lua_tostring(luaState, 2)
				local index = self:ReadCString(indexPointer)
		
				local object = instance[index]

				self:FromLuau(luaState, object)

				return 1
			end),
			__newindex = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)

				local indexPointer = VMMacros.lua_tostring(luaState, 2)
				local index = self:ReadCString(indexPointer)
		
				local value = self:ToLuau(luaState, 3)
		
				instance[index] = value
		
				return 0
			end),
			__call = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
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
			end),
			__tostring = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)

				cFunctions.lua_pushstring(luaState, self:LoadCString(tostring(instance)))

				return 1
			end),
			__eq = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local target = self:ToLuau(luaState, 2)

				cFunctions.lua_pushboolean(luaState, instance == target)

				return 1
			end),
			__concat = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance .. object)

				return 1
			end),
			__unm = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)

				self:FromLuau(luaState, -instance)

				return 1
			end),
			__add = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance + object)

				return 1
			end),
			__sub = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance - object)

				return 1
			end),
			__mul = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance * object)

				return 1
			end),
			__div = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance / object)

				return 1
			end),
			__idiv = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance // object)

				return 1
			end),
			__mod = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance % object)

				return 1
			end),
			__pow = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance ^ object)

				return 1
			end),
			__lt = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance < object)

				return 1
			end),
			__le = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)
				local object = self:ToLuau(luaState, 2)

				self:FromLuau(luaState, instance <= object)

				return 1
			end),
			__len = self:LoadCFunction(luaState, function(luaState)
				local instance = self:ToLuau(luaState, 1)

				self:FromLuau(luaState, #instance)

				return 1
			end),
			__iter = notImplemented("__iter"),
   
		}

		VMContext:SetValue(`metatable.methods.source`, metatableSource)
		
		metamethods = metatableSource
	end

	for metamethod, pointer in metamethods do
		VMMacros.lua_pushcfunction(luaState, pointer)
		cFunctions.lua_setfield(luaState, -2, self:LoadCString(metamethod))
	end

	cFunctions.lua_pushstring(luaState, self:LoadCString("The metatable is locked"))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__metatable"))

	cFunctions.lua_pushstring(luaState, self:LoadCString(typeof(instance)))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__type"))

	cFunctions.lua_pushstring(luaState, self:LoadCString(`{uuidCounter}`))
	cFunctions.lua_setfield(luaState, -2, self:LoadCString("__uuid"))

	VMContext:SetValue(`userdata-{uuidCounter}`, instance)

	uuidCounter += 1

	cFunctions.lua_setmetatable(luaState, -2)
	
	instanceRef = cFunctions.lua_ref(luaState, cFunctions.lua_gettop(luaState))
	instanceTable[instance] = instanceRef

	VMContext:SetValue(`instance.source`, instanceTable)
end

--[[
	Pulls the last object on the VM's lua stack, and translates it from the C datatype into a value
	we can use in luau.
]]
function Bindings.ToLuau<T>(self: Bindings, luaState: Types.LuaState, position: number): T
	local typeNamePointer = cFunctions.luaL_typename(luaState, position)
	local typeName = self:ReadCString(typeNamePointer)
	
	local top = cFunctions.lua_gettop(luaState)

	if typeName == "number" then
		local number = VMMacros.lua_tonumber(luaState, position)

		return number :: any
	elseif typeName == "string" then
		local stringPointer = VMMacros.lua_tostring(luaState, position)
		local string = self:ReadCString(stringPointer)

		return string :: any
	elseif 
		typeName == "Instance"
		or typeName == "RBXScriptSignal"
		or typeName == "RBXScriptConnection"
		or typeName == "Axes"
		or typeName == "BrickColor"
		or typeName == "CatalogSearchParams"
		or typeName == "CFrame"
		or typeName == "Color3"
		or typeName == "ColorSequence"
		or typeName == "ColorSequenceKeypoint"
		or typeName == "Content"
		or typeName == "DateTime"
		or typeName == "DockWidgetPluginGuiInfo"
		or typeName == "Enum"
		or typeName == "EnumItem"
		or typeName == "Enums"
		or typeName == "Faces"
		or typeName == "FloatCurveKey"
		or typeName == "Font"
		or typeName == "NumberRange"
		or typeName == "NumberSequence"
		or typeName == "NumberSequenceKeypoint"
		or typeName == "OverlapParams"
		or typeName == "Path2DControlPoint"
		or typeName == "PathWaypoint"
		or typeName == "PhysicalProperties"
		or typeName == "Random"
		or typeName == "Ray"
		or typeName == "RaycastParams"
		or typeName == "RaycastResult"
		or typeName == "RBXScriptConnection"
		or typeName == "RBXScriptSignal"
		or typeName == "Rect"
		or typeName == "Region3"
		or typeName == "Region3int16"
		or typeName == "RotationCurveKey"
		or typeName == "Secret"
		or typeName == "SharedTable"
		or typeName == "TweenInfo"
		or typeName == "UDim"
		or typeName == "UDim2"
		or typeName == "Vector2"
		or typeName == "Vector2int16"
		or typeName == "Vector3"
		or typeName == "Vector3int16"
	then
		cFunctions.lua_getmetatable(luaState, position)
		cFunctions.lua_getfield(luaState, top + 1, self:LoadCString("__uuid"))

		local instanceUuidPointer = VMMacros.lua_tostring(luaState, top + 2)
		local instanceUuid = self:ReadCString(instanceUuidPointer)

		Macros.lua_pop(luaState, 1)
		Macros.lua_pop(luaState, 1)

		return VMContext:GetValue(`userdata-{instanceUuid}`) :: any
	elseif typeName == "userdata" then
		local userdataName = VMMacros.lua_tostring(luaState, position)

		return Bindings:ReadCString(userdataName) :: any
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
	elseif valueType == "function" then
		VMMacros.lua_pushcfunction(luaState, self:LoadCFunction(luaState, value), self:LoadCString(debug.info(value, "n")))
	elseif
		valueType == "Instance"
		or valueType == "RBXScriptSignal"
		or valueType == "RBXScriptConnection"
		or valueType == "Axes"
		or valueType == "BrickColor"
		or valueType == "CatalogSearchParams"
		or valueType == "CFrame"
		or valueType == "Color3"
		or valueType == "ColorSequence"
		or valueType == "ColorSequenceKeypoint"
		or valueType == "Content"
		or valueType == "DateTime"
		or valueType == "DockWidgetPluginGuiInfo"
		or valueType == "Enum"
		or valueType == "EnumItem"
		or valueType == "Enums"
		or valueType == "Faces"
		or valueType == "FloatCurveKey"
		or valueType == "Font"
		or valueType == "NumberRange"
		or valueType == "NumberSequence"
		or valueType == "NumberSequenceKeypoint"
		or valueType == "OverlapParams"
		or valueType == "Path2DControlPoint"
		or valueType == "PathWaypoint"
		or valueType == "PhysicalProperties"
		or valueType == "Random"
		or valueType == "Ray"
		or valueType == "RaycastParams"
		or valueType == "RaycastResult"
		or valueType == "RBXScriptConnection"
		or valueType == "RBXScriptSignal"
		or valueType == "Rect"
		or valueType == "Region3"
		or valueType == "Region3int16"
		or valueType == "RotationCurveKey"
		or valueType == "Secret"
		or valueType == "SharedTable"
		or valueType == "TweenInfo"
		or valueType == "UDim"
		or valueType == "UDim2"
		or valueType == "Vector2"
		or valueType == "Vector2int16"
		or valueType == "Vector3"
		or valueType == "Vector3int16"
	then
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