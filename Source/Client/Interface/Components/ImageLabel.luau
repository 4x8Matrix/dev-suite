local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Sift = require(Package.Parent.Sift)

local Theme = require(Package.Client.Interface.Theme)

return function(scope: FusionTypes.Scope, props: {
	[any]: any
})
	return scope:New("ImageLabel")(Sift.Dictionary.merge({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.BaseIconColor3,

		ScaleType = Enum.ScaleType.Fit,
	}, props))
end
