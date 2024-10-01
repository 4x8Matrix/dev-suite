--[[
	High level explanation of this Singleton is that it's job is to create, manage the state of, and emit relevant
	signals for the UI/Panel that appears, and can be interactively used by the developer.

	This module should wrap around the UI, allowing other Singletons to just pry on Signals and other bits
	instead of having to write in support for their UI pages directly.

	This Interface singleton handles two important UIs:
	- Indication UI
		used to show the window once clicked/activated by a user.

	- Window UI
		used to navigate the variety of features the Dev Suite offers.
]]

local Players = game:GetService("Players")
local Package = script.Parent.Parent.Parent

local Hotkeys = require(Package.Client.Singletons.Hotkeys)

local Window = require(Package.Client.Interface.Fusion.Window)
local Indicator = require(Package.Client.Interface.Fusion.Indicator)

local Fusion = require(Package.Parent.Fusion)
local Signal = require(Package.Parent.Signal)

local isInterfaceOpen = false
local isProcessingRequest = false

local windowScope = Fusion.scoped(Fusion)
local indicatorScope = Fusion.scoped(Fusion)

local windowObject: ScreenGui
local indicatorObject: ScreenGui

local showWindowValue = windowScope:Value(nil)
local hideWindowValue = windowScope:Value(nil)

local showIndicatorValue = indicatorScope:Value(nil)
local hideIndicatorValue = indicatorScope:Value(nil)

local clickToSelectValue = windowScope:Value(false)
local highlightSelectedInstanceValue = windowScope:Value(false)

local runtimeValue = windowScope:Value("Roblox")
local availableRuntimesValue = windowScope:Value({
	"Roblox", "Luau", "Swift"
})

local selectedInstanceValue = windowScope:Value(nil)

local Interface = {}

Interface.MinimiseWindowRequested = Signal.new()
Interface.OpenWindowRequested = Signal.new()

Interface.EvalClientCodeRequested = Signal.new()
Interface.EvalServerCodeRequested = Signal.new()

Interface.ClickToSelectEnabled = Signal.new()
Interface.ClickToSelectDisabled = Signal.new()

Interface.HighlightSelectedInstanceEnabled = Signal.new()
Interface.HighlightSelectedInstanceDisabled = Signal.new()

Interface.SelectedInstanceChanged = Signal.new()

--[[
	This function will create both the Window + Indicator UI.
]]
function Interface.CreateInterface(self: Interface)
	local windowScreenGui = windowScope:Value(nil)
	windowObject = Window(windowScope, {
		screenGui = windowScreenGui,
		selectedPage = windowScope:Value(nil),

		explorer = {
			instances = {
				game:GetService("Workspace"),
				game:GetService("Players"),
				game:GetService("Lighting"),
				game:GetService("MaterialService"),
				game:GetService("ReplicatedFirst"),
				game:GetService("ReplicatedStorage"),
				game:GetService("ServerScriptService"),
				game:GetService("ServerStorage"),
				game:GetService("StarterGui"),
				game:GetService("StarterPack"),
				game:GetService("StarterPlayer"),
				game:GetService("Teams"),
				game:GetService("SoundService"),
				game:GetService("Chat"),
				game:GetService("TextChatService"),
				game:GetService("LocalizationService"),
				game:GetService("TestService"),
				game:GetService("VRService")
			},

			clickToSelect = clickToSelectValue,
			showSelection = highlightSelectedInstanceValue,

			selectedInstance = selectedInstanceValue,
		},

		callbacks = {
			showWindow = showWindowValue,
			hideWindow = hideWindowValue
		},

		sandbox = {
			runtime = runtimeValue,
			availableRuntimes = availableRuntimesValue,
		},

		signals = {
			minimiseWindow = self.MinimiseWindowRequested,

			sandbox = {
				evalClientCode = self.EvalClientCodeRequested,
				evalServerCode = self.EvalServerCodeRequested
			}
		}
	})

	indicatorObject = Indicator(indicatorScope, {
		callbacks = {
			showIndicator = showIndicatorValue,
			hideIndicator = hideIndicatorValue
		},

		signals = {
			openWindow = self.OpenWindowRequested
		}
	})

	windowScope:Observer(clickToSelectValue):onChange(function()
		local value = Fusion.peek(clickToSelectValue)

		if value then
			self.ClickToSelectEnabled:Fire()
		else
			self.ClickToSelectDisabled:Fire()
		end
	end)

	windowScope:Observer(highlightSelectedInstanceValue):onChange(function()
		local value = Fusion.peek(highlightSelectedInstanceValue)

		if value then
			self.HighlightSelectedInstanceEnabled:Fire()
		else
			self.HighlightSelectedInstanceDisabled:Fire()
		end
	end)

	windowScope:Observer(selectedInstanceValue):onChange(function()
		local value = Fusion.peek(highlightSelectedInstanceValue)

		self.SelectedInstanceChanged:Fire(value)
	end)

	windowScreenGui:set(windowObject)

	windowObject.Parent = Players.LocalPlayer.PlayerGui
	windowObject.Name = `[DEBUG-TOOL]`

	windowObject:SetAttribute(`IsDebugUI`, true)
	windowObject:AddTag(`_DebugInterface`)

	indicatorObject.Parent = Players.LocalPlayer.PlayerGui
	indicatorObject.Name = `[DEBUG-INDICATOR]`

	indicatorObject:SetAttribute(`IsDebugUI`, true)
	indicatorObject:AddTag(`_DebugInterface`)

	task.delay(0.1, function()
		Fusion.peek(showIndicatorValue)()
	end)
end

--[[
	Responsible for showing, making the Window UI appear on the players screen, this will hide the indicator UI as it will
	no longer be required.
]]
function Interface.ActivateInterface(_: Interface)
	isInterfaceOpen = true

	Fusion.peek(showWindowValue)()
	Fusion.peek(hideIndicatorValue)()
end

--[[
	Responsible for hiding, making the Window UI disappear on the players screen, this will show the indicator UI.
]]
function Interface.DeactivateInterface(_: Interface)
	isInterfaceOpen = false

	Fusion.peek(hideWindowValue)()
	Fusion.peek(showIndicatorValue)()
end

--[[
	Returns the instance that is currently selected in the explorer.
]]
function Interface.GetSelectedInstance(_: Interface)
	return Fusion.peek(selectedInstanceValue)
end

--[[
	Responsible for setting the selected instance in the explorer tab.
]]
function Interface.SetSelectedInstance(_: Interface, instance: Instance)
	selectedInstanceValue:set(instance)
end

--[[
	Responsible for setting the selected instance in the explorer tab.
]]
function Interface.GetSelectedRuntime(_: Interface): string
	return Fusion.peek(runtimeValue)
end

function Interface.OnStart(self: Interface)
	self:CreateInterface()

	self.MinimiseWindowRequested:Connect(function()
		self:DeactivateInterface()
	end)

	self.OpenWindowRequested:Connect(function()
		self:ActivateInterface()
	end)

	Hotkeys.OnHotkeyPressed:Connect(function()
		if isProcessingRequest then
			return
		end

		isProcessingRequest = true

		if isInterfaceOpen then
			self:DeactivateInterface()
		else
			self:ActivateInterface()
		end

		isProcessingRequest = false
	end)
end

export type Interface = typeof(Interface)

return Interface