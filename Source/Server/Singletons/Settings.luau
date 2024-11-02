local Package = script.Parent.Parent.Parent

local Signal = require(Package.Parent.Signal)

local Authentication = require(Package.Server.Singletons.Authentication)

local Network = require(Package.Server.Network)

local serverSettings: SettingOptions = {
	DefaultHotkey = Enum.KeyCode.F10
}

local Settings = {}

Settings.OnUpdated = Signal.new()

function Settings.GetSetting(_: Settings, setting: string)
	return serverSettings[setting]
end

function Settings.UpdateServerSettings(self: Settings, settings: SettingOptions)
	serverSettings = settings

	self.OnUpdated:Fire()
end

function Settings.OnStart(self: Settings)
	local function generateSettingsTableForClient()
		return {
			DefaultHotkey = serverSettings.DefaultHotkey.Name
		}
	end

	self.OnUpdated:Connect(function()
		Network.ServerSettingsUpdated.FireList(Authentication:GetListOfAuthenticatedPlayers(), generateSettingsTableForClient())
	end)

	Network.FetchSettingsRequested.SetCallback(function()
		return generateSettingsTableForClient()
	end)
end

export type Settings = typeof(Settings)

export type SettingOptions = {
	DefaultHotkey: Enum.KeyCode,
}

return Settings