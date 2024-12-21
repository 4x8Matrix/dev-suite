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

local interceptedRemotesArray = windowScope:Value({})
local logsArray = windowScope:Value({})
local eventsArray = windowScope:Value({})

local selectedPage = windowScope:Value(nil)

local selectedInstanceValue = windowScope:Value(nil)
local actionsList = windowScope:Value({})
local customPagesList = windowScope:Value({})

local threadList = windowScope:Value({ })
local threadHistory = windowScope:Value({})
local threadStats = windowScope:Value({})

local vmStats = windowScope:Value({})
local luauRegistry = windowScope:Value({})

local drawcallStats = windowScope:Value({
	prefix = "",
	name = "Drawcall",
	stats = {
		Scene = {
			Triangles = "?",
			Drawcalls = "?",
		},
		Shadows = {
			Triangles = "?",
			Drawcalls = "?",
		}
	},
	graph = { },
})

local frameStats = windowScope:Value({
	prefix = "ms",
	name = "Frame",
	stats = {
		Frame = "?",
		Heartbeat = "?",
		Physics = "?",

		["GPU Time"] = "?",
		["CPU Time"] = "?",
	},
	graph = { },
})

local metadataStats = windowScope:Value({
	prefix = "",
	name = "Metadata",
	stats = {
		["Rbxl Version"] = "?",
		["Place Version"] = "?",
	},
	graph = { },
})

local instanceStats = windowScope:Value({
	prefix = "",
	name = "Instance",
	stats = {
		Count = "?",
		Collisions = "?",
		Moving = "?",
	},
	graph = { },
})

local networkStats = windowScope:Value({
	prefix = "kbps",
	name = "Network",
	stats = {
		Data = {
			Send = "?",
			Recv = "?",
		},
		Physics = {
			Send = "?",
			Recv = "?",
		},
	},
	graph = { },
})

local memoryStats = windowScope:Value({
	prefix = "MB",
	name = "Memory",
	stats = {
		Graphics = {
			Particles = "?",
			Models = "?",
			SpatialHash = "?",
			Terrain = "?",
			Texture = "?",
		},
		Roblox = {
			Internal = "?",
			Http = "?",
			Instances = "?",
			Signals = "?",
			LuaHeap = "?",
			Script = "?",
		},
		Physics = {
			Collisions = "?",
			Parts = "?",
		},
		World = {
			Sounds = "?",
			CSG = "?",
			Navigation = "?",
			Animation = "?",
			Gui = "?",
			Voxels = "?",
		}
	},
	graph = { },
})

local Interface = {}

Interface.ExecuteActionRequested = Signal.new()

Interface.MinimiseWindowRequested = Signal.new()
Interface.OpenWindowRequested = Signal.new()

Interface.EvalClientCodeRequested = Signal.new()
Interface.EvalServerCodeRequested = Signal.new()

Interface.ClickToSelectEnabled = Signal.new()
Interface.ClickToSelectDisabled = Signal.new()

Interface.HighlightSelectedInstanceEnabled = Signal.new()
Interface.HighlightSelectedInstanceDisabled = Signal.new()

Interface.ExportLogsRequested = Signal.new()
Interface.ClearLogsRequested = Signal.new()
Interface.BreakpointLogsRequested = Signal.new()

Interface.SelectedInstanceChanged = Signal.new()

Interface.RepeatRemoteEventCallRequested = Signal.new()

Interface.RefreshStatsRequested = Signal.new()
Interface.EnableAutoRefreshRequested = Signal.new()
Interface.DisableAutoRefreshRequested = Signal.new()

