local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local Sift = require(Package.Parent.Sift)

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local ImageButton = require(Package.Client.Interface.Components.ImageButton)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local TYPE_ICON_MAP = table.freeze({
	["Global"] = Theme.GlobeIcon,
	["Function"] = Theme.FunctionIcon,
	["Index"] = Theme.NodesIcon,
	["Instance"] = Theme.CubeIcon,
	["Thread"] = Theme.BranchIcon
})

local TYPE_ICON_COLORS = table.freeze({
	["Function"] = Theme.FunctionIconColor,
})

local ListFrame = {}

function ListFrame.Render(scope: Scope, props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			ThreadContentFrame = scope:New("Frame")({
				Size = UDim2.fromScale(0.55, 1),
				BackgroundTransparency = 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 15),
						paddingWidth = UDim.new(0, 15)
					}),

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

						[Fusion.Children] = scope:Computed(function(use)
							local threadList = use(props.debugger.threadList)
							local threadStats = use(props.debugger.threadStats)
							local children = {
								UIListLayout = scope:New("UIListLayout")({
									SortOrder = Enum.SortOrder.LayoutOrder,
									FillDirection = Enum.FillDirection.Vertical,
									Padding = UDim.new(0, 5),
								})
							}

							if #threadList == 0 then
								table.insert(children, scope:New("Frame")({
									Size = UDim2.fromScale(1, 0.3),
									BackgroundColor3 = Theme.BaseTopbarColor3,
								
									[Fusion.Children] = {
										UIPadding = UIPadding(scope, {
											paddingWidth = UDim.new(0.1, 0),
											paddingHeight = UDim.new(0.25, 0)
										}),
				
										TextLabel0 = TextLabel(scope, {
											Size = UDim2.fromScale(1, 0.45),
											TextTransparency = 0.5,
											Text = `Please execute something in the <i>Sandbox</i>!`
										}),

										TextLabel1 = TextLabel(scope, {
											Size = UDim2.fromScale(1, 0.5),
											Position = UDim2.fromScale(0, 0.5),
											TextTransparency = 0.5,
											Text = `<b>The Debugger will reflect actions taken inside of the Sandbox.</b>`
										})
									}
								}))
							end

							for index, threadId in threadList do
								local threadMetadata = threadStats[threadId]
								local threadMetadataChildren = {}

								for _, object in {
									{
										icon = Theme.BranchIcon,
										text = threadMetadata.childThreadCount
									},
									{
										icon = Theme.FunctionIcon,
										text = threadMetadata.methodCallCount
									},
									{
										icon = Theme.NodesIcon,
										text = threadMetadata.indexCount
									},
									{
										icon = Theme.CubeIcon,
										text = threadMetadata.instanceRefCount
									}
								} do
									table.insert(threadMetadataChildren, scope:New("Frame")({
										Size = UDim2.fromScale(1, 1),
										BackgroundTransparency = 1,

										[Fusion.Children] = {
											UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

											Label = TextLabel(scope, {
												Text = object.text,
												Position = UDim2.fromScale(0.8, 0.8),
												Size = UDim2.fromScale(0.4, 0.4),
												TextTransparency = 0.5,
											}),

											Icon = ImageLabel(scope, {
												Image = object.icon,
												ImageTransparency = 0.5,
												Size = UDim2.fromScale(0.7, 0.7),
												Position = UDim2.fromScale(0.5, 0.5),
												AnchorPoint = Vector2.new(0.5, 0.5),
											})
										}
									}))
								end

								table.insert(children, scope:New("Frame")({
									Size = UDim2.new(1, 0, 0, 75),
									Position = UDim2.fromScale(0, ((index - 1) * 0.1)),
									BackgroundColor3 = Theme.BaseTopbarColor3,
									LayoutOrder = #threadList - index,

									[Fusion.Children] = {
										UICorner = UICorner(scope, {
											level = 0.5
										}),

										UIPadding = UIPadding(scope, {
											paddingHeight = UDim.new(0, 12),
											paddingWidth = UDim.new(0, 30)
										}),

										Label = TextLabel(scope, {
											Text = threadId,
											TextXAlignment = Enum.TextXAlignment.Left,
											Size = UDim2.fromScale(0.8, 0.3),
											Position = UDim2.fromScale(0, 0),
											TextTransparency = 0.5,
										}),

										Button = ImageButton(scope, {
											Size = UDim2.fromScale(0.2, 1),
											Position = UDim2.fromScale(1.035, 0),
											AnchorPoint = Vector2.new(1, 0),
											BackgroundTransparency = 0,
											BackgroundColor3 = Theme.BaseSidebarColor3,
											

											[Fusion.OnEvent("Activated")] = function()
												props.selectedThread:set(threadId)
											end,

											[Fusion.Children] = {
												UICorner = UICorner(scope, {
													level = 0.5
												}),

												UIPadding = UIPadding(scope, {
													paddingHeight = UDim.new(0.4, 0),
													paddingWidth = UDim.new(0.7, 0)
												}),

												ImageLabel = ImageLabel(scope, {
													Image = Theme.StraightArrowIcon,
												})
											}
										}),

										Metadata = scope:New("Frame")({
											Size = UDim2.fromScale(0.8, 0.7),
											Position = UDim2.fromScale(0, 0.3),
											BackgroundTransparency = 1,

											[Fusion.Children] = Sift.Dictionary.merge(threadMetadataChildren, {
												UIPadding = UIPadding(scope, {
													paddingHeight = UDim.new(0, 12),
													paddingWidth = UDim.new(0, 12)
												}),

												UIListLayout = scope:New("UIListLayout")({
													FillDirection = Enum.FillDirection.Horizontal,
													Padding = UDim.new(0, 5),
												})
											})
										})
									}
								}))
							end

							return children
						end)
					})
				}
			}),

			StatsContentFrame = scope:New("Frame")({
				Size = UDim2.fromScale(0.45, 1),
				Position = UDim2.fromScale(0.55, 0),
				BackgroundTransparency = 1,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 15),
						paddingWidth = UDim.new(0, 0)
					}),

					VMStatsFrame = scope:New("Frame")({
						Size = UDim2.fromScale(1, 0.3),
						BackgroundColor3 = Theme.BaseTopbarColor3,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {
								level = 0.5
							}),

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

								[Fusion.Children] = scope:Computed(function(use)
									local stats = use(props.debugger.vmStats)
									local children = {}

									table.insert(children, UIPadding(scope, {
										paddingHeight = UDim.new(0, 15),
										paddingWidth = UDim.new(0, 30)
									}))

									table.insert(children, TextLabel(scope, {
										Text = "VM Stats",
										Size = UDim2.fromScale(1, 0.2),
										TextXAlignment = Enum.TextXAlignment.Left,
									}))

									for index, stat in {
										`VM Memory: {stats.memory or "?"}%`,
										`VM Threads: {stats.threads or "?"}`,
										`VM Instances: {stats.instances or "?"}`,
									} do
										table.insert(children, scope:New("Frame")({
											Size = UDim2.fromScale(1, 0.15),
											Position = UDim2.fromScale(0, 0.13 + (index * 0.15)),
											BackgroundTransparency = 1,

											[Fusion.Children] = {
												ArrowIcon = ImageLabel(scope, {
													Image = Theme.DropdownArrowIcon,
													Position = UDim2.fromScale(0, 0),
													AnchorPoint = Vector2.new(0, 0),
													Size = UDim2.fromScale(0.1, 1)
												}),

												Label = TextLabel(scope, {
													Text = stat,
													TextXAlignment = Enum.TextXAlignment.Left,
													Size = UDim2.fromScale(0.9, 1),
													Position = UDim2.fromScale(0.1, 0),
													TextTransparency = 0.5,
												})
											}
										}))
									end

									return children
								end)
							})
						}
					}),

					LuauRegistryFrame = scope:New("Frame")({
						Size = UDim2.fromScale(1, 0.68),
						Position = UDim2.fromScale(0, 0.32),
						BackgroundColor3 = Theme.BaseTopbarColor3,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {
								level = 0.5
							}),

							ScrollingFrame = scope:New("ScrollingFrame")({
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								AutomaticCanvasSize = Enum.AutomaticSize.XY,
								ClipsDescendants = true,
								CanvasSize = UDim2.fromScale(0, 1),
								MidImage = Theme.MiddleScrollingFrameIcon,
								TopImage = Theme.TopScrollingFrameIcon,
								BottomImage = Theme.BottomScrollingFrameIcon,
								ScrollBarImageColor3 = Theme.AccentColor3,
								ScrollBarThickness = 3,

								[Fusion.Children] = scope:Computed(function(use)
									local stats = use(props.debugger.luauRegistry)
									local children = {}

									table.insert(children, UIPadding(scope, {
										paddingHeight = UDim.new(0, 15),
										paddingWidth = UDim.new(0, 30)
									}))

									table.insert(children, TextLabel(scope, {
										Text = "VM Registry",
										Size = UDim2.fromScale(1, 0.09),
										TextXAlignment = Enum.TextXAlignment.Left,
									}))

									for index, stat in stats do
										table.insert(children, scope:New("Frame")({
											Size = UDim2.fromScale(1, 0.07),
											Position = UDim2.fromScale(0, 0.07 + (index * 0.1)),
											BackgroundTransparency = 1,

											[Fusion.Children] = {
												Icon = ImageLabel(scope, {
													Image = TYPE_ICON_MAP[stat.type] or Theme.CubeIcon,
													ImageColor3 = TYPE_ICON_COLORS[stat.type],
													Position = UDim2.fromScale(0, 0),
													AnchorPoint = Vector2.new(0, 0),
													Size = UDim2.fromScale(0.1, 1)
												}),

												Label = TextLabel(scope, {
													Text = stat.name,
													TextXAlignment = Enum.TextXAlignment.Left,
													Size = UDim2.fromScale(0.9, 1),
													Position = UDim2.fromScale(0.1, 0),
													TextTransparency = 0.5,
												})
											}
										}))
									end

									return children
								end)
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
	selectedThread: FusionTypes.Value<string>,

	debugger: {
		threadList: FusionTypes.Value<{ string }>,
		threadHistory: FusionTypes.Value<{ [string]: {
			type: string,
			message: string
		} }>,
		threadStats: FusionTypes.Value<{ [string]: {
			childThreadCount: number,
			methodCallCount: number,
			indexCount: number,
			instanceRefCount: number
		} }>,

		vmStats: FusionTypes.Value<{
			memory: number,
			threads: number,
			instances: number
		}>,

		luauRegistry: FusionTypes.Value<{
			{
				type: string,
				name: string
			}
		}>
	},
}

return {
	Render = ListFrame.Render,
} :: PageTypes.PageElement<Scope, Props>
