--[[
	Settings is responsible for not only fetching settings from the server, when, and once they change - but
	allowing other singletons to query these settings.
]]

local Package = script.Parent.Parent.Parent

local Signal = require(Package.Parent.Signal)

local Network = require(Package.Client.Network)

local clientSettings = {}

local Settings = {}

Settings.OnUpdated = Signal.new()

--[[
	Query the setting of a value.
]]
function Settings.GetSetting(_: Settings, setting: string)
	return clientSettings[setting]
end

function Settings.OnStart(_: Settings)
	local function updateClientSettings(serverSettings)
		clientSettings = {
			DefaultHotkey = Enum.KeyCode[serverSettings.DefaultHotkey]
		}
	end
	
	Network.ServerSettingsUpdated.SetCallback(function(serverSettings)
		updateClientSettings(serverSettings)
	end)

	updateClientSettings(Network.FetchSettingsRequested.Call())
end

export type Settings = typeof(Settings)

return Settings