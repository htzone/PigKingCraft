--@name pkc_rulesinit
--@description PVP规则约束
--@auther redpig
--@date 2016-11-05

--根据id获取各队伍的猪王保护半径, 暂时这样，哎呀，真TM懒 _(:3 」∠)_
--TODO 应该把各猪王的等级信息放在一个全局变量中的
local function getPigkingRange(pigkingId)
	local needLevelUpScore = GLOBAL.WIN_SCORE / 10
	if pigkingId ==  GLOBAL.GROUP_BIGPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP1_SCORE
		local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
		if GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel] then
			return GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
		end
	elseif pigkingId ==  GLOBAL.GROUP_REDPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP2_SCORE
		local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
		if GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel] then
			return GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
		end
	elseif pigkingId ==  GLOBAL.GROUP_LONGPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP3_SCORE
		local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
		if GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel] then
			return GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
		end
	elseif pigkingId ==  GLOBAL.GROUP_CUIPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP4_SCORE
		local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
		if GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel] then
			return GLOBAL.PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
		end
	end
	return nil
end

--移除燃烧属性
local function removeBurnable(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst 
		and inst:HasTag("structure") 
		and inst.components.burnable
		then
			if inst:HasTag("canlight") then
				inst:RemoveTag("canlight")
			end	
			inst:AddTag("nolight")
			inst:AddTag("fireimmune")
		end
	end
end

--设置所有建筑不可烧
for _, recipes in pairs(GLOBAL.AllRecipes) do
	AddPrefabPostInit(recipes.name, removeBurnable)
end

--新加入的建筑放这里
local newStructureTable = {
"pkc_pighouse_big",
"pkc_pighouse_red",
"pkc_pighouse_long",
"pkc_pighouse_cui",
}
for _, name in pairs(newStructureTable) do
	AddPrefabPostInit(name, removeBurnable)
end

--设置游戏火焰蔓延半径
local CurrentMakeSmallPropagator = GLOBAL.MakeSmallPropagator
GLOBAL.MakeSmallPropagator = function(inst)
	CurrentMakeSmallPropagator(inst)
	if inst.components.propagator then
		inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
	end
end
local CurrentMakeMediumPropagator = GLOBAL.MakeMediumPropagator
GLOBAL.MakeMediumPropagator = function(inst)
	CurrentMakeMediumPropagator(inst)
	if inst.components.propagator then
		inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
	end
end
local MakeLargePropagator = GLOBAL.MakeLargePropagator
GLOBAL.MakeLargePropagator = function(inst)
	MakeLargePropagator(inst)
	if inst.components.propagator then
		inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
	end
end

--当有敌人在附近下线会掉落身上所有物品(客机才有效)
if GLOBAL.LEVAE_DROP_EVERYTHING then
	AddComponentPostInit("playerspawner", function(PlayerSpawner, inst)
		inst:ListenForEvent("ms_playerdespawn", function (inst, player)
			local x, y, z = player.Transform:GetWorldPosition()
			local ents = GLOBAL.TheSim:FindEntities(x, y, z, 30)
			local hasOtherGroupMobNear = false
			for _, v in ipairs(ents) do
				--if v:HasTag("player") 
				if v ~= player and v:IsValid() 
				and v.components.health and not v.components.health:IsDead()
				and v.components.pkc_group and v.components.pkc_group:getChooseGroup() ~= player.components.pkc_group:getChooseGroup()
				then
					hasOtherGroupMobNear = true
					break
				end
			end
			if hasOtherGroupMobNear and player and player.components.inventory then
				player.components.inventory:DropEverything(false, false)
			end
		end)
	end)
end

--死亡不减血量上限
AddComponentPostInit("health", function(self, inst)
    self.oldDeltaPenalty = self.DeltaPenalty
	if GLOBAL.TheWorld.ismastersim then
		function self:DeltaPenalty(delta)
			return self:oldDeltaPenalty(0)
		end
	end
end)

--设置游戏中不存在的物品
local cantExistPrefabs = {
"pigking", --猪王
"mandrake_planted", --曼德拉
"panflute", --排箫
}
local function removePrefab(inst)
	inst:DoTaskInTime(0.8, function()
		if inst then
			inst:Remove()
		end	
	end)
end
for _, prefab_name in pairs(cantExistPrefabs) do
	AddPrefabPostInit(prefab_name, removePrefab)
end

--建造物品，为每个建造的新物品添加Tag
local function OnBuildNew(doer, prod) 
	if prod and (not prod.components.inventoryitem or prod.components.container) then --仓库物品除了背包以外都不需要加Tag
		if doer and doer.components.pkc_group then
			prod.saveTags = {}
			prod:AddTag("pkc_group"..doer.components.pkc_group:getChooseGroup())
			prod.saveTags["pkc_group"..doer.components.pkc_group:getChooseGroup()] = 1
			prod.pkc_group_id = doer.components.pkc_group:getChooseGroup()
		end
	end
    if doer.components.builder.old_onBuild then
        doer.components.builder.old_onBuild(doer, prod)
    end
end

AddPlayerPostInit(function(inst) 
    if GLOBAL.TheWorld.ismastersim then 
        if inst.components.builder then
            if inst.components.builder.onBuild then
                inst.components.builder.old_onBuild = inst.components.builder.onBuild
            end
            inst.components.builder.onBuild = OnBuildNew
        end
    end
end)

--不能在猪王附近建墙
local function ifBuildWallNearPigking(act)
	local ents = GLOBAL.TheSim:FindEntities(act.pos.x, act.pos.y, act.pos.z, 8, {"king", "eyeturret"})
	local hasPigKingNear = false
	for _, obj in pairs(ents) do
		if obj then
			hasPigKingNear = true
			break
		end
	end
	return hasPigKingNear
end

--安置物品，为每个安置的新物品添加Tag
local old_DEPLOY = GLOBAL.ACTIONS.DEPLOY.fn 
GLOBAL.ACTIONS.DEPLOY.fn = function(act)
    if GLOBAL.TheWorld.ismastersim then 
		local x = act.pos.x
		local y = act.pos.y
		local z = act.pos.z
		--判断安置的是否为墙
		if act and act.invobject and string.find(act.invobject.prefab, "wall_") then 	
			if ifBuildWallNearPigking(act) then
				act.doer:DoTaskInTime(0, function ()	
					if act.doer and act.doer.components.talker then
						act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH5)
					end
				end)
				return false
			end
		end
		--为安置物添加标记
		if act.doer and act.doer.components.pkc_group then
			local ents = GLOBAL.TheSim:FindEntities(x, y, z, 0)
			for _, obj in pairs(ents) do
				obj.saveTags = {}
				obj:AddTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup())
				obj.saveTags["pkc_group"..act.doer.components.pkc_group:getChooseGroup()] = 1
				obj.pkc_group_id = act.doer.components.pkc_group:getChooseGroup()
			end
		end
		return old_DEPLOY(act)
	end	
