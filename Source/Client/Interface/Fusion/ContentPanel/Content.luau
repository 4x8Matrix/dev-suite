local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local lastScope
local lastFrame
local lastRender

return function(scope: FusionTypes.Scope, props: {
	[any]: any
}): Frame
	table.insert(scope, function()
		if lastScope then
			Fusion.doCleanup(lastScope)
		end
	end)

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 0.9),
		Position = UDim2.fromScale(0, 0.1),

		BorderSizePixel = 0,

		BackgroundColor3 = Theme.BaseBackgroundColor3,

		[Fusion.Children] = {
			scope:Computed(function(use)
				local frame = use(props.selectedPage)

				if lastFrame == frame then
					return lastRender
				end

				lastFrame = frame

				local contentScope = Fusion.scoped(Fusion)

				if lastScope then
					Fusion.doCleanup(lastScope)
				end

				lastScope = contentScope

				if frame.CustomPage then
					table.insert(lastScope, frame.CleanupCallback)

					return frame.RenderCallback(contentScope, props)
				else
					lastRender = frame and frame.Render(contentScope, props) or nil
				
					return lastRender
				end
			end),
		}
	})
end
