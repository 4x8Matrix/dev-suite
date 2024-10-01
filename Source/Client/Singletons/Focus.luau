--[[
	Focus provides a way to query if the user is focused on the Roblox application or not.
]]

local UserInputService = game:GetService("UserInputService")

local Package = script.Parent.Parent.Parent

local Signal = require(Package.Parent.Signal)

local isFocused = true

local Focus = {}

Focus.OnFocused = Signal.new()
Focus.OnUnfocused = Signal.new()

--[[
	Returns a boolean dependant on if the window is active or not.
]]
function Focus.IsActive(_: Focus)
	return isFocused
end

function Focus.OnStart(self: Focus)
	UserInputService.WindowFocusReleased:Connect(function()
		isFocused = false

		self.OnUnfocused:Fire()
	end)

	UserInputService.WindowFocused:Connect(function()
		isFocused = true

		self.OnFocused:Fire()
	end)
end

export type Focus = typeof(Focus)

return Focus