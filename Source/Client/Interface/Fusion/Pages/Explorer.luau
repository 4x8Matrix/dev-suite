local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Explorer = {}

Explorer.DisplayName = `Explorer`
Explorer.DisplayOrder = 3
Explorer.DisplayIcon = Theme.ExplorerIcon
Explorer.Enabled = false

function Explorer.Render(scope: Scope, _props: Props)
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
	Render = Explorer.Render,
	Properties = {
		DisplayOrder = Explorer.DisplayOrder,
		DisplayName = Explorer.DisplayName,
		DisplayIcon = Explorer.DisplayIcon,

		Enabled = Explorer.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
