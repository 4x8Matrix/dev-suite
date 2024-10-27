--[[
	LiveEvents handles the logic for the LiveEvents tab on the Interface
]]

local Players = game:GetService("Players")

local Package = script.Parent.Parent.Parent

local Interface = require(Package.Client.Singletons.Interface)

local ClassIndex = require(Package.Parent.ClassIndex)

local MAXIMUM_EVENTS_COUNT = 10000

local instanceIgnoreList = {}
local propertyIgnoreList = {}

local updateInterfaceThread

local liveEventsArray = {}

local LiveEvents = {}

--[[
	Will block an Instance, or descendants of that instance from appearing on the 'LiveEvents' tab.
]]
function LiveEvents.AddIgnoredInstance(_: LiveEvents, instance: Instance)
	table.insert(instanceIgnoreList, instance)
end

--[[
	Will block a property from appearing on the 'LiveEvents' tab.
]]
function LiveEvents.AddIgnoredProperty(_: LiveEvents, property: string)
	table.insert(propertyIgnoreList, property)
end

--[[
	Responsible for updating the interface, has a delay of 0.05 to reduce large changes having an impact on performance.
]]
function LiveEvents.UpdateInterface(_: LiveEvents, noDelay: boolean?)
	if updateInterfaceThread then
		task.cancel(updateInterfaceThread)
	end

	updateInterfaceThread = task.delay(noDelay and 0 or 0.05, function()
		updateInterfaceThread = nil

		Interface:SetLiveEvents(liveEventsArray)
	end)
end

--[[
	Responsible for removing any excess events in the case we hit the maximum events we can log.
]]
function LiveEvents.ReserveMemory(_: LiveEvents)
	local totalCount = #liveEventsArray

	if totalCount > MAXIMUM_EVENTS_COUNT then
		table.remove(liveEventsArray, #liveEventsArray)
	end
end

--[[
	Callback responsible for handling what happens when an instance's property, changes.
]]
function LiveEvents.OnInstanceChanged(self: LiveEvents, object: Instance, property: string)
	local propertySecurity = ClassIndex.GetClassMemberSecurity(object.ClassName, property)

	table.insert(liveEventsArray, 1, {
		instanceName = object.Name,
		className = object.ClassName,
		propertyName = property,
		propertyValue = propertySecurity.Read == "None" and object[property]
			or "Unknown (ScriptSecurity)"
	})

	self:ReserveMemory()
	self:UpdateInterface()
end

function LiveEvents.OnStart(self: LiveEvents)
	-- events that just annoyed me, we don't need and update when the camera changes. We know.
	self:AddIgnoredInstance(workspace.CurrentCamera)
	self:AddIgnoredInstance(Players.LocalPlayer)

	self:AddIgnoredProperty(`Parent`)
	self:AddIgnoredProperty(`TopbarInset`)
	self:AddIgnoredProperty(`NetworkIsSleeping`)

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