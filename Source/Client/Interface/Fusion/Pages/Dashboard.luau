local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local Fusion = require(Package.Parent.Fusion)

local Dashboard = {}

Dashboard.DisplayName = `Dashboard`
Dashboard.DisplayOrder = 1
Dashboard.DisplayIcon = Theme.DashboardIcon
Dashboard.Enabled = true
Dashboard.DefaultPage = true

function Dashboard.Render(scope: Scope, _props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			ImageLabel = ImageLabel(scope, {
				Image = Theme.DashboardIcon,
				Size = UDim2.fromScale(0.3, 0.3),
				Position = UDim2.fromScale(0.5, 0.3),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),

			Label1 = TextLabel(scope, {
				Size = UDim2.fromScale(0.4, 0.2),
				Position = UDim2.fromScale(0.5, 0.6),
				AnchorPoint = Vector2.new(0.5, 0.5),

				Text = `Welcome to the Dev-Suite.`
			}),

			Label2 = TextLabel(scope, {
				Size = UDim2.fromScale(0.7, 0.1),
				Position = UDim2.fromScale(0.5, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),

				TextTransparency = 0.5,

				Text = `Click on any of the side-bar buttons to get started.`
			})
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {}

return {
	Render = Dashboard.Render,
	Properties = {
		DisplayOrder = Dashboard.DisplayOrder,
		DisplayName = Dashboard.DisplayName,
		DisplayIcon = Dashboard.DisplayIcon,

		Enabled = Dashboard.Enabled,
		DefaultPage = Dashboard.DefaultPage
	}
} :: PageTypes.PageElement<Scope, Props>
