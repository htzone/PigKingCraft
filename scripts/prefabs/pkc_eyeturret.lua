--
-- 重写眼球塔
-- Author: RedPig
-- Date: 2016/11/01
--

require "prefabutil"
--pkc_eyeturret_big

local assets =
{
    Asset("ANIM", "anim/eyeball_turret.zip"),
    Asset("ANIM", "anim/eyeball_turret_object.zip"),
	Asset("MINIMAP_IMAGE", "eyeball_turret"),
}

local prefabs =
{
    "eye_charge",
    "eyeturret_base",
}

local brain = require "brains/eyeturretbrain"

local MAX_LIGHT_FRAME = 24

local function OnUpdateLight(inst, dframes)
    local frame = inst._lightframe:value() + dframes
    if frame >= MAX_LIGHT_FRAME then
        inst._lightframe:set_local(MAX_LIGHT_FRAME)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
        inst._lightframe:set_local(frame)
    end

    if frame <= 20 then
        local k = frame / 20
        --radius:    0   -> 3.5
        --intensity: .65 -> .9
        --falloff:   .7  -> .9
        inst.Light:SetRadius(3.5 * k)
        inst.Light:SetIntensity(.9 * k + .65 * (1 - k))
        inst.Light:SetFalloff(.9 * k + .7 * (1 - k))
    else
        local k = (frame - 20) / (MAX_LIGHT_FRAME - 20)
        --radius:    3.5 -> 0
        --intensity: .9  -> .65
        --falloff:   .9  -> .7
        inst.Light:SetRadius(3.5 * (1 - k))
        inst.Light:SetIntensity(.65 * k + .9 * (1 - k))
        inst.Light:SetFalloff(.7 * k + .9 * (1 - k))
    end

    if TheWorld.ismastersim then
        inst.Light:Enable(frame < MAX_LIGHT_FRAME)
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function triggerlight(inst)
    inst._lightframe:set(0)
    OnLightDirty(inst)
end

local function retargetfn(inst)
    return FindEntity(inst, 20,
        function(guy)
            if guy == nil or inst == nil or not inst.components.combat:CanTarget(guy) then
                return false
            end
            if guy.components.pkc_group and guy.components.pkc_group:isSameGroup(inst) then
                return false
            end
            --以敌对成员的随从为目标
            if guy.components.follower then
                local leader = guy.components.follower.leader
                if leader and leader.components.pkc_group and inst.components.pkc_group
                        and leader.components.pkc_group:getChooseGroup() ~= inst.components.pkc_group:getChooseGroup() then
                    return true
                end
            end
            --以敌对成员为目标
            return guy.components.pkc_group
				and guy.components.pkc_group:getChooseGroup() ~= inst.components.pkc_group:getChooseGroup()
        end,
        { "_combat" }, --see entityreplica.lua
        { "INLIMBO" }
    )
end

local function shouldKeepTarget(inst, target)
    if inst.components.pkc_group and inst.components.pkc_group:isSameGroup(target) then
        return false
    end
    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and inst:IsNear(target, 20)
end

local function ShareTargetFn(dude)
    return dude:HasTag("eyeturret") or dude
end

--家里眼球塔被攻击时提示玩家
local function remindPlayerOnAttacked(inst)
    if not inst.isUnderAttack then
        local groupId = inst.components.pkc_group:getChooseGroup()
        local groupTag = "pkc_group"..tostring(groupId)
        local pigking = FindEntity(inst, 20, nil, {"king", "pig", groupTag})
        if pigking ~= nil then
            for _, player in pairs(AllPlayers) do
                if player and player.components.pkc_group and player.components.pkc_group:isSameGroup(inst) then
                    player:DoTaskInTime(0, function ()
                        if player and player:IsValid() and player.components.talker then
                            player.components.talker:Say(PKC_SPEECH.EYETURRET.SPEECH1)
                        end
                    end)
                end
            end
        end
        inst.isUnderAttack = true
        inst:DoTaskInTime(math.random(4, 8), function()
            inst.isUnderAttack = false
        end)
    end
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, 15, 
		function(dude) 
			return (dude:HasTag("eyeturret") or dude:HasTag("pig")) and dude.components.pkc_group and dude.components.pkc_group:getChooseGroup() == inst.components.pkc_group:getChooseGroup()
		end, 
		30)
        --家里眼球塔被攻击时提示玩家
        remindPlayerOnAttacked(inst)
    end
end

