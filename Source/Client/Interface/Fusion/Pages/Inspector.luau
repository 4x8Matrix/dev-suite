local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local Repr = require(Package.Vendor.Repr)

local Highlighter = require(Package.Parent.Highlighter)
local Sift = require(Package.Parent.Sift)

local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Inspector = {}

Inspector.DisplayName = `Inspector`
Inspector.DisplayOrder = 7
Inspector.DisplayIcon = Theme.InspectorIcon
Inspector.Enabled = true

function Inspector.Render(scope: Scope, props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UICorner = UICorner(scope, {}),

			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0, 10),
				paddingWidth = UDim.new(0, 10)
			}),

			InstanceLabel = scope:New("Frame")({
				Size = UDim2.fromScale(1, 0.09),
				BackgroundColor3 = Theme.BaseTopbarColor3,
				BackgroundTransparency = 0,

				[Fusion.Children] = {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
		
						Padding = UDim.new(0.025, 0),
					}),

					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 0),
						paddingWidth = UDim.new(0, 10)
					}),

					Label = scope:Computed(function(use)
						local selectedInstance = use(props.explorer.selectedInstance)

						if not selectedInstance or not selectedInstance:IsA("ModuleScript") then
							return nil
						end

						local name = selectedInstance:GetFullName()

						if #name > 50 then
							name = `...{string.sub(name, #name - 50, #name)}`
						end

						return TextLabel(scope, {
							Size = UDim2.fromScale(1, 0.5),
							Text = `<i>{name}</i>`,
							TextTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Left,
						})
					end)
				}
			}),

			ScrollingFrame = scope:Computed(function(use)
				local selectedInstance = use(props.explorer.selectedInstance)
				local isValidInstance = selectedInstance and selectedInstance:IsA("ModuleScript")

				local messageLabels = {}
			
				if not selectedInstance or not selectedInstance:IsA("ModuleScript") then
					table.insert(messageLabels, scope:New("Frame")({
						Size = UDim2.new(1, 0, 0, 40),
						BackgroundColor3 = Theme.BaseTopbarColor3,
					
						[Fusion.Children] = {
							UIPadding = UIPadding(scope, {
								paddingWidth = UDim.new(0.05, 0),
								paddingHeight = UDim.new(0.5, 0)
							}),
	
							TextLabel = TextLabel(scope, {
								TextTransparency = 0.5,
								Text = `Please select a <b><i>ModuleScript</i></b> in the <b><i>Explorer</i></b> to inspect.`,
							})
						}
					}))
				else
					local success, response = pcall(require, selectedInstance)

					if not success then
						response = string.gsub(response, "<", "&lt;")
						response = string.gsub(response, ">", "&gt;")

						table.insert(messageLabels, scope:New("Frame")({
							Size = UDim2.new(1, 0, 0, 40),
							BackgroundColor3 = Theme.BaseTopbarColor3,
						
							[Fusion.Children] = {
								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0.05, 0),
									paddingHeight = UDim.new(0.5, 0)
								}),
		
								TextLabel = TextLabel(scope, {
									TextTransparency = 0.5,
									Text = `Module <b><i>{selectedInstance.Name}</i></b> could not be loaded.`,
								}),
							}
						}))

						table.insert(messageLabels, scope:New("Frame")({
							Size = UDim2.new(1, 0, 0, 40),
							BackgroundColor3 = Theme.BaseTopbarColor3,
						
							[Fusion.Children] = {
								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0.05, 0),
									paddingHeight = UDim.new(0.5, 0)
								}),
		
								TextLabel = TextLabel(scope, {
									TextTransparency = 0.5,
									TextColor3 = Theme.ErrorColor3,
									Text = response,
								}),
							}
						}))
					else
						local label = TextLabel(scope, {
							TextTransparency = 0.5,
							TextXAlignment = Enum.TextXAlignment.Left,
							AutomaticSize = Enum.AutomaticSize.XY,
							Text = Repr(response, {
								pretty = true,
								-- tabs = true,
								spaces = 8,
							}),
							TextScaled = false,
							TextWrapped = false,
						})

						table.insert(messageLabels, scope:New("Frame")({
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1,
						
							[Fusion.Children] = {
								UIPadding = UIPadding(scope, {
									paddingWidth = UDim.new(0, 10),
									paddingHeight = UDim.new(0, 10)
								}),
		
								TextLabel = label,
							}
						}))

						task.defer(function()
							Highlighter.highlight({
								textObject = label
							})
						end)
					end
				end

				return scope:New("ScrollingFrame")({
					Size = UDim2.fromScale(1, isValidInstance and 0.89 or 1),
					Position = UDim2.fromScale(0, isValidInstance and 0.11 or 0),
					BackgroundColor3 = Theme.BaseTopbarColor3,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromScale(0, 0),
					ClipsDescendants = true,
					MidImage = Theme.MiddleScrollingFrameIcon,
					TopImage = Theme.TopScrollingFrameIcon,
					BottomImage = Theme.BottomScrollingFrameIcon,
					ScrollBarImageColor3 = Theme.AccentColor3,
					ScrollBarThickness = 3,
	
					[Fusion.Children] = Sift.Dictionary.merge(messageLabels, {
						UIListLayout = scope:New("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
							VerticalAlignment = Enum.VerticalAlignment.Top,
			
							Padding = UDim.new(0, 10),
						}),
					})
				})
			end)
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
	Render = Inspector.Render,
	Properties = {
		DisplayOrder = Inspector.DisplayOrder,
		DisplayName = Inspector.DisplayName,
		DisplayIcon = Inspector.DisplayIcon,

		Enabled = Inspector.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
