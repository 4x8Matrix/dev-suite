local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

return function(scope: FusionTypes.Scope, props: {
	level: number?,
})
	return scope:New("UICorner")({
		CornerRadius = UDim.new(0, 8 - ((props.level or 1 - 1) * 2)),
	})
end