end

--保存
local function OnSave(inst, data)
	if inst.OldOnSave ~= nil then
		inst.OldOnSave(inst, data)
	end
	if inst.saveTags ~= nil and GLOBAL.next(inst.saveTags) ~= nil then
		data.saveTags = inst.saveTags
	end
	if inst.pkc_group_id ~= nil then
		data.pkc_group_id = inst.pkc_group_id
	end
end

--加载
local function OnLoad(inst, data)
	if inst.OldOnLoad ~= nil then
		inst.OldOnLoad(inst, data)
	end
	if data ~= nil then 
		if data.saveTags ~= nil and GLOBAL.next(data.saveTags) ~= nil then
			inst.saveTags = data.saveTags
			for tag, v in pairs(inst.saveTags) do
				if v then
					inst:AddTag(tag)
				end
			end
		end
		if data.pkc_group_id ~= nil then
			inst.pkc_group_id = data.pkc_group_id
		end
	end 
end

for _, v in pairs(GLOBAL.AllRecipes) do
	AddPrefabPostInit(v.name, function(inst)
		inst.OldOnSave = inst.OnSave
		inst.OnSave = OnSave
		inst.OldOnLoad = inst.OnLoad
		inst.OnLoad = OnLoad
	end)
end

--猪王附近建筑受保护
local old_HAMMER = GLOBAL.ACTIONS.HAMMER.fn
GLOBAL.ACTIONS.HAMMER.fn = function(act)
	if act.target == nil or act.doer == nil then
		return old_HAMMER(act)
	end
	
	--本队的人无限制
	--[[
	if (act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id) 
	--or act.target.prefab == "pighouse" or act.target.prefab == "rabbithouse"
	then
		return old_HAMMER(act)
	end
	]]--
	--物品无队伍标记可砸
	if act.target.pkc_group_id == nil then
		return old_HAMMER(act)
	end
	--猪王附近建筑被保护
	if not act.doer.components.pkc_group then
		return old_HAMMER(act)
	else
		local x, y, z = act.target.Transform:GetWorldPosition()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
		local hasEnemyPigKingNear = false
		for _,obj in pairs(ents) do
			--if obj and obj:HasTag("king") and obj.components.pkc_group and obj.components.pkc_group:getChooseGroup() ~= act.doer.components.pkc_group:getChooseGroup() then
			if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup()) then
				if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > act.target:GetPosition():Dist(obj:GetPosition()) then
					hasEnemyPigKingNear = true
					break
				end
			end
		end	
		if not hasEnemyPigKingNear then
			return old_HAMMER(act)
		else
			--和平时期在地方猪王附近砸的不是自己的猪人房
			if string.find(act.target.prefab, "pkc_pighouse")  and act.doer.components.pkc_group:getChooseGroup() ~= act.target.pkc_group_id then
				if (GLOBAL.TheWorld.state.cycles + 2) <=  GLOBAL.PEACE_TIME then --和平时期不能砸
					act.doer:DoTaskInTime(0, function ()	
						if act.doer and act.doer.components.talker then
							act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH3)
						end
					end)
					return false
				else
					return old_HAMMER(act)
				end
			end
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
				end
            end)
		end
	end
