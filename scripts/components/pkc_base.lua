--
-- 基地生成组件
-- Author: 大猪猪，RedPig
-- Date: 2016/10/23
--

local PKC_BASE = Class(function(self, inst)
	self.inst = inst
end)

--是否为安全位置
local function isSavePos(pos)
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 18)
	for _, obj in ipairs(ents) do
		if obj and (obj:HasTag("blocker") or obj.prefab == "mermhouse")
				and obj:GetPosition():Dist(pos) <= 8 then
			return false
		end
		if obj and (obj:HasTag("beehive")
				or obj:HasTag("lava")) then
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
local function produceSingleUtil(prefname, pos, offset)
	local prefab = SpawnPrefab(prefname)
	if prefab then
		prefab.Transform:SetPosition((pos + offset):Get())
	end
	--SpawnPrefab(prefname).Transform:SetPosition((pos + offset):Get())
	return prefab
end

--位置是否合格
local function isValidBasePos(pos, previousPos, minDistance)
	for _, v in pairs(previousPos) do
		if v and pos:Dist(v) < minDistance then
			return false -- 只要有一个小于允许的最小距离,那么继续选位置
		end
	end
	if not isSavePos(pos) then -- 不是安全的位置
		return false
	end
	return true
end

--相同的构造部分
local function commonBuild(previousPos)
	local centers = {}
	local ground = TheWorld
	for _, node in ipairs(ground.topology.nodes) do
		if ground.Map:IsPassableAtPoint(node.x, 0, node.y) then
			if node.tags ~= nil
					and (table.contains(node.tags, "not_mainland")
					or table.contains(node.tags, "lunacyarea")) then
				-- do nothing 基地不要生成在岛屿
			else
				table.insert(centers, {x = node.x, z = node.y})
			end
		end
	end
	local pos = nil
	local tryMakeBaseTimes = 0
	if #centers > 0 then
		pos = choosePos(centers)
		local size, _ = TheWorld.Map:GetSize()
		size = math.abs(size)
		local minDistance = GROUP_NUM > 2 and size * 0.6 or size * 0.8
		while not isValidBasePos(pos, previousPos, minDistance) do
			pos = choosePos(centers)
			tryMakeBaseTimes = tryMakeBaseTimes + 1
		end
	end
	print("pkc_tryMakeBaseTimes:"..tryMakeBaseTimes)
	return pos
end

--清理猪王附近的东西
local function clearPigkingNear(pigking)
	if pigking and pigking.Transform then
		local x, y, z = pigking.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 8)
		for _, obj in ipairs(ents) do
			if obj and obj ~= pigking and not obj:HasTag("burnt") then
				obj:Remove()
			end
		end
	end
end

--生成单个基地
local function produceSingleBase(previousPos, groupId)
	local pos = commonBuild(previousPos)
	local pigking = nil
	local pighousePrefab = nil
	local eyetuuretPrefab = nil
	local homesignPrefab = nil
	local chestPrefab = nil
	if groupId == GROUP_BIGPIG_ID then
		pigking = produceSingleUtil("pkc_bigpig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_big"
		eyetuuretPrefab = "pkc_eyeturret_big"
		homesignPrefab = "pkc_homesign_big"
		chestPrefab = "pkc_largechest_big"
	elseif groupId == GROUP_REDPIG_ID then
		pigking = produceSingleUtil("pkc_redpig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_red"
		eyetuuretPrefab = "pkc_eyeturret_red"
		homesignPrefab = "pkc_homesign_red"
		chestPrefab = "pkc_largechest_red"
	elseif groupId == GROUP_LONGPIG_ID then
		pigking = produceSingleUtil("pkc_longpig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_long"
		eyetuuretPrefab = "pkc_eyeturret_long"
		homesignPrefab = "pkc_homesign_long"
		chestPrefab = "pkc_largechest_long"
	elseif groupId == GROUP_CUIPIG_ID then
		pigking = produceSingleUtil("pkc_cuipig", pos, Vector3(-3, 0, -3))
		pighousePrefab = "pkc_pighouse_cui"
		eyetuuretPrefab = "pkc_eyeturret_cui"
		homesignPrefab = "pkc_homesign_cui"
		chestPrefab = "pkc_largechest_cui"
	end
	
	--清理
	clearPigkingNear(pigking)
	
	--安置建筑
	pkc_roundSpawn(pigking, pighousePrefab, 12, PKC_PIGHOUSE_NUM, true) --猪人房
	pkc_roundSpawn(pigking, eyetuuretPrefab, 5, PKC_EYETURRET_NUM, false) --眼球塔
	--pkc_roundSpawnForWriteable(pigking, homesignPrefab, 9, 1, PKC_SPEECH.GROUP_SIGN.SPEECH26, true) --传送牌
	pkc_roundSpawnForMulti(pigking, {homesignPrefab, chestPrefab}, 8, PKC_SPEECH.GROUP_SIGN.SPEECH26, true)
	return pos
end

--生成基地并保存基地的位置	
function PKC_BASE:produceBase(group_num) -- 参数是基地的个数
	if not self.inst.hasProduceBase then
		local pt = self.inst:GetPosition()
		local pos1 = produceSingleBase({pt}, GROUP_BIGPIG_ID)	-- 产生基地,且和已经存在的位置做距离的比较
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