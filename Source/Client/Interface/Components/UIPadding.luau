local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

return function(scope: FusionTypes.Scope, props: {
	paddingWidth: UDim,
	paddingHeight: UDim,
})
	return scope:New("UIPadding")({
		PaddingBottom = UDim.new(props.paddingHeight.Scale / 2, props.paddingHeight.Offset / 2),
		PaddingTop = UDim.new(props.paddingHeight.Scale / 2, props.paddingHeight.Offset / 2),

		PaddingLeft = UDim.new(props.paddingWidth.Scale / 2, props.paddingWidth.Offset / 2),
		PaddingRight = UDim.new(props.paddingWidth.Scale / 2, props.paddingWidth.Offset / 2),
	})
end
