--[[
	
]]
local contextMap = {}

local Context = {}

--[[
	Set a value for this specific LuaState. 
]]
function Context.SetValue(_: Context,  key: any, value: any)
	contextMap[key] = value
end

--[[
	Set a value for this specific LuaState. 
]]
function Context.UpdateValue(_: Context,  key: any, compute: (value: any) -> any)
	contextMap[key] = compute(contextMap[key])
end

--[[
	Get a value for this specific LuaState. 
]]
function Context.GetValue(_: Context, key: any, default: any?)
	return contextMap[key] ~= nil and contextMap[key] or default
end

export type ContextMap = { }

export type Context = typeof(Context)

return Context