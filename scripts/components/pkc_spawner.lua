--
-- 怪物据点安置
-- Author: Redpig
-- Date: 2021/2/1
--
local weightTable = {
	[0] = 10,
	[1] = 20,
	[2] = 20,
	[3] = 80,
	[4] = 60,
	[5] = 10,
}

local PKC_SPAWNER = Class(function(self, inst)
	self.inst = inst
	if not TheWorld.ismastersim then
		return
	end
end)

function PKC_SPAWNER:startSpawn(prefabName, radius)
	radius = radius or 4
	self.inst:DoTaskInTime(.1, function()
		if self.inst then
			local num = pkc_weightedChoose(weightTable)
			pkc_roundSpawn(self.inst, prefabName, radius, num, true)
		end
	end)
end

function PKC_SPAWNER:OnSave()
	return
	{
	}
end

function PKC_SPAWNER:OnLoad(data)
	if data ~= nil then
	end
end

return PKC_SPAWNER