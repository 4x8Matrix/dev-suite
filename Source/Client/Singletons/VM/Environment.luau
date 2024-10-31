--# selene: allow(shadowing)

--[[
	
]]

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMBindings = require(Package.Client.Singletons.VM.Bindings)
local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMMacros = require(Package.Client.Singletons.VM.Macros)
local VMContext = require(Package.Client.Singletons.VM.Context)
local VMConstants = require(Package.Client.Singletons.VM.Constants)

local RobloxGlobals = require(Package.Client.Singletons.VM.Roblox.Globals)
local RobloxGlobalTable = require(Package.Client.Singletons.VM.Roblox.GlobalTable)
local RobloxSharedTable = require(Package.Client.Singletons.VM.Roblox.SharedTable)
local RobloxEnvironmentTable = require(Package.Client.Singletons.VM.Roblox.EnvironmentTable)

local ExploitGlobals = require(Package.Client.Singletons.VM.Exploit.Globals)
local ExploitEnvironmentTable = require(Package.Client.Singletons.VM.Exploit.EnvironmentTable)

local TaskLibrary = require(Package.Client.Singletons.VM.Roblox.Libraries.Task)

local cFunctions = LuauCeption.wasm.cfns

local Environment = {}

--[[
	
]]
function Environment.Hook(_: Environment, metamethod: string, caller: (luaState: VMTypes.LuaState) -> number)
	local metamethods = VMContext:GetValue(`metatable.methods.source`)
	local pointer = metamethods[metamethod]

	assert(pointer, `failed to hook metamethod '{metamethod}' doesn't exist!`)

	return VMBindings:OverwriteCFunction(pointer, caller)
end

--[[
	
]]
function Environment.Implement(_: Environment, luaState: VMTypes.LuaState, name: string, source: any)
	VMMacros.lua_newtable(luaState)

	for objName, callback in source do
		VMMacros.lua_pushcfunction(luaState, VMBindings:LoadCFunction(luaState, function(luaState: VMTypes.LuaState)
			local arguments = {}

			for index = 1, cFunctions.lua_gettop(luaState) do
				table.insert(arguments, VMBindings:ToLuau(luaState, index))
			end

			local results = table.pack(callback(table.unpack(arguments)))

			for index = 1, results.n do
				VMBindings:FromLuau(luaState, results[index])
			end

			return results.n
		end), VMBindings:LoadCString(objName))

		cFunctions.lua_setfield(luaState, -2, VMBindings:LoadCString(objName))
	end

	VMMacros.lua_setglobal(luaState, VMBindings:LoadCString(name))
end

--[[
	
]]
function Environment.WriteEnvironment(self: Environment, luaState: VMTypes.LuaState)
	RobloxGlobalTable(luaState)
	RobloxSharedTable(luaState)
	RobloxEnvironmentTable(luaState)

	RobloxGlobals(luaState)
	TaskLibrary(luaState)

	ExploitEnvironmentTable(luaState)
	ExploitGlobals(luaState)

	self:Implement(luaState, "Axes", Axes)
	self:Implement(luaState, "BrickColor", BrickColor)
	self:Implement(luaState, "CatalogSearchParams", CatalogSearchParams)
	self:Implement(luaState, "CFrame", CFrame)
	self:Implement(luaState, "Color3", Color3)
	self:Implement(luaState, "ColorSequence", ColorSequence)
	self:Implement(luaState, "ColorSequenceKeypoint", ColorSequenceKeypoint)
	self:Implement(luaState, "DateTime", DateTime)
	self:Implement(luaState, "Faces", Faces)
	self:Implement(luaState, "FloatCurveKey", FloatCurveKey)
	self:Implement(luaState, "Font", Font)
	self:Implement(luaState, "Instance", Instance)
	self:Implement(luaState, "NumberRange", NumberRange)
	self:Implement(luaState, "NumberSequence", NumberSequence)
	self:Implement(luaState, "NumberSequenceKeypoint", NumberSequenceKeypoint)
	self:Implement(luaState, "OverlapParams", OverlapParams)
	self:Implement(luaState, "PathWaypoint", PathWaypoint)
	self:Implement(luaState, "PhysicalProperties", PhysicalProperties)
	self:Implement(luaState, "Random", Random)
	self:Implement(luaState, "Ray", Ray)
	self:Implement(luaState, "RaycastParams", RaycastParams)
	self:Implement(luaState, "Rect", Rect)
	self:Implement(luaState, "Region3", Region3)
	self:Implement(luaState, "Region3int16", Region3int16)
	self:Implement(luaState, "RotationCurveKey", RotationCurveKey)
	self:Implement(luaState, "SharedTable", SharedTable)
	self:Implement(luaState, "TweenInfo", TweenInfo)
	self:Implement(luaState, "UDim", UDim)
	self:Implement(luaState, "UDim2", UDim2)
	self:Implement(luaState, "Vector2", Vector2)
	self:Implement(luaState, "Vector2int16", Vector2int16)
	self:Implement(luaState, "Vector3", Vector3)
	self:Implement(luaState, "Vector3int16", Vector3int16)
end

--[[
	
]]
function Environment.WriteFunctionEnvironment(_: Environment, luaState: VMTypes.LuaState)
	cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, VMBindings:LoadCString("script.exploit.environment"))

	cFunctions.lua_setfenv(luaState, -2)
end

export type Environment = typeof(Environment)

return Environment