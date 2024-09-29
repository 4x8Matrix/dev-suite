--[[
	VMBindings provide utilities, or helpful functions for manipulating the Luau VM, from things such as reading/writing C
	strings, to creating CFunctions that act as functions we can define in Luau.

	It's also responsible for the creation of the Lua State.
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local runtime = LuauCeption.wasm.rt
local store = runtime.store

local cFunctions = LuauCeption.wasm.cfns

local VMBindings = {}

--[[
	Responsible for loading a luau string, into the wasm llvm, will return a pointer.
]]
function VMBindings.LoadCString(_: VMBindings, source: string): Pointer
	local stringLength = #source
    local stringPointer = cFunctions.malloc(stringLength + 1)

	store.string(LuauCeption.wasm.memory, stringPointer, source)
	store.i32_n8(LuauCeption.wasm.memory, stringPointer + stringLength, 0)

    return stringPointer
end

--[[
	Responsible for reading from a pointer, and returning the luau string at that offset.
]]
function VMBindings.ReadCString(_: VMBindings, pointer: Pointer): string
	local stringLength = cFunctions.strlen(pointer)

	return buffer.readstring(LuauCeption.wasm.memory.data, pointer, stringLength)
end

--[[
	Responsible for wrapping a C function as a luau function, allowing you to create C functions in the Luau VM.
]]
function VMBindings.LoadCFunction(_: VMBindings, luaState: LuaState, source: (state: LuaState, currentIndex: number) -> ()): Pointer
	local pointer = #LuauCeption.wasm.indirect_function_table.data + 1

	LuauCeption.wasm.indirect_function_table.data[pointer] = function(currentIndex: number)
		local result = source(luaState, currentIndex)

		return result
	end

	return pointer
end

--[[
	Instantiate a Lua State.
]]
function VMBindings.LoadLuaState(self: VMBindings, bytecode: string): LuaState
	local bytecodePointer = self:LoadCString(bytecode)
	local chunkNamePointer = self:LoadCString("SandboxChunk")

	local luaState = cFunctions.luaL_newstate()

	local loadResult = cFunctions.luau_load(luaState, chunkNamePointer, bytecodePointer, #bytecode, 0)

	cFunctions.free(bytecodePointer)
	cFunctions.free(chunkNamePointer)

	if loadResult == 0 then
		return luaState
	else
		cFunctions.lua_close(luaState)

		error(`Failed to load Luau bytecode`)
	end
end

--[[
	Errors the Luau VM
]]
function VMBindings.Error(_: VMBindings, luaState: LuaState, errorPointer: Pointer)
	cFunctions.lua_pushstring(luaState, errorPointer)
	cFunctions.lua_error(luaState)
end

export type LuaState = number
export type Pointer = number

export type VMBindings = typeof(VMBindings)

return VMBindings