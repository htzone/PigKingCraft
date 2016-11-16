--@name pkc_base
--@description 生成基地组件
--@auther redpig
--@date 2016-10-23

local PKC_BASE = Class(function(self, inst)
	self.inst = inst
end)

--随机地点中心
local function choosePos()
	local ground = TheWorld
	local centers = {}
	for _, node in ipairs(ground.topology.nodes) do
		if ground.Map:IsPassableAtPoint(node.x, 0, node.y) then
			table.insert(centers, {x = node.x, z = node.y})
		end
	end
	if #centers > 0 then
		local pos = centers[math.random(#centers)]
		return Point(pos.x, 0, pos.z)
	end
end

--构造地毯
local function rebuildTile(tile, pt, offset)
	local map = TheWorld.Map
    local original_tile_type = map:GetTileAtPoint((pt + offset):Get())
    local x, y = map:GetTileCoordsAtPoint((pt + offset):Get())
    if x and y then
        map:SetTile(x,y, tile)
        map:RebuildLayer(original_tile_type, x, y )
        map:RebuildLayer(tile, x, y )
    end
    local minimap = TheWorld.minimap.MiniMap
    minimap:RebuildLayer(original_tile_type, x, y)
    minimap:RebuildLayer(tile, x, y)
end

--生成单个设施 
--@大猪猪 10-31
local function produceSingleUtil(prefname, pos, offset)
	SpawnPrefab(prefname).Transform:SetPosition((pos + offset):Get())
end

--位置是否合格
--@大猪猪 10-31
local function isValidBasePos(pos, previousPos)
	for _, v in pairs(previousPos) do
		if v and pos:Dist(v) < GROUP_DISTANCE then
			return false	--只要有一个小于允许的最小距离,那么继续选位置
		end
	end
	return true
end

--相同的构造部分
local function commenBuild(previousPos)
	local pos = choosePos()
	while not isValidBasePos(pos, previousPos) do
		pos = choosePos()
	end
	--produceSingleUtil("firepit", pos, Vector3(1.5,0,0))
	--rebuildTile(GROUND.CARPET, pos, Vector3(-3, 0, -3))
	--rebuildTile(GROUND.CARPET, pos, Vector3(0, 0, 0))
	--rebuildTile(GROUND.CARPET, pos, Vector3(-3, 0, 0))
	--rebuildTile(GROUND.CARPET, pos, Vector3(0, 0, -3))
	--rebuildTile(GROUND.CARPET, pos, Vector3(1, 0, 0))
	--rebuildTile(GROUND.CARPET, pos, Vector3(-3, 0, 3))
	--rebuildTile(GROUND.CARPET, pos, Vector3(2, 0, 2))
	--produceSingleUtil("coldfirepit", pos, Vector3(-1.5,0,0))
	--produceSingleUtil("cookpot",pos,Vector3(0,0,-3))
	--produceSingleUtil("cookpot",pos,Vector3(3,0,-3))
	--produceSingleUtil("cookpot",pos,Vector3(0,0,-6))
	--produceSingleUtil("cookpot",pos,Vector3(3,0,-6))
	--produceSingleUtil("icebox",pos,Vector3(1.5,0,-4.5))
	--produceSingleUtil("tent",pos,Vector3(3,0,3))
	--produceSingleUtil("siestahut",pos,Vector3(-3,0,3))
	return pos
end

--生成单个基地
--@大猪猪 10-31
local function produceSingleBase(previousPos, groupId)
	local pos = commenBuild(previousPos)
	if groupId == GROUP_BIGPIG_ID then
		produceSingleUtil("pkc_bigpig", pos, Vector3(-3, 0, -3))
	elseif groupId == GROUP_REDPIG_ID then
		produceSingleUtil("pkc_redpig", pos, Vector3(-3, 0, -3))
	elseif groupId == GROUP_LONGPIG_ID then
		produceSingleUtil("pkc_longpig", pos, Vector3(-3, 0, -3))
	elseif groupId == GROUP_CUIPIG_ID then
		produceSingleUtil("pkc_cuipig", pos, Vector3(-3, 0, -3))
	end
	return pos
end

--生成基地并保存基地的位置	
--@大猪猪 10-31
function PKC_BASE:produceBase(group_num)	--参数是基地的个数
	if not self.inst.hasProduceBase then
		local pt = self.inst:GetPosition()
		local pos1 = produceSingleBase({pt}, GROUP_BIGPIG_ID)	--产生基地,且和已经存在的位置做距离的比较
		TheWorld.components.pkc_baseinfo:SetBasePos("BIG", pos1)
		
		local pos2 = produceSingleBase({pt,pos1}, GROUP_REDPIG_ID)
		TheWorld.components.pkc_baseinfo:SetBasePos("RED", pos2)
		
		local pos3
		if group_num >= 3 then
			pos3=produceSingleBase({pt,pos1,pos2}, GROUP_LONGPIG_ID)
			TheWorld.components.pkc_baseinfo:SetBasePos("LONG", pos3)
		end
		local pos4
		if group_num >= 4 then
			pos4=produceSingleBase({pt,pos1,pos2,pos3}, GROUP_CUIPIG_ID)
			TheWorld.components.pkc_baseinfo:SetBasePos("CUI", pos4)
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