--@name pkc_base
--@description 生成基地组件
--@auther redpig
--@date 2016-10-23

local PKC_BASE = Class(function(self, inst)
	self.inst = inst
end)

--是否为安全位置
local function isSavePos(pos)
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 15)
	for _, obj in ipairs(ents) do
		 if obj and (obj:HasTag("houndmound") or obj:HasTag("beehive") or obj:HasTag("tallbird") or obj:HasTag("lava") or obj:HasTag("blocker")) then
			return false
		end
	end
	return true
end

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

--构造地皮
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
	local prefab = SpawnPrefab(prefname)
	if prefab then
		prefab.Transform:SetPosition((pos + offset):Get())
	end
	--SpawnPrefab(prefname).Transform:SetPosition((pos + offset):Get())
	return prefab
end

--位置是否合格
--@大猪猪 10-31
local function isValidBasePos(pos, previousPos)
	for _, v in pairs(previousPos) do
		if v and pos:Dist(v) < GROUP_DISTANCE then
			return false	--只要有一个小于允许的最小距离,那么继续选位置
		end
	end
	if not isSavePos(pos) then --不是安全的位置
		return false
	end
	return true
end

--相同的构造部分
local function commenBuild(previousPos)
	local pos = choosePos()
	while not isValidBasePos(pos, previousPos) do
		pos = choosePos()
	end
	return pos
end

--清理猪王附近的东西
local function clearPigkingNear(pigking)
	if pigking and pigking.Transform then
		local x, y, z = pigking.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 4)
		for _, obj in ipairs(ents) do
			if obj and obj ~= pigking and not obj:HasTag("burnt") then
				obj:Remove()
			end
		end
	end
end

--生成单个基地
--@大猪猪 10-31
local function produceSingleBase(previousPos, groupId)
	local pos = commenBuild(previousPos)
	local pigking = nil
	if groupId == GROUP_BIGPIG_ID then
		pigking = produceSingleUtil("pkc_bigpig", pos, Vector3(-3, 0, -3))
	elseif groupId == GROUP_REDPIG_ID then
		pigking = produceSingleUtil("pkc_redpig", pos, Vector3(-3, 0, -3))
	elseif groupId == GROUP_LONGPIG_ID then
		pigking = produceSingleUtil("pkc_longpig", pos, Vector3(-3, 0, -3))
	elseif groupId == GROUP_CUIPIG_ID then
		pigking = produceSingleUtil("pkc_cuipig", pos, Vector3(-3, 0, -3))
	end
	clearPigkingNear(pigking)
	for i=1, 4 do
		pkc_trySpawn(pigking, "pighouse", 5, 12, 30) --生成周围的猪人房
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