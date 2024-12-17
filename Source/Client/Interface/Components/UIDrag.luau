local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

return function(scope: FusionTypes.Scope)
	return scope:New("UIDragDetector")({
		BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.EntireObject,
	})
end