--[[
	This function will create both the Window + Indicator UI.
]]
function Interface.CreateInterface(self: Interface)
	windowObject = Window(windowScope, {
		selectedPage = selectedPage,
		size = windowScope:Value(Vector2.new(584, 312)),

		customPages = customPagesList,
		
		debugger = {
			threadList = threadList,
			threadHistory = threadHistory,
			threadStats = threadStats,

			vmStats = vmStats,
			luauRegistry = luauRegistry
		},

		logging = {
			logs = logsArray,

			sortOrder = windowScope:Value("Time"),
			context = windowScope:Value("Client")
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

			clickToSelect = clickToSelectValue,
			showSelection = highlightSelectedInstanceValue,

			selectedInstance = selectedInstanceValue,
		},

		actions = {
			closedFolders = windowScope:Value({}),

			actions = actionsList
		},

		statistics = {
			selectedCategory = windowScope:Value(nil),

			memoryStats = memoryStats,
			networkStats = networkStats,
			instanceStats = instanceStats,
			metadataStats = metadataStats,
			drawcallStats = drawcallStats,
			frameStats = frameStats,
		},

		liveEvents = {
			events = eventsArray,
		},

		callbacks = {
			showWindow = showWindowValue,
			hideWindow = hideWindowValue
		},

		interceptor = {
			intercepted = interceptedRemotesArray,
		},

		signals = {
			minimiseWindow = self.MinimiseWindowRequested,

			actions = {
				executeAction = self.ExecuteActionRequested,
			},

			logging = {
				exportLogs = self.ExportLogsRequested,
				clearLogs = self.ClearLogsRequested,
				breakpointLogs = self.BreakpointLogsRequested,
			},

			sandbox = {
				evalClientCode = self.EvalClientCodeRequested,
				evalServerCode = self.EvalServerCodeRequested
			},

			interceptor = {
				repeatEvent = self.RepeatRemoteEventCallRequested
			},

			statistics = {
				refresh = self.RefreshStatsRequested,

				enableAutoRefresh = self.EnableAutoRefreshRequested,
				disableAutoRefresh = self.DisableAutoRefreshRequested
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
	
]]
function Interface.SetLogs(_: Interface, logs: { [any]: any })
	logsArray:set(logs)
end

--[[
	
]]
function Interface.SetLiveEvents(_: Interface, events: { [any]: any })
	eventsArray:set(events)
end

--[[
	
]]
function Interface.SetActions(_: Interface, actions: { [any]: any })
	actionsList:set(actions)
end

--[[
	Will allow code from outside of the interface to set what interface is currently active.
]]
function Interface.SetSelectedPage(_: Interface, pageName: string)
	selectedPage:set(require(Package.Client.Interface.Fusion.Pages[pageName]))
end

--[[

]]
function Interface.GetSelectedPage(_: Interface)
	return Fusion.peek(selectedPage).Properties.DisplayName
end

--[[
	Will set the array of intercepted remotes.
]]
function Interface.SetInterceptedRemotes(_: Interface, events: { [any]: any })
	interceptedRemotesArray:set(events)
end

--[[
	Will set the stats for the Memory tab.
]]
function Interface.SetMemoryStats(_: Interface, stats: { [any]: any })
	local newStats = Fusion.peek(memoryStats)

	newStats.stats = stats

	memoryStats:set(newStats)
end

--[[
	Will set the stats for the Network section.
]]
function Interface.SetNetworkStats(_: Interface, stats: { [any]: any })
	local newStats = Fusion.peek(networkStats)

	newStats.stats = stats

	networkStats:set(newStats)
end

--[[
	Will set the stats for the Instance section.
]]
function Interface.SetInstanceStats(_: Interface, stats: { [any]: any })
	local newStats = Fusion.peek(instanceStats)

	newStats.stats = stats

	instanceStats:set(newStats)
end

--[[
	Will set the stats for the Metadata section.
]]
function Interface.SetMetadataStats(_: Interface, stats: { [any]: any })
	local newStats = Fusion.peek(metadataStats)

	newStats.stats = stats

	metadataStats:set(newStats)
end

--[[
	Will set the stats for the Drawcall section.
]]
function Interface.SetDrawcallStats(_: Interface, stats: { [any]: any })
	local newStats = Fusion.peek(drawcallStats)

	newStats.stats = stats

	drawcallStats:set(newStats)
end

--[[
	Will set the stats for the Frame section.
]]
function Interface.SetFrameStats(_: Interface, stats: { [any]: any })
	local newStats = Fusion.peek(frameStats)

	newStats.stats = stats

	frameStats:set(newStats)
end

--[[
	
]]
function Interface.SetThreadList(_: Interface, list: { string })
	threadList:set(list)
end

--[[
	
]]
function Interface.SetThreadHistory(_: Interface, history: {
	[string]: {
		[string]: {
			type: string,
			message: string
		}
	}
})
	threadHistory:set(history)
end

--[[
	
]]
function Interface.SetThreadStats(_: Interface, stats: { [string]: {
	childThreadCount: number,
	methodCallCount: number,
	indexCount: number,
	instanceRefCount: number
} })
	threadStats:set(stats)
end

--[[
	
]]
function Interface.SetVMStats(_: Interface, stats: {
	memory: number,
	threads: number,
	instances: number
})
	vmStats:set(stats)
end

--[[
	
]]
function Interface.SetLuauRegistry(_: Interface, registry: {
	{
		type: string,
		name: string
	}
})
	luauRegistry:set(registry)
end

--[[
	Will add a page to the custom pages state
]]
function Interface.AddCustomPage(_: Interface, pageName: string, pageIcon: string, renderCallback: () -> (), cleanupCallback: () -> ())
	local currentPageList = Fusion.peek(customPagesList)

	table.insert(currentPageList, {
		name = pageName,
		icon = pageIcon,
		renderCallback = renderCallback,
		cleanupCallback = cleanupCallback,
	})

	customPagesList:set(currentPageList)
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