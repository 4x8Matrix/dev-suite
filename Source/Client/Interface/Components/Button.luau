local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Sift = require(Package.Parent.Sift)

return function(scope: FusionTypes.Scope, props: {
	[any]: any
})
	return scope:New("ImageButton")(Sift.Dictionary.merge({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		ScaleType = Enum.ScaleType.Fit,
	}, props))
end
