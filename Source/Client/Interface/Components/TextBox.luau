local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Sift = require(Package.Parent.Sift)

local Theme = require(Package.Client.Interface.Theme)

return function(scope: FusionTypes.Scope, props: {
	[any]: any
})
	return scope:New("TextBox")(Sift.Dictionary.merge({
		FontFace = Theme.BaseLabelFont,
		TextColor3 = Theme.BaseLabelColor3,
		
		RichText = true,

		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		TextScaled = true,
	}, props))
end
