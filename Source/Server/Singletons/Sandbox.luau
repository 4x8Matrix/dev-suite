--[[
	
]]

local Package = script.Parent.Parent.Parent

local Network = require(Package.Server.Network)

local Console = require(Package.Parent.Console)

local reporter = Console.new(script.Name)

local Sandbox = {}

function Sandbox.Execute(_: Sandbox, source: string)
	local response = { pcall(loadstring, source, "DevSuite-Eval") }

	if response[1] then
		response[2]()
	else
		reporter:Warn(`Enable ServerScriptService.LoadstringEnabled for Server execution!`)
		reporter:Debug(response[2])
	end
end

function Sandbox.OnStart(self: Sandbox)
	Network.ExecuteServerScriptRequested.On(function(_: Player, source: string)
		self:Execute(source)
	end)
end

export type Sandbox = typeof(Sandbox)

return Sandbox