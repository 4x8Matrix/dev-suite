local Package = script.Parent.Parent.Parent.Parent

local Fusion = require(Package.Parent.Fusion)

local FusionTypes = require(Package.Types.Fusion)
local SignalTypes = require(Package.Types.Signal)

local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIStroke = require(Package.Client.Interface.Components.UIStroke)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local ImageButton = require(Package.Client.Interface.Components.ImageButton)

local Theme = require(Package.Client.Interface.Theme)

return function(scope: FusionTypes.Scope, props: {
	callbacks: {
		showIndicator: FusionTypes.Value<() -> ()>,
		hideIndicator: FusionTypes.Value<() -> ()>,
	},

	signals: {
		openWindow: SignalTypes.Signal<()>,
	}
}): ScreenGui
	local goalPosition: FusionTypes.Value<number> = scope:Value(0)
	local tween: FusionTypes.Tween<number> = scope:Tween(goalPosition, TweenInfo.new(0.15, Enum.EasingStyle.Quad))

	props.callbacks.showIndicator:set(function()
		goalPosition:set(1)
	end)

	props.callbacks.hideIndicator:set(function()
		goalPosition:set(0)
	end)

	return scope:New("ScreenGui")({
		IgnoreGuiInset = true,
		ClipToDeviceSafeArea = false,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ScreenInsets = Enum.ScreenInsets.None,

		DisplayOrder = math.huge,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		[Fusion.Children] = {
			ContentFrame = scope:New("CanvasGroup")({
				AnchorPoint = Vector2.new(0.5, 0.5),

				Size = scope:Computed(function(use)
					local value = use(tween)

					return UDim2.fromOffset(24, 24):Lerp(UDim2.fromOffset(32, 32), value)
				end),

				Position = UDim2.fromScale(0.5, 0.1),

				BackgroundColor3 = Theme.BaseBackgroundColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),

					UIStroke = UIStroke(scope, {
						transparency = scope:Computed(function(use)
							local value = use(tween)

							return 1 - value
						end)
					}),

					UIPadding = UIPadding(scope, {
						paddingWidth = UDim.new(0.025, 0),
						paddingHeight = UDim.new(0.025, 0)
					}),

					UIGradient = scope:New("UIGradient")({
						Transparency = scope:Computed(function(use)
							local value = use(tween)

							return NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1 - value),
								NumberSequenceKeypoint.new(1, 1 - value)
							})
						end),
					}),

					OpenButton = ImageButton(scope, {
						Image = Theme.DevSuiteIcon,
						ImageColor3 = Theme.AccentColor3,
						ImageTransparency = 0.5,
		
						Size = UDim2.fromScale(0.75, 0.75),

						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
		
						[Fusion.OnEvent("Activated")] = function()
							props.signals.openWindow:Fire()
						end,
		
						[Fusion.Children] = {
							UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
						}
					})
				}
			})
		}
	})
end
