local Package = script.Parent.Parent.Parent.Parent.Parent

local SignalTypes = require(Package.Types.Signal)
local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local ActionList = require(Package.Client.Interface.Fusion.Pages.Actions.ActionList)
local ActionExecution = require(Package.Client.Interface.Fusion.Pages.Actions.ActionExecution)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Actions = {}

Actions.DisplayName = `Actions`
Actions.DisplayOrder = 8
Actions.DisplayIcon = Theme.ActionsIcon
Actions.Enabled = true

function Actions.Render(scope: Scope, props: Props)
	local focusedAction = scope:Value(nil)

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0.05, 0),
				paddingWidth = UDim.new(0.03, 0)
			}),
			
			ActionsPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.45, 1),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					
					Background = scope:New("Frame")({
						Size = UDim2.fromScale(0.5, 1),
						BackgroundColor3 = Theme.BaseTopbarColor3,
					}),

					[Fusion.Children] = {
						Content = scope:New("Frame")({
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							ClipsDescendants = true,

							[Fusion.Children] = scope:Computed(function(use)
								local actions = use(props.actions.actions)
		
								use(props.actions.closedFolders)
		
								return ActionList.Render(scope, actions, {
									selectedAction = focusedAction,
									closedFolders = props.actions.closedFolders,
								})
							end)
						})
					}
				}
			}),

			ActionExecutionPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.535, 1),
				Position = UDim2.fromScale(0.465, 0),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),

					Content = scope:New("Frame")({
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ClipsDescendants = true,

						[Fusion.Children] = scope:Computed(function(use)
							use(focusedAction)

							return ActionExecution.Render(scope, {
								selectedAction = focusedAction,
								closedFolders = props.actions.closedFolders
							}, props.signals.actions.executeAction)
						end)
					})
				},
			}),
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {
	actions: {
		closedFolders: FusionTypes.Value<{ string }>,

		actions: {
			{
				path: { string },
				name: string,
				description: string,

				uuid: string,
				context: "Server" | "Client",

				arguments: {
					{
						type: string,
						name: string,
						default: string,
					}
				}
			}
		}
	},

	signals: {
		actions: {
			executeAction: SignalTypes.Signal<string>
		},
	}
}

return {
	Render = Actions.Render,
	Properties = {
		DisplayOrder = Actions.DisplayOrder,
		DisplayName = Actions.DisplayName,
		DisplayIcon = Actions.DisplayIcon,

		Enabled = Actions.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
