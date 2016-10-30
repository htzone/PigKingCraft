--@name pkc_producebase
--@description 生成基地组件
--@auther redpig
--@date 2016-10-23

local PKC_BASE = Class(function(self, inst)
	self.inst = inst
end)

--随机地点中心
local function choose_pos()
	local ground = TheWorld
	local centers = {}
	for i, node in ipairs(ground.topology.nodes) do
		if ground.Map:IsPassableAtPoint(node.x, 0, node.y) then
			table.insert(centers, {x = node.x, z = node.y})
		end
	end
	if #centers > 0 then
		local pos = centers[math.random(#centers)]
		return Point(pos.x, 0, pos.z)
	end
end

--生成基地
function PKC_BASE:ProduceBase(group_num)
	
	if not self.inst.hasProduceBase then
		local pt = self.inst:GetPosition()
		local x,y,z = pt:Get()
		local pos1 = choose_pos()
		while pos1:Dist(pt) < 200 do
			pos1 = choose_pos()
		end
		local x1,y1,z1 = pos1:Get()
		SpawnPrefab("firepit").Transform:SetPosition(x1+1.5,y,z1)
		SpawnPrefab("coldfirepit").Transform:SetPosition(x1-1.5,y,z1)
		SpawnPrefab("cookpot").Transform:SetPosition(x1,y,z1-3)
		SpawnPrefab("cookpot").Transform:SetPosition(x1+3,y,z1-3)
		SpawnPrefab("cookpot").Transform:SetPosition(x1,y,z1-6)
		SpawnPrefab("cookpot").Transform:SetPosition(x1+3,y,z1-6)
		SpawnPrefab("icebox").Transform:SetPosition(x1+1.5,y,z1-4.5)
		SpawnPrefab("tent").Transform:SetPosition(x1+3,y,z1+3)
		SpawnPrefab("siestahut").Transform:SetPosition(x1-3,y,z1+3)
		--生成海贼基地
		local pos2 = choose_pos()
		while pos2:Dist(pt) < 200 or pos2:Dist(pos1) < 200 do
			pos2 = choose_pos()
		end
		local x2,y2,z2 = pos2:Get()
		SpawnPrefab("firepit").Transform:SetPosition(x2+1.5,y,z2)
		SpawnPrefab("coldfirepit").Transform:SetPosition(x2-1.5,y,z2)
		SpawnPrefab("cookpot").Transform:SetPosition(x2,y,z2-3)
		SpawnPrefab("cookpot").Transform:SetPosition(x2+3,y,z2-3)
		SpawnPrefab("cookpot").Transform:SetPosition(x2,y,z2-6)
		SpawnPrefab("cookpot").Transform:SetPosition(x2+3,y,z2-6)
		SpawnPrefab("icebox").Transform:SetPosition(x2+1.5,y,z2-4.5)
		SpawnPrefab("tent").Transform:SetPosition(x2+3,y,z2+3)
		SpawnPrefab("siestahut").Transform:SetPosition(x2-3,y,z2+3)
		
		self.inst.hasProduceBase = true
	end
end

function PKC_BASE:OnSave()
	return
	{
		hasProduceBase = self.inst.hasProduceBase,
	}
end

function PKC_BASE:OnLoad(data)
	if data ~= nil then
		if data.hasProduceBase ~= nil then
			self.inst.hasProduceBase = data.hasProduceBase
		end
	end
end

return PKC_BASE