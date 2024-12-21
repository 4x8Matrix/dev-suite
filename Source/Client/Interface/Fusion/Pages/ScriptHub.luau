local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local ScriptHub = {}

ScriptHub.DisplayName = `Script Hub`
ScriptHub.DisplayOrder = 4
ScriptHub.DisplayIcon = Theme.ScriptHubIcon
ScriptHub.Enabled = true

function ScriptHub.Render(scope: Scope, _props: Props)
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
	Render = ScriptHub.Render,
	Properties = {
		DisplayOrder = ScriptHub.DisplayOrder,
		DisplayName = ScriptHub.DisplayName,
		DisplayIcon = ScriptHub.DisplayIcon,

		Enabled = ScriptHub.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