end

--猪王附近农作物防挖
local old_DIG = GLOBAL.ACTIONS.DIG.fn 
GLOBAL.ACTIONS.DIG.fn = function(act)
	if act.target == nil or act.doer == nil then
		return old_DIG(act)
	end
	--本队的人无限制
	if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_DIG(act)
	end
	--物品无队伍标记
	if act.target.pkc_group_id == nil then
		return old_DIG(act)
	end
	--猪王附近受保护
	if not act.doer.components.pkc_group then
		return old_DIG(act)
	else
		local x, y, z = act.target.Transform:GetWorldPosition()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
		local hasEnemyPigKingNear = false
		for _,obj in pairs(ents) do
			if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup()) then
				if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > act.target:GetPosition():Dist(obj:GetPosition()) then
					hasEnemyPigKingNear = true
					break
				end
			end
		end	
		if not hasEnemyPigKingNear then
			return old_DIG(act)
		else
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
				end
            end)
		end
	end
end

--猪王附近物品防烧
local old_LIGHT = GLOBAL.ACTIONS.LIGHT.fn 
GLOBAL.ACTIONS.LIGHT.fn = function(act)
	if act.target == nil or act.doer == nil then
		return old_LIGHT(act)
	end
	--本队的人无限制
    if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_LIGHT(act)
	end
	--物品无队伍标记
	if act.target.pkc_group_id == nil and not act.target:HasTag("tree") then --树长大后没有标记了
		return old_LIGHT(act)
	end
	--猪王附近受保护
	if not act.doer.components.pkc_group then
		return old_LIGHT(act)
	else
		local x, y, z = act.target.Transform:GetWorldPosition()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
		local hasEnemyPigKingNear = false
		for _,obj in pairs(ents) do
			if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup()) then
				if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > act.target:GetPosition():Dist(obj:GetPosition()) then
					hasEnemyPigKingNear = true
					break
				end
			end
		end	
		if not hasEnemyPigKingNear then
			return old_LIGHT(act)
		else
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
				end
            end)
		end
	end
end

--防作祟
local old_HAUNT = GLOBAL.ACTIONS.HAUNT.fn
GLOBAL.ACTIONS.HAUNT.fn = function(act)
	if act.target == nil or act.doer == nil then
		return old_HAUNT(act)
	end
    --本队的人无限制
    if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_HAUNT(act)
	end
	--物品无队伍标记
	if act.target.pkc_group_id == nil then
		return old_HAUNT(act)
	end
	--猪王附近受保护
	if not act.doer.components.pkc_group then
		return old_HAUNT(act)
	else
		local x, y, z = act.target.Transform:GetWorldPosition()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
		local hasEnemyPigKingNear = false
		for _,obj in pairs(ents) do
			if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup()) then
				if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > act.target:GetPosition():Dist(obj:GetPosition()) then
					hasEnemyPigKingNear = true
					break
				end
			end
		end	
		if not hasEnemyPigKingNear then
			return old_HAUNT(act)
		else
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
				end
            end)
		end
	end
