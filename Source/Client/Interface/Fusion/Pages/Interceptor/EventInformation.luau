local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)
local ClassIndex = require(Package.Parent.ClassIndex)

local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextBox = require(Package.Client.Interface.Components.TextBox)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Theme = require(Package.Client.Interface.Theme)

local FusionTypes = require(Package.Types.Fusion)

local EventList = {}

function EventList.Render(scope: FusionTypes.Scope, _: any, focusedEvent: FusionTypes.Value<any>)
	local event = Fusion.peek(focusedEvent)

	local iconInformation = ClassIndex.GetClassIcon(event.eventType)
	local ancestorTree = {}

	local objects = table.clone(event.ancestors)

	table.insert(objects, {
		class = event.eventType,
		name = event.eventName
	})

	for depth, objectInformation in objects do
		local imageData = ClassIndex.GetClassIcon(objectInformation.class)
		local genuineDepth = depth - 1

		table.insert(ancestorTree, scope:New("Frame")({
			Size = UDim2.new(1, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 0,
			BackgroundColor3 = Theme.BaseTopbarColor3,
	
			[Fusion.Children] = {
				UIListLayout = scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
	
					Padding = UDim.new(0.025, 0),
				}),
	
				PaddingLeft = scope:New("Frame")({
					Size = UDim2.fromScale(0.1 * genuineDepth, 1),
					BackgroundTransparency = 1,
					LayoutOrder = 1
				}),
	
				Icon = ImageLabel(scope, {
					Size = UDim2.fromScale(0.75, 0.75),
					Image = imageData.Image,
					ImageRectOffset = imageData.ImageRectOffset,
					ImageRectSize = imageData.ImageRectSize,
					LayoutOrder = 3,
	
					[Fusion.Children] = {
						UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
					}
				}),
	
				Label = TextLabel(scope, {
					Size = UDim2.fromScale(1, 0.75),
					Text = `{objectInformation.name}`,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 4,
				})
			}
		}))
	end

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingWidth = UDim.new(0.05, 0),
				paddingHeight = UDim.new(0.09, 0)
			}),

			FilePathFrame = scope:New("Frame")({
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.5, 0),
				BackgroundTransparency = 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingWidth = UDim.new(0.1, 0),
						paddingHeight = UDim.new(0, 0)
					}),

					Background = scope:New("Frame")({
						Size = UDim2.fromScale(1, 1.02),
						BackgroundColor3 = Theme.BaseTopbarColor3,

						[Fusion.Children] = {
							UICorner = UICorner(scope, { }),
						}
					}),
	
					ScrollingFrame = scope:New("ScrollingFrame")({
						Size = UDim2.fromScale(1, 1),
						CanvasSize = UDim2.fromScale(0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.XY,
						ScrollBarThickness = 3,
						BackgroundTransparency = 1,
						MidImage = Theme.MiddleScrollingFrameIcon,
						TopImage = Theme.TopScrollingFrameIcon,
						BottomImage = Theme.BottomScrollingFrameIcon,
						ScrollBarImageColor3 = Theme.AccentColor3,
						ZIndex = 2,
						ClipsDescendants = true,

						[Fusion.Children] = Sift.Dictionary.merge(ancestorTree, {
							UIListLayout = scope:New("UIListLayout")({
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Vertical,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
				
								Padding = UDim.new(0.025, 0),
							}),
						})
					})
				}
			}),

			InformationFrame = scope:New("Frame")({
				Size = UDim2.fromScale(0.5, 1),
				BackgroundTransparency = 1,
				
				[Fusion.Children] = {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
		
						Padding = UDim.new(0.05, 0),
					}),
		
					TopField = scope:New("Frame")({
						Size = UDim2.new(1, 0, 0, 35),
						BackgroundColor3 = Theme.BaseTopbarColor3,
						BackgroundTransparency = 1,
						LayoutOrder = 1,
		
						[Fusion.Children] = {
							UICorner = UICorner(scope, { }),
		
							EventNameFrame = scope:New("Frame")({
								Size = UDim2.new(1, -45, 0, 35),
								Position = UDim2.new(0, 45, 0, 0),
								BackgroundColor3 = Theme.BaseTopbarColor3,
								LayoutOrder = 2,
				
								[Fusion.Children] = {
									UICorner = UICorner(scope, { }),
				
									UIPadding = UIPadding(scope, {
										paddingWidth = UDim.new(0.05, 0),
										paddingHeight = UDim.new(0.5, 0)
									}),

									TextLabel = TextLabel(scope, {
										Text = `<b>{event.eventName}</b>`,
										TextScaled = false,
										TextTruncate = Enum.TextTruncate.AtEnd,
										Size = UDim2.fromScale(0.6, 1),
										Position = UDim2.fromScale(0.2, 0),
										TextXAlignment = Enum.TextXAlignment.Left,
									}),

									Icon = ImageLabel(scope, {
										Size = UDim2.fromScale(1, 1),
										Position = UDim2.fromScale(0.05, 0),
										Image = iconInformation.Image,
										ImageRectOffset = iconInformation.ImageRectOffset,
										ImageRectSize = iconInformation.ImageRectSize,
			
										[Fusion.Children] = {
											UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
										}
									}),
								}
							}),
		
							BackEventButton = Button(scope, {
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 0,
								BackgroundColor3 = Theme.BaseTopbarColor3,
		
								[Fusion.OnEvent("Activated")] = function()
									focusedEvent:set(nil)
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
		
									BackIcon = ImageLabel(scope, {
										Size = UDim2.fromScale(0.7, 1),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.fromScale(0.5, 0.5),
										Image = Theme.StraightArrowIcon,
										Rotation = 180,
		
										[Fusion.Children] = {
											UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
										}
									}),
								}
							})
						}
					}),
		
					MiddleField = scope:New("Frame")({
						Size = UDim2.new(1, 0, 0, 35),
						BackgroundColor3 = Theme.BaseTopbarColor3,
						LayoutOrder = 2,
		
						[Fusion.Children] = {
							UICorner = UICorner(scope, { }),
		
							UIPadding = UIPadding(scope, {
								paddingWidth = UDim.new(0.1, 0),
								paddingHeight = UDim.new(0.5, 0)
							}),

							ContextIcon0 = ImageLabel(scope, {
								Size = UDim2.fromScale(1, 1),
								Position = UDim2.fromScale(0, 0),
								Image = event.context == "Server" and Theme.ClientIcon or Theme.ServerIcon,
								ImageColor3 = event.context == "Server" and Theme.ClientColor3 or Theme.ServerColor3,
	
								[Fusion.Children] = {
									UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
								}
							}),

							ArrowIcon1 = ImageLabel(scope, {
								Size = UDim2.fromScale(1, 1),
								Position = UDim2.fromScale(0.15, 0),
								Image = Theme.StraightArrowIcon,
	
								[Fusion.Children] = {
									UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
								}
							}),

							ContextIcon1 = ImageLabel(scope, {
								Size = UDim2.fromScale(1, 1),
								Position = UDim2.fromScale(0.33, 0),
								Image = event.context == "Server" and Theme.ServerIcon or Theme.ClientIcon,
								ImageColor3 = event.context == "Server" and Theme.ServerColor3 or Theme.ClientColor3,
	
								[Fusion.Children] = {
									UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
								}
							}),

							Divider = scope:New("Frame")({
								Size = UDim2.new(0, 4, 2, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								BorderSizePixel = 0,
								BackgroundColor3 = Theme.BaseBackgroundColor3,
							}),

							SizeLabel = TextLabel(scope, {
								Text = `<i>{event.eventSize}</i>`,
								Position = UDim2.fromScale(0.5, 0),
								Size = UDim2.fromScale(0.5, 1),
								TextXAlignment = Enum.TextXAlignment.Center,
							}),
						}
					}),
		
					ContentField = scope:New("Frame")({
						Size = UDim2.new(1, 0, 0, 155),
						BackgroundColor3 = Theme.BaseTopbarColor3,
						LayoutOrder = 3,
		
						[Fusion.Children] = {
							UICorner = UICorner(scope, { }),
		
							UIPadding = UIPadding(scope, {
								paddingWidth = UDim.new(0.1, 0),
								paddingHeight = UDim.new(0.1, 0)
							}),

							TextBox = TextBox(scope, {
								Size = UDim2.fromScale(1, 1),
								TextEditable = false,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Top,
								Text = event.eventData,
								FontFace = Theme.BaseLabelFont,
								TextColor3 = Theme.BaseLabelColor3,
								BackgroundTransparency = 1,
								TextWrapped = true,
							})
						}
					})
				}
			})
		}
	})
end

return EventList