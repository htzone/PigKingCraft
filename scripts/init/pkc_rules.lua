--@name pkc_rulesinit
--@description PVP规则约束
--@auther redpig
--@date 2016-11-05

local function removeBurnable(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst 
		and inst:HasTag("structure")
		and inst.components.burnable
		and not inst.prefab == "pighouse"
		and not inst.prefab == "rabbithouse"
		then
			inst:RemoveTag("canlight")
			inst:AddTag("nolight")
			inst:AddTag("fireimmune")
		end
	end
end

--设置所有建筑不可烧
for _,recipes in pairs(GLOBAL.AllRecipes) do
	AddPrefabPostInit(recipes.name, removeBurnable)
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

--当有敌人在附近下线会掉落身上所有物品(客机或服务器才有效)
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

--安置物品，为每个安置的新物品添加Tag
local old_DEPLOY = GLOBAL.ACTIONS.DEPLOY.fn 
GLOBAL.ACTIONS.DEPLOY.fn = function(act)
    if GLOBAL.TheWorld.ismastersim then 
		local x = act.pos.x
		local y = act.pos.y
		local z = act.pos.z
		act.doer:DoTaskInTime(0, function ()
			if act.doer and act.doer.components.pkc_group then
				local ents = GLOBAL.TheSim:FindEntities(x, y, z, 0)
				for _, obj in pairs(ents) do
					obj.saveTags = {}
					obj:AddTag("pkc_group"..act.doer.components.pkc_group:getChooseGroup())
					obj.saveTags["pkc_group"..act.doer.components.pkc_group:getChooseGroup()] = 1
					obj.pkc_group_id = act.doer.components.pkc_group:getChooseGroup()
				end
			end
		end)
	end	
    return old_DEPLOY(act)
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
	if (act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id) 
	or act.target.prefab == "pighouse" or act.target.prefab == "rabbithouse"
	then
		return old_HAMMER(act)
	end

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
				hasEnemyPigKingNear = true
				break
			end
		end	
		if not hasEnemyPigKingNear then
			return old_HAMMER(act)
		else
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
				hasEnemyPigKingNear = true
				break
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
	if act.target.pkc_group_id == nil then
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
				hasEnemyPigKingNear = true
				break
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
				hasEnemyPigKingNear = true
				break
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
					hasEnemyPigKingNear = true
					break
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
						hasEnemyPigKingNear = true
						break
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
	if act.doer.components.pkc_group and act.target.components.pkc_group
	and act.doer.components.pkc_group:getChooseGroup() == act.target.components.pkc_group:getChooseGroup() then
		return false
	end
	return old_ATTACK(act)
end