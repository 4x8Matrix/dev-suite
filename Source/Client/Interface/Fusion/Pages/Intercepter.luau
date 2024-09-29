local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Intercepter = {}

Intercepter.DisplayName = `Intercepter`
Intercepter.DisplayOrder = 4
Intercepter.DisplayIcon = Theme.IntercepterIcon
Intercepter.Enabled = false

function Intercepter.Render(scope: Scope, _props: Props)
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
	Render = Intercepter.Render,
	Properties = {
		DisplayOrder = Intercepter.DisplayOrder,
		DisplayName = Intercepter.DisplayName,
		DisplayIcon = Intercepter.DisplayIcon,

		Enabled = Intercepter.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
