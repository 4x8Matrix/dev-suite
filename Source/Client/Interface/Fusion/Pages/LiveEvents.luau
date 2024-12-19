local Package = script.Parent.Parent.Parent.Parent.Parent

local ClassIndex = require(Package.Parent.ClassIndex)
local Sift = require(Package.Parent.Sift)

local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local VALUE_TYPE_TEXT_COLORS = table.freeze({
	["boolean"] = Theme.BooleanColor,
	["number"] = Theme.NumberColor,
	["Vector3"] = Theme.NumberColor,
	["CFrame"] = Theme.NumberColor,
	["nil"] = Theme.NilColor,
	["string"] = Theme.StringColor,
	["EnumItem"] = Theme.EnumColor,
	["Instance"] = Theme.InstanceColor
})

local LiveEvents = {}

LiveEvents.DisplayName = `LiveEvents`
LiveEvents.DisplayOrder = 10
LiveEvents.DisplayIcon = Theme.LiveEventsIcon
LiveEvents.Enabled = true

function LiveEvents.Render(scope: Scope, props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UICorner = UICorner(scope, {}),

			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0, 10),
				paddingWidth = UDim.new(0, 10)
			}),

			ScrollingFrame = scope:New("ScrollingFrame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ClipsDescendants = true,
				MidImage = Theme.MiddleScrollingFrameIcon,
				TopImage = Theme.TopScrollingFrameIcon,
				BottomImage = Theme.BottomScrollingFrameIcon,
				ScrollBarImageColor3 = Theme.AccentColor3,
				ScrollBarThickness = 3,

				[Fusion.Children] = scope:Computed(function(use)
					local events = use(props.liveEvents.events)
					local messageLabels = {}
		
					if #events == 0 then
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
									Text = `No events have been snooped on yet, go do something!`
								})
							}
						}))
					else
						for index, event in events do
							local imageData = ClassIndex.GetClassIcon(event.className)
							local valueColor = VALUE_TYPE_TEXT_COLORS[typeof(event.propertyValue)]
		
							if not valueColor then
								valueColor = Color3.new(1, 1, 1)
							end
		
							table.insert(messageLabels, 1, scope:New("Frame")({
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
										Image = imageData.Image,
										ImageRectOffset = imageData.ImageRectOffset,
										ImageRectSize = imageData.ImageRectSize,
			
										[Fusion.Children] = {
											UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
										}
									}),
			
									InstanceInformation = TextLabel(scope, {
										Size = UDim2.fromScale(0.4, 1),
										Position = UDim2.fromScale(0.075, 0),
										TextTransparency = 0.25,
										TextXAlignment = Enum.TextXAlignment.Left,
										TextScaled = false,
										TextTruncate = Enum.TextTruncate.AtEnd,
			
										Text = `<b>{event.instanceName}.{event.propertyName}</b>`,
			
										[Fusion.Children] = {
											UIPadding = UIPadding(scope, {
												paddingWidth = UDim.new(0, 0),
												paddingHeight = UDim.new(0.1, 0)
											}),
										}
									}),
		
									ArrowIcon = ImageLabel(scope, {
										Size = UDim2.fromScale(1, 1),
										Position = UDim2.fromScale(0.49, 0),
										Image = Theme.StraightArrowIcon,
		
										[Fusion.Children] = {
											UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
										}
									}),
		
									ValueInformation = TextLabel(scope, {
										Size = UDim2.fromScale(0.5, 1),
										Position = UDim2.fromScale(0.55, 0),
										TextTransparency = 0.25,
										TextXAlignment = Enum.TextXAlignment.Left,
										TextScaled = false,
										TextTruncate = Enum.TextTruncate.AtEnd,
			
										Text = `<i>{event.propertyValue}</i>`,
										TextColor3 = valueColor,
			
										[Fusion.Children] = {
											UIPadding = UIPadding(scope, {
												paddingWidth = UDim.new(0, 0),
												paddingHeight = UDim.new(0.1, 0)
											}),
										}
									}),
								}
							}))
						end
					end
		
					return Sift.Dictionary.merge(messageLabels, {
						UIListLayout = scope:New("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
							VerticalAlignment = Enum.VerticalAlignment.Top,
			
							Padding = UDim.new(0.025, 0),
						}),
					})
				end)
			}),
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {
	liveEvents: {
		events: FusionTypes.Value<{
			{
				instanceName: string,
				className: string,
				propertyName: string,
				propertyValue: any,
			}
		}>
	}
}

return {
	Render = LiveEvents.Render,
	Properties = {
		DisplayOrder = LiveEvents.DisplayOrder,
		DisplayName = LiveEvents.DisplayName,
		DisplayIcon = LiveEvents.DisplayIcon,

		Enabled = LiveEvents.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
