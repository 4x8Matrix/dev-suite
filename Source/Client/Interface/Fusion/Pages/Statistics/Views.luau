local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local Theme = require(Package.Client.Interface.Theme)

local SignalTypes = require(Package.Types.Signal)

local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local FusionTypes = require(Package.Types.Fusion)

local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)

local Views = {}

local function expandedView(scope: Scope, statsObject: StatStructure, size: UDim2, position: UDim2)
	local contentLabels = {}

	for sectionName, data in statsObject.stats do
		table.insert(contentLabels, TextLabel(scope, {
			Size = UDim2.new(1, 0, 0, 14),
			Text = `{sectionName}`,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.5, 
			LayoutOrder = #contentLabels + 1,

			[Fusion.Children] = {
				UIPadding = UIPadding(scope, {
					paddingHeight = UDim.new(0, 0),
					paddingWidth = UDim.new(0, 40)
				})
			}
		}))

		for name, value in data do
			table.insert(contentLabels, TextLabel(scope, {
				Size = UDim2.new(1, 0, 0, 15),
				Text = `<i>{name}</i>`,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5,
				LayoutOrder = #contentLabels + 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 0),
						paddingWidth = UDim.new(0, 60)
					})
				}
			}))

			table.insert(contentLabels, TextLabel(scope, {
				Size = UDim2.new(1, 0, 0, 10),
				Text = `<b>{value}{statsObject.prefix and ` <i>{statsObject.prefix}</i>` or ""}</b>`,
				TextColor3 = Theme.AccentColor3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5,
				LayoutOrder = #contentLabels + 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 0),
						paddingWidth = UDim.new(0, 80)
					})
				}
			}))
		end
	end

	return scope:New("Frame")({
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.BaseTopbarColor3,

		[Fusion.Children] = {
			UICorner = UICorner(scope, {
				level = 2,
			}),

			HeaderLabel = TextLabel(scope, {
				Text = `<b>{statsObject.name}</b>`,
				Size = UDim2.new(1, 0, 0, 25),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5, 

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 10),
						paddingWidth = UDim.new(0, 20)
					})
				}
			}),

			ScrollingBar = scope:New("ScrollingFrame")({
				Size = UDim2.new(1, 0, 1, -25),
				Position = UDim2.fromOffset(0, 25),
				BackgroundColor3 = Theme.BaseTopbarColor3,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ClipsDescendants = true,
				MidImage = Theme.MiddleScrollingFrameIcon,
				TopImage = Theme.TopScrollingFrameIcon,
				BottomImage = Theme.BottomScrollingFrameIcon,
				ScrollBarImageColor3 = Theme.AccentColor3,
				ScrollBarThickness = 3,

				[Fusion.Children] = Sift.Dictionary.merge(contentLabels, {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
		
						Padding = UDim.new(0, 5),
					}),
				})
			})
		}
	})
end

local function standardView(scope: Scope, statsObject: StatStructure, size: UDim2, position: UDim2)
	local contentLabels = {}

	for sectionName, data in statsObject.stats do
		table.insert(contentLabels, TextLabel(scope, {
			Size = UDim2.new(1, 0, 0, 14),
			Text = `{sectionName}`,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.5, 
			LayoutOrder = #contentLabels + 1,

			[Fusion.Children] = {
				UIPadding = UIPadding(scope, {
					paddingHeight = UDim.new(0, 0),
					paddingWidth = UDim.new(0, 40)
				})
			}
		}))

		for name, value in data do
			table.insert(contentLabels, TextLabel(scope, {
				Size = UDim2.new(1, 0, 0, 15),
				Text = `<i>{name}</i>: <font color="rgb({
						math.round(Theme.AccentColor3.R * 255)
					},{
						math.round(Theme.AccentColor3.G * 255)
					},{
						math.round(Theme.AccentColor3.B * 255)
					})"><b>{
						value
					}{
						statsObject.prefix and ` <i>{statsObject.prefix}</i>` or ""
					}</b></font>`,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5,
				LayoutOrder = #contentLabels + 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 0),
						paddingWidth = UDim.new(0, 60)
					})
				}
			}))
		end
	end

	return scope:New("Frame")({
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.BaseTopbarColor3,

		[Fusion.Children] = {
			UICorner = UICorner(scope, {
				level = 2,
			}),

			HeaderLabel = TextLabel(scope, {
				Text = `<b>{statsObject.name}</b>`,
				Size = UDim2.new(1, 0, 0, 25),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5, 

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 10),
						paddingWidth = UDim.new(0, 20)
					})
				}
			}),

			ScrollingBar = scope:New("ScrollingFrame")({
				Size = UDim2.new(1, 0, 1, -25),
				Position = UDim2.fromOffset(0, 25),
				BackgroundColor3 = Theme.BaseTopbarColor3,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ClipsDescendants = true,
				MidImage = Theme.MiddleScrollingFrameIcon,
				TopImage = Theme.TopScrollingFrameIcon,
				BottomImage = Theme.BottomScrollingFrameIcon,
				ScrollBarImageColor3 = Theme.AccentColor3,
				ScrollBarThickness = 3,

				[Fusion.Children] = Sift.Dictionary.merge(contentLabels, {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
		
						Padding = UDim.new(0, 5),
					}),
				})
			})
		}
	})
