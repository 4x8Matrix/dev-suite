local Package = script.Parent.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)
local Sift = require(Package.Parent.Sift)
local ClassIndex = require(Package.Parent.ClassIndex)

local MEMBER_TYPE_ICON_MAP = table.freeze({
	["Event"] = Theme.EventIcon,
	["Function"] = Theme.FunctionIcon,
	["Property"] = Theme.PropertyIcon,
	["Attribute"] = Theme.PropertyIcon
})

local MEMBER_TYPE_ICON_COLORS = table.freeze({
	["Event"] = Theme.EventIconColor,
	["Function"] = Theme.FunctionIconColor,
	["Property"] = Theme.PropertyIconColor,
	["Attribute"] = Theme.FunctionIconColor
})

local MEMBER_TYPE_TEXT_COLORS = table.freeze({
	["boolean"] = Theme.BooleanColor,
	["number"] = Theme.NumberColor,
	["Vector3"] = Theme.NumberColor,
	["CFrame"] = Theme.NumberColor,
	["nil"] = Theme.NilColor,
	["string"] = Theme.StringColor,
	["EnumItem"] = Theme.EnumColor,
	["Instance"] = Theme.InstanceColor
})

local currentlyRenderingInstance
local fusionValue
local hasRenderedEmptyPage = false

local Properties = {}

local function processData(scope: FusionTypes.Scope, object: Instance, propertyName: string, isAttribute: boolean)
	local member = isAttribute and object:GetAttribute(propertyName) or object[propertyName]
	local memberType = typeof(member)

	local textColor3 = MEMBER_TYPE_TEXT_COLORS[memberType] or Theme.BaseLabelColor3
	local textContent = tostring(member)
	local textSize = UDim2.new(1, 0, 0, 20)

	if memberType == "table" then
		textContent = "{ ... }"
	elseif memberType == "string" then
		textContent = `"{member}"`
	elseif memberType == "EnumItem" then
		textContent = `{member.Name}`
	elseif memberType == "Vector3" then
		textContent = `<b>X:</b> {math.round(member.X)}\n<b>Y:</b> {math.round(member.Y)}\n<b>Z:</b> {math.round(member.Z)}`

		textSize = UDim2.new(1, 0, 0, 40)
	elseif memberType == "CFrame" then
		local components = table.pack(member:GetComponents())

		textContent = `<b>X:</b> {
			math.round(components[1])
		}\n<b>Y:</b> {
			math.round(components[2])
		}\n<b>Z:</b> {
			math.round(components[3])
		}\n<b>R00:</b> {
			math.round(components[4])
		}\n<b>R01:</b> {
			math.round(components[5])
		}\n<b>R02:</b> {
			math.round(components[6])
		}\n<b>R10:</b> {
			math.round(components[7])
		}\n<b>R11:</b> {
			math.round(components[8])
		}\n<b>R12:</b> {
			math.round(components[9])
		}\n<b>R20:</b> {
			math.round(components[10])
		}\n<b>R21:</b> {
			math.round(components[11])
		}`

		textSize = UDim2.new(1, 0, 0, 130)
	end

	return scope:New("Frame")({
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,

		[Fusion.Children] = {
			UIListLayout = scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				Padding = UDim.new(0.025, 0),
			}),

			PaddingLeft = scope:New("Frame")({
				Size = UDim2.new(0.2, 0, 0, 20),
				BackgroundTransparency = 1,
				LayoutOrder = 1
			}),

			Icon = ImageLabel(scope, {
				Size = UDim2.new(1, 0, 0, 12),
				Image = Theme.DropdownArrowIcon,
				LayoutOrder = 2,

				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			Label = TextLabel(scope, {
				Size = textSize,
				Text = textContent,
				TextColor3 = textColor3,
				AutomaticSize = Enum.AutomaticSize.X,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 3,

				[Fusion.Children] = {
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 7.5),
						paddingWidth = UDim.new()
					})
				}
			})
		}
	})
end

