local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Statistics = {}

Statistics.DisplayName = `Statistics`
Statistics.DisplayOrder = 11
Statistics.DisplayIcon = Theme.StatisticsIcon
Statistics.Enabled = false

function Statistics.Render(scope: Scope, _props: Props)
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
	Render = Statistics.Render,
	Properties = {
		DisplayOrder = Statistics.DisplayOrder,
		DisplayName = Statistics.DisplayName,
		DisplayIcon = Statistics.DisplayIcon,

		Enabled = Statistics.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
