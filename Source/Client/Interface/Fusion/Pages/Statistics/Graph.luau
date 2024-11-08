local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local SignalTypes = require(Package.Types.Signal)

local Graph = {}

function Graph.render(_scope: Scope, _props: Props)
	-- to-do, later date.
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

return Graph