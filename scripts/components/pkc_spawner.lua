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

function PKC_SPAWNER:startSpawn(prefabName, radius, num, clear, actionFn)
	radius = radius or 4
	clear = clear ~= nil and clear or true
	self.inst:DoTaskInTime(.1, function()
		if self.inst then
			local spawnNum = num or pkc_weightedChoose(weightTable)
			local mobs = pkc_roundSpawn(self.inst, prefabName, radius, spawnNum, clear)
			if actionFn ~= nil and mobs then
				actionFn(mobs)
			end
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