local function processMember(scope: FusionTypes.Scope, object: Instance, className: string, memberName: string, isAttribute: boolean)
	local memberType = isAttribute and "Attribute" or ClassIndex.GetClassMemberType(className, memberName)

	local memberIcon = MEMBER_TYPE_ICON_MAP[memberType]
	local memberIconColor = MEMBER_TYPE_ICON_COLORS[memberType]

	local isProperty = memberType == "Property"

	return scope:New("Frame")({
		Size = UDim2.new(1, 0, 0, 20 * (isProperty and 2 or 1)),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,

		[Fusion.Children] = {
			Content = scope:New("Frame")({
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,

				[Fusion.Children] = {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
		
						Padding = UDim.new(0.025, 0),
					}),
		
					PaddingLeft = scope:New("Frame")({
						Size = UDim2.fromScale(0.1, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 1
					}),
		
					Icon = ImageLabel(scope, {
						Size = UDim2.new(0, 20, 0, 12),
						Image = memberIcon,
						ImageColor3 = memberIconColor,
						LayoutOrder = 2,
		
						[Fusion.Children] = {
							UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
						}
					}),
		
					Label = TextLabel(scope, {
						Size = UDim2.new(1, 0, 0, 20),
						Text = memberName,
						AutomaticSize = Enum.AutomaticSize.X,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 3,

						[Fusion.Children] = {
							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0.25, 0),
								paddingWidth = UDim.new()
							})
						}
					})
				}
			}),

			property = (isProperty or isAttribute) and processData(scope, object, memberName, isAttribute) or nil
		}
	})
end

local function processClass(scope: FusionTypes.Scope, object: Instance, class: string)
	local imageData = ClassIndex.GetClassIcon(class)
	local members = {}

	local classMembers = ClassIndex.GetClassMembers(class)

	table.sort(classMembers, function(a, b)
		return ClassIndex.GetClassMemberType(class, a) > ClassIndex.GetClassMemberType(class, b)
	end)

	for _, member in classMembers do
		table.insert(members, processMember(scope, object, class, member, false))
	end

	for name in object:GetAttributes() do
		table.insert(members, processMember(scope, object, class, name, true))
	end

	return scope:New("Frame")({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,

		[Fusion.Children] = Sift.Dictionary.merge(members, {
			UIListLayout = scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			Header = scope:New("Frame")({
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,

				LayoutOrder = -1,

				[Fusion.Children] = {
					UIListLayout = scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
		
						Padding = UDim.new(0.025, 0),
					}),
		
					Icon = ImageLabel(scope, {
						Size = UDim2.new(1, 0, 0, 12),
						Image = imageData.Image,
						ImageRectOffset = imageData.ImageRectOffset,
						ImageRectSize = imageData.ImageRectSize,
						LayoutOrder = 3,
		
						[Fusion.Children] = {
							UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
						}
					}),
		
					Label = TextLabel(scope, {
						Size = UDim2.new(1, 0, 0, 20),
						Text = `Class '{class}'`,
						AutomaticSize = Enum.AutomaticSize.X,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 4,

						[Fusion.Children] = {
							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0.25, 0),
								paddingWidth = UDim.new()
							})
						}
					})
				}
			})
		})
	})
end

function Properties.Setup(_: FusionTypes.Scope, value: FusionTypes.Value<Instance?>)
	fusionValue = value
end

function Properties.Stop(_: FusionTypes.Scope)
	currentlyRenderingInstance = nil
end

function Properties.RenderEmptyPage(scope: FusionTypes.Scope, scrollingFrame: ScrollingFrame)
	scope:New("Frame")({
		Parent = scrollingFrame,
		Size = UDim2.fromScale(0.9, 0.9),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			-- UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({}),

			ImageLabel = ImageLabel(scope, {
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0.15, 0.15),
				
				Image = Theme.PropertiesIcon,
				ImageTransparency = 0.5,
		
				[Fusion.Children] = {
					UIAspectRatioConstraint = scope:New("UIAspectRatioConstraint")({})
				}
			}),

			TextLabel = TextLabel(scope, {
				Size = UDim2.fromScale(0.8, 0.15),
				Position = UDim2.fromScale(0.15, 0.75),

				Text = "Select an Object to view the properties of that Object.",
				TextTransparency = 0.5,
			})
		}
	})
end

function Properties.Render(scope: FusionTypes.Scope, scrollingFrame: ScrollingFrame)
	local instance = Fusion.peek(fusionValue)

	if not instance and not hasRenderedEmptyPage then
		hasRenderedEmptyPage = true

		Properties.RenderEmptyPage(scope, scrollingFrame)
	end
	
	if currentlyRenderingInstance == instance then
		return
	end

	currentlyRenderingInstance = instance

	for _, scrollingFrameObject in scrollingFrame:GetChildren() do
		if scrollingFrameObject:IsA("UIListLayout") then
			continue
		end

		scrollingFrameObject:Destroy()
	end

	local classes = ClassIndex.GetClassSuperclasses(instance.ClassName)
	
	table.remove(classes, #classes)
	table.insert(classes, 1, instance.ClassName)

	for _, class in classes do
		local frame = processClass(scope, instance, class)

		frame.Parent = scrollingFrame
	end
end

return Properties