end

--防睡帐篷
AddStategraphPostInit("wilson", function(sg)
	if GLOBAL.TheWorld.ismastersim then
		local oldFn = sg.states["tent"].onenter
		sg.states["tent"].onenter = function(inst)
			local target = inst:GetBufferedAction().target
			--本队的人无限制
			if inst.components.pkc_group and target.pkc_group_id 
			and inst.components.pkc_group:getChooseGroup() == target.pkc_group_id
			then
				return oldFn(inst)
			end
			--物品无队伍标记
			if target.pkc_group_id == nil then
				return oldFn(inst)
			end
			--猪王附近受保护
			if not inst.components.pkc_group then
				return oldFn(inst)
			else
				local x, y, z = target.Transform:GetWorldPosition()
				local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
				local hasEnemyPigKingNear = false
				for _,obj in pairs(ents) do
					if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..inst.components.pkc_group:getChooseGroup()) then
						if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > target:GetPosition():Dist(obj:GetPosition()) then
							hasEnemyPigKingNear = true
							break
						end
					end
				end	
				if not hasEnemyPigKingNear then
					return oldFn(inst)
				else
					inst:DoTaskInTime(0, function ()	
						if inst then
							inst:PushEvent("performaction", { action = inst.bufferedaction })
							inst:ClearBufferedAction()
							inst.sg:GoToState("idle")
							if inst.components.talker then
								inst.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
							end
						end
					end)
					return 
				end
			end
			
		end
	end
end)
	
--防魔法
local old_CASTSPELL = GLOBAL.ACTIONS.CASTSPELL.fn
GLOBAL.ACTIONS.CASTSPELL.fn = function(act)
    --For use with magical staffs
	if GLOBAL.TheWorld.ismastersim == false then return old_CASTSPELL(act) end
    local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act.pos) then

		if act.target == nil or act.doer == nil then
			staff.components.spellcaster:CastSpell(act.target, act.pos)
			return true
		end
		
		if act.target:HasTag("king") then
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH2)
				end
			end)
			return false
		end
		
		--本队的人无限制
		if (act.doer.components.pkc_group and act.target.pkc_group_id 
		and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id)
		or act.target.prefab == "pighouse" or act.target.prefab == "rabbithouse"
		then
			staff.components.spellcaster:CastSpell(act.target, act.pos)
			return true
		end
		
		--猪王附近受保护
		if not act.doer.components.pkc_group then
			staff.components.spellcaster:CastSpell(act.target, act.pos)
			return true
		else
			local x, y, z = act.target.Transform:GetWorldPosition()
			local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
			local hasEnemyPigKingNear = false
			for _,obj in pairs(ents) do
				if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup()) then
					if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > act.target:GetPosition():Dist(obj:GetPosition()) then
						hasEnemyPigKingNear = true
						break
					end
				end
			end	
			if not hasEnemyPigKingNear then
				staff.components.spellcaster:CastSpell(act.target, act.pos)
				return true
			else
				act.doer:DoTaskInTime(0, function ()	
					if act.doer and act.doer.components.talker then
						act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
					end
				end)
				return false
			end
		end
    end
end

--敌人建筑附近不能建造
local old_BUILD = GLOBAL.ACTIONS.BUILD.fn
GLOBAL.ACTIONS.BUILD.fn = function(act)
	if act.doer == nil then
		return old_BUILD(act)
	end
	if not act.doer.components.pkc_group then
		return old_BUILD(act)
	end
	local x, y, z = act.doer.Transform:GetWorldPosition()
	local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10)
	for _, obj in ipairs(ents) do
		if obj and obj:IsValid() and obj:HasTag("structure") and obj.pkc_group_id and obj.pkc_group_id ~= act.doer.components.pkc_group:getChooseGroup() then
			act.doer:DoTaskInTime(0, function ()
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH4)
				end
			end)
			return false
		end
	end
	return old_BUILD(act)
