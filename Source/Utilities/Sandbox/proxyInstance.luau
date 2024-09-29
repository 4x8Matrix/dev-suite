
local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VMBindings)
local VMMacros = require(Package.Client.Singletons.VMMacros)

local cFunctions = LuauCeption.wasm.cfns

local function writeMetaMethod(luaState: VMBindings.LuaState, metamethod: string, callback: (luaState: VMBindings.LuaState) -> ())
	VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function()
		return callback(luaState)
	end))

	cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString(metamethod))
end

local function writeMetaProperty(luaState: VMBindings.LuaState, metamethod: string, value: string)
	cFunctions.lua_pushstring(luaState, VMBindings:LoadCString(value))
	cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString(metamethod))
end

return function(luaState: VMBindings.LuaState, instance: Instance, deallocator: () -> ()?)
	local userdataName = VMBindings:LoadCString(tostring(instance))
	local userdataPointer
	
	userdataPointer = cFunctions.lua_newuserdatadtor(luaState, 16, VMBindings:LoadCFunction(luaState, function()
		if deallocator then
			deallocator()
		end

		-- cFunctions.free(userdataPointer)
	end))

	VMMacros.lua_newtable(luaState)
	
	writeMetaProperty(luaState, "__metatable", "The metatable is locked")
	writeMetaProperty(luaState, "__type", "Instance")

	writeMetaMethod(luaState, "__tostring", function()
		cFunctions.lua_pushstring(luaState, userdataName)

		return 1
	end)

	writeMetaMethod(luaState, "__namecall", function()
		error(`NAMECALL NOT IMPLEMENTED`)

		return 0
	end)

	writeMetaMethod(luaState, "__index", function()
		error(`INDEX NOT IMPLEMENTED`)

		return 0
	end)

	writeMetaMethod(luaState, "__newindex", function()
		error(`NEWINDEX NOT IMPLEMENTED`)

		return 0
	end)

	writeMetaMethod(luaState, "__call", function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to call a Instance value`))

		return 0
	end)

	writeMetaMethod(luaState, "__iter", function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to iterate over a Instance value`))

		return 0
	end)

	writeMetaMethod(luaState, "__len", function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to get length a Instance value`))

		return 0
	end)

	writeMetaMethod(luaState, "__eq", function()
		error(`EQ NOT IMPLEMENTED`)

		return 0
	end)

	writeMetaMethod(luaState, "__add", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (add) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__sub", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (sub) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__mul", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (mul) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__div", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (div) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__idiv", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (idiv) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__mod", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (mod) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__pow", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (pow) on Instance and {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__unm", function()
		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to perform arithmetic (unm) on Instance`))

		return 0
	end)

	writeMetaMethod(luaState, "__le", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to compare Instance < {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__gt", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to compare Instance < {typeName}`))

		return 0
	end)

	writeMetaMethod(luaState, "__concat", function()
		local stringPointer = cFunctions.lua_typename(luaState, 3, 0)
		local typeName = VMBindings:ReadCString(stringPointer)

		VMBindings:Error(luaState, VMBindings:LoadCString(`attempt to concatenate Instance with {typeName}`))

		return 0
	end)

	cFunctions.lua_setmetatable(luaState, -2)
end
