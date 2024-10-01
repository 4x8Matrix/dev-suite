local RunService = game:GetService("RunService")

local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)

local UIExplorer = require(Package.Client.Interface.Fusion.Pages.Explorer.Explorer)
local UIProperties = require(Package.Client.Interface.Fusion.Pages.Explorer.Properties)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Explorer = {}

Explorer.DisplayName = `Explorer`
Explorer.DisplayOrder = 3
Explorer.DisplayIcon = Theme.ExplorerIcon
Explorer.Enabled = true

function Explorer.Render(scope: Scope, props: Props)
	local frameCount = 0

	local explorerScrollingFrame = scope:New("ScrollingFrame")({
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollBarThickness = 3,
		MidImage = Theme.MiddleScrollingFrameIcon,
		TopImage = Theme.TopScrollingFrameIcon,
		BottomImage = Theme.BottomScrollingFrameIcon,
		ScrollBarImageColor3 = Theme.AccentColor3,
		ZIndex = 2,
		ClipsDescendants = true,

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}
	})

	local propertiesScrollingFrame = scope:New("ScrollingFrame")({
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollBarThickness = 3,
		MidImage = Theme.MiddleScrollingFrameIcon,
		TopImage = Theme.TopScrollingFrameIcon,
		BottomImage = Theme.BottomScrollingFrameIcon,
		ScrollBarImageColor3 = Theme.AccentColor3,
		ZIndex = 2,
		ClipsDescendants = true,

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}
	})

	UIExplorer.Setup(scope, props.explorer.selectedInstance)
	UIProperties.Setup(scope, props.explorer.selectedInstance)

	table.insert(scope, RunService.Heartbeat:Connect(function()
		frameCount += 1

		if frameCount % 5 ~= 0 then
			return
		end

		frameCount = 0

		UIExplorer.Render(scope, props.explorer.instances, explorerScrollingFrame)
		UIProperties.Render(scope, propertiesScrollingFrame)
	end))

	table.insert(scope, function()
		UIExplorer.Reset()

		props.explorer.selectedInstance:set(nil)
	end)

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0.045, 0),
				paddingWidth = UDim.new(0.025, 0)
			}),

			ExplorerPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.425, 1),

				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {
						level = 0.5
					}),

					BackgroundFrame = scope:New("Frame")({
						Size = UDim2.fromScale(0.5, 1),

						BackgroundColor3 = Theme.BaseTopbarColor3,
					}),

					ContentFrame = explorerScrollingFrame
				}
			}),

			PropertiesPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.425, 1),
				Position = UDim2.fromScale(0.44, 0),

				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {
						level = 0.5
					}),

					BackgroundFrame = scope:New("Frame")({
						Size = UDim2.fromScale(0.5, 1),

						BackgroundColor3 = Theme.BaseTopbarColor3,
					}),

					ContentFrame = propertiesScrollingFrame
				}
			}),

			SettingPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.12, 1),
				Position = UDim2.fromScale(0.88, 0),

				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {
						level = 0.5
					}),

					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder
					}),

					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.025, 0),
						paddingWidth = UDim.new(0.2, 0)
					}),

					ClickToSelectButton = Button(scope, {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.BaseSidebarColor3,

						[Fusion.OnEvent("Activated")] = function()
							props.explorer.clickToSelect:set(not Fusion.peek(props.explorer.clickToSelect))
						end,

						[Fusion.Children] = {
							UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

							UICorner = UICorner(scope, {
								level = 0.5
							}),

							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0.5, 0),
								paddingWidth = UDim.new(0.5, 0)
							}),

							ImageLabe = ImageLabel(scope, {
								Image = Theme.PointerIcon,
								ImageTransparency = scope:Computed(function(use)
									local isEnabled = use(props.explorer.clickToSelect)
		
									return isEnabled and 0 or 0.5
								end),
							})
						}
					}),

					ShowSelectionButton = Button(scope, {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.BaseSidebarColor3,

						[Fusion.OnEvent("Activated")] = function()
							props.explorer.showSelection:set(not Fusion.peek(props.explorer.showSelection))
						end,

						[Fusion.Children] = {
							UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

							UICorner = UICorner(scope, {
								level = 0.5
							}),

							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0.5, 0),
								paddingWidth = UDim.new(0.5, 0)
							}),

							ImageLabe = ImageLabel(scope, {
								Image = Theme.Selectioncon,
								ImageTransparency = scope:Computed(function(use)
									local isEnabled = use(props.explorer.showSelection)
		
									return isEnabled and 0 or 0.5
								end),
							})
						}
					})
				}
			})
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {
	explorer: {
		instances: { Instance },

		clickToSelect: FusionTypes.Value<boolean>,
		showSelection: FusionTypes.Value<boolean>,

		selectedInstance: FusionTypes.Value<Instance?>,
	},
}

return {
	Render = Explorer.Render,
	Properties = {
		DisplayOrder = Explorer.DisplayOrder,
		DisplayName = Explorer.DisplayName,
		DisplayIcon = Explorer.DisplayIcon,

		Enabled = Explorer.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
