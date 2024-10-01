local Package = script.Parent.Parent.Parent.Parent

local Fusion = require(Package.Parent.Fusion)
local Signal = require(Package.Parent.Signal)

local Window = require(Package.Client.Interface.Fusion.Window)

return function(parent)
	local scope = Fusion.scoped(Fusion)

	local screenGui = scope:Value(nil)
	local selectedPage = scope:Value(nil)

	local showWindowValue = scope:Value(nil)
	
	local windowObject = Window(scope, {
		screenGui = screenGui,
		selectedPage = selectedPage,

		callbacks = {
			showWindow = showWindowValue,
			hideWindow = scope:Value(nil),
		},

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

			clickToSelect = scope:Value(nil),
			showSelection = scope:Value(nil),

			selectedInstance = scope:Value(nil),
		},

		signals = {
			minimiseWindow = Signal.new(),

			sandbox = {
				evalClientCode = Signal.new(),
				evalServerCode = Signal.new()
			}
		}
	})

	screenGui:set(windowObject)

	task.delay(0.1, function()
		Fusion.peek(showWindowValue)()
	end)

	windowObject.Parent = parent

	return function()
		windowObject:Destroy()

		Fusion.doCleanup(scope)
	end
end
