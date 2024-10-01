local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Package = script.Parent.Parent.Parent.Parent.Parent

local Sift = require(ReplicatedStorage.Packages.Sift)
local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local Theme = require(Package.Client.Interface.Theme)

local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local ImageButton = require(Package.Client.Interface.Components.ImageButton)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local TextButton = require(Package.Client.Interface.Components.TextButton)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local UICorner = require(Package.Client.Interface.Components.UICorner)

local Codeblock = require(Package.Client.Interface.Components.Codeblock)

local Fusion = require(Package.Parent.Fusion)

local Sandbox = {}

Sandbox.DisplayName = `Sandbox`
Sandbox.DisplayOrder = 2
Sandbox.DisplayIcon = Theme.SandboxIcon
Sandbox.Enabled = true

function Sandbox.Render(scope: Scope, props: Props)
	local textBoxValue = scope:Value()
	local dropdownOpenValue = scope:Value()

	local ignoreInputOnce = false

	table.insert(scope, UserInputService.InputEnded:Connect(function(inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			if not Fusion.peek(dropdownOpenValue) then
				return
			end

			if ignoreInputOnce then
				ignoreInputOnce = false
				
				return
			end

			dropdownOpenValue:set(false)
		end
	end))

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0.045, 0),
				paddingWidth = UDim.new(0.025, 0)
			}),

			Codeblock = Codeblock(scope, {
				Size = UDim2.fromScale(1, 0.85),
				
				textBox = textBoxValue
			}),

			runOnServerButton = Button(scope, {
				Size = UDim2.fromScale(0.13, 0.13),
				Position = UDim2.fromScale(0.92, 0.87),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.ServerColor3,

				[Fusion.OnEvent("Activated")] = function()
					local textBox = Fusion.peek(textBoxValue)

					if textBox then
						props.signals.sandbox.evalServerCode:Fire(textBox.Text)
					end
				end,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

					ImageLabel = ImageLabel(scope, {
						Image = Theme.PlayIcon,

						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),

						AnchorPoint = Vector2.new(0.5, 0.5)
					})
				}
			}),

			runOnClientButton = Button(scope, {
				Size = UDim2.fromScale(0.13, 0.13),
				Position = UDim2.fromScale(0.83, 0.87),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.ClientColor3,

				[Fusion.OnEvent("Activated")] = function()
					local textBox = Fusion.peek(textBoxValue)

					if textBox then
						props.signals.sandbox.evalClientCode:Fire(textBox.Text)
					end
				end,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

					ImageLabel = ImageLabel(scope, {
						Image = Theme.PlayIcon,

						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),

						AnchorPoint = Vector2.new(0.5, 0.5)
					})
				}
			}),

			clearButton = Button(scope, {
				Size = UDim2.fromScale(0.13, 0.13),
				Position = UDim2.fromScale(0, 0.87),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.BaseSidebarColor3,

				[Fusion.OnEvent("Activated")] = function()
					local textBox = Fusion.peek(textBoxValue)

					if textBox then
						textBox.Text = ``
					end
				end,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

					ImageLabel = ImageLabel(scope, {
						Image = Theme.RestartIcon,

						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),

						AnchorPoint = Vector2.new(0.5, 0.5)
					})
				}
			}),

			runtimeDropdown = Button(scope, {
				Size = UDim2.fromScale(0.3, 0.13),
				Position = UDim2.fromScale(0.085, 0.87),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.BaseSidebarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),

					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0.5, 0),
						paddingWidth = UDim.new(0.2, 0)
					}),
		
					TextLabel = TextLabel(scope, {
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = scope:Computed(function(use)
							return use(props.sandbox.runtime)
						end),

						Size = UDim2.fromScale(0.8, 1),
						Position = UDim2.fromScale(0, 0.5),

						AnchorPoint = Vector2.new(0, 0.5)
					}),

					TabButton = ImageButton(scope, {
						Size = UDim2.fromScale(0.2, 1),
						Image = Theme.TabIcon,
						Position = UDim2.fromScale(0.8, 0),
	
						Rotation = scope:Computed(function(use)
							local isOpen = use(dropdownOpenValue)

							return isOpen and 180 or 90
						end),
				
						[Fusion.OnEvent("Activated")] = function()
							ignoreInputOnce = true

							dropdownOpenValue:set(not Fusion.peek(dropdownOpenValue))
						end,
				
						[Fusion.Children] = {
							-- UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
						}
					})
				}
			}),

			dropdownElement = scope:New("Frame")({
				ZIndex = 2,

				Size = scope:Computed(function(use)
					local runtimes = use(props.sandbox.availableRuntimes)

					return UDim2.new(0.3, 0, 0.1, 30 * #runtimes)
				end),

				Position = scope:Computed(function(use)
					local runtimes = use(props.sandbox.availableRuntimes)

					return UDim2.new(0.085, 0, 0.785, -30 * #runtimes)
				end),
	
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.BaseSidebarColor3,
				Visible = scope:Computed(function(use)
					local isOpen = use(dropdownOpenValue)

					return isOpen
				end),

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),

					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 30),
						paddingWidth = UDim.new(0, 20)
					}),

					Gradient = scope:New("UIGradient")({
						Rotation = -90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
							ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
						})
					}),
		
					Line = scope:New("Frame")({
						Position = UDim2.fromScale(0.125, 1),
						Size = UDim2.new(0.75, 0, 0, 2),

						BackgroundColor3 = Theme.AccentColor3,
					}),

					Children = scope:Computed(function(use)
						local runtimes = use(props.sandbox.availableRuntimes)
						local runtimeLabels = {}

						for _, runtimeName in runtimes do
							table.insert(runtimeLabels, TextButton(scope, {
								Size = UDim2.new(1, 0, 0, 20),
								TextXAlignment = Enum.TextXAlignment.Left,
								
								Text = runtimeName,

								[Fusion.OnEvent("Activated")] = function()
									props.sandbox.runtime:set(runtimeName)
								end,

								[Fusion.Children] = {
									UIPadding = UIPadding(scope, {
										paddingHeight = UDim.new(0.3, 0),
										paddingWidth = UDim.new(0, 0)
									}),
								}
							}))
						end
	
						return scope:New("Frame")({
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,

							[Fusion.Children] = Sift.Dictionary.merge(runtimeLabels, {
								UIListLayout = scope:New("UIListLayout")({
									SortOrder = Enum.SortOrder.LayoutOrder,
									FillDirection = Enum.FillDirection.Vertical,
									VerticalAlignment = Enum.VerticalAlignment.Center,
					
									Padding = UDim.new(0.025, 0),
								}),
							})
						})
					end),
				}
			})
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {
	sandbox: {
		runtime: FusionTypes.Value<string>,
		availableRuntimes: FusionTypes.Value<{ string }>,
	},

	signals: {
		sandbox: {
			evalServerCode: SignalTypes.Signal<string>,
			evalClientCode: SignalTypes.Signal<string>,
		},
	}
}

return {
	Render = Sandbox.Render,
	Properties = {
		DisplayOrder = Sandbox.DisplayOrder,
		DisplayName = Sandbox.DisplayName,
		DisplayIcon = Sandbox.DisplayIcon,

		Enabled = Sandbox.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
