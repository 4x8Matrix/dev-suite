local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Inspector = {}

Inspector.DisplayName = `Inspector`
Inspector.DisplayOrder = 9
Inspector.DisplayIcon = Theme.InspectorIcon
Inspector.Enabled = false

function Inspector.Render(scope: Scope, _props: Props)
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
	Render = Inspector.Render,
	Properties = {
		DisplayOrder = Inspector.DisplayOrder,
		DisplayName = Inspector.DisplayName,
		DisplayIcon = Inspector.DisplayIcon,

		Enabled = Inspector.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
