--[[
	
]]

local HttpService = game:GetService("HttpService")

local Package = script.Parent.Parent.Parent

local Network = require(Package.Server.Network)

local Authentication = require(Package.Server.Singletons.Authentication)

local Hooks = {}

function Hooks.OnStart(_: Hooks)
	Network.HttpGetRequest.SetCallback(function(player, url)
		Authentication:Validate(player)

		local response = HttpService:GetAsync(url, true)

		return response
	end)
end

export type Hooks = typeof(Hooks)

return Hooks