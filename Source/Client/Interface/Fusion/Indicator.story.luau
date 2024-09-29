local Package = script.Parent.Parent.Parent.Parent

local Fusion = require(Package.Parent.Fusion)
local Signal = require(Package.Parent.Signal)

local Indicator = require(Package.Client.Interface.Fusion.Indicator)

return function(parent)
	local scope = Fusion.scoped(Fusion)

	local showIndicatorValue = scope:Value(nil)

	local windowObject = Indicator(scope, {
		callbacks = {
			showIndicator = showIndicatorValue,
			hideIndicator = scope:Value(nil),
		},

		signals = {
			openWindow = Signal.new()
		}
	})

	task.delay(0.1, function()
		Fusion.peek(showIndicatorValue)()
	end)

	windowObject.Parent = parent

	return function()
		windowObject:Destroy()

		Fusion.doCleanup(scope)
	end
end
