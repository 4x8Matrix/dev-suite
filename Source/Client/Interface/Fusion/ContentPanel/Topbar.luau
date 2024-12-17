local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Theme = require(Package.Client.Interface.Theme)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local ImageButton = require(Package.Client.Interface.Components.ImageButton)

local Fusion = require(Package.Parent.Fusion)

return function(scope: FusionTypes.Scope, props: {
	selectedPage: FusionTypes.Value<Frame>,

	minimiseWindowRequested: () -> (),
}): Frame
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 0.1),
		Position = UDim2.fromScale(0, 0),

		BackgroundColor3 = Theme.BaseTopbarColor3,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0, 0),
				paddingWidth = UDim.new(0.05, 0)
			}),

			HeaderLabel = TextLabel(scope, {
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = scope:Computed(function(use)
					local frame = scope.peek(props.selectedPage)
					
					use(props.selectedPage)
		
					return `● Status: <i>{frame and frame.Properties.DisplayName or `No Page Selected`}</i>` 
				end),

				FontFace = Theme.TopbarLabelFont,
				TextColor3 = Theme.TopbarLabelColor3,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.4, 0),
						paddingWidth = UDim.new(0, 0)
					})
				}
			}),

			ExitButton = ImageButton(scope, {
				Image = Theme.MinimiseIcon,

				Size = UDim2.fromScale(1, 0.7),

				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),

				[Fusion.OnEvent("Activated")] = function()
					props.minimiseWindowRequested()
				end,

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			})
		}
	})
end
