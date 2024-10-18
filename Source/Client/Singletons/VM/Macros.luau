--[[
	Macros is more embedded into the Luau VM, and some understanding of the Luau repository, it essentially
	just implements the C++ macros that make life a little bit easier.
]]

local Package = script.Parent.Parent.Parent.Parent

local LuauCeption = require(Package.Vendor.LuauCeption)

local VMTypes = require(Package.Client.Singletons.VM.Types)
local VMConstants = require(Package.Client.Singletons.VM.Constants)

local cFunctions = LuauCeption.wasm.cfns

local Macros = {}

-- #define lua_tonumber(luaState, i) lua_tonumberx(luaState, i, NULL)
function Macros.lua_tonumber(luaState: VMTypes.LuaState, i: number)
	return cFunctions.lua_tonumberx(luaState, i, 0)
end

-- #define lua_upvalueindex(i) (LUA_GLOBALSINDEX - (i))
function Macros.lua_upvalueindex(i: number)
	return VMConstants.LUAU_GLOBALSINDEX - i
end

-- #define lua_tointeger(luaState, i) lua_tointegerx(luaState, i, NULL)
function Macros.lua_tointeger(luaState: VMTypes.LuaState, i: number)
	return cFunctions.lua_tointegerx(luaState, i)
end

-- #define lua_tounsigned(luaState, i) lua_tounsignedx(luaState, i, NULL)
function Macros.lua_tounsigned(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_pop(luaState, n) lua_settop(luaState, -(n)-1)
function Macros.lua_pop(luaState: VMTypes.LuaState, n: number)
	return cFunctions.lua_settop(luaState, -n - 1)
end

-- #define lua_newtable(luaState) lua_createtable(luaState, 0, 0)
function Macros.lua_newtable(luaState: VMTypes.LuaState)
	return cFunctions.lua_createtable(luaState, 0, 0)
end

-- #define lua_newuserdata(luaState, s) lua_newuserdatatagged(luaState, s, 0)
function Macros.lua_newuserdata(luaState: VMTypes.LuaState, s: number)
	return cFunctions.lua_newuserdatatagged(luaState, s, 0)
end

-- #define lua_strlen(luaState, i) lua_objlen(luaState, (i))
function Macros.lua_strlen(luaState: VMTypes.LuaState, i: number)
	return cFunctions.lua_objlen(luaState, i)
end

-- #define lua_isfunction(L, n) (lua_type(L, (n)) == LUA_TFUNCTION)
function Macros.lua_isfunction(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_istable(L, n) (lua_type(L, (n)) == LUA_TTABLE)
function Macros.lua_istable(_: VMTypes.LuaState)
	-- idk 
end

-- #define lua_islightuserdata(L, n) (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
function Macros.lua_islightuserdata(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_isnil(L, n) (lua_type(L, (n)) == LUA_TNIL)
function Macros.lua_isnil(_: VMTypes.LuaState)
	-- idk 
end

-- #define lua_isboolean(L, n) (lua_type(L, (n)) == LUA_TBOOLEAN)
function Macros.lua_isboolean(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_isvector(L, n) (lua_type(L, (n)) == LUA_TVECTOR)
function Macros.lua_isvector(_: VMTypes.LuaState)
	-- idk 
end

-- #define lua_isthread(L, n) (lua_type(L, (n)) == LUA_TTHREAD)
function Macros.lua_isthread(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_isbuffer(L, n) (lua_type(L, (n)) == LUA_TBUFFER)
function Macros.lua_isbuffer(_: VMTypes.LuaState)
	-- idk 
end

-- #define lua_isnone(L, n) (lua_type(L, (n)) == LUA_TNONE)
function Macros.lua_isnone(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_isnoneornil(L, n) (lua_type(L, (n)) <= LUA_TNIL)
function Macros.lua_isnoneornil(_: VMTypes.LuaState)
	-- idk 
end

-- #define lua_pushliteral(L, s) lua_pushlstring(L, "" s, (sizeof(s) / sizeof(char)) - 1)
function Macros.lua_pushliteral(_: VMTypes.LuaState)
	-- idk
end

-- #define lua_pushcfunction(L, fn, debugname) lua_pushcclosurek(L, fn, debugname, 0, NULL)
function Macros.lua_pushcfunction(luaState: VMTypes.LuaState, fn: number, debugname: number?)
	return cFunctions.lua_pushcclosurek(luaState, fn, debugname or 0, 0, 0)
end

-- #define lua_pushcclosure(L, fn, debugname, nup) lua_pushcclosurek(L, fn, debugname, nup, NULL)
function Macros.lua_pushcclosure(luaState: VMTypes.LuaState, fn: number, nup: number)
	cFunctions.lua_pushcclosurek(luaState, fn, 0, nup, 0)
end

-- #define lua_pushlightuserdata(L, p) lua_pushlightuserdatatagged(L, p, 0)
function Macros.lua_pushlightuserdata(_: VMTypes.LuaState)
	-- idk 
end

-- #define lua_setglobal(L, s) lua_setfield(L, LUA_GLOBALSINDEX, (s))
function Macros.lua_setglobal(luaState: VMTypes.LuaState, s: number)
	return cFunctions.lua_setfield(luaState, VMConstants.LUAU_GLOBALSINDEX, s)
end

-- #define lua_getglobal(L, s) lua_getfield(L, LUA_GLOBALSINDEX, (s))
function Macros.lua_getglobal(luaState: VMTypes.LuaState, s: number)
	return cFunctions.lua_getfield(luaState, VMConstants.LUAU_GLOBALSINDEX, s)
end

-- #define lua_tostring(L, i) lua_tolstring(L, (i), NULL)
function Macros.lua_tostring(luaState: VMTypes.LuaState, i: number)
	return cFunctions.lua_tolstring(luaState, i, 0)
end

-- #define lua_pushfstring(L, fmt, ...) lua_pushfstringL(L, fmt, ##__VA_ARGS__)
function Macros.lua_pushfstring(_: VMTypes.LuaState)
	-- idk 
end

-- #define luaL_checkstring(L, n) (luaL_checklstring(L, (n), NULL))
function Macros.luaL_checkstring(luaState: VMTypes.LuaState, n: number)
	return cFunctions.luaL_checklstring(luaState, n, 0)
end

-- #define luaL_optstring(L, n, d) (luaL_optlstring(L, (n), (d), NULL))
function Macros.luaL_optstring(luaState: VMTypes.LuaState, n: number, d: number)
	return cFunctions.luaL_optlstring(luaState, n, d, 0)
end

-- #define luaL_getmetatable(L, n) (lua_getfield(L, LUA_REGISTRYINDEX, (n)))
function Macros.luaL_getmetatable(luaState: VMTypes.LuaState, n: number)
	return cFunctions.lua_getfield(luaState, VMConstants.LUA_REGISTRYINDEX, n)
end

-- LUA_API void lua_getfenv(lua_State* L, int idx);
function Macros.lua_getfenv(luaState: VMTypes.LuaState, i: number)
	return LuauCeption.wasm.indirect_function_table.data[480](luaState, i)
end

return Macros