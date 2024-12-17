local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIStroke = require(Package.Client.Interface.Components.UIStroke)
local UIDrag = require(Package.Client.Interface.Components.UIDrag)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)

local SidebarPanel = require(Package.Client.Interface.Fusion.SidebarPanel)
local ContentPanel = require(Package.Client.Interface.Fusion.ContentPanel)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

type StatStructure = {
	prefix: string,
	name: string,
	stats: {
		[string]: {
			[string]: number
		} | string,
	},
	graph: {
		[string]: number
	}
}

return function(scope: FusionTypes.Scope, props: {
	selectedPage: FusionTypes.Value<FusionTypes.Value<PageTypes.PageElement<FusionTypes.Scope, any>>>,
	size: FusionTypes.Value<Vector2>,

	customPages: FusionTypes.Value<{
		{
			name: string,
			icon: string?,
			renderCallback: () -> () -> (),
			cleanupCallback: () -> ()
		}
	}>,
	
	callbacks: {
		showWindow: FusionTypes.Value<() -> ()>,
		hideWindow: FusionTypes.Value<() -> ()>,
	},

	statistics: {
		selectedCategory: FusionTypes.Value<string?>,

		memoryStats: FusionTypes.Value<StatStructure>,
		networkStats: FusionTypes.Value<StatStructure>,
		instanceStats: FusionTypes.Value<StatStructure>,
		metadataStats: FusionTypes.Value<StatStructure>,
		drawcallStats: FusionTypes.Value<StatStructure>,
		frameStats: FusionTypes.Value<StatStructure>
	},

	explorer: {
		instances: { Instance },

		clickToSelect: FusionTypes.Value<boolean>,
		showSelection: FusionTypes.Value<boolean>,

		selectedInstance: FusionTypes.Value<Instance>
	},
	
	actions: {
		closedFolders: FusionTypes.Value<{ string }>,

		actions: {
			{
				path: { string },
				name: string,
				description: string,

				uuid: string,
				context: "Server" | "Client",

				arguments: {
					{
						type: string,
						name: string,
						default: string,
					}
				}
			}
		}
	},

	liveEvents: {
		events: FusionTypes.Value<{
			{
				instanceName: string,
				className: string,
				propertyName: string,
				propertyValue: any,
			}
		}>
	},

	interceptor: {
		intercepted: FusionTypes.Value<{
			eventType: "RemoteEvent" | "BindableEvent" | "RemoteFunction" | "BindableFunction",
			eventUUID: string?,

			eventName: string,
			eventData: string,
			eventSize: string,

			ancestors: {
				{
					class: string,
					name: string
				}
			},

			context: "Server" | "Client",
		}>
	},
	
	logging: {
		sortOrder: FusionTypes.Value<"Alphabetical" | "Time" | "Priority">,
		context: FusionTypes.Value<"Server" | "Client">,

		logs: FusionTypes.Value<{
			{
				message: string,
				type: Enum.MessageType,
				context: "Server" | "Client",
				time: number,
				count: number,
			}
		}>
	},

	signals: {
		actions: {
			executeAction: SignalTypes.Signal<string>
		},

		sandbox: {
			evalServerCode: SignalTypes.Signal<string>,
			evalClientCode: SignalTypes.Signal<string>,
		},

		interceptor: {
			repeatEvent: SignalTypes.Signal<string>,
		},

		logging: {
			exportLogs: SignalTypes.Signal<()>,
			clearLogs: SignalTypes.Signal<()>,
			breakpointLogs: SignalTypes.Signal<()>
		},

		statistics: {
			refresh: SignalTypes.Signal<()>,

			enableAutoRefresh: SignalTypes.Signal<()>,
			disableAutoRefresh: SignalTypes.Signal<()>
		},
	
		minimiseWindow: SignalTypes.Signal<()>,
	}
}): ScreenGui
	local goalPosition: FusionTypes.Value<number> = scope:Value(0)
	local tween: FusionTypes.Tween<number> = scope:Tween(goalPosition, TweenInfo.new(0.15, Enum.EasingStyle.Quad))
	
	local dragStartPosition
	local dragStartSize

	props.callbacks.hideWindow:set(function()
		goalPosition:set(0)
	end)

	props.callbacks.showWindow:set(function()
		goalPosition:set(1)
	end)

	return scope:New("ScreenGui")({
		IgnoreGuiInset = true,
		ClipToDeviceSafeArea = false,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ScreenInsets = Enum.ScreenInsets.None,

		DisplayOrder = math.huge,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		Enabled = scope:Computed(function(use)
			local value = use(tween)

			return value ~= 0
		end),

		[Fusion.Children] = {
			ContentFrame = scope:New("CanvasGroup")({
				AnchorPoint = Vector2.new(0.5, 0.5),

				Size = scope:Computed(function(use)
					local targetSize = use(props.size)
					local value = use(tween)

					return UDim2.fromOffset(targetSize.X / 2, targetSize.Y / 2):Lerp(UDim2.fromOffset(targetSize.X, targetSize.Y), value)
				end),

				Position = UDim2.fromScale(0.5, 0.5),

				BackgroundColor3 = Theme.BaseBackgroundColor3,

				[Fusion.Children] = {
					UIDrag = UIDrag(scope),
					UIResize = ImageLabel(scope, {
						Size = UDim2.fromOffset(10, 15),
						Image = Theme.PlayIcon,
						Rotation = 45,
						Position = UDim2.fromScale(1, 1) + UDim2.fromOffset(0, 5),
						ScaleType = Enum.ScaleType.Stretch,
						ImageColor3 = Theme.BaseIconColor3,
						ImageTransparency = 0.5,

						AnchorPoint = Vector2.new(1, 1),

						[Fusion.Children] = {
							Drag = scope:New("UIDragDetector")({
								DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,

								[Fusion.OnEvent("DragContinue")] = function(position)
									local alpha = position - dragStartPosition
									local newSize = dragStartSize + alpha

									props.size:set(Vector2.new(
										math.min(math.max(newSize.X, 445), 760),
										math.min(math.max(newSize.Y, 237), 405)
									))
								end,

								[Fusion.OnEvent("DragStart")] = function(position)
									dragStartPosition = position
									dragStartSize = Fusion.peek(props.size)
								end
							})
						}
					}),

					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({
						AspectRatio = 1.872
					}),

					UIGradient = scope:New("UIGradient")({
						Transparency = scope:Computed(function(use)
							local value = use(tween)

							return NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1 - value),
								NumberSequenceKeypoint.new(1, 1 - value)
							})
						end),
					}),

					UICorner = UICorner(scope, {}),

					UIStroke = UIStroke(scope, {
						transparency = scope:Computed(function(use)
							local value = use(tween)

							return 1 - value
						end)
					}),

					UIPadding = UIPadding(scope, {
						paddingWidth = UDim.new(0.025, 0),
						paddingHeight = UDim.new(0.05, 0)
					}),

					Content = scope:New("CanvasGroup")({
						Size = UDim2.fromScale(1, 1),

						BackgroundTransparency = 1,

						[Fusion.Children] = {
							SidebarPanel = SidebarPanel(scope, {
								selectedPage = props.selectedPage,
								customPages = props.customPages,
							}),
							ContentPanel = ContentPanel(scope, {
								selectedPage = props.selectedPage,
								signals = props.signals,
								explorer = props.explorer,
								interceptor = props.interceptor,
								logging = props.logging,
								liveEvents = props.liveEvents,
								actions = props.actions,
								statistics = props.statistics,

								minimiseWindowRequested = function()
									goalPosition:set(0)

									task.wait(0.2)

									props.signals.minimiseWindow:Fire()
								end
							}),

							UICorner = UICorner(scope, {}),
						}
					})
				}
			})
		}
	})
end
