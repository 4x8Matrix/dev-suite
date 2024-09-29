local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local LiveEvents = {}

LiveEvents.DisplayName = `LiveEvents`
LiveEvents.DisplayOrder = 6
LiveEvents.DisplayIcon = Theme.LiveEventsIcon
LiveEvents.Enabled = false

function LiveEvents.Render(scope: Scope, _props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {}

return {
	Render = LiveEvents.Render,
	Properties = {
		DisplayOrder = LiveEvents.DisplayOrder,
		DisplayName = LiveEvents.DisplayName,
		DisplayIcon = LiveEvents.DisplayIcon,

		Enabled = LiveEvents.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
