local UserInputService = game:GetService("UserInputService")

local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local Theme = require(Package.Client.Interface.Theme)

local Button = require(Package.Client.Interface.Components.Button)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)
local UICorner = require(Package.Client.Interface.Components.UICorner)

local Codeblock = require(Package.Client.Interface.Components.Codeblock)

local disassemble = require(Package.Utilities.Luau.disassemble)

local LuauCeption = require(Package.Vendor.LuauCeption)

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

			disassembleButton = Button(scope, {
				Size = UDim2.fromScale(0.13, 0.13),
				Position = UDim2.fromScale(0.085, 0.87),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.BaseSidebarColor3,

				[Fusion.OnEvent("Activated")] = function()
					local textBox = Fusion.peek(textBoxValue)

					if textBox then
						local bytecode = LuauCeption.luau_compile(textBox.Text)

						textBox.Text = disassemble(bytecode)
					end
				end,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

					ImageLabel = ImageLabel(scope, {
						Image = Theme.DisassembleIcon,

						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),

						AnchorPoint = Vector2.new(0.5, 0.5)
					})
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
