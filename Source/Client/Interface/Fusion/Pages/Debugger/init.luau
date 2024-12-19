local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Package = script.Parent.Parent.Parent.Parent.Parent

local Sift = require(ReplicatedStorage.Packages.Sift)
local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)

local Theme = require(Package.Client.Interface.Theme)

local ListFrame = require(Package.Client.Interface.Fusion.Pages.Debugger.ListFrame)
local ThreadFrame = require(Package.Client.Interface.Fusion.Pages.Debugger.ThreadFrame)

local Fusion = require(Package.Parent.Fusion)

local Embedded = {}

Embedded.DisplayName = `Debugger`
Embedded.DisplayOrder = 3
Embedded.DisplayIcon = Theme.DebuggerIcon
Embedded.Enabled = false

function Embedded.Render(scope: Scope, props: Props)
	local selectedThread = scope:Value()

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = scope:Computed(function(use)
			local threadValue = use(selectedThread)

			if threadValue then
				return ThreadFrame.Render(scope, Sift.Dictionary.merge({
					selectedThread = selectedThread
				}, props))
			else
				return ListFrame.Render(scope, Sift.Dictionary.merge({
					selectedThread = selectedThread
				}, props))
			end
		end)
	})
end

type Scope = FusionTypes.Scope
type Props = {}

return {
	Render = Embedded.Render,
	Properties = {
		DisplayOrder = Embedded.DisplayOrder,
		DisplayName = Embedded.DisplayName,
		DisplayIcon = Embedded.DisplayIcon,

		Enabled = Embedded.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
