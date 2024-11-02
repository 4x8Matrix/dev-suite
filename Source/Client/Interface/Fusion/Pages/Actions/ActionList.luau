local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)

local ImageButton = require(Package.Client.Interface.Components.ImageButton)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local Theme = require(Package.Client.Interface.Theme)

local FusionTypes = require(Package.Types.Fusion)

local ActionList = {}

function ActionList.RenderAction(
	scope: FusionTypes.Scope,
	node: Action,
	depth: number,
	values: {
		selectedAction: FusionTypes.Value<Action>,
		closedFolders: FusionTypes.Value<{ string }>
	},
	children: { Instance }
)
	local frame
	local isReadyForEvent

	frame = scope:New("Frame")({
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0,
		LayoutOrder = #children,
		BackgroundColor3 = scope:Computed(function(use)
			local isNodeActive = use(values.selectedAction) == node

			return isNodeActive and Theme.AccentColor3 or Theme.BaseTopbarColor3
		end),

		[Fusion.OnEvent("InputBegan")] = function(inputObject: InputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				isReadyForEvent = true
			end
		end,

		[Fusion.OnEvent("InputEnded")] = function(inputObject: InputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				if not isReadyForEvent then
					return
				end

				values.selectedAction:set(node)
			end
		end,

		[Fusion.Children] = {
			UIListLayout = scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				Padding = UDim.new(0.025, 0),
			}),

			PaddingLeft = scope:New("Frame")({
				Size = UDim2.fromScale(0.1 * depth, 1),
				BackgroundTransparency = 1,
				LayoutOrder = 1
			}),

			Icon = ImageLabel(scope, {
				Size = UDim2.fromScale(0.75, 0.75),
				LayoutOrder = 3,
				Image = Theme.ActionsIcon,

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			Label = TextLabel(scope, {
				Size = UDim2.fromScale(1, 0.75),
				Text = node.name,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 4,
			})
		}
	})

	table.insert(children, frame)
end

function ActionList.RenderFolder(
	scope: FusionTypes.Scope,
	node: ActionNode,
	depth: number,
	values: {
		selectedAction: FusionTypes.Value<Action>,
		closedFolders: FusionTypes.Value<{ string }>
	},
	children: { Instance }
)
	local tabButton
	local frame

	local fullName = node.fullName

	tabButton = ImageButton(scope, {
		Size = UDim2.fromScale(1, 1),
		Image = Theme.TabIcon,
		ImageTransparency = #node.children <= 0 and 1 or 0,

		Rotation = scope:Computed(function(use)
			return use(values.closedFolders)[node.fullName] and 90 or 0
		end),

		[Fusion.OnEvent("Activated")] = function()
			local newclosedFolders = Fusion.peek(values.closedFolders)

			newclosedFolders[node.fullName] = not newclosedFolders[node.fullName]

			values.closedFolders:set(newclosedFolders)
		end,

		[Fusion.Children] = {
			UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
		}
	})

	frame = scope:New("Frame")({
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.BaseTopbarColor3,
		LayoutOrder = #children,

		[Fusion.Children] = {
			UIListLayout = scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				Padding = UDim.new(0.025, 0),
			}),

			PaddingLeft = scope:New("Frame")({
				Size = UDim2.fromScale(0.1 * depth, 1),
				BackgroundTransparency = 1,
				LayoutOrder = 1
			}),

			Tab = scope:New("Frame")({
				Size = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				LayoutOrder = 2,

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

					Tab = tabButton
				}
			}),

			Icon = ImageLabel(scope, {
				Size = UDim2.fromScale(0.75, 0.75),
				LayoutOrder = 3,
				Image = scope:Computed(function(use)
					return use(values.closedFolders)[node.fullName] and Theme.FolderIcon or Theme.OpenFolderIcon
				end),

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			Label = TextLabel(scope, {
				Size = UDim2.fromScale(1, 0.75),
				Text = node.name,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 4,
			})
		}
	})

	table.insert(children, frame)

	if not Fusion.peek(values.closedFolders)[fullName] then
		for _, childNode in node.children do
			if childNode.type == "Folder" then
				ActionList.RenderFolder(scope, childNode, depth + 1, values, children)
			elseif childNode.type == "Action" then
				ActionList.RenderAction(scope, childNode.action :: any, depth + 1, values, children)
			end
		end
	end
end

function ActionList.IntoNodesTable(actions: { Action }): ActionNode
	local actionNodes = {
		type = "Folder",
		name = "Actions",
		children = {}
	}
	
	for _, action in actions do
		local actionTreeBase = actionNodes
		local objectFullName = ""

		for index, path in action.path do
			objectFullName ..= `{index ~= 1 and `/` or ``}{path}`

			local indexFound = Sift.Array.findWhere(actionTreeBase.children, function(element)
				return element.name == path
			end)

			if not indexFound then
				table.insert(actionTreeBase.children, {
					type = "Folder",
					name = path,
					fullName = objectFullName,
					children = {}
				})
			end

			actionTreeBase = actionTreeBase.children[#actionTreeBase.children]
		end

		table.insert(actionTreeBase.children, {
			type = "Action",
			action = action,
			children = {}
		})
	end

	return actionNodes
end

function ActionList.RenderEmptyPage(scope: FusionTypes.Scope)
	return scope:New("Frame")({
		Size = UDim2.fromScale(0.9, 0.9),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			ImageLabel = ImageLabel(scope, {
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0.15, 0.05),
				Rotation = 180,
				
				Image = Theme.PropertiesIcon,
				ImageTransparency = 0.5,
		
				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			TextLabel = TextLabel(scope, {
				Size = UDim2.fromScale(0.8, 0.235),
				Position = UDim2.fromScale(0.15, 0.7),

				Text = "Create 'Actions' through the Dev Suite developer API!",
				TextTransparency = 0.5,
			})
		}
	})
end

function ActionList.Render(
	scope: FusionTypes.Scope,
	actions: { Action },
	values: {
		selectedAction: FusionTypes.Value<Action>,
		closedFolders: FusionTypes.Value<{ string }>
	}
)
	local actionNodes = ActionList.IntoNodesTable(actions)
	local children = {
		scope:New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Top,

			Padding = UDim.new(0.025, 0),
		}),
	}

	warn(actionNodes)

	if #actionNodes.children == 0 then
		return ActionList.RenderEmptyPage(scope)
	end

	for _, node in actionNodes.children do
		if node.type == "Folder" then
			ActionList.RenderFolder(scope, node, 0, values, children)
		elseif node.type == "Action" then
			ActionList.RenderAction(scope, node.action, 0, values, children)
		end
	end

	return children
end

export type ActionNode = {
	type: string,

	name: string?,
	fullName: string?,
	children: { ActionNode },

	action: Action?
}

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

return ActionList