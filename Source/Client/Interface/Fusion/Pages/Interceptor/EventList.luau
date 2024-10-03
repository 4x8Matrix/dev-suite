local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local Fusion = require(Package.Parent.Fusion)
local Sift = require(Package.Parent.Sift)
local ClassIndex = require(Package.Parent.ClassIndex)

local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Theme = require(Package.Client.Interface.Theme)

local FusionTypes = require(Package.Types.Fusion)

local EventList = {}

function EventList.Render(scope: FusionTypes.Scope, props: any, focusedEvent: FusionTypes.Value<any>)
	return scope:New("ScrollingFrame")({
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Fusion.Children] = scope:Computed(function(use)
			local interceptedEvents = use(props.interceptor.intercepted)
			local interceptedEventLabels = {}

			if #interceptedEvents == 0 then
				table.insert(interceptedEventLabels, scope:New("Frame")({
					Size = UDim2.fromScale(1, 0.2),
					BackgroundColor3 = Theme.BaseTopbarColor3,
				
					[Fusion.Children] = {
						UIPadding = UIPadding(scope, {
							paddingWidth = UDim.new(0.05, 0),
							paddingHeight = UDim.new(0.5, 0)
						}),

						TextLabel = TextLabel(scope, {
							TextTransparency = 0.5,
							Text = `No remotes have been intercepted yet, i'd suggest we do something!`
						})
					}
				}))
			end

			for index, event in interceptedEvents do
				local iconInformation = ClassIndex.GetClassIcon(event.eventType)

				table.insert(interceptedEventLabels, 1, scope:New("Frame")({
					Size = UDim2.new(1, 0, 0, 35),
					BackgroundColor3 = index % 2 == 0 and Theme.BaseTopbarColor3 or Theme.BaseSidebarColor3,
					LayoutOrder = index,

					[Fusion.Children] = {
						UICorner = UICorner(scope, { }),

						UIPadding = UIPadding(scope, {
							paddingWidth = UDim.new(0.05, 0),
							paddingHeight = UDim.new(0.5, 0)
						}),

						Icon = ImageLabel(scope, {
							Size = UDim2.fromScale(1, 1),
							Image = iconInformation.Image,
							ImageRectOffset = iconInformation.ImageRectOffset,
							ImageRectSize = iconInformation.ImageRectSize,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
							}
						}),

						ArrowIcon0 = ImageLabel(scope, {
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.1, 0),
							Image = Theme.StraightArrowIcon,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
							}
						}),

						ContextIcon = ImageLabel(scope, {
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.165, 0),
							Image = event.context == "Server" and Theme.ServerIcon or Theme.ClientIcon,
							ImageColor3 = event.context == "Server" and Theme.ServerColor3 or Theme.ClientColor3,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
							}
						}),

						ArrowIcon1 = ImageLabel(scope, {
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.23, 0),
							Image = Theme.StraightArrowIcon,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
							}
						}),

						RemoteInformation = TextLabel(scope, {
							Size = UDim2.fromScale(0.4, 1),
							Position = UDim2.fromScale(0.33, 0),
							TextTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextScaled = false,
							TextTruncate = Enum.TextTruncate.AtEnd,

							Text = `{event.eventName} - <i>{event.eventSize}</i>`,

							[Fusion.Children] = {
								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0, 0),
									paddingHeight = UDim.new(0.1, 0)
								}),
							}
						}),

						MoreInformationButton = Button(scope, {
							Size = UDim2.fromScale(1.4, 1.4),
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.fromScale(1.01, 0.5),
							BackgroundTransparency = 0,
							BackgroundColor3 = index % 2 == 0 and Theme.BaseSidebarColor3 or Theme.BaseTopbarColor3,

							[Fusion.OnEvent("Activated")] = function()
								focusedEvent:set(event)
							end,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

								UICorner = UICorner(scope, {
									level = 0.85,
								}),

								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0.2, 0),
									paddingHeight = UDim.new(0.2, 0)
								}),

								QuestionIcon = ImageLabel(scope, {
									Size = UDim2.fromScale(1, 1),
									Position = UDim2.fromScale(0.165, 0),
									Image = Theme.QuestionIcon,

									[Fusion.Children] = {
										UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
									}
								}),
							}
						}),

						RepeatEventButton = Button(scope, {
							Size = UDim2.fromScale(1.4, 1.4),
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.fromScale(0.95, 0.5),
							BackgroundTransparency = 0,
							BackgroundColor3 = index % 2 == 0 and Theme.BaseSidebarColor3 or Theme.BaseTopbarColor3,
							Visible = event.context == "Server",

							[Fusion.OnEvent("Activated")] = function()
								props.signals.interceptor.repeatEvent:Fire(event.eventUUID)
							end,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

								UICorner = UICorner(scope, {
									level = 0.85,
								}),

								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0.3, 0),
									paddingHeight = UDim.new(0.3, 0)
								}),

								RepeatIcon = ImageLabel(scope, {
									Size = UDim2.fromScale(1, 1),
									Position = UDim2.fromScale(0.165, 0),
									Image = Theme.RepeatIcon,

									[Fusion.Children] = {
										UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
									}
								}),
							}
						})
					}
				}))
			end

			return Sift.Dictionary.merge(interceptedEventLabels, {
				UIListLayout = scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Top,
	
					Padding = UDim.new(0.025, 0),
				}),

				UIPadding = UIPadding(scope, {
					paddingWidth = UDim.new(0, 10),
					paddingHeight = UDim.new(0, 10)
				}),
			})
		end)
	})
end

return EventList