end

--防开
AddComponentPostInit("container", function(Container, target)
    Container.OriginalOpenFn = Container.Open
    --if GLOBAL.TheWorld.ismastersim == false then return Container:OriginalOpenFn(doer) end
	if GLOBAL.TheWorld.ismastersim then
		function Container:Open(doer)
			
			if doer.components.pkc_group and target.pkc_group_id 
			and doer.components.pkc_group:getChooseGroup() == target.pkc_group_id
			then
				return Container:OriginalOpenFn(doer)
			end
			
			--物品无队伍标记可砸
			if target.pkc_group_id == nil then
				return Container:OriginalOpenFn(doer)
			end
			
			--猪王附近受保护
			if not doer.components.pkc_group then
				return Container:OriginalOpenFn(doer)
			else
				local x, y, z = target.Transform:GetWorldPosition()
				local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
				local hasEnemyPigKingNear = false
				for _,obj in pairs(ents) do
					if obj and obj:HasTag("king") and not obj:HasTag("pkc_group"..doer.components.pkc_group:getChooseGroup()) then
						if obj.pkc_group_id and getPigkingRange(obj.pkc_group_id) > target:GetPosition():Dist(obj:GetPosition()) then
							hasEnemyPigKingNear = true
							break
						end
					end
				end	
				if not hasEnemyPigKingNear then
					return Container:OriginalOpenFn(doer)
				else
					doer:DoTaskInTime(0, function ()	
						if doer and doer.components.talker then
							doer.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH1)
						end
					end)
				end
			end
		end
	end
end)

--防止火焰蔓延
AddComponentPostInit("propagator", function(self, inst)
	self.OriginalAddHeat = self.AddHeat
	if GLOBAL.TheWorld.ismastersim then
		function self:AddHeat(amount)
			if self.inst.pkc_group_id then
				return 
			else
				return self:OriginalAddHeat(amount)
			end
		end
	end
end)

--防炸
AddComponentPostInit("explosive", function(explosive, inst)
		inst.buildingdamage = 0
		explosive.CurrentOnBurnt = explosive.OnBurnt
		function explosive:OnBurnt()
			local x, y, z = inst.Transform:GetWorldPosition()
			local ents2 = GLOBAL.TheSim:FindEntities(x, y, z, 10)
			local nearbyStructure = false
			for k, v in ipairs(ents2) do
				if v.components.burnable ~= nil and not v.components.burnable:IsBurning() then
					if v.pkc_group_id then
						nearbyStructure = true
						break
					end
				end
			end
			if nearbyStructure then 
				inst:RemoveTag("canlight")
			else
				inst:AddTag("canlight")
				explosive:CurrentOnBurnt()
			end
		end
end)

--攻击限制(限制无伤害)
local old_ATTACK = GLOBAL.ACTIONS.ATTACK.fn 
GLOBAL.ACTIONS.ATTACK.fn = function(act)
	if act.target == nil or act.doer == nil then
		return old_ATTACK(act)
	end
	--没有加入阵营的不限制
	if not act.doer.components.pkc_group or not act.target.components.pkc_group then
		return old_ATTACK(act)
	end
	
	--同组队友之间不能伤害
	if act.doer.components.pkc_group and act.target.components.pkc_group and act.target.components.pkc_group:getChooseGroup() ~= 0 then
		
		if act.doer.components.pkc_group:getChooseGroup() == act.target.components.pkc_group:getChooseGroup() then
			return false
		end
		if act.target:HasTag("pig") and act.target.components.follower and act.target.components.follower.leader ~= nil then
			return old_ATTACK(act)
		end
		--和平时期
		if (GLOBAL.TheWorld.state.cycles + 2) <=  GLOBAL.PEACE_TIME then 
			return false
		end
	end
	return old_ATTACK(act)
end

--------简单的垃圾清理功能，提升服务器性能-------
--仓库物品的掉落和捡起添加Tag
AddComponentPostInit("inventoryitem", function(self, inst)
	self.OriginalOnDropped = self.OnDropped
	self.OriginalOnPickup = self.OnPickup
	function self:OnDropped(randomdir)
		if inst then
			inst:AddTag("pkc_dropitem")
			inst.droptime = GLOBAL.os.time()
		end
		return self:OriginalOnDropped(randomdir)
	end
	function self:OnPickup(pickupguy)
		if inst and inst:HasTag("pkc_dropitem") then
			inst:RemoveTag("pkc_dropitem")
			inst.droptime = nil
		end
		return self:OriginalOnPickup(pickupguy)
	end
end)

