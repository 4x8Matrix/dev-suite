--[[
	
]]

local Package = script.Parent.Parent.Parent

local Network = require(Package.Client.Network)

local VM = require(Package.Client.Singletons.VM)

local Interface = require(Package.Client.Singletons.Interface)

local Sandbox = {}

function Sandbox.OnStart(_: Sandbox)
	Interface.EvalClientCodeRequested:Connect(function(source: string)
		VM:Eval(source)
	end)

	Interface.EvalServerCodeRequested:Connect(function(source: string)
		Network.ExecuteServerScriptRequested.Fire(source)
	end)
end

export type Sandbox = typeof(Sandbox)

return Sandbox