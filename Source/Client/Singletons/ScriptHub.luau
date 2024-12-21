--[[
	ScriptHub handles the logic for the ScriptHub tab on the Interface
]]

local Package = script.Parent.Parent.Parent

local Interface = require(Package.Client.Singletons.Interface)
local VM = require(Package.Client.Singletons.VM)

local INTERNALLY_REGISTERED_SCRIPTS = table.freeze({
	{
		name = "Infinite Yield",
		description = "Loads the Admin 'Infinite Yield'",
		source = [[loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()]]
	},
	{
		name = "Hello, World",
		description = "Development script used to test the Script Hub",
		source = [[loadstring(game:HttpGetAsync("https://pastebin.com/raw/uXvzZpcM"))()]]
	}
})

local ScriptHub = {}

function ScriptHub.OnStart(_: ScriptHub)
	Interface:SetScripts(table.clone(INTERNALLY_REGISTERED_SCRIPTS))

	Interface.ExecuteScriptRequested:Connect(function(code: string)
		VM:Eval(code, true)
	end)
end

export type ScriptHub = typeof(ScriptHub)

return ScriptHub