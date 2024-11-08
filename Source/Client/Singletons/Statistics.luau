--[[
	
]]

local Stats = game:GetService("Stats")

local Package = script.Parent.Parent.Parent

local Interface = require(Package.Client.Singletons.Interface)

local AUTO_UPDATE_ENABLED = false
local INTERNAL_MEMORY_TAGS_MAP = table.freeze({
	Roblox = {
		Enum.DeveloperMemoryTag.LuaHeap,
		Enum.DeveloperMemoryTag.Script,
		Enum.DeveloperMemoryTag.Signals,
		Enum.DeveloperMemoryTag.Internal,
		Enum.DeveloperMemoryTag.HttpCache,
	},
	World = {
		Enum.DeveloperMemoryTag.Sounds,
		Enum.DeveloperMemoryTag.GeometryCSG,
		Enum.DeveloperMemoryTag.Navigation,
		Enum.DeveloperMemoryTag.TerrainVoxels,
		Enum.DeveloperMemoryTag.Animation,
		Enum.DeveloperMemoryTag.Gui,
	},
	Physics = {
		Enum.DeveloperMemoryTag.PhysicsCollision,
		Enum.DeveloperMemoryTag.PhysicsParts,
	},
	Graphics = {
		Enum.DeveloperMemoryTag.GraphicsSolidModels,
		Enum.DeveloperMemoryTag.GraphicsSpatialHash,
		Enum.DeveloperMemoryTag.GraphicsTerrain,
		Enum.DeveloperMemoryTag.GraphicsParticles,
		Enum.DeveloperMemoryTag.GraphicsTexture,
	}
})

local Statistics = {}

function Statistics.UpdateMemoryStats(_: Statistics)
	local memoryStats = {}
	
	for category, objects in INTERNAL_MEMORY_TAGS_MAP do
		memoryStats[category] = {}

		for _, memoryTag in objects do
			local name = memoryTag.Name
			local stat = Stats:GetMemoryUsageMbForTag(memoryTag)

			memoryStats[category][name] = math.round(stat * 100) / 100
		end
	end

	Interface:SetMemoryStats(memoryStats)
end

function Statistics.UpdateNetworkStats(_: Statistics)
	Interface:SetNetworkStats({
		Data = {
			Send = math.round(Stats.DataSendKbps * 100) / 100,
			Recv = math.round(Stats.DataReceiveKbps * 100) / 100,
		},
		Physics = {
			Send = math.round(Stats.PhysicsSendKbps * 100) / 100,
			Recv = math.round(Stats.PhysicsReceiveKbps * 100) / 100,
		}
	})
end

function Statistics.UpdateInstanceStats(_: Statistics)
	Interface:SetInstanceStats({
		Moving = math.round(Stats.MovingPrimitivesCount * 100) / 100,
		Static = math.round(Stats.PrimitivesCount * 100) / 100,

		Total = math.round(Stats.InstanceCount * 100) / 100,
		Collisions = math.round(Stats.ContactsCount * 100) / 100
	})
end

function Statistics.UpdateFrameStats(_: Statistics)
	Interface:SetFrameStats({
		Frame = Stats.RenderFrameTime,
		Heartbeat = Stats.HeartbeatTime,
		Physics = Stats.PhysicsTime,

		["GPU Time"] = Stats.RenderGPUFrameTime,
		["CPU Time"] = Stats.RenderCPUFrameTime,
	})
end

function Statistics.UpdateDrawcallStats(_: Statistics)
	Interface:SetDrawcallStats({
		Scene = {
			Triangles = math.round(Stats.SceneTriangleCount * 100) / 100,
			Drawcalls = math.round(Stats.SceneDrawcallCount * 100) / 100,
		},
		Shadows = {
			Triangles = math.round(Stats.ShadowTriangleCount * 100) / 100,
			Drawcalls = math.round(Stats.ShadowDrawCount * 100) / 100,
		}
	})
end

function Statistics.UpdateStatsBulk(self: Statistics)
	-- self:UpdateDrawcallStats()
	task.wait()
	-- self:UpdateFrameStats()
	task.wait()
	self:UpdateInstanceStats()
	task.wait()
	self:UpdateMemoryStats()
	task.wait()
	self:UpdateNetworkStats()
end

function Statistics.OnStart(self: Statistics)
	Interface:SetMetadataStats({
		-- selene: allow(undefined_variable)
		["Rbxl Version"] = string.split(version(), ".")[2],
		["Place Version"] = game.PlaceVersion,
	})

	Interface.RefreshStatsRequested:Connect(function()
		self:UpdateStatsBulk()
	end)

	while AUTO_UPDATE_ENABLED do
		task.wait(1)

		self:UpdateStatsBulk()
	end
end

export type Statistics = typeof(Statistics)

return Statistics