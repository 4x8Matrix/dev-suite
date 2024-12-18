local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Embedded = {}

Embedded.DisplayName = `Script Hub`
Embedded.DisplayOrder = 4
Embedded.DisplayIcon = Theme.ScriptHubIcon
Embedded.Enabled = true

function Embedded.Render(scope: Scope, _props: Props)
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
	Render = Embedded.Render,
	Properties = {
		DisplayOrder = Embedded.DisplayOrder,
		DisplayName = Embedded.DisplayName,
		DisplayIcon = Embedded.DisplayIcon,

		Enabled = Embedded.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
