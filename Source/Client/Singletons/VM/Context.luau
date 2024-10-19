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
	Get a value for this specific LuaState. 
]]
function Context.GetValue(_: Context, key: any)
	return contextMap[key]
end

export type ContextMap = { }

export type Context = typeof(Context)

return Context