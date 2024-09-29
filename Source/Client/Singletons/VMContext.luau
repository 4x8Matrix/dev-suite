--[[
	VM Context, when broken down is relatively simple, it's main job is to track instances, userdatas and objects
	used in various Luau VMs then build a sophisticated map as required by those Luau VMs.

	Example, Luau VM requires `game`, ok, well we give them `game`, but as an proxy - they don't get the game object
	they get a middleman, something that bridges the gap between Roblox <-> Luau.
		(Technically i'm forced to do this anyway, because we're using a LuauVM and C won't just "understand" what
		'game' is)
]]

local Package = script.Parent.Parent.Parent

local VMBindings = require(Package.Client.Singletons.VMBindings)

local stateMap: { [VMBindings.LuaState]: ContextMap } = {}
local sharedContext = table.freeze({
	Values = {},
	Proxies = {}
})

local VMContext = {}

--[[
	Set a value for this specific LuaState. 
]]
function VMContext.SetValue(self: VMContext, luaState: VMBindings.LuaState, valueName: string, value: any, isGlobal: boolean?)
	local context = self:GetContext(luaState)

	if isGlobal then
		context.GlobalValues[valueName] = value
	else
		context.Values[valueName] = value
	end
end

--[[
	Get a value for this specific LuaState. 
]]
function VMContext.GetValue(self: VMContext, luaState: VMBindings.LuaState, valueName: string, isGlobal: boolean?)
	local context = self:GetContext(luaState)

	return isGlobal and context.GlobalValues[valueName] or context.Values[valueName]
end

--[[
	Get the context surroinding the Luau VM
]]
function VMContext.GetContext(_: VMContext, luaState: VMBindings.LuaState)
	return stateMap[luaState]
end

function VMContext.NewContext(_: VMContext, luaState: VMBindings.LuaState)
	stateMap[luaState] = table.freeze({
		Values = {},
		GlobalValues = sharedContext.Values,

		Proxies = {},
		GlobalProxies = sharedContext.Proxies
	})
end

function VMContext.DestroyContext(_: VMContext, luaState: VMBindings.LuaState)
	stateMap[luaState] = nil
end

export type ContextMap = {
	Values: { [string]: any },
	GlobalValues: { [string]: any },

	Proxies: { [any]: any, },
	GlobalProxies: { [string]: any },
}

export type VMContext = typeof(VMContext)

return VMContext