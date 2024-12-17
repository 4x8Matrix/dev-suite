# Dev Suite - 👋

Dev Suite is a collection of tools and resources that enables developers to pentest and validate the security of their Roblox experiences.

Dev Suite is yet to be feature complete - but you're still able to use this tool in your projects by installing it via wally.

### Motivation
I've always found that exploiters generally have the advantage over developers when it comes to testing, they have a client that they can use to execute *any* code in the Roblox environment..

Right, so this is why I created Dev Suite, it's designed to not only emulate the exploiter environment - but provide tools wrapping around the ecosystem itself.

### API Documentation
Dev Suite provides a minimal API that enables you to interact with some of the modules, as well as authentication for this package.

#### Actions
> DevSuite.CreateAction

The `CreateAction` function enables developers to add custom functionality to the Dev Suite, when adding a function - that function will be represented in the `Actions` tab.

The purpose is to allow developers to create debug commands, or functionality for QA teams to use, without needing to use an alternative such as a commands framework.

```lua
DevSuite:CreateAction(actionCallback: (...any) -> (), actionSettings: {
	name: string,
	description: string?,
	arguments: {
		type: "Number" | "String" | "Boolean" | "Player",
		name: string,
		default: any?
	}?,
})
```

#### Authentication
> DevSuite.SetAuthenticationCallback
---

The `SetAuthenticationCallback` function allows developers to set a custom authentication callback that determines which players can access Dev Suite.

This callback is only available on the server and will be called whenever a player first loads in.

```lua
DevSuite:SetAuthenticationCallback(callback: (Player) -> boolean)
```

*Example:*
```lua
-- Only allow players in group 12345 with rank 100 or higher
DevSuite:SetAuthenticationCallback(function(player)
    return player:GetRankInGroup(12345) >= 100
end)
```

#### VM
*As developers - Dev Suite enables you to interop with the Client-side VM, this functionality is limited - but can be used in special cases to do some unique things.*

> DevSuite.AddLibraryToVM

Allows developers to add custom libraries to the client-side VM environment. This enables extending the VM's functionality with custom functions that can interact with the LuauCeption VM and underlying Lua state.

```lua
DevSuite:AddLibraryToVM(self: DevSuite, name: string, library: {
	[string]: (luauCeption: VM.LuauCeption, luaState: number) -> number
})
```

> DevSuite.AddGlobalToVM

Enables adding global variables/functions to the VM's global environment. This allows injecting individual global values that can be accessed from code executed in the VM.

```lua
DevSuite:AddGlobalToVM(self: DevSuite, name: string, callback: (luauCeption: VM.LuauCeption, luaState: number) -> number)
```

> DevSuite.HookVMMetamethod

Provides the ability to hook into Lua metamethods within the VM, allowing developers to intercept and modify behavior of core operations like indexing, newindex, etc.

```lua
DevSuite:HookVMMetamethod(self: DevSuite, name: string, callback: (luauCeption: VM.LuauCeption, luaState: number) -> number)
```

*Example:*

```lua
-- keep track of the original __namecall function
local __namecall
	
__namecall = DevSuite:HookVMMetamethod("__namecall", function(luauCeption, luaState: VMTypes.LuaState)
	-- do cool things
	local methodName = cstring(lua_namecallatom(luaState, 0))
	local object = toLuau(luaState, 1)

	print(`VM called '{methodName}' on '{object}'`)

	-- return what the default implementation would return
	return __namecall(luaState)
end)