--物品掉落添加Tag
AddComponentPostInit("lootdropper", function(self, inst)
	self.OriginalFlingItem = self.FlingItem
	function self:FlingItem(loot, pt, bouncedcb)
		if loot ~= nil then
			loot:AddTag("pkc_dropitem")
			loot.droptime = GLOBAL.os.time()
		end
		return self:OriginalFlingItem(loot, pt, bouncedcb)
	end
end)	

--执行清理
local function updateWorld(inst)
	
	if (GLOBAL.TheWorld.state.cycles + 2) <  GLOBAL.PEACE_TIME and (GLOBAL.TheWorld.state.cycles + 2) >= 0 then
		inst:DoTaskInTime(1, function()
			GLOBAL.pkc_makeAllPlayersSpeak(GLOBAL.PKC_SPEECH.PEACE_TIME_TIPS.SPEECH2..((GLOBAL.PEACE_TIME + 1) - (GLOBAL.TheWorld.state.cycles + 2))..GLOBAL.PKC_SPEECH.PEACE_TIME_TIPS.SPEECH3)
		end)
	end
	
	if (GLOBAL.TheWorld.state.cycles + 2) ==  GLOBAL.PEACE_TIME then --和平时期结束
		inst:DoTaskInTime(1, function()
			GLOBAL.SpawnPrefab("lightning")
			GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.PEACE_TIME_TIPS.SPEECH1)
			GLOBAL.pkc_makeAllPlayersSpeak(GLOBAL.PKC_SPEECH.PEACE_TIME_TIPS.SPEECH4)
		end)
	end
	
	if GLOBAL.TheWorld.state.cycles ~= 0 and (GLOBAL.TheWorld.state.cycles + 2) % GLOBAL.WORLD_DELETE_INTERVAL == 0 then
		inst:DoTaskInTime(12, function()
			GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.AUTO_CLEAR.SPEECH1..(GLOBAL.WORLD_DELETE_TIME+1)..GLOBAL.PKC_SPEECH.AUTO_CLEAR.SPEECH2)
		end)
		inst:DoTaskInTime(42, function()
			GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.CLEANING)
			if inst then
				for _, v in pairs(GLOBAL.Ents) do
					if v and v:HasTag("pkc_dropitem") and v.components.inventoryitem and not v.components.container and v.prefab ~= "chester_eyebone" then 
						if not v:HasTag("burnt") and not v.components.inventoryitem:IsHeld() and v.droptime ~= nil then
							if GLOBAL.os.time() - v.droptime > (GLOBAL.WORLD_DELETE_TIME * GLOBAL.TUNING.TOTAL_DAY_TIME) then
								v:Remove()
							end
						end 
					end 
				end 
			end
		end)
	end
end 

--监听天数变换
AddPrefabPostInit("world", function(inst)
	if inst.ismastersim then
		inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(inst) end)
	end 		
end)

local function buildPigHouse(self, recname, pt, rotation, skin)
	local recipe = GLOBAL.GetValidRecipe(recname)
    if recipe ~= nil and (self:IsBuildBuffered(recname) or self:CanBuild(recname)) then
        if recipe.placer ~= nil and
            self.inst.components.rider ~= nil and
            self.inst.components.rider:IsRiding() then
            return false, "MOUNTED"
        elseif recipe.level.ORPHANAGE > 0 and (
                self.inst.components.petleash == nil or
                self.inst.components.petleash:IsFull() or
                self.inst.components.petleash:HasPetWithTag("critter")
            ) then
            return false, "HASPET"
        end

        local wetlevel = self.buffered_builds[recname]
        if wetlevel ~= nil then
            self.buffered_builds[recname] = nil
            self.inst.replica.builder:SetIsBuildBuffered(recname, false)
        else
            local materials = self:GetIngredients(recname)
            wetlevel = self:GetIngredientWetness(materials)
            self:RemoveIngredients(materials, recname)
        end
        self.inst:PushEvent("refreshcrafting")
		local prod = nil
		if recname == "pighouse" then
			if self.inst.components.pkc_group then
				if self.inst.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_BIGPIG_ID then
					prod = GLOBAL.SpawnPrefab("pkc_pighouse_big", skin, nil, self.inst.userid)
				elseif self.inst.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_REDPIG_ID then
					prod = GLOBAL.SpawnPrefab("pkc_pighouse_red", skin, nil, self.inst.userid)
				elseif self.inst.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_LONGPIG_ID then
					prod = GLOBAL.SpawnPrefab("pkc_pighouse_long", skin, nil, self.inst.userid)
				elseif self.inst.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_CUIPIG_ID then
					prod = GLOBAL.SpawnPrefab("pkc_pighouse_cui", skin, nil, self.inst.userid)
				end
			end
		else
			prod = GLOBAL.SpawnPrefab(recipe.product, skin, nil, self.inst.userid)
		end
        --local prod = SpawnPrefab(recipe.product, skin, nil, self.inst.userid)
        if prod ~= nil then
            
            pt = pt or self.inst:GetPosition()

            if wetlevel > 0 and prod.components.inventoryitem ~= nil then
                prod.components.inventoryitem:InheritMoisture(wetlevel, self.inst:GetIsWet())
            end

            if prod.components.inventoryitem ~= nil then
                if self.inst.components.inventory ~= nil then
                    --self.inst.components.inventory:GiveItem(prod)
                    self.inst:PushEvent("builditem", { item = prod, recipe = recipe, skin = skin })
                    GLOBAL.ProfileStatsAdd("build_"..prod.prefab)

                    if prod.components.equippable ~= nil and self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) == nil then
                        if recipe.numtogive <= 1 then
                            --The item is equippable. Equip it.
                            self.inst.components.inventory:Equip(prod)
                        elseif prod.components.stackable ~= nil then
                            --The item is stackable. Just increase the stack size of the original item.
                            prod.components.stackable:SetStackSize(recipe.numtogive)
                            self.inst.components.inventory:Equip(prod)
                        else
                            --We still need to equip the original product that was spawned, so do that.
                            self.inst.components.inventory:Equip(prod)
                            --Now spawn in the rest of the items and give them to the player.
                            for i = 2, recipe.numtogive do
                                local addt_prod = GLOBAL.SpawnPrefab(recipe.product)
                                self.inst.components.inventory:GiveItem(addt_prod, nil, pt)
                            end
                        end
                    elseif recipe.numtogive <= 1 then
                        --Only the original item is being received.
                        self.inst.components.inventory:GiveItem(prod, nil, pt)
                    elseif prod.components.stackable ~= nil then
                        --The item is stackable. Just increase the stack size of the original item.
                        prod.components.stackable:SetStackSize(recipe.numtogive)
                        self.inst.components.inventory:GiveItem(prod, nil, pt)
                    else
                        --We still need to give the player the original product that was spawned, so do that.
                        self.inst.components.inventory:GiveItem(prod, nil, pt)
                        --Now spawn in the rest of the items and give them to the player.
                        for i = 2, recipe.numtogive do
                            local addt_prod = GLOBAL.SpawnPrefab(recipe.product)
                            self.inst.components.inventory:GiveItem(addt_prod, nil, pt)
                        end
                    end

                    if self.onBuild ~= nil then
                        self.onBuild(self.inst, prod)
                    end
                    prod:OnBuilt(self.inst)

                    return true
                end
            else
                prod.Transform:SetPosition(pt:Get())
                --V2C: or 0 check added for backward compatibility with mods that
                --     have not been updated to support placement rotation yet
                prod.Transform:SetRotation(rotation or 0)
                self.inst:PushEvent("buildstructure", { item = prod, recipe = recipe, skin = skin })
                prod:PushEvent("onbuilt", { builder = self.inst })
                GLOBAL.ProfileStatsAdd("build_"..prod.prefab)

                if self.onBuild ~= nil then
                    self.onBuild(self.inst, prod)
                end

                prod:OnBuilt(self.inst)

                return true
            end
        end
    end
end

--重写建造方法
AddComponentPostInit("builder", function(self, inst)
	self.OriginalDoBuild = self.DoBuild
	function self:DoBuild(recname, pt, rotation, skin)
		if recname == "pighouse" then
			return buildPigHouse(self, recname, pt, rotation, skin)
		end
		return self:OriginalDoBuild(recname, pt, rotation, skin)
	end
end)	

--重写读触手书
local function readBookTenttaclesFn(inst, reader)
	local pt = reader:GetPosition()
	local numtentacles = 3
	
	reader:StartThread(function()
		for k = 1, numtentacles do
			local theta = math.random() * 2 * GLOBAL.PI
			local radius = math.random(3, 8)

			-- we have to special case this one because birds can't land on creep
			local result_offset = GLOBAL.FindValidPositionByFan(theta, radius, 12, function(offset)
				local pos = pt + offset
				local ents = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
				return GLOBAL.next(ents) == nil
			end)

			if result_offset ~= nil then
				local pos = pt + result_offset
				
				local ents = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 40)
				local hasPigKingNear = false
				for _,obj in pairs(ents) do
					if obj and obj:HasTag("king") then
						hasPigKingNear = true
						break
					end
				end	
				if hasPigKingNear then
					reader:DoTaskInTime(0, function ()
						if reader and reader.components.talker then
							reader.components.talker:Say(GLOBAL.PKC_SPEECH.PIGKING_PROTECT.SPEECH5)
						end
					end)
					return false
				end
				
				reader.components.sanity:DoDelta(-(GLOBAL.READ_BOOK_TENTACLES_SANITY))
				local tentacle = GLOBAL.SpawnPrefab("tentacle")
				tentacle.Transform:SetPosition(pos:Get())

				GLOBAL.ShakeAllCameras(GLOBAL.CAMERASHAKE.FULL, .2, .02, .25, reader, 40)

				--need a better effect
				GLOBAL.SpawnPrefab("splash_ocean").Transform:SetPosition(pos:Get())
				--PlayFX((pt + result_offset), "splash", "splash_ocean", "idle")
				tentacle.sg:GoToState("attack_pre")
			end

			GLOBAL.Sleep(.33)
		end
	end)
	return true
end

--重写读催眠书
local function readBookSleepFn(inst, reader)
	reader.components.sanity:DoDelta(-(GLOBAL.READ_BOOK_SLEEP_SANITY))

	local x, y, z = reader.Transform:GetWorldPosition()
	local range = 15
	local ents = GLOBAL.TheNet:GetPVPEnabled() and
				GLOBAL.TheSim:FindEntities(x, y, z, range, nil, { "playerghost" }, { "sleeper", "player" }) or
				GLOBAL.TheSim:FindEntities(x, y, z, range, { "sleeper" }, { "player" })
	for i, v in ipairs(ents) do
		if v ~= reader and
			not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
			not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) 
			--and (not v.components.pkc_group or (v.components.pkc_group and reader.components.pkc_group and v.components.pkc_group:getChooseGroup() ~= reader.components.pkc_group:getChooseGroup()))
			then
			if not v.components.pkc_group then
				if v.components.sleeper ~= nil then
					v.components.sleeper:AddSleepiness(2, 10)
				elseif v.components.grogginess ~= nil then
					v.components.grogginess:AddGrogginess(8, 16)
				else
					v:PushEvent("knockedout")
				end
			else
				if reader.components.pkc_group and v.components.pkc_group:getChooseGroup() ~= reader.components.pkc_group:getChooseGroup() then
					if v:HasTag("player") then --只虚弱敌方玩家
						if v.components.grogginess ~= nil then
							v.components.grogginess:AddGrogginess(8, 16)
						end
					else
						if v.components.sleeper ~= nil then
							v.components.sleeper:AddSleepiness(2, 5)
						elseif v.components.grogginess ~= nil then
							v.components.grogginess:AddGrogginess(8, 16)
						else
							v:PushEvent("knockedout")
						end
					end
				end
			end
			
		end
	end
	return true
end

--老奶奶读书限制（触手书）
AddPrefabPostInit("book_tentacles", function(inst)
	if inst and inst.components.book then
		inst.components.book.onread = readBookTenttaclesFn
	end
end)

--老奶奶读书限制（睡眠书）
AddPrefabPostInit("book_sleep", function(inst)
	if inst and inst.components.book then
		inst.components.book.onread = readBookSleepFn
	end
end)
