local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local Theme = require(Package.Client.Interface.Theme)

local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local TextButton = require(Package.Client.Interface.Components.TextButton)
local RadioButton = require(Package.Client.Interface.Components.RadioButton)
local TextBox = require(Package.Client.Interface.Components.TextBox)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local UICorner = require(Package.Client.Interface.Components.UICorner)

local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)

local Logging = {}

Logging.DisplayName = `Logging`
Logging.DisplayOrder = 9
Logging.DisplayIcon = Theme.LoggingIcon
Logging.Enabled = true

function Logging.Render(scope: Scope, props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0.045, 0),
				paddingWidth = UDim.new(0.025, 0)
			}),

			LeftPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.235, 1),
				BackgroundTransparency = 1,

				[Fusion.Children] = {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
		
						Padding = UDim.new(0.025, 0),
					}),

					SortOrderPanel = scope:New("Frame")({
						Size = UDim2.fromScale(1, 0.34),
						BackgroundColor3 = Theme.BaseTopbarColor3,
						LayoutOrder = 1,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {}),

							Background = scope:New("Frame")({
								Size = UDim2.fromScale(0.5, 1),
								BackgroundColor3 = Theme.BaseTopbarColor3,
							}),

							Content = scope:New("Frame")({
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,

								[Fusion.Children] = {
									UIPadding = UIPadding(scope, {
										paddingHeight = UDim.new(0.2, 0),
										paddingWidth = UDim.new(0.2, 0)
									}),

									TitleLabel = TextLabel(scope, {
										Text = "Sort Order",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Size = UDim2.fromScale(1, 0.175)
									}),

									RadioButton0 = RadioButton(scope, {
										Size = UDim2.fromScale(0.2, 0.2),
										Position = UDim2.fromScale(0, 0.3),

										toggled = scope:Computed(function(use)
											local sortOrder = use(props.logging.sortOrder)

											return sortOrder == "Alphabetical"
										end),

										[Fusion.OnEvent("Activated")] = function()
											props.logging.sortOrder:set("Alphabetical")
										end,
									}),

									RadioButtonText0 = TextLabel(scope, {
										Text = "Alphabet...",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Position = UDim2.fromScale(0.25, 0.3),
										Size = UDim2.fromScale(1, 0.175)
									}),

									RadioButton1 = RadioButton(scope, {
										Size = UDim2.fromScale(0.2, 0.2),
										Position = UDim2.fromScale(0, 0.55),

										toggled = scope:Computed(function(use)
											local sortOrder = use(props.logging.sortOrder)

											return sortOrder == "Time"
										end),

										[Fusion.OnEvent("Activated")] = function()
											props.logging.sortOrder:set("Time")
										end,
									}),

									RadioButtonText1 = TextLabel(scope, {
										Text = "Time",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Position = UDim2.fromScale(0.25, 0.55),
										Size = UDim2.fromScale(1, 0.175)
									}),

									RadioButton2 = RadioButton(scope, {
										Size = UDim2.fromScale(0.2, 0.2),
										Position = UDim2.fromScale(0, 0.8),

										toggled = scope:Computed(function(use)
											local sortOrder = use(props.logging.sortOrder)

											return sortOrder == "Priority"
										end),

										[Fusion.OnEvent("Activated")] = function()
											props.logging.sortOrder:set("Priority")
										end,
									}),

									RadioButtonText2 = TextLabel(scope, {
										Text = "Priority",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Position = UDim2.fromScale(0.25, 0.8),
										Size = UDim2.fromScale(1, 0.175)
									}),
								}
							})
						}
					}),

					ContextPanel = scope:New("Frame")({
						Size = UDim2.fromScale(1, 0.285),
						BackgroundColor3 = Theme.BaseTopbarColor3,
						LayoutOrder = 2,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {}),

							Background = scope:New("Frame")({
								Size = UDim2.fromScale(0.5, 1),
								BackgroundColor3 = Theme.BaseTopbarColor3,
							}),

							Content = scope:New("Frame")({
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,

								[Fusion.Children] = {
									UIPadding = UIPadding(scope, {
										paddingHeight = UDim.new(0.2, 0),
										paddingWidth = UDim.new(0.2, 0)
									}),

									TitleLabel = TextLabel(scope, {
										Text = "Context",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Size = UDim2.fromScale(1, 0.2)
									}),

									RadioButton0 = RadioButton(scope, {
										Size = UDim2.fromScale(0.275, 0.275),
										Position = UDim2.fromScale(0, 0.3),

										toggled = scope:Computed(function(use)
											local context = use(props.logging.context)

											return context == "Server"
										end),

										[Fusion.OnEvent("Activated")] = function()
											props.logging.context:set("Server")
										end,
									}),

									RadioButtonText0 = TextLabel(scope, {
										Text = "Server",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Position = UDim2.fromScale(0.25, 0.3),
										Size = UDim2.fromScale(1, 0.2)
									}),

									RadioButton1 = RadioButton(scope, {
										Size = UDim2.fromScale(0.275, 0.275),
										Position = UDim2.fromScale(0, 0.66),
										
										toggled = scope:Computed(function(use)
											local context = use(props.logging.context)
											
											return context == "Client"
										end),

										[Fusion.OnEvent("Activated")] = function()
											props.logging.context:set("Client")
										end,
									}),

									RadioButtonText1 = TextLabel(scope, {
										Text = "Client",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Position = UDim2.fromScale(0.25, 0.66),
										Size = UDim2.fromScale(1, 0.2)
									})
								}
							})
						}
					}),

					ActionsPanel = scope:New("Frame")({
						Size = UDim2.fromScale(1, 0.375),
						BackgroundColor3 = Theme.BaseTopbarColor3,
						LayoutOrder = 3,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {}),

							Background = scope:New("Frame")({
								Size = UDim2.fromScale(0.5, 1),
								BackgroundColor3 = Theme.BaseTopbarColor3,
							}),

							Content = scope:New("Frame")({
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,

								[Fusion.Children] = {
									UIPadding = UIPadding(scope, {
										paddingHeight = UDim.new(0.2, 0),
										paddingWidth = UDim.new(0.2, 0)
									}),

									TitleLabel = TextLabel(scope, {
										Text = "Actions",
										TextTransparency = 0.5,
										TextXAlignment = Enum.TextXAlignment.Left,
										Size = UDim2.fromScale(1, 0.15)
									}),

									ExportTextButton = TextButton(scope, {
										Size = UDim2.fromScale(1, 0.265),
										Position = UDim2.fromScale(0, 0.2),
										BackgroundTransparency = 0,
										BackgroundColor3 = Theme.BaseSidebarColor3,
										Text = "Export",
										TextTransparency = 0.5,

										[Fusion.OnEvent("Activated")] = function()
											props.signals.logging.exportLogs:Fire()
										end,

										[Fusion.Children] = {
											UICorner = UICorner(scope, {}),
											UIPadding = UIPadding(scope, {
												paddingHeight = UDim.new(0.4, 0),
												paddingWidth = UDim.new(0, 0)
											}),
										}
									}),

									ClearTextButton = TextButton(scope, {
										Size = UDim2.fromScale(1, 0.265),
										Position = UDim2.fromScale(0, 0.5),
										BackgroundTransparency = 0,
										BackgroundColor3 = Theme.BaseSidebarColor3,
										Text = "Clear",
										TextTransparency = 0.5,

										[Fusion.OnEvent("Activated")] = function()
											props.signals.logging.clearLogs:Fire()
										end,

										[Fusion.Children] = {
											UICorner = UICorner(scope, {}),
											UIPadding = UIPadding(scope, {
												paddingHeight = UDim.new(0.4, 0),
												paddingWidth = UDim.new(0, 0)
											}),
										}
									}),

									BreakpointTextButton = TextButton(scope, {
										Size = UDim2.fromScale(1, 0.265),
										Position = UDim2.fromScale(0, 0.8),
										BackgroundTransparency = 0,
										BackgroundColor3 = Theme.BaseSidebarColor3,
										Text = "Breakpoint",
										TextTransparency = 0.5,

										[Fusion.OnEvent("Activated")] = function()
											props.signals.logging.breakpointLogs:Fire()
										end,

										[Fusion.Children] = {
											UICorner = UICorner(scope, {}),
											UIPadding = UIPadding(scope, {
												paddingHeight = UDim.new(0.4, 0),
												paddingWidth = UDim.new(0, 0)
											}),
										}
									})
								}
							})
						}
					}),
				}
			}),

			ContentPanel = scope:New("ScrollingFrame")({
				Size = UDim2.fromScale(0.75, 1),
				Position = UDim2.fromScale(0.25, 0),
				BackgroundColor3 = Theme.BaseTopbarColor3,
				AutomaticCanvasSize = Enum.AutomaticSize.XY,
				CanvasSize = UDim2.fromScale(0, 0),
				ClipsDescendants = true,
				MidImage = Theme.MiddleScrollingFrameIcon,
				TopImage = Theme.TopScrollingFrameIcon,
				BottomImage = Theme.BottomScrollingFrameIcon,
				ScrollBarImageColor3 = Theme.AccentColor3,
				ScrollBarThickness = 3,

				[Fusion.Children] = scope:Computed(function(use0)
					local messageLogs = table.clone(use0(props.logging.logs))
					local sortOrder = use0(props.logging.sortOrder)
					local context = use0(props.logging.context)
					local messageLabels = {}

					if sortOrder == "Alphabetical" then
						table.sort(messageLogs, function(a, b)
							return a.message < b.message
						end)
					elseif sortOrder == "Priority" then
						table.sort(messageLogs, function(a, b)
							return a.type.Value > b.type.Value
						end)
					end

					for index, logObject in messageLogs do
						table.insert(messageLabels, scope:New("Frame")({
							Size = UDim2.new(1, 0, 0, 15),
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundTransparency = 1,
							LayoutOrder = index,
							Visible = context == logObject.context,

							[Fusion.Children] = {
								ContextImage = ImageLabel(scope, {
									Size = UDim2.fromOffset(15, 15),
									Image = logObject.context == "Server" and Theme.ServerIcon or Theme.ClientIcon,
									ImageColor3 = logObject.context == "Server" and Theme.ServerColor3 or Theme.ClientColor3,

									[Fusion.Children] = {
										UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),
									}
								}),

								Content = TextBox(scope, {
									Size = UDim2.fromScale(1, 1),
									Position = UDim2.fromOffset(20, 0),
									TextXAlignment = Enum.TextXAlignment.Left,
									TextWrapped = false,
									TextScaled = false,
									TextSize = 12,
									Text = `{
										logObject.type ~= Enum.MessageType.MessageOutput and "<b>" or ""
									}{
										logObject.message
									}{
										logObject.type ~= Enum.MessageType.MessageOutput and "</b>" or ""
									}{
										logObject.count ~= 1 and ` <i>x{logObject.count}</i>` or ``
									}`,
									TextColor3 = logObject.type == Enum.MessageType.MessageOutput and Theme.OutputLogColor
										or logObject.type == Enum.MessageType.MessageWarning and Theme.OutputWarnColor
										or logObject.type == Enum.MessageType.MessageError and Theme.OutputErrorColor
										or logObject.type == Enum.MessageType.MessageInfo and Theme.OutputInformationColor,
									AutomaticSize = Enum.AutomaticSize.X,
								})
							}
						}))
					end

					if #messageLogs == 0 then
						table.insert(messageLabels, scope:New("Frame")({
							Size = UDim2.fromScale(1, 0.2),
							BackgroundColor3 = Theme.BaseTopbarColor3,
						
							[Fusion.Children] = {
								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0.05, 0),
									paddingHeight = UDim.new(0.5, 0)
								}),
		
								TextLabel = TextLabel(scope, {
									TextTransparency = 0.5,
									Text = `No logs have been generated for the '{context}' environment.`
								})
							}
						}))
					end

					return Sift.Dictionary.merge(messageLabels, {
						UICorner = UICorner(scope, {}),

						UIListLayout = scope:New("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
							VerticalAlignment = Enum.VerticalAlignment.Top,
			
							Padding = UDim.new(0.025, 0),
						}),	

						UIPadding = UIPadding(scope, {
							paddingHeight = UDim.new(0, 10),
							paddingWidth = UDim.new(0, 20)
						}),
					})
				end)
			})
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {
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
		logging: {
			exportLogs: SignalTypes.Signal<()>,
			clearLogs: SignalTypes.Signal<()>,
			breakpointLogs: SignalTypes.Signal<()>
		},
	}
}

return {
	Render = Logging.Render,
	Properties = {
		DisplayOrder = Logging.DisplayOrder,
		DisplayName = Logging.DisplayName,
		DisplayIcon = Logging.DisplayIcon,

		Enabled = Logging.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
