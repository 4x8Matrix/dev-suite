local Package = script.Parent.Parent.Parent

local Signal = require(Package.Parent.Signal)

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
	local function generateSettingsTableForCline()
		return {
			DefaultHotkey = serverSettings.DefaultHotkey.Name
		}
	end

	self.OnUpdated:Connect(function()
		Network.ServerSettingsUpdated:FireAll(generateSettingsTableForCline())
	end)

	Network.FetchSettingsRequested.SetCallback(function()
		return generateSettingsTableForCline()
	end)
end

export type Settings = typeof(Settings)

export type SettingOptions = {
	DefaultHotkey: Enum.KeyCode,
}

return Settings