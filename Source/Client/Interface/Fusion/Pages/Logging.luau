local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Logging = {}

Logging.DisplayName = `Logging`
Logging.DisplayOrder = 5
Logging.DisplayIcon = Theme.LoggingIcon
Logging.Enabled = false

function Logging.Render(scope: Scope, _props: Props)
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
	Render = Logging.Render,
	Properties = {
		DisplayOrder = Logging.DisplayOrder,
		DisplayName = Logging.DisplayName,
		DisplayIcon = Logging.DisplayIcon,

		Enabled = Logging.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
