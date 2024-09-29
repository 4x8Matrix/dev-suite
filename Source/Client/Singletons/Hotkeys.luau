--[[
	High level explanation of this Singleton is that it's job to provide a singleton for tracking inputs, specific
	inputs will allow specific actions to occur, for example;

	- upon F10 being activated, show the Dev-Suite interface.
]]

local UserInputService = game:GetService("UserInputService")

local Package = script.Parent.Parent.Parent

local Signal = require(Package.Parent.Signal)

local Settings = require(Package.Client.Singletons.Settings)

local Hotkeys = {}

Hotkeys.OnHotkeyPressed = Signal.new()

function Hotkeys.OnStart(self: Hotkeys)
	UserInputService.InputBegan:Connect(function(inputObject: InputObject)
		local hotkey = Settings.GetSetting(Settings, "DefaultHotkey")

		if inputObject.KeyCode ~= hotkey then
			return
		end

		self.OnHotkeyPressed:Fire()
	end)
end

export type Hotkeys = typeof(Hotkeys)

return Hotkeys