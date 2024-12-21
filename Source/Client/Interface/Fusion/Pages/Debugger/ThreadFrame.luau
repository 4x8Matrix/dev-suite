local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

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

local ListFrame = {}

function ListFrame.Render(scope: Scope, props: Props)
	local disabledFilters = scope:Value({})

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0, 15),
				paddingWidth = UDim.new(0, 15)
			}),

			Topbar = scope:New("Frame")({
				Size = UDim2.fromScale(0.885, 0.15),
				Position = UDim2.fromScale(0.115, 0),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, { }),

					Frames = scope:New("Frame")({
						Size =  UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,

						[Fusion.Children] = scope:Computed(function(use)
							local disabledFiltersValue = use(disabledFilters)

							local children = {
								UIListLayout = scope:New("UIListLayout")({
									VerticalAlignment = Enum.VerticalAlignment.Center,
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 10)
								}),
	
								UIPadding = UIPadding(scope, {
									paddingHeight = UDim.new(0, 20),
									paddingWidth = UDim.new(0, 20)
								}),
							}

							for filterName, icon in TYPE_ICON_MAP do
								table.insert(children, ImageButton(scope, {
									Size = UDim2.fromScale(1, 1),
									Image = icon,
									ImageTransparency = disabledFiltersValue[filterName] and 0.5 or 0,
	
									[Fusion.OnEvent("Activated")] = function()
										disabledFiltersValue[filterName] = not disabledFiltersValue[filterName]

										disabledFilters:set(disabledFiltersValue)
									end,
	
									[Fusion.Children] = {
										UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),
									}
								}))
							end
							
							return children 
						end)
					})
				}
			}),

			ExitButton = ImageButton(scope, {
				Size = UDim2.fromScale(0.1, 0.15),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.OnEvent("Activated")] = function()
					props.selectedThread:set(nil)
				end,

				[Fusion.Children] = {
					UICorner = UICorner(scope, { }),

					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.6, 0),
						paddingWidth = UDim.new(0.6, 0)
					}),

					ImageLabel = ImageLabel(scope, {
						Image = Theme.StraightArrowIcon,
						Rotation = 180,
					})
				},
			}),

			Content = scope:New("Frame")({
				Size = UDim2.fromScale(1, 0.85),
				Position = UDim2.fromScale(0, 0.18),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, { }),

					ScrollingFrame = scope:New("ScrollingFrame")({
						Size = UDim2.fromScale(1, 1),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.fromScale(0, 0),
						ClipsDescendants = true,
						MidImage = Theme.MiddleScrollingFrameIcon,
						TopImage = Theme.TopScrollingFrameIcon,
						BottomImage = Theme.BottomScrollingFrameIcon,
						ScrollBarImageColor3 = Theme.AccentColor3,
						ScrollBarThickness = 3,
						BackgroundTransparency = 1,

						[Fusion.Children] = scope:Computed(function(use)
							local threadHistory = use(props.debugger.threadHistory)
							local selectedThread = Fusion.peek(props.selectedThread)

							if not selectedThread then
								return { }
							end
				
							local children = {
								UIListLayout = scope:New("UIListLayout")({
									SortOrder = Enum.SortOrder.LayoutOrder,
									FillDirection = Enum.FillDirection.Vertical,
								}),
							}

							if #threadHistory[selectedThread] == 0 then
								table.insert(children, scope:New("Frame")({
									Size = UDim2.fromScale(1, 0.2),
									BackgroundColor3 = Theme.BaseTopbarColor3,
								
									[Fusion.Children] = {
										UIPadding = UIPadding(scope, {
											paddingWidth = UDim.new(0.1, 0),
											paddingHeight = UDim.new(0.25, 0)
										}),
				
										TextLabel0 = TextLabel(scope, {
											Size = UDim2.fromScale(1, 0.45),
											TextTransparency = 0.5,
											Text = `Nothing has been captured yet..`
										})
									}
								}))
							end

							for index, object in threadHistory[selectedThread] do
								table.insert(children, scope:New("Frame")({
									Size = UDim2.new(1, 0, 0, 25),
									BackgroundTransparency = 1,
									LayoutOrder = index,
									Visible = scope:Computed(function(_use)
										local disabledFiltersValue = _use(disabledFilters)

										return not disabledFiltersValue[object.type]
									end),

									[Fusion.Children] = {
										UIPadding = UIPadding(scope, {
											paddingHeight = UDim.new(0, 0),
											paddingWidth = UDim.new(0, 10)
										}),

										Icon = ImageLabel(scope, {
											Size = UDim2.fromScale(0.1, 0.8),
											Image = TYPE_ICON_MAP[object.type],
											Position = UDim2.fromScale(0, 0.25),
										}),

										Text = TextLabel(scope, {
											Text = `<i>{object.message}</i>`,
											Size = UDim2.fromScale(0.9, 0.6),
											Position = UDim2.fromScale(0.1, 0.4),
											TextXAlignment = Enum.TextXAlignment.Left,
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
end

type Scope = FusionTypes.Scope
type Props = {
	selectedThread: FusionTypes.Value<string?>,

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
