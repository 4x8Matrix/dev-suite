--[[
	
]]

local Players = game:GetService("Players")

local Interface = require(script.Parent.Interface)

local MAXIMUM_EVENTS_COUNT = 10000

local instanceIgnoreList = {}
local propertyIgnoreList = {}

local updateInterfaceThread

local liveEventsArray = {}

local LiveEvents = {}

function LiveEvents.AddIgnoredInstance(_: LiveEvents, instance: Instance)
	table.insert(instanceIgnoreList, instance)
end

function LiveEvents.AddIgnoredProperty(_: LiveEvents, property: string)
	table.insert(propertyIgnoreList, property)
end

function LiveEvents.UpdateInterface(_: LiveEvents, noDelay: boolean?)
	if updateInterfaceThread then
		task.cancel(updateInterfaceThread)
	end

	updateInterfaceThread = task.delay(noDelay and 0 or 0.05, function()
		updateInterfaceThread = nil

		Interface:SetLiveEvents(liveEventsArray)
	end)
end

function LiveEvents.ReserveMemory(_: LiveEvents)
	local totalCount = #liveEventsArray

	if totalCount > MAXIMUM_EVENTS_COUNT then
		table.remove(liveEventsArray, #liveEventsArray)
	end
end

function LiveEvents.OnInstanceChanged(self: LiveEvents, object: Instance, property: string)
	table.insert(liveEventsArray, 1, {
		instanceName = object.Name,
		className = object.ClassName,
		propertyName = property,
		propertyValue = object[property]
	})

	self:ReserveMemory()
	self:UpdateInterface()
end

function LiveEvents.OnStart(self: LiveEvents)
	self:AddIgnoredInstance(workspace.CurrentCamera)
	self:AddIgnoredInstance(Players.LocalPlayer)

	self:AddIgnoredProperty(`Parent`)
	self:AddIgnoredProperty(`OriginalScriptGuid`)
	self:AddIgnoredProperty(`ScriptGuid`)
	self:AddIgnoredProperty(`OverrideMouseIconBehavior`)

	Players.LocalPlayer.CharacterAdded:Connect(function()
		self:AddIgnoredInstance(Players.LocalPlayer.Character)
	end)

	if Players.LocalPlayer.Character then
		self:AddIgnoredInstance(Players.LocalPlayer.Character)
	end
	
	-- selene: allow(deprecated)
	game.ItemChanged:Connect(function(object: Instance, descriptor: string)
		if table.find(instanceIgnoreList, object) then
			return
		end

		if table.find(propertyIgnoreList, descriptor) then
			return
		end

		for _, ignored in instanceIgnoreList do
			if ignored:IsAncestorOf(object) then
				return
			end
		end

		self:OnInstanceChanged(object, descriptor)
	end)
end

export type LiveEvents = typeof(LiveEvents)

return LiveEvents