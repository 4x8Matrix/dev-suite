local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Datastores = {}

Datastores.DisplayName = `Datastores`
Datastores.DisplayOrder = 11
Datastores.DisplayIcon = Theme.DatastoresIcon
Datastores.Enabled = false

function Datastores.Render(scope: Scope, _props: Props)
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
	Render = Datastores.Render,
	Properties = {
		DisplayOrder = Datastores.DisplayOrder,
		DisplayName = Datastores.DisplayName,
		DisplayIcon = Datastores.DisplayIcon,

		Enabled = Datastores.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
