local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Sift = require(Package.Parent.Sift)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local ScriptHub = {}

ScriptHub.DisplayName = `Script Hub`
ScriptHub.DisplayOrder = 4
ScriptHub.DisplayIcon = Theme.ScriptHubIcon
ScriptHub.Enabled = true

function ScriptHub.Render(scope: Scope, props: Props)
	return scope:New("ScrollingFrame")({
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Fusion.Children] = scope:Computed(function(use)
			local scripts = use(props.scriptHub.scripts)
			local scriptFrames = {}

			if #scripts == 0 then
				table.insert(scriptFrames, scope:New("Frame")({
					Size = UDim2.fromScale(1, 0.2),
					BackgroundColor3 = Theme.BaseTopbarColor3,
				
					[Fusion.Children] = {
						UIPadding = UIPadding(scope, {
							paddingWidth = UDim.new(0.05, 0),
							paddingHeight = UDim.new(0.5, 0)
						}),

						TextLabel = TextLabel(scope, {
							TextTransparency = 0.5,
							Text = `No scripts found.. somethings gone wrong! Please contact a developer!`,
							Size = UDim2.fromScale(1, 0.6),
							Position = UDim2.fromScale(0, 0.2),
						})
					}
				}))
			end

			for _, script in scripts do
				table.insert(scriptFrames, scope:New("Frame")({
					Size = UDim2.fromScale(1, 0.2),
					BackgroundColor3 = Theme.BaseTopbarColor3,
				
					[Fusion.Children] = {
						UIPadding = UIPadding(scope, {
							paddingWidth = UDim.new(0.05, 0),
							paddingHeight = UDim.new(0.5, 0)
						}),

						Icon = ImageLabel(scope, {
							Size = UDim2.fromScale(0.1, 1),
							Position = UDim2.fromScale(0, 0),
							Image = Theme.ScriptHubIcon,

							[Fusion.Children] = {
								UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),
							}
						}),

						TitleLabel = TextLabel(scope, {
							TextTransparency = 0,
							Text = `<b>{script.name}</b>`,

							TextXAlignment = Enum.TextXAlignment.Left,
							Size = UDim2.fromScale(1, 0.5),
							Position = UDim2.fromScale(0.1, 0),
						}),

						DescriptionLabel = TextLabel(scope, {
							TextTransparency = 0.5,
							Text = script.description,

							TextXAlignment = Enum.TextXAlignment.Left,
							Size = UDim2.fromScale(1, 0.5),
							Position = UDim2.fromScale(0.1, 0.5),
						}),

						ExecuteButton = Button(scope, {
							Image = Theme.PlayIcon,
							Size = UDim2.fromScale(0.1, 1),
							Position = UDim2.fromScale(0.925, 0),

							[Fusion.OnEvent("Activated")] = function()
								props.signals.scriptHub.execute:Fire(script.source)
							end
						})
					}
				}))
			end

			return Sift.Dictionary.merge(scriptFrames, {
				UIListLayout = scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Top,
	
					Padding = UDim.new(0.025, 0),
				}),

				UIPadding = UIPadding(scope, {
					paddingWidth = UDim.new(0, 10),
					paddingHeight = UDim.new(0, 10)
				}),
			})
		end)
	})
end

type Scope = FusionTypes.Scope
type Props = {
	scriptHub: {
		scripts: FusionTypes.Value<{
			{
				name: string,
				description: string,
				source: string,
			}
		}>
	},

	signals: {
		scriptHub: {
			execute: SignalTypes.Signal<string>,
		},
	}
}

return {
	Render = ScriptHub.Render,
	Properties = {
		DisplayOrder = ScriptHub.DisplayOrder,
		DisplayName = ScriptHub.DisplayName,
		DisplayIcon = ScriptHub.DisplayIcon,

		Enabled = ScriptHub.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
