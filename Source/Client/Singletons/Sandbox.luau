--[[
	
]]

local Package = script.Parent.Parent.Parent

local VM = require(Package.Client.Singletons.VM)

local Interface = require(Package.Client.Singletons.Interface)

local Sandbox = {}

function Sandbox.OnStart(_: Sandbox)
	Interface.EvalClientCodeRequested:Connect(function(source: string)
		local selectedRuntime = Interface:GetSelectedRuntime() :: any

		VM:Eval(source, selectedRuntime)
	end)
end

export type Sandbox = typeof(Sandbox)

return Sandbox