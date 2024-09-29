--[[
	High level explanation of this Singleton is that it's job is to provide bindings to other Services to figure out if
	the current player (local player) is able to access the Dev Suite.
]]

local Package = script.Parent.Parent.Parent

local Network = require(Package.Client.Network)

local authenticationState

local Authentication = {}

Authentication.AuthenticationCallback = nil :: ((Player) -> boolean)? 

--[[
	Returns a boolean, defines if the user is able to interact with the dev suite or not.
]]
function Authentication.IsAuthenticated(_: Authentication): boolean
	if authenticationState == nil then
		authenticationState = Network.AuthenticateRequested.Call()
	end

	return authenticationState == "Accepted"
end

export type Authentication = typeof(Authentication)

return Authentication