local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Package = script.Parent.Parent.Parent.Parent

local Theme = require(ReplicatedStorage.Packages.DevSuite.Client.Interface.Theme)
local FusionTypes = require(Package.Types.Fusion)

local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)

return function(scope: FusionTypes.Scope, props: {
	toggled: FusionTypes.Value<boolean>,

	[any]: any
})
	local propsClone = table.clone(props)

	local children = propsClone[Fusion.Children]
	local isToggled = propsClone.toggled

	propsClone.toggled = nil
	propsClone[Fusion.Children] = nil

	return scope:New("ImageButton")(Sift.Dictionary.merge({
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.BaseBackgroundColor3,

		ScaleType = Enum.ScaleType.Fit,

		[Fusion.Children] = {
			UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

			UICorner = scope:New("UICorner")({
				CornerRadius = UDim.new(1, 0)
			}),

			Fill = scope:New("Frame")({
				Size = UDim2.fromScale(0.4, 0.4),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Theme.AccentColor3,
				Visible = scope:Computed(function(use)
					return use(isToggled)
				end),

				[Fusion.Children] =  Sift.Dictionary.merge(children, {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),
		
					UICorner = scope:New("UICorner")({
						CornerRadius = UDim.new(1, 0)
					}),
				})
			})
		}
	}, propsClone))
end
