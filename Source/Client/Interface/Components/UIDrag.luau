local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

return function(scope: FusionTypes.Scope, props: {
	bounds: FusionTypes.Value<ScreenGui>
})
	return scope:New("UIDragDetector")({
		BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.EntireObject,
		BoundingUI = scope:Computed(function(use)
			use(props.bounds)

			return scope.peek(props.bounds)
		end)
	})
end