local function EquipWeapon(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("eye_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end
end

local function ondeploy(inst, pt, deployer)
    local turret = SpawnPrefab("eyeturret")
    if turret ~= nil then
        turret.Physics:SetCollides(false)
        turret.Physics:Teleport(pt.x, 0, pt.z)
        turret.Physics:SetCollides(true)
        turret:syncanim("place")
        turret:syncanimpush("idle_loop", true)
        turret.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
        inst:Remove()
    end
end

local function syncanim(inst, animname, loop)
    inst.AnimState:PlayAnimation(animname, loop)
    inst.base.AnimState:PlayAnimation(animname, loop)
end

local function syncanimpush(inst, animname, loop)
    inst.AnimState:PushAnimation(animname, loop)
    inst.base.AnimState:PushAnimation(animname, loop)
end

local function itemfn()
    local inst = CreateEntity()
   
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("eyeball_turret_object")
    inst.AnimState:SetBuild("eyeball_turret_object")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("eyeturret")
	inst:AddTag("pkc_defences") --标记为防御力量

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    --Tag to make proper sound effects play on hit.
    inst:AddTag("largecreature")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)
    
    return inst
end

local function fn(groupId)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.Transform:SetFourFaced()

    inst.MiniMapEntity:SetIcon("eyeball_turret.png")

	inst:AddComponent("pkc_group")
    inst:AddTag("eyeturret")
    inst:AddTag("companion")
	inst:AddTag("pkc_defences") --标记为防御力量
	inst:AddTag("pkc_group"..groupId) --队伍标记
	
    inst.AnimState:SetBank("eyeball_turret")
    inst.AnimState:SetBuild("eyeball_turret")
    inst.AnimState:PlayAnimation("idle_loop")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.65)
    inst.Light:SetFalloff(.7)
    inst.Light:SetColour(251/255, 234/255, 234/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst._lightframe = net_smallbyte(inst.GUID, "eyeturret._lightframe", "lightdirty")
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.base = SpawnPrefab("eyeturret_base")
    inst.base.entity:SetParent(inst.entity)

    inst.syncanim = syncanim
    inst.syncanimpush = syncanimpush

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(PKC_EYETURRET_HEALTH)
    inst.components.health:StartRegen(TUNING.EYETURRET_REGEN, 1)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.EYETURRET_RANGE)
    inst.components.combat:SetDefaultDamage(PKC_EYETURRET_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.EYETURRET_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)

    inst.triggerlight = triggerlight

    MakeLargeFreezableCharacter(inst)

    MakeHauntableFreeze(inst)

    inst:AddComponent("inventory")
    inst:DoTaskInTime(1, EquipWeapon)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_TINY    

    inst:AddComponent("inspectable")
	if not inst.components.named then
		inst:AddComponent("named")
	end
	inst.components.named:SetName("争霸眼球塔")
    inst:AddComponent("lootdropper")

    inst:ListenForEvent("attacked", OnAttacked)

    inst:SetStateGraph("SGeyeturret")
    inst:SetBrain(brain)

    return inst
end

local baseassets =
{
    Asset("ANIM", "anim/eyeball_turret_base.zip"),
}

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("eyeball_turret_base")
    inst.AnimState:SetBuild("eyeball_turret_base")
    inst.AnimState:PlayAnimation("idle_loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return
Prefab("pkc_eyeturret_big", function()
	local inst = fn(GROUP_BIGPIG_ID)
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.BIGPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
	inst.pkc_group_id = GROUP_BIGPIG_ID
	return inst
end, assets, prefabs),
Prefab("pkc_eyeturret_red", function()
	local inst = fn(GROUP_REDPIG_ID)
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.REDPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_REDPIG_ID)
	inst.pkc_group_id = GROUP_REDPIG_ID
	return inst
end, assets, prefabs),
Prefab("pkc_eyeturret_long", function()
	local inst = fn(GROUP_LONGPIG_ID)
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.LONGPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_LONGPIG_ID)
	inst.pkc_group_id = GROUP_LONGPIG_ID
	return inst
end, assets, prefabs),
Prefab("pkc_eyeturret_cui", function()
	local inst = fn(GROUP_CUIPIG_ID)
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.CUIPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_CUIPIG_ID)
	inst.pkc_group_id = GROUP_CUIPIG_ID
	return inst
end, assets, prefabs)
    --Prefab("eyeturret_item", itemfn, assets, prefabs),
    --MakePlacer("eyeturret_item_placer", "eyeball_turret", "eyeball_turret", "idle_place"),
   --Prefab("eyeturret_base", basefn, baseassets)
