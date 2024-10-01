--[[
	VMMacros is more embedded into the Luau VM, and some understanding of the Luau repository, it essentially
	just implements the C++ macros that make life a little bit easier.
]]

local Package = script.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)
local VMBindings = require(Package.Client.Singletons.VMBindings)

local LUAI_MAXCSTACK = 8000
local LUAU_GLOBALSINDEX = -LUAI_MAXCSTACK - 2002

local cFunctions = LuauCeption.wasm.cfns

local VMMacros = {}

-- #define lua_tonumber(luaState, i) lua_tonumberx(luaState, i, NULL)
function VMMacros.lua_tonumber(luaState: VMBindings.LuaState, i: number)
	return cFunctions.lua_tonumberx(luaState, i)
end

-- #define lua_upvalueindex(i) (LUA_GLOBALSINDEX - (i))
function VMMacros.lua_upvalueindex(i: number)
	return LUAU_GLOBALSINDEX - i
end

-- #define lua_tointeger(luaState, i) lua_tointegerx(luaState, i, NULL)
function VMMacros.lua_tointeger(luaState: VMBindings.LuaState, i: number)
	return cFunctions.lua_tointegerx(luaState, i)
end

-- #define lua_tounsigned(luaState, i) lua_tounsignedx(luaState, i, NULL)
function VMMacros.lua_tounsigned(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_pop(luaState, n) lua_settop(luaState, -(n)-1)
function VMMacros.lua_pop(luaState: VMBindings.LuaState, n: number)
	return cFunctions.lua_settop(luaState, -n - 1)
end

-- #define lua_newtable(luaState) lua_createtable(luaState, 0, 0)
function VMMacros.lua_newtable(luaState: VMBindings.LuaState)
	return cFunctions.lua_createtable(luaState, 0, 0)
end

-- #define lua_newuserdata(luaState, s) lua_newuserdatatagged(luaState, s, 0)
function VMMacros.lua_newuserdata(luaState: VMBindings.LuaState, s: number)
	return cFunctions.lua_newuserdatatagged(luaState, s, 0)
end

-- #define lua_strlen(luaState, i) lua_objlen(luaState, (i))
function VMMacros.lua_strlen(luaState: VMBindings.LuaState, i: number)
	return cFunctions.lua_objlen(luaState, i)
end

-- #define lua_isfunction(L, n) (lua_type(L, (n)) == LUA_TFUNCTION)
function VMMacros.lua_isfunction(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_istable(L, n) (lua_type(L, (n)) == LUA_TTABLE)
function VMMacros.lua_istable(_: VMBindings.LuaState)
	-- idk 
end

-- #define lua_islightuserdata(L, n) (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
function VMMacros.lua_islightuserdata(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_isnil(L, n) (lua_type(L, (n)) == LUA_TNIL)
function VMMacros.lua_isnil(_: VMBindings.LuaState)
	-- idk 
end

-- #define lua_isboolean(L, n) (lua_type(L, (n)) == LUA_TBOOLEAN)
function VMMacros.lua_isboolean(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_isvector(L, n) (lua_type(L, (n)) == LUA_TVECTOR)
function VMMacros.lua_isvector(_: VMBindings.LuaState)
	-- idk 
end

-- #define lua_isthread(L, n) (lua_type(L, (n)) == LUA_TTHREAD)
function VMMacros.lua_isthread(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_isbuffer(L, n) (lua_type(L, (n)) == LUA_TBUFFER)
function VMMacros.lua_isbuffer(_: VMBindings.LuaState)
	-- idk 
end

-- #define lua_isnone(L, n) (lua_type(L, (n)) == LUA_TNONE)
function VMMacros.lua_isnone(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_isnoneornil(L, n) (lua_type(L, (n)) <= LUA_TNIL)
function VMMacros.lua_isnoneornil(_: VMBindings.LuaState)
	-- idk 
end

-- #define lua_pushliteral(L, s) lua_pushlstring(L, "" s, (sizeof(s) / sizeof(char)) - 1)
function VMMacros.lua_pushliteral(_: VMBindings.LuaState)
	-- idk
end

-- #define lua_pushcfunction(L, fn, debugname) lua_pushcclosurek(L, fn, debugname, 0, NULL)
function VMMacros.lua_pushcfunction(luaState: VMBindings.LuaState, fn: number, debugname: number?)
	return cFunctions.lua_pushcclosurek(luaState, fn, debugname or 0, 0, 0)
end

-- #define lua_pushcclosure(L, fn, debugname, nup) lua_pushcclosurek(L, fn, debugname, nup, NULL)
function VMMacros.lua_pushcclosure(luaState: VMBindings.LuaState, fn: number, nup: number)
	cFunctions.lua_pushcclosurek(luaState, fn, 0, nup, 0)
end

-- #define lua_pushlightuserdata(L, p) lua_pushlightuserdatatagged(L, p, 0)
function VMMacros.lua_pushlightuserdata(_: VMBindings.LuaState)
	-- idk 
end

-- #define lua_setglobal(L, s) lua_setfield(L, LUA_GLOBALSINDEX, (s))
function VMMacros.lua_setglobal(luaState: VMBindings.LuaState, s: number)
	return cFunctions.lua_setfield(luaState, LUAU_GLOBALSINDEX, s)
end

-- #define lua_getglobal(L, s) lua_getfield(L, LUA_GLOBALSINDEX, (s))
function VMMacros.lua_getglobal(luaState: VMBindings.LuaState, s: number)
	return cFunctions.lua_getfield(luaState, LUAU_GLOBALSINDEX, s)
end

-- #define lua_tostring(L, i) lua_tolstring(L, (i), NULL)
function VMMacros.lua_tostring(luaState: VMBindings.LuaState, i: number)
	return cFunctions.lua_tolstring(luaState, i, 0)
end

-- #define lua_pushfstring(L, fmt, ...) lua_pushfstringL(L, fmt, ##__VA_ARGS__)
function VMMacros.lua_pushfstring(_: VMBindings.LuaState)
	-- idk 
end

-- #define luaL_checkstring(L, n) (luaL_checklstring(L, (n), NULL))
function VMMacros.luaL_checkstring(luaState: VMBindings.LuaState, n: number)
	return cFunctions.luaL_checklstring(luaState, n, 0)
end

-- #define luaL_optstring(L, n, d) (luaL_optlstring(L, (n), (d), NULL))
function VMMacros.luaL_optstring(luaState: VMBindings.LuaState, n: number, d: number)
	return cFunctions.luaL_optlstring(luaState, n, d, 0)
end

-- LUA_API void lua_getfenv(lua_State* L, int idx);
function VMMacros.lua_getfenv(luaState: VMBindings.LuaState, i: number)
	return LuauCeption.wasm.indirect_function_table.data[480](luaState, i)
end

export type LuaState = number
export type Pointer = string

return VMMacros