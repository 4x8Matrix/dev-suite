local Players = game:GetService("Players")

local Package = script.Parent.Parent.Parent

local Console = require(Package.Parent.Console)

local Network = require(Package.Server.Network)

local evaluationCache: { [number]: boolean } = { }
local reporter = Console.new(script.Name)

local hasWarned = false

local Authentication = {}

Authentication.AuthenticationCallback = nil :: ((Player) -> boolean)? 

function Authentication.IsAuthenticated(self: Authentication, player: Player): boolean
	if evaluationCache[player.UserId] ~= nil then
		return evaluationCache[player.UserId]
	end

	if self.AuthenticationCallback then
		evaluationCache[player.UserId] = self.AuthenticationCallback(player)

		if evaluationCache[player.UserId] then
			player:SetAttribute(`DevSuite_Auth`, true)
		end

		return evaluationCache[player.UserId]
	end

	if not hasWarned then
		reporter:Warn(`Authentication callback not set, authenticating player '{player.Name}' as authenticated.`)

		hasWarned = true
	end

	player:SetAttribute(`DevSuite_Auth`, true)

	return true
end

function Authentication.Validate(self: Authentication, player: Player, ...): boolean
	assert(self:IsAuthenticated(player), `Player '{player.Name}' is not authenticated.`)

	return ...
end

function Authentication.SetAuthenticated(_: Authentication, player: Player, authenticated: boolean)
	evaluationCache[player.UserId] = authenticated
end

function Authentication.GetListOfAuthenticatedPlayers(self: Authentication): { Player }
	local authenticated = {}
	
	for _, player in Players:GetPlayers() do
		if self:IsAuthenticated(player) then
			table.insert(authenticated, player)
		end
	end

	return authenticated
end

function Authentication.OnStart(self: Authentication)
	Network.AuthenticateRequested.SetCallback(function(player: Player)
		return self:IsAuthenticated(player) and "Accepted" or "Rejected"
	end)
end

export type Authentication = typeof(Authentication)

return Authentication