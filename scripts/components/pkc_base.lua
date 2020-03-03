--@name pkc_base
--@description 生成基地组件
--@author redpig
--@date 2016-10-23

local PKC_BASE = Class(function(self, inst)
	self.inst = inst
end)

--是否为安全位置
local function isSavePos(pos)
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 20)
	for _, obj in ipairs(ents) do
		if obj and (obj:HasTag("blocker") or obj.prefab == "mermhouse") and obj:GetPosition():Dist(pos) <= 8 then
			return false
		end
		if obj and (obj:HasTag("houndmound") or obj:HasTag("beehive") or obj:HasTag("tallbird") or obj:HasTag("lava") or obj:HasTag("spiderden")) then
			return false
		end
	end
	return true
end

--随机地点中心
local function choosePos(centers)
	local pos = centers[math.random(#centers)]
	return Point(pos.x, 0, pos.z)
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
	local centers = {}
	local ground = TheWorld
	for _, node in ipairs(ground.topology.nodes) do
		if ground.Map:IsPassableAtPoint(node.x, 0, node.y) then
			if node.tags ~= nil and table.contains( node.tags, "lunacyarea" ) then
			
			else
				table.insert(centers, {x = node.x, z = node.y})
			end
		end
	end
	local pos = nil
	if #centers > 0 then
		pos = choosePos(centers)
		while not isValidBasePos(pos, previousPos) do
			pos = choosePos(centers)
		end
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
	local pighousePrefab = nil
	local pighouse = nil
	local eyetuuretPrefab = nil
	local eyetuuret = nil
	local homesignPrefab = nil
	if groupId == GROUP_BIGPIG_ID then
		pigking = produceSingleUtil("pkc_bigpig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_big"
		eyetuuretPrefab = "pkc_eyeturret_big"
		homesignPrefab = "pkc_homesign_big"
	elseif groupId == GROUP_REDPIG_ID then
		pigking = produceSingleUtil("pkc_redpig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_red"
		eyetuuretPrefab = "pkc_eyeturret_red"
		homesignPrefab = "pkc_homesign_red"
	elseif groupId == GROUP_LONGPIG_ID then
		pigking = produceSingleUtil("pkc_longpig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_long"
		eyetuuretPrefab = "pkc_eyeturret_long"
		homesignPrefab = "pkc_homesign_long"
	elseif groupId == GROUP_CUIPIG_ID then
		pigking = produceSingleUtil("pkc_cuipig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_cui"
		eyetuuretPrefab = "pkc_eyeturret_cui"
		homesignPrefab = "pkc_homesign_cui"
	end
	
	--清理
	clearPigkingNear(pigking)
	
	--安置建筑
	pkc_roundSpawn(pigking, pighousePrefab, 10, PKC_PIGHOUSE_NUM) --猪人房
	pkc_roundSpawn(pigking, eyetuuretPrefab, 5, PKC_EYETURRET_NUM) --眼球塔
	pkc_roundSpawn(pigking, homesignPrefab, 7, 1) --传送牌
	
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