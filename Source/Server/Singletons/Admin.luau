local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

--[[
	
]]

local Package = script.Parent.Parent.Parent

local Network = require(Package.Server.Network)

local Authentication = require(Package.Server.Singletons.Authentication)

local Admin = {}

function Admin.OnStart(_: Admin)
	Network.KickUserRequested.On(function(player, target)
		Authentication:Validate(player)

		target:Kick("You have been kicked by an administrator.")
	end)

	Network.BanUserRequested.On(function(player, target)
		Authentication:Validate(player)

		Players:BanAsync({
			UserIds = { target.UserId },
			ApplyToUniverse = true,
			Duration = -1,
			DisplayReason = "You have been banned by an administrator.",
			PrivateReason = `Player '{target.Name}' has been banned by {player.Name}.`,
			ExcludeAltAccounts = false,
		})
	end)

	Network.AdminUserRequested.On(function(player, target)
		Authentication:Validate(player)

		Authentication:SetAuthenticated(target, true)
		TeleportService:Teleport(game.PlaceId, target)
	end)

	Network.RejoinRequested.On(function(player)
		Authentication:Validate(player)

		TeleportService:Teleport(game.PlaceId, player)
	end)

	Network.ShutdownServerRequested.On(function(requestingPlayer)
		Authentication:Validate(requestingPlayer)

		local reservedServerId = TeleportService:ReserveServer(game.PlaceId)

		for _, player in Players:GetPlayers() do
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerId, { player }, nil, { DEV_SUITE_REJOIN_PUBLIC_SERVER = true })
		end

		Players.PlayerAdded:Connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerId, { player }, nil, { DEV_SUITE_REJOIN_PUBLIC_SERVER = true })
		end)

		TeleportService.TeleportInitFailed:Connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerId, { player }, nil, { DEV_SUITE_REJOIN_PUBLIC_SERVER = true })
		end)
	end)

	Players.PlayerAdded:Connect(function(player)
		local joinData = player:GetJoinData()

		if joinData.TeleportData and joinData.TeleportData.DEV_SUITE_REJOIN_PUBLIC_SERVER then
			TeleportService:TeleportAsync(game.PlaceId, { player })
		end
	end)
end

export type Admin = typeof(Admin)

return Admin