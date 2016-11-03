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

--生成单个设施 
--@大猪猪 10-31
local function produceSingleUtil(prefname,pos,offset)
	SpawnPrefab(prefname).Transform:SetPosition( (pos+offset):Get() )
end

--位置是否合格
--@大猪猪 10-31
local function isValidBasePos(pos,previousPos)
	for k,v in pairs(previousPos) do
		if v and pos:Dist(v) < GROUP_DISTANCE then
			return true	--只要有一个小于允许的最小距离,那么继续选位置
		end
	end
	return false
end

--生成单个基地
--@大猪猪 10-31
local function produceSingleBase(previousPos)
	local pos=choose_pos()
	while isValidBasePos(pos,previousPos) do
		pos = choose_pos()
	end
	produceSingleUtil("firepit",pos,Vector3(1.5,0,0))
	produceSingleUtil("coldfirepit",pos,Vector3(-1.5,0,0))
	produceSingleUtil("cookpot",pos,Vector3(0,0,-3))
	produceSingleUtil("cookpot",pos,Vector3(3,0,-3))
	produceSingleUtil("cookpot",pos,Vector3(0,0,-6))
	produceSingleUtil("cookpot",pos,Vector3(3,0,-6))
	produceSingleUtil("icebox",pos,Vector3(1.5,0,-4.5))
	produceSingleUtil("tent",pos,Vector3(3,0,3))
	produceSingleUtil("siestahut",pos,Vector3(-3,0,3))
	return pos
end

--生成基地并保存基地的位置	
--@大猪猪 10-31
function PKC_BASE:ProduceBase(group_num)	--参数是基地的个数
	if not self.inst.hasProduceBase then
		local pt = self.inst:GetPosition()
		local pos1=produceSingleBase({pt})	--产生基地,且和已经存在的位置做距离的比较
		TheWorld.components.pkc_baseinfo:SetBasePos("BIG",pos1)
		
		local pos2=produceSingleBase({pt,pos1})
		TheWorld.components.pkc_baseinfo:SetBasePos("RED",pos2)
		
		local pos3
		if group_num>=3 then
			pos3=produceSingleBase({pt,pos1,pos2})
			TheWorld.components.pkc_baseinfo:SetBasePos("LONG",pos3)
		end
		local pos4
		if group_num>=4 then
			pos4=produceSingleBase({pt,pos1,pos2,pos3})
			TheWorld.components.pkc_baseinfo:SetBasePos("CUI",pos4)
		end
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