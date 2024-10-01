local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local ImageButton = require(Package.Client.Interface.Components.ImageButton)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)
local ClassIndex = require(Package.Parent.ClassIndex)

local expandedInstances = { [workspace] = true }
local instanceLabels = {}
local selectedInstance

local Explorer = {}

local function processInstanceLabel(scope: FusionTypes.Scope, object: Instance, depth: number)
	local imageData = ClassIndex.GetClassIcon(object.ClassName)
	local childrenCount = #object:GetChildren()

	local tabButton
	local frame

	local isReadyForEvent
	
	tabButton = ImageButton(scope, {
		Size = UDim2.fromScale(1, 1),
		Image = Theme.TabIcon,
		ImageTransparency = childrenCount <= 0 and 1 or 0,

		Rotation = expandedInstances[object] and 90 or 0,

		[Fusion.OnEvent("Activated")] = function()
			expandedInstances[object] = not expandedInstances[object]

			tabButton.Rotation = expandedInstances[object] and 90 or 0
		end,

		[Fusion.Children] = {
			UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
		}
	})

	frame = scope:New("Frame")({
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.BaseTopbarColor3,

		[Fusion.OnEvent("InputBegan")] = function(inputObject: InputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				isReadyForEvent = true
			end
		end,

		[Fusion.OnEvent("InputEnded")] = function(inputObject: InputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				if not isReadyForEvent then
					return
				end

				selectedInstance:set(object)
			end
		end,

		[Fusion.Children] = {
			UIListLayout = scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				Padding = UDim.new(0.025, 0),
			}),

			PaddingLeft = scope:New("Frame")({
				Size = UDim2.fromScale(0.1 * depth, 1),
				BackgroundTransparency = 1,
				LayoutOrder = 1
			}),

			Tab = scope:New("Frame")({
				Size = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				LayoutOrder = 2,

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

					Tab = tabButton
				}
			}),

			Icon = ImageLabel(scope, {
				Size = UDim2.fromScale(0.75, 0.75),
				Image = imageData.Image,
				ImageRectOffset = imageData.ImageRectOffset,
				ImageRectSize = imageData.ImageRectSize,
				LayoutOrder = 3,

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			Label = TextLabel(scope, {
				Size = UDim2.fromScale(1, 0.75),
				Text = object.Name,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 4,
			})
		}
	})

	return frame
end

function Explorer.ProcessInstance(scope: FusionTypes.Scope, object: Instance, scrollingFrame: ScrollingFrame, depth: number)
	local children = object:GetChildren()
	local order = #scrollingFrame:GetChildren()
	local isSelected = Fusion.peek(selectedInstance) == object

	if object:HasTag("_DEBUG_IGNORE") then
		return
	end

	local label = instanceLabels[object] or processInstanceLabel(scope, object, depth)

	label.LayoutOrder = order

	if isSelected then
		label.BackgroundColor3 = Theme.AccentColor3
	else
		label.BackgroundColor3 = Theme.BaseTopbarColor3
	end

	if not instanceLabels[object] then
		instanceLabels[object] = label
	end

	label.Parent = scrollingFrame

	if expandedInstances[object] then
		for _, child in children do
			Explorer.ProcessInstance(scope, child, scrollingFrame, depth + 1)
		end
	end
end

function Explorer.Reset()
	instanceLabels = {}
end

function Explorer.Setup(scope: FusionTypes.Scope, value: FusionTypes.Value<Instance?>)
	selectedInstance = value

	scope:Observer(value):onChange(function()
		local instance = Fusion.peek(value)

		if instance then
			local parent = instance.Parent

			while parent ~= game do
				expandedInstances[parent] = true

				parent = parent.Parent
			end
		end
	end)
end

function Explorer.Render(scope: FusionTypes.Scope, instances: { Instance }, scrollingFrame: ScrollingFrame)
	for _, scrollingFrameObject in scrollingFrame:GetChildren() do
		if scrollingFrameObject:IsA("UIListLayout") then
			continue
		end

		scrollingFrameObject.Parent = nil
	end

	for _, object in instances do
		Explorer.ProcessInstance(scope, object, scrollingFrame, 0)
	end
end

return Explorer
