local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Theme = require(Package.Client.Interface.Theme)

return function(scope: FusionTypes.Scope, props: {
	transparency: number?
})
	return scope:New("UIStroke")({
		Thickness = Theme.UIStrokeThickness,
		Color = Theme.AccentColor3,
		Transparency = props.transparency or 0
	})
end
