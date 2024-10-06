local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Performance = {}

Performance.DisplayName = `Performance`
Performance.DisplayOrder = 9
Performance.DisplayIcon = Theme.PerformanceIcon
Performance.Enabled = false

function Performance.Render(scope: Scope, _props: Props)
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
	Render = Performance.Render,
	Properties = {
		DisplayOrder = Performance.DisplayOrder,
		DisplayName = Performance.DisplayName,
		DisplayIcon = Performance.DisplayIcon,

		Enabled = Performance.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
