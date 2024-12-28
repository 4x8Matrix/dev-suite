local Players = game:GetService("Players")
--[[
	
]]

local Package = script.Parent.Parent.Parent

local Interface = require(Package.Client.Singletons.Interface)

local Network = require(Package.Client.Network)

local Admin = {}

function Admin.UpdateAdminPlayers(_: Admin)
	local playerList = {}
	
	for _, player in Players:GetPlayers() do
		table.insert(playerList, {
			name = player.DisplayName,
			id = tostring(player.UserId),
			isAdmin = player:GetAttribute("DevSuite_Auth")
		})
	end

	Interface:SetAdminPlayers(playerList)
end

function Admin.OnPlayerAdded(self: Admin, player: Player, avoidUpdate: boolean?)
	player:GetAttributeChangedSignal("DevSuite_Auth"):Connect(function()
		self:UpdateAdminPlayers()
	end)

	if not avoidUpdate then
		self:UpdateAdminPlayers()
	end
end

function Admin.OnStart(self: Admin)
	Interface.KickUserRequested:Connect(function(userId: string)
		Network.KickUserRequested.Fire(Players:GetPlayerByUserId(userId))
	end)

	Interface.BanUserRequested:Connect(function(userId: string)
		Network.BanUserRequested.Fire(Players:GetPlayerByUserId(userId))
	end)

	Interface.AdminUserRequested:Connect(function(userId: string)
		Network.AdminUserRequested.Fire(Players:GetPlayerByUserId(userId))
	end)

	Interface.RejoinServerRequested:Connect(function()
		Network.RejoinRequested.Fire()
	end)

	Interface.ShutdownServerRequested:Connect(function()
		Network.ShutdownServerRequested.Fire()
	end)

	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function()
		self:UpdateAdminPlayers()
	end)

	for _, player in Players:GetPlayers() do
		self:OnPlayerAdded(player, true)
	end

	self:UpdateAdminPlayers()
end

export type Admin = typeof(Admin)

return Admin