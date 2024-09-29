local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local SignalTypes = require(Package.Types.Signal)

local Theme = require(Package.Client.Interface.Theme)

local Content = require(Package.Client.Interface.Fusion.ContentPanel.Content)
local Topbar = require(Package.Client.Interface.Fusion.ContentPanel.Topbar)

local Fusion = require(Package.Parent.Fusion)

return function(scope: FusionTypes.Scope, props: {
	selectedPage: FusionTypes.Value<Frame>,

	minimiseWindowRequested: () -> (),

	signals: {
		sandbox: {
			evalServerCode: SignalTypes.Signal<string>,
			evalClientCode: SignalTypes.Signal<string>,
		},
	
		minimiseWindow: SignalTypes.Signal<()>,
	}
}): Frame
	return scope:New("Frame")({
		Size = UDim2.fromScale(0.8, 1),
		Position = UDim2.fromScale(0.2, 0),

		BorderSizePixel = 0,

		BackgroundColor3 = Theme.BaseBackgroundColor3,

		[Fusion.Children] = {
			Content = Content(scope, {
				selectedPage = props.selectedPage,
				signals = props.signals,
			}),
			Topbar = Topbar(scope, {
				selectedPage = props.selectedPage,
				minimiseWindowRequested = props.minimiseWindowRequested,
			})
		}
	})
end
