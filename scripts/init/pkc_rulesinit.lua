--@name pkc_rulesinit
--@description 规则约束
--@auther RedPig
--@date 2016-11-05

local function removeBurnable(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst 
		and inst:HasTag("structure")
		and inst.components.burnable
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

--设置火焰蔓延半径为一半半径
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

--当有敌人在附近时下线会掉落身上所有物品(客机或服务器才有效)
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

--不存在的物品
local cantExistPrefabs = {
"pigking",
"mandrake_planted",
"panflute",
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

--建造新的物品，为每个建造的新物品添加Tag
local function OnBuildNew(doer, prod) 
	if prod and (not prod.components.inventoryitem or prod.components.container) then --仓库物品除了背包以外都不需要加Tag
		if doer and doer.components.pkc_group then
			prod.saveTags = {}
			prod:AddTag("pkc_group_"..doer.components.pkc_group:getChooseGroup())
			prod.saveTags["pkc_group_"..doer.components.pkc_group:getChooseGroup()] = 1
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
					obj:AddTag("pkc_group_"..act.doer.components.pkc_group:getChooseGroup())
					obj.saveTags["pkc_group_"..act.doer.components.pkc_group:getChooseGroup()] = 1
					obj.pkc_group_id = act.doer.components.pkc_group:getChooseGroup()
				end
			end
		end)
	end	
    return old_DEPLOY(act)
end

-----建造物品的Tag和标记保存与加载----
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

local function OnLoad(inst, data)
	if inst.OldOnLoad ~= nil then
		inst.OldOnLoad(inst, data)
	end
	if data ~= nil then 
		if data.saveTags ~= nil and GLOBAL.next(data.saveTags) ~= nil then
			inst.saveTags = data.saveTags
			for groupTag,_ in pairs(inst.saveTags) do
				inst:AddTag(groupTag)
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

--猪王附近建筑受防砸
local old_HAMMER = GLOBAL.ACTIONS.HAMMER.fn
GLOBAL.ACTIONS.HAMMER.fn = function(act)
	--本队的人无限制
	if (act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id) 
	or act.target.prefab == "pighouse"
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
			if obj and obj:HasTag("king") and obj.components.pkc_group and obj.components.pkc_group:getChooseGroup() ~= act.doer.components.pkc_group:getChooseGroup() then
				hasEnemyPigKingNear = true
				break
			end
		end	
		if not hasEnemyPigKingNear then
			return old_HAMMER(act)
		else
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say("可惜，受敌方猪王保护！")
				end
            end)
		end
	end
end

--猪王附近农作物防挖
local old_DIG = GLOBAL.ACTIONS.DIG.fn 
GLOBAL.ACTIONS.DIG.fn = function(act)
	--本队的人无限制
	if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_DIG(act)
	end
	--物品无队伍标记可砸
	if act.target.pkc_group_id == nil then
		return old_DIG(act)
	end
	--猪王附近农作物受保护
	if not act.doer.components.pkc_group then
		return old_DIG(act)
	else
		local x, y, z = act.target.Transform:GetWorldPosition()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
		local hasEnemyPigKingNear = false
		for _,obj in pairs(ents) do
			if obj and obj:HasTag("king") and obj.components.pkc_group and obj.components.pkc_group:getChooseGroup() ~= act.doer.components.pkc_group:getChooseGroup() then
				hasEnemyPigKingNear = true
				break
			end
		end	
		if not hasEnemyPigKingNear then
			return old_DIG(act)
		else
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say("可惜，受敌方猪王保护！")
				end
            end)
		end
	end
end

--猪王附近物品防烧
local old_LIGHT = GLOBAL.ACTIONS.LIGHT.fn 
GLOBAL.ACTIONS.LIGHT.fn = function(act)
	--本队的人无限制
    if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_LIGHT(act)
	end
	--物品无队伍标记可砸
	if act.target.pkc_group_id == nil then
		return old_LIGHT(act)
	end
	--猪王附近农作物受保护
	if not act.doer.components.pkc_group then
		return old_LIGHT(act)
	else
		local x, y, z = act.target.Transform:GetWorldPosition()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, GLOBAL.PIGKING_RANGE)
		local hasEnemyPigKingNear = false
		for _,obj in pairs(ents) do
			if obj and obj:HasTag("king") and obj.components.pkc_group and obj.components.pkc_group:getChooseGroup() ~= act.doer.components.pkc_group:getChooseGroup() then
				hasEnemyPigKingNear = true
				break
			end
		end	
		if not hasEnemyPigKingNear then
			return old_LIGHT(act)
		else
			act.doer:DoTaskInTime(0, function ()	
				if act.doer and act.doer.components.talker then
					act.doer.components.talker:Say("可惜，受敌方猪王保护！")
				end
            end)
		end
	end
end

--攻击限制
local old_ATTACK = GLOBAL.ACTIONS.ATTACK.fn 
GLOBAL.ACTIONS.ATTACK.fn = function(act)
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
