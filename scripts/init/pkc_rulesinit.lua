--@name pkc_rulesinit
--@description ����Լ��
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

--�������н���������
for _,recipes in pairs(GLOBAL.AllRecipes) do
	AddPrefabPostInit(recipes.name, removeBurnable)
end

--���û������Ӱ뾶Ϊһ��뾶
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

--���е����ڸ���ʱ���߻��������������Ʒ(�ͻ������������Ч)
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

--��������Ѫ������
AddComponentPostInit("health", function(self, inst)
    self.oldDeltaPenalty = self.DeltaPenalty
	if GLOBAL.TheWorld.ismastersim then
		function self:DeltaPenalty(delta)
			return self:oldDeltaPenalty(0)
		end
	end
end)

--�����ڵ���Ʒ
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

--�����µ���Ʒ��Ϊÿ�����������Ʒ���Tag
local function OnBuildNew(doer, prod) 
	if prod and (not prod.components.inventoryitem or prod.components.container) then --�ֿ���Ʒ���˱������ⶼ����Ҫ��Tag
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

--������Ʒ��Ϊÿ�����õ�����Ʒ���Tag
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

-----������Ʒ��Tag�ͱ�Ǳ��������----
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

--�������������ܷ���
local old_HAMMER = GLOBAL.ACTIONS.HAMMER.fn
GLOBAL.ACTIONS.HAMMER.fn = function(act)
	--���ӵ���������
	if (act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id) 
	or act.target.prefab == "pighouse"
	then
		return old_HAMMER(act)
	end
	--��Ʒ�޶����ǿ���
	if act.target.pkc_group_id == nil then
		return old_HAMMER(act)
	end
	--������������������
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
					act.doer.components.talker:Say("��ϧ���ܵз�����������")
				end
            end)
		end
	end
end

--��������ũ�������
local old_DIG = GLOBAL.ACTIONS.DIG.fn 
GLOBAL.ACTIONS.DIG.fn = function(act)
	--���ӵ���������
	if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_DIG(act)
	end
	--��Ʒ�޶����ǿ���
	if act.target.pkc_group_id == nil then
		return old_DIG(act)
	end
	--��������ũ�����ܱ���
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
					act.doer.components.talker:Say("��ϧ���ܵз�����������")
				end
            end)
		end
	end
end

--����������Ʒ����
local old_LIGHT = GLOBAL.ACTIONS.LIGHT.fn 
GLOBAL.ACTIONS.LIGHT.fn = function(act)
	--���ӵ���������
    if act.doer.components.pkc_group and act.target.pkc_group_id 
	and act.doer.components.pkc_group:getChooseGroup() == act.target.pkc_group_id
	then
		return old_LIGHT(act)
	end
	--��Ʒ�޶����ǿ���
	if act.target.pkc_group_id == nil then
		return old_LIGHT(act)
	end
	--��������ũ�����ܱ���
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
					act.doer.components.talker:Say("��ϧ���ܵз�����������")
				end
            end)
		end
	end
end

--��������
local old_ATTACK = GLOBAL.ACTIONS.ATTACK.fn 
GLOBAL.ACTIONS.ATTACK.fn = function(act)
	--û�м�����Ӫ�Ĳ�����
	if not act.doer.components.pkc_group or not act.target.components.pkc_group then
		return old_ATTACK(act)
	end
	--ͬ�����֮�䲻���˺�
	if act.doer.components.pkc_group and act.target.components.pkc_group
	and act.doer.components.pkc_group:getChooseGroup() == act.target.components.pkc_group:getChooseGroup() then
		return false
	end
	return old_ATTACK(act)
end
