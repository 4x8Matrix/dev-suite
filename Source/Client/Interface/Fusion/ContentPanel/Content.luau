local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

return function(scope: FusionTypes.Scope, props: {
	selectedPage: FusionTypes.Value<Frame>,

	signals: { [any]: any }
}): Frame
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 0.9),
		Position = UDim2.fromScale(0, 0.1),

		BorderSizePixel = 0,

		BackgroundColor3 = Theme.BaseBackgroundColor3,

		[Fusion.Children] = {
			scope:Computed(function(use)
				local frame = scope.peek(props.selectedPage)
				
				use(props.selectedPage)
	
				return frame and frame.Render(scope, props) or nil
			end),
		}
	})
end
