local Package = script.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)

local TextLabel = require(Package.Client.Interface.Components.TextLabel)

local UICorner = require(Package.Client.Interface.Components.UICorner)

local Highlighter = require(Package.Parent.Highlighter)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local DEFAULT_EDITOR_TEXT_CONTENT = "-- Press 'Run' to execute this code!\n\nprint(\"Hello, World!\")"

local function createTextBox(scope: FusionTypes.Scope, props: {
	lineCount: FusionTypes.Value<number>
})
	return scope:New("TextBox")({
		Size = UDim2.fromScale(1, 1),
		FontFace = Theme.CodeblockFont,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		RichText = true,
		TextColor3 = Theme.CodeblockColor3,
		TextSize = 17,
		Text = DEFAULT_EDITOR_TEXT_CONTENT,
		MultiLine = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,

		AutomaticSize = Enum.AutomaticSize.Y,

		[Fusion.OnChange("Text")] = function(content)
			props.lineCount:set(#string.split(content, "\n"))
		end,

		[Fusion.Children] = {
			UIPadding = scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, 10),
			})
		}
	})
end

local function createScrollingFrame(scope: FusionTypes.Scope, props: {
	textBox: FusionTypes.Value<TextBox>
})
	local hue, saturation, value = Theme.CodeblockBackgroundColor3:ToHSV()

	local lineCountFrameColor3 = Color3.fromHSV(hue, saturation, value * 0.7) 
	local lineCountNumberFrameColor3 = Color3.fromHSV(hue, saturation, value * 0.8)

	local lineCount = scope:Value(#string.split(DEFAULT_EDITOR_TEXT_CONTENT, "\n"))

	local textBox = createTextBox(scope, {
		lineCount = lineCount
	})

	local removeHighlighting

	props.textBox:set(textBox)

	return scope:New("ScrollingFrame")({
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Fusion.Children] = {
			LineCountFrame = scope:New("Frame")({
				Size = UDim2.new(0, 40, 1, 0),
				Position = UDim2.fromOffset(0, 0),

				BackgroundColor3 = lineCountFrameColor3,
				AutomaticSize = Enum.AutomaticSize.Y,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),

					RightPanel = scope:New("Frame")({
						Size = UDim2.fromScale(0.3, 1),
						BorderSizePixel = 0,
						BackgroundColor3 = lineCountNumberFrameColor3,
						Position = UDim2.fromScale(0.7, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
					}),

					LineCount = TextLabel(scope, {
						Size = UDim2.fromScale(0.7, 999),
						Position = UDim2.fromOffset(0, 3.5),
						AnchorPoint = Vector2.new(0, 0),
						TextSize = 17,
						FontFace = Theme.CodeblockFont,
						TextScaled = false,
						Text = scope:Computed(function(use)
							local lineCountText = ""
							use(lineCount)
							local count = Fusion.peek(lineCount)

							if count > 1000 and removeHighlighting then
								removeHighlighting()
								removeHighlighting = nil
							else
								if count < 1000 then
									if not removeHighlighting then
										task.defer(function()
											removeHighlighting = Highlighter.highlight({
												textObject = textBox
											})
										end)
									end
								end
							end

							for index = 1, count do
								lineCountText ..= `{index}\n`
							end

							return lineCountText
						end),
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Top,
						AutomaticSize = Enum.AutomaticSize.Y,
						

						[Fusion.Children] = {
							UIPadding = scope:New("UIPadding")({
								PaddingTop = UDim.new(0, 10),
								PaddingBottom = UDim.new(0, 10),
							})
						}
					})
				}
			}),

			CodeEditor = scope:New("Frame")({
				Size = UDim2.new(1, -45, 1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(45, 0),

				AutomaticSize = Enum.AutomaticSize.Y,

				[Fusion.Children] = {
					TextBox = textBox
				}
			})
		}
	})
end

return function(scope: FusionTypes.Scope, props: {
	Size: UDim2,

	textBox: FusionTypes.Value<TextBox>
})
	local scrollingFrame = createScrollingFrame(scope, {
		textBox = props.textBox,
	})

	return scope:New("CanvasGroup")({
		BackgroundColor3 = Theme.CodeblockBackgroundColor3,
		Size = props.Size,

		[Fusion.Children] = {
			UICorner = UICorner(scope, {
				level = 2,
			}),

			UIGradient = scope:New("UIGradient")({
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
				})
			}),

			ScrollingFrame = scrollingFrame
		}
	})
end
