--[[
	VM Context, when broken down is relatively simple, it's main job is to track instances, userdatas and objects
	used in various Luau VMs then build a sophisticated map as required by those Luau VMs.

	Example, Luau VM requires `game`, ok, well we give them `game`, but as an proxy - they don't get the game object
	they get a middleman, something that bridges the gap between Roblox <-> Luau.
		(Technically i'm forced to do this anyway, because we're using a LuauVM and C won't just "understand" what
		'game' is)
]]

local Package = script.Parent.Parent.Parent.Parent

local VMTypes = require(Package.Client.Singletons.VM.Types)

local stateMap: { [VMTypes.LuaState]: ContextMap } = {}

local Context = {}

--[[
	Set a value for this specific LuaState. 
]]
function Context.SetValue(_: Context, luaState: VMTypes.LuaState, key: any, value: any)
	stateMap[luaState][key] = value
end

--[[
	Get a value for this specific LuaState. 
]]
function Context.GetValue(_: Context, luaState: VMTypes.LuaState, key: any)
	return stateMap[luaState][key]
end

function Context.NewContext(_: Context, luaState: VMTypes.LuaState)
	stateMap[luaState] = { }
end

function Context.DestroyContext(_: Context, luaState: VMTypes.LuaState)
	stateMap[luaState] = nil
end

export type ContextMap = { }

export type Context = typeof(Context)

return Context