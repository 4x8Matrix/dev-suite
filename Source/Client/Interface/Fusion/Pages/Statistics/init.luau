local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local Graph = require(Package.Client.Interface.Fusion.Pages.Statistics.Graph)
local Views = require(Package.Client.Interface.Fusion.Pages.Statistics.Views)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Statistics = {}

Statistics.DisplayName = `Statistics`
Statistics.DisplayOrder = 9
Statistics.DisplayIcon = Theme.StatisticsIcon
Statistics.Enabled = true

function Statistics.Render(scope: Scope, props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = scope:Computed(function(use)
			local selectedCategory = use(props.statistics.selectedCategory)

			if selectedCategory then
				return Graph.render(scope, props)
			else
				return Views.render(scope, props)
			end
		end)
	})
end

type StatStructure = {
	prefix: string,
	name: string,
	stats: {
		[string]: {
			[string]: number
		} | string,
	},
	graph: {
		[string]: number
	}
}

type Scope = FusionTypes.Scope
type Props = {
	statistics: {
		selectedCategory: FusionTypes.Value<string?>,

		memoryStats: FusionTypes.Value<StatStructure>,
		networkStats: FusionTypes.Value<StatStructure>,
		instanceStats: FusionTypes.Value<StatStructure>,
		metadataStats: FusionTypes.Value<StatStructure>,
		drawcallStats: FusionTypes.Value<StatStructure>,
		frameStats: FusionTypes.Value<StatStructure>
	},

	signals: {
		statistics: {
			refresh: SignalTypes.Signal<()>,

			enableAutoRefresh: SignalTypes.Signal<()>,
			disableAutoRefresh: SignalTypes.Signal<()>
		},
	}
}

return {
	Render = Statistics.Render,
	Properties = {
		DisplayOrder = Statistics.DisplayOrder,
		DisplayName = Statistics.DisplayName,
		DisplayIcon = Statistics.DisplayIcon,

		Enabled = Statistics.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
