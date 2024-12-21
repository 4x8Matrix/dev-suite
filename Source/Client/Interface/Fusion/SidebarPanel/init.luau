local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local Button = require(Package.Client.Interface.Components.Button)

local Sift = require(Package.Parent.Sift)
local Fusion = require(Package.Parent.Fusion)

local DEBUG_DEFAULT_MENU = `Debugger`

return function(scope: FusionTypes.Scope, props: {
	selectedPage: FusionTypes.Value<PageTypes.PageElement<FusionTypes.Scope, any>>,
	customPages: FusionTypes.Value<{
		{
			name: string,
			icon: string?,
			renderCallback: () -> () -> (),
			cleanupCallback: () -> ()
		}
	}>,
}): CanvasGroup
	return scope:Computed(function(use)
		local pageProperties = use(props.customPages)
		local customPages = {}
		local modulePages = {}

		local sidebarElements = { }
		local firstPage

		for _, page in Package.Client.Interface.Fusion.Pages:GetChildren() do
			local pageData = require(page)

			if not pageData.Properties.Enabled then
				pageData.Properties.DisplayOrder += 100
			end

			table.insert(modulePages, pageData)
		end

		for _, pageProperty in pageProperties do
			table.insert(customPages, {
				Properties = {
					DisplayOrder = #modulePages + 1,
					DisplayName = pageProperty.name,
					DisplayIcon = pageProperty.icon,

					Enabled = true,
				},

				RenderCallback = pageProperty.renderCallback,
				CleanupCallback = pageProperty.cleanupCallback,

				CustomPage = true,
			})
		end

		for _, pageData in Sift.Array.concat(modulePages, Fusion.peek(customPages)) do
			if DEBUG_DEFAULT_MENU then
				if pageData.Properties.DisplayName == DEBUG_DEFAULT_MENU then
					firstPage = pageData
				end
			else
				if pageData.Properties.DisplayOrder == 1 then
					firstPage = pageData
				end
			end
	
			table.insert(sidebarElements, scope:New("Frame")({
				Size = UDim2.new(1, 0, 0, 32),
	
				BackgroundTransparency = 1,
	
				LayoutOrder = pageData.Properties.DisplayOrder,
	
				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.5, 0),
						paddingWidth = UDim.new(0.2, 0)
					}),
	
					ImageLabel = ImageLabel(scope, {
						Position = UDim2.fromScale(0, 0.5),
						AnchorPoint = Vector2.new(0, 0.5),
						Size = UDim2.fromScale(0.175, 1),
	
						ImageTransparency = scope:Computed(function(use_)
							local isSelectedPage = scope.peek(props.selectedPage) == pageData
	
							use_(props.selectedPage)
	
							if not pageData.Properties.Enabled then
								return 0.8
							end
				
							return isSelectedPage and 0 or 0.5
						end),
	
						Image = pageData.Properties.DisplayIcon,
	
						[Fusion.Children] = {
							UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
						}
					}),
	
					TextLabel = TextLabel(scope, {
						Position = UDim2.fromScale(0.2, 0),
						Size = UDim2.fromScale(0.8, 1),
	
						TextTransparency = scope:Computed(function(use_)
							local isSelectedPage = scope.peek(props.selectedPage) == pageData
	
							use_(props.selectedPage)
	
							if not pageData.Properties.Enabled then
								return 0.8
							end
				
							return isSelectedPage and 0 or 0.5
						end),
	
						TextXAlignment = Enum.TextXAlignment.Left,
	
						Text = pageData.Properties.DisplayName,
	
						[Fusion.Children] = {
							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0.2, 0),
								paddingWidth = UDim.new(0.1, 0)
							}),
						}
					}),
	
					Button = Button(scope, {
						Active = pageData.Properties.Enabled,
	
						[Fusion.OnEvent("Activated")] = function()
							props.selectedPage:set(pageData)
						end
					})
				}
			}))
		end
	
		if not scope.peek(props.selectedPage) then
			props.selectedPage:set(firstPage)
		end
		
		return scope:New("Frame")({
			Size = UDim2.fromScale(0.2, 1),
	
			BackgroundColor3 = Theme.BaseSidebarColor3,
	
			[Fusion.Children] = {
				Content = scope:New("CanvasGroup")({
					Size = UDim2.fromScale(1, 1),
	
					BackgroundTransparency = 1,
	
					[Fusion.Children] = {
						UIGradient = scope:New("UIGradient")({
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.05, 0),
								NumberSequenceKeypoint.new(0.9, 0),
								NumberSequenceKeypoint.new(1, 1)
							})
						}),
			
						ScrollingFrame = scope:New("ScrollingFrame")({
							Size = UDim2.fromScale(1, 1),
							CanvasSize = UDim2.fromScale(0, 0),
	
							ScrollBarThickness = 0,
			
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
			
							BackgroundTransparency = 1,
			
							[Fusion.Children] = Sift.Dictionary.merge({
								UIListLayout = scope:New("UIListLayout")({
									FillDirection = Enum.FillDirection.Vertical,
									SortOrder = Enum.SortOrder.LayoutOrder
								})
							}, sidebarElements)
						})
					}
				})
			}
		})
	end)
end
