local Package = script.Parent.Parent.Parent.Parent

local Fusion = require(Package.Parent.Fusion)
local Signal = require(Package.Parent.Signal)

local Window = require(Package.Client.Interface.Fusion.Window)

return function(parent)
	local scope = Fusion.scoped(Fusion)

	local screenGui = scope:Value(nil)
	local selectedPage = scope:Value(nil)

	local showWindowValue = scope:Value(nil)

	-- selene: allow(undefined_variable)
	local version = string.split(version(), ".")

	local windowObject = Window(scope, {
		screenGui = screenGui,
		selectedPage = selectedPage,

		size = scope:Value(Vector2.new(584, 312)),
		customPages = scope:Value({
			{
				name = "example 1",
				icon = "rbxassetid://10251677039",
				renderCallback = function()
					print("render page 1")
				end,
				cleanupCallback = function()
					print("unrender page 1")
				end
			},
			{
				name = "example 2",
				icon = "rbxassetid://10251677039",
				renderCallback = function()
					
				end,
				cleanupCallback = function()
					
				end
			}
		}),

		callbacks = {
			showWindow = showWindowValue,
			hideWindow = scope:Value(nil),
		},

		statistics = {
			selectedCategory = scope:Value(nil),

			memoryStats = scope:Value({
				prefix = "MB",
				name = "Memory",
				stats = {
					Graphics = {
						Particles = 100,
						Models = 100,
						SpatialHash = 100,
						Terrain = 100,
						Texture = 100,
						-- Character = 100
					},
					Roblox = {
						Internal = 100,
						Http = 100,
						Instances = 100,
						Signals = 100,
						LuaHeap = 100,
						Script = 100,
					},
					Physics = {
						Collisions = 100,
						Parts = 100,
					},
					World = {
						Sounds = 100,
						CSG = 100,
						Navigation = 100,
						Animation = 100,
						Gui = 100,
						Voxels = 100,
					}
				},
				graph = { },
			}),
			networkStats = scope:Value({
				prefix = "kbps",
				name = "Network",
				stats = {
					Data = {
						Send = 100,
						Recv = 100,
					},
					Physics = {
						Send = 100,
						Recv = 100,
					},
				},
				graph = { },
			}),
			instanceStats = scope:Value({
				prefix = "",
				name = "Instance",
				stats = {
					Count = 10,
					Collisions = 100,
					Movingd = 100,
				},
				graph = { },
			}),
			metadataStats = scope:Value({
				prefix = "",
				name = "Metadata",
				stats = {
					["Rbxl Version"] = version[2],
					["Place Version"] = game.PlaceVersion,
				},
				graph = { },
			}),
			drawcallStats = scope:Value({
				prefix = "",
				name = "Drawcall",
				stats = {
					Scene = {
						Drawcalls = 10,
						Triangles = 100,
					},
					Shadows = {
						Drawcalls = 10,
						Triangles = 100,
					}
				},
				graph = { },
			}),
			frameStats = scope:Value({
				prefix = "ms",
				name = "Frame",
				stats = {
					["Frame"] = 100,
					["Heartbeat"] = 100,
					["Physics"] = 100,
					["GPU Time"] = 100,
					["CPU Time"] = 100,
				},
				graph = { },
			}),
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

			selectedInstance = scope:Value(),
		},

		logging = {
			logs = scope:Value({
				
			}),

			sortOrder = scope:Value("Time"),
			context = scope:Value("Client")
		},

		interceptor = {
			intercepted = scope:Value({
				
			})
		},

		actions = {
			closedFolders = scope:Value({}),

			actions = scope:Value({
				{
					path = { "Example", "A" },
					name = "Command 1",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				{
					path = { "Example", "A" },
					name = "Command 2",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				{
					path = { "Example", "A" },
					name = "Command 3",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},

				{
					path = { "Example", "B" },
					name = "Command 1",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				{
					path = { "Example", "B" },
					name = "Command 2",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				{
					path = { "Example", "B" },
					name = "Command 3",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				
				{
					path = { "Example" },
					name = "Command 1",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				{
					path = { "Example" },
					name = "Command 2",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
				{
					path = { "Example" },
					name = "Command 3",
					description = "",

					uuid = "",
					context = "Server",

					arguments = { }
				},
			})
		},

		liveEvents = {
			events = scope:Value({ })
		},

		signals = {
			minimiseWindow = Signal.new(),

			actions = {
				executeAction = Signal.new()
			},

			logging = {
				exportLogs = Signal.new(),
				clearLogs = Signal.new(),
				breakpointLogs = Signal.new()
			},

			sandbox = {
				evalClientCode = Signal.new(),
				evalServerCode = Signal.new(),
			},

			interceptor = {
				repeatEvent = Signal.new()
			},

			statistics = {
				refresh = Signal.new(),

				enableAutoRefresh = Signal.new(),
				disableAutoRefresh = Signal.new(),
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
