--[[
	
]]

local UserInputService = game:GetService("UserInputService")

local Package = script.Parent.Parent.Parent

local Interface = require(Package.Client.Singletons.Interface)
local Theme = require(Package.Client.Interface.Theme)

local highlightInstance = Instance.new("Highlight")

local clickToHighlightEnabled = false
local clickToSelectEnabled = false

local Explorer = {}

function Explorer.OnStart(_: Explorer)
	highlightInstance.FillColor = Theme.AccentColor3
	highlightInstance:AddTag(`_DEBUG_IGNORE`)

	UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if not clickToSelectEnabled then
			return
		end
		
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			local mouse = game.UserInputService:GetMouseLocation()
			local ray = workspace.Camera:ViewportPointToRay(mouse.X, mouse.Y)
			local result = workspace:Raycast(ray.Origin, ray.Direction * 9999999999)

			if result then
				Interface:SetSelectedInstance(result.Instance)
			end
		end
	end)

	Interface.ClickToSelectDisabled:Connect(function()
		clickToSelectEnabled = false
	end)

	Interface.ClickToSelectEnabled:Connect(function()
		clickToSelectEnabled = true
	end)

	Interface.HighlightSelectedInstanceDisabled:Connect(function()
		clickToHighlightEnabled = false

		highlightInstance.Parent = nil
	end)

	Interface.HighlightSelectedInstanceEnabled:Connect(function()
		clickToHighlightEnabled = true

		highlightInstance.Parent = Interface:GetSelectedInstance()
	end)

	Interface.SelectedInstanceChanged:Connect(function()
		if not clickToHighlightEnabled then
			return
		end

		highlightInstance.Parent = Interface:GetSelectedInstance()
	end)
end

export type Explorer = typeof(Explorer)

return Explorer