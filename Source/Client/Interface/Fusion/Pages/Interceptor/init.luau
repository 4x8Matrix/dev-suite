local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local Theme = require(Package.Client.Interface.Theme)

local EventList = require(Package.Client.Interface.Fusion.Pages.Interceptor.EventList)
local EventInformation = require(Package.Client.Interface.Fusion.Pages.Interceptor.EventInformation)

local Fusion = require(Package.Parent.Fusion)

local Interceptor = {}

Interceptor.DisplayName = `Interceptor`
Interceptor.DisplayOrder = 4
Interceptor.DisplayIcon = Theme.InterceptorIcon
Interceptor.Enabled = true

function Interceptor.Render(scope: Scope, props: Props)
	local focusedEvent = scope:Value(nil)

	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = scope:Computed(function(use)
			local event = use(focusedEvent)

			if event then
				return EventInformation.Render(scope, props, focusedEvent)
			else
				return EventList.Render(scope, props, focusedEvent)
			end
		end)
	})
end

type Scope = FusionTypes.Scope
type Props = {
	interceptor: {
		intercepted: FusionTypes.Value<{
			eventType: "RemoteEvent" | "BindableEvent" | "RemoteFunction" | "BindableFunction",
			eventUUID: string?,

			eventName: string,
			eventData: string,
			eventSize: string,

			ancestors: {
				{
					class: string,
					name: string
				}
			},

			context: "Server" | "Client",
		}>
	},

	signals: {
		interceptor: {
			repeatEvent: SignalTypes.Signal<string>,
		},
	}
}

return {
	Render = Interceptor.Render,
	Properties = {
		DisplayOrder = Interceptor.DisplayOrder,
		DisplayName = Interceptor.DisplayName,
		DisplayIcon = Interceptor.DisplayIcon,

		Enabled = Interceptor.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