end

local function labelsView(scope: Scope, statsObject: StatStructure, size: UDim2, position: UDim2)
	local contentLabels = {}

	for name, value in statsObject.stats do
		table.insert(contentLabels, TextLabel(scope, {
			Size = UDim2.new(1, 0, 0, 14),
			Text = `{name}: <font color="rgb({
					math.round(Theme.AccentColor3.R * 255)
				},{
					math.round(Theme.AccentColor3.G * 255)
				},{
					math.round(Theme.AccentColor3.B * 255)
				})"><b>{
					value
				}{
					statsObject.prefix and ` <i>{statsObject.prefix}</i>` or ""
				}</b></font>`,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.5,
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = #contentLabels + 1,

			[Fusion.Children] = {
				UIPadding = UIPadding(scope, {
					paddingHeight = UDim.new(0, 0),
					paddingWidth = UDim.new(0, 30)
				})
			}
		}))
	end

	return scope:New("Frame")({
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.BaseTopbarColor3,

		[Fusion.Children] = {
			UICorner = UICorner(scope, {
				level = 2,
			}),

			HeaderLabel = TextLabel(scope, {
				Text = `<b>{statsObject.name}</b>`,
				Size = UDim2.new(1, 0, 0, 25),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5, 

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 10),
						paddingWidth = UDim.new(0, 20)
					})
				}
			}),

			ScrollingBar = scope:New("ScrollingFrame")({
				Size = UDim2.new(1, 0, 1, -25),
				Position = UDim2.fromOffset(0, 25),
				BackgroundColor3 = Theme.BaseTopbarColor3,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ClipsDescendants = true,
				MidImage = Theme.MiddleScrollingFrameIcon,
				TopImage = Theme.TopScrollingFrameIcon,
				BottomImage = Theme.BottomScrollingFrameIcon,
				ScrollBarImageColor3 = Theme.AccentColor3,
				ScrollBarThickness = 3,

				[Fusion.Children] = Sift.Dictionary.merge(contentLabels, {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
		
						Padding = UDim.new(0, 5),
					}),
				})
			})
		}
	})
end

function Views.render(scope: Scope, props: Props)
	return scope:Computed(function(use)
		return {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0, 10),
				paddingWidth = UDim.new(0, 10)
			}),
	
			MemoryBox = expandedView(scope, use(props.statistics.memoryStats), UDim2.fromScale(0.321, 0.85), UDim2.fromScale(0, 0.15)),
	
			NetworkBox = standardView(scope, use(props.statistics.networkStats), UDim2.fromScale(0.321, 0.45), UDim2.fromScale(0.332, 0)),
			InstanceBox = labelsView(scope, use(props.statistics.instanceStats), UDim2.fromScale(0.321, 0.25), UDim2.fromScale(0.332, 0.47)),
			MetadataBox = labelsView(scope, use(props.statistics.metadataStats), UDim2.fromScale(0.321, 0.26), UDim2.fromScale(0.332, 0.74)),
	
			DrawcallsBox = standardView(scope, use(props.statistics.drawcallStats), UDim2.fromScale(0.321, 0.5), UDim2.fromScale(0.664, 0)),
			FramesBox = labelsView(scope, use(props.statistics.frameStats), UDim2.fromScale(0.321, 0.48), UDim2.fromScale(0.664, 0.52)),

			SettingPanel = scope:New("Frame")({
				Size = UDim2.fromScale(0.321, 0.13),
				Position = UDim2.fromScale(0, 0),

				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {
						level = 0.5
					}),

					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder
					}),

					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.2, 0),
						paddingWidth = UDim.new(0.05, 0)
					}),

					ClickToRefreshButton = Button(scope, {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.BaseSidebarColor3,

						[Fusion.OnEvent("Activated")] = function()
							props.signals.statistics.refresh:Fire()
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

							ImageLabel = ImageLabel(scope, {
								Image = Theme.RestartIcon,
								ImageTransparency = 0.4,
							})
						}
					})
				}
			})
		}
	end)
end

type StatStructure = {
	prefix: string,
	name: string,
	stats: {
		[string]: {
			[string]: number
		} | string,
	},
	graph: {
		[string]: number
	}
}

type Scope = FusionTypes.Scope
type Props = {
	statistics: {
		selectedCategory: FusionTypes.Value<string?>,

		memoryStats: FusionTypes.Value<StatStructure>,
		networkStats: FusionTypes.Value<StatStructure>,
		instanceStats: FusionTypes.Value<StatStructure>,
		metadataStats: FusionTypes.Value<StatStructure>,
		drawcallStats: FusionTypes.Value<StatStructure>,
		frameStats: FusionTypes.Value<StatStructure>
	},

	signals: {
		statistics: {
			refresh: SignalTypes.Signal<()>,

			enableAutoRefresh: SignalTypes.Signal<()>,
			disableAutoRefresh: SignalTypes.Signal<()>
		},
	}
}

return Views