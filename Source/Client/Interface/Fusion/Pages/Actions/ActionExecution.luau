local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local TextBox = require(ReplicatedStorage.Packages.DevSuite.Client.Interface.Components.TextBox)
local UICorner = require(ReplicatedStorage.Packages.DevSuite.Client.Interface.Components.UICorner)
local UIPadding = require(ReplicatedStorage.Packages.DevSuite.Client.Interface.Components.UIPadding)
local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)

local Button = require(Package.Client.Interface.Components.Button)
local ImageButton = require(Package.Client.Interface.Components.ImageButton)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local Theme = require(Package.Client.Interface.Theme)

local SignalTypes = require(Package.Types.Signal)
local FusionTypes = require(Package.Types.Fusion)

local ActionExecution = {}

function ActionExecution.RenderEmptyPage(scope: FusionTypes.Scope)
	return scope:New("Frame")({
		Size = UDim2.fromScale(0.9, 0.9),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			ImageLabel = ImageLabel(scope, {
				Size = UDim2.fromScale(0.7, 0.8),
				Position = UDim2.fromScale(0.225, 0.05),
				
				Image = Theme.PropertiesIcon,
				ImageTransparency = 0.5,
		
				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			TextLabel = TextLabel(scope, {
				Size = UDim2.fromScale(0.8, 0.15),
				Position = UDim2.fromScale(0.15, 0.7),

				Text = "Select an action to execute it!",
				TextTransparency = 0.5,
			})
		}
	})
end

function ActionExecution.Render(
	scope: FusionTypes.Scope,
	values: {
		selectedAction: FusionTypes.Value<Action>,
		closedFolders: FusionTypes.Value<{ string }>
	},
	executeSignal: SignalTypes.Signal<string>
)
	local selectedAction = Fusion.peek(values.selectedAction)
	local argumentObjects = {}
	local arguments = {}

	if not selectedAction then
		return ActionExecution.RenderEmptyPage(scope)
	end

	if #selectedAction.arguments == 0 then
		table.insert(argumentObjects, scope:New("Frame")({
			Size = UDim2.fromScale(0.9, 0.9),
	
			BackgroundTransparency = 1,
	
			[Fusion.Children] = {
				ImageLabel = ImageLabel(scope, {
					Size = UDim2.fromScale(0.8, 0.8),
					Position = UDim2.fromScale(0.3, 0.05),
					
					Image = Theme.PropertiesIcon,
					ImageTransparency = 0.5,
			
					[Fusion.Children] = {
						UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
					}
				}),
	
				TextLabel = TextLabel(scope, {
					Size = UDim2.fromScale(0.8, 0.2),
					Position = UDim2.fromScale(0.15, 0.8),
	
					Text = "No parameters have been listed!",
					TextTransparency = 0.5,
				})
			}
		}))
	else
		table.insert(argumentObjects, scope:New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,

			Padding = UDim.new(0, 10),
		}))

		for _, argument in selectedAction.arguments do
			local defaultValue = argument.default
			local argumentIndex = #arguments + 1
			local textBox

			if not defaultValue then
				if argument.type == "Player" and Players.LocalPlayer then
					defaultValue = Players.LocalPlayer.Name
				elseif argument.type == "Number" then
					defaultValue = "0"
				end
			end

			textBox = TextBox(scope, {
				Size = UDim2.new(1, 0, 0, 25),
				Position = UDim2.fromOffset(0, 25),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.BaseTopbarColor3,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,

				Text = `{defaultValue or ""}`,

				[Fusion.OnEvent("FocusLost")] = function()
					local validInput = false
					local value

					if argument.type == "Player" then
						value = Players:FindFirstChild(textBox.Text)

						validInput = value ~= nil
					elseif argument.type == "Number" then
						value = tonumber(textBox.Text) ~= nil

						validInput = value ~= nil
					elseif argument.type == "String" then
						value = textBox.Text

						validInput = value ~= nil
					end

					if validInput then
						arguments[argumentIndex] = value
					else
						textBox.Text = ``
					end
				end,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.3, 0),
						paddingWidth = UDim.new(0.1, 0)
					})
				}
			})

			arguments[argumentIndex] = defaultValue

			table.insert(argumentObjects, scope:New("Frame")({
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 10),
						paddingWidth = UDim.new(0.1, 0)
					}),

					SubTitleLabel = TextLabel(scope, {
						Text = `{argument.name}`,
						Size = UDim2.new(1, 0, 0, 25),
						TextTransparency = 0.25,
						TextSize = 14,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = false,
	
						[Fusion.Children] = {
							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0.3, 0),
								paddingWidth = UDim.new()
							})
						}
					}),

					TextBox = textBox
				}
			}))
		end
	end

	return {
		TitleLabel = scope:New("Frame")({
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,

			[Fusion.Children] = {
				UIListLayout = scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
	
					Padding = UDim.new(0.025, 0),
				}),

				Label = TextLabel(scope, {
					Text = `<b>{selectedAction.name}</b>`,
					Size = UDim2.fromScale(0, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.X,
					TextScaled = false,

					[Fusion.Children] = {
						UIPadding = UIPadding(scope, {
							paddingHeight = UDim.new(0.3, 0),
							paddingWidth = UDim.new()
						})
					}
				}),

				Icon = ImageLabel(scope, {
					Image = Theme.ActionsIcon,
					Size = UDim2.fromScale(0.6, 0.6),
					Position = UDim2.fromScale(0.2, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),

					[Fusion.Children] = {
						UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),
					}
				})
			}
		}),

		DescriptionLabel = scope:New("Frame")({
			Size = UDim2.fromScale(1, 0.15),
			Position = UDim2.fromScale(0, 0.1),
			BackgroundTransparency = 1,

			[Fusion.Children] = {
				Label = TextLabel(scope, {
					Text = `<i>{selectedAction.description}</i>`,
					Size = UDim2.fromScale(1, 1),
					TextTransparency = 0.5,
					TextSize = 12,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = false,

					[Fusion.Children] = {
						UIPadding = UIPadding(scope, {
							paddingHeight = UDim.new(0.3, 0),
							paddingWidth = UDim.new()
						})
					}
				}),
			}
		}),

		ArgumentsFrame = scope:New("Frame")({
			Size = UDim2.fromScale(0.9, 0.55),
			Position = UDim2.fromScale(0.05, 0.275),
			BackgroundColor3 = Theme.BaseBackgroundColor3,

			[Fusion.Children] = {
				UICorner = UICorner(scope, {}),

				ScrollingFrame = scope:New("ScrollingFrame")({
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromScale(0, 0),
					ClipsDescendants = true,
					MidImage = Theme.MiddleScrollingFrameIcon,
					TopImage = Theme.TopScrollingFrameIcon,
					BottomImage = Theme.BottomScrollingFrameIcon,
					ScrollBarImageColor3 = Theme.AccentColor3,
					ScrollBarThickness = 3,

					[Fusion.Children] = argumentObjects
				})
			}
		}),

		ExecuteButton = Button(scope, {
			Size = UDim2.fromScale(1, 0.15),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0, 0.85),
			BackgroundTransparency = 0,
			BackgroundColor3 = selectedAction.context == "Server" and Theme.ServerColor3 or Theme.ClientColor3,

			[Fusion.OnEvent("Activated")] = function()
				executeSignal:Fire(selectedAction.uuid)
			end,

			[Fusion.Children] = {
				UICorner = UICorner(scope, {}),

				ExecuteIcon = ImageLabel(scope, {
					Image = Theme.TabIcon,
					Size = UDim2.fromScale(0.6, 0.6),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),

					[Fusion.Children] = {
						UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),
					}
				})
			}
		})
	}
end

export type Action = {
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

return ActionExecution