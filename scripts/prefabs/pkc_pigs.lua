--
-- 重写猪人
-- Author: RedPig
-- Date: 2016/11/01
--

local assets =
{
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/pig_build.zip"),
    Asset("ANIM", "anim/pigspotted_build.zip"),
    Asset("ANIM", "anim/pig_guard_build.zip"),
    Asset("ANIM", "anim/werepig_build.zip"),
    Asset("ANIM", "anim/werepig_basic.zip"),
    Asset("ANIM", "anim/werepig_actions.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "meat",
    "monstermeat",
    "poop",
    "tophat",
    "strawhat",
    "pigskin",
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 50
local PIG_TARGET_DIST = 30

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
end

local function CalcSanityAura(inst, observer)
    return (inst.prefab == "moonpig" and -TUNING.SANITYAURA_LARGE)
        or (inst.components.werebeast ~= nil and inst.components.werebeast:IsInWereState() and -TUNING.SANITYAURA_LARGE)
        or (inst.components.follower ~= nil and inst.components.follower.leader == observer and TUNING.SANITYAURA_SMALL)
        or 0
end

local function ShouldAcceptItem(inst, item)
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    elseif item.components.edible ~= nil then
        local foodtype = item.components.edible.foodtype
        if foodtype == FOODTYPE.MEAT or foodtype == FOODTYPE.HORRIBLE then
            return inst.components.follower.leader == nil or inst.components.follower:GetLoyaltyPercent() <= 0.9
        elseif foodtype == FOODTYPE.VEGGIE or foodtype == FOODTYPE.RAW then
            local last_eat_time = inst.components.eater:TimeSinceLastEating()
            return (last_eat_time == nil or
                    last_eat_time >= TUNING.PIG_MIN_POOP_PERIOD)
                and (inst.components.inventory == nil or
                    not inst.components.inventory:Has(item.prefab, 1))
        end
        return true
    end
end

--贿赂猪人
local function OnGetItemFromPlayer(inst, giver, item)
    --I eat food
    if item.components.edible ~= nil then
        if inst.components.pkc_group and giver.components.pkc_group
        and inst.components.pkc_group:getChooseGroup() ~= giver.components.pkc_group:getChooseGroup() then
            return;
        end
        item.pkc_isplayergive = true --tag for player give
        --meat makes us friends (unless I'm a guard)
        if item.components.edible.foodtype == FOODTYPE.MEAT or item.components.edible.foodtype == FOODTYPE.HORRIBLE or item.prefab == "goldnugget" then
            if inst.components.combat:TargetIs(giver) then
                --inst.components.combat:SetTarget(nil)
            elseif giver.components.leader ~= nil and not inst:HasTag("guard") then
                giver:PushEvent("makefriend")
                giver.components.leader:AddFollower(inst)
                if item.prefab == "goldnugget" then
                    inst.components.follower:AddLoyaltyTime(500)
                else
                    inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * TUNING.PIG_LOYALTY_PER_HUNGER)
                end
                inst.components.follower.maxfollowtime =
                    giver:HasTag("polite")
                    and TUNING.PIG_LOYALTY_MAXTIME + TUNING.PIG_LOYALTY_POLITENESS_MAXTIME_BONUS
                    or TUNING.PIG_LOYALTY_MAXTIME
            end
        end
        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end

    --I wear hats
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current ~= nil then
            inst.components.inventory:DropItem(current)
        end
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end

    if item and item.prefab == "goldnugget" then
        item:Remove()
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnEat(inst, food)
    if food.components.edible ~= nil then
        if food.components.edible.foodtype == FOODTYPE.VEGGIE then
            SpawnPrefab("poop").Transform:SetPosition(inst.Transform:GetWorldPosition())
        elseif food.components.edible.foodtype == FOODTYPE.MEAT then
            SpawnPrefab("poop").Transform:SetPosition(inst.Transform:GetWorldPosition())
            if inst.components.werebeast ~= nil and not inst.components.werebeast:IsInWereState() and
                    food.components.edible:GetHealth(inst) < 0 then
                inst.components.werebeast:TriggerDelta(1)
            end
        end
    end
end

local function OnAttackedByDecidRoot(inst, attacker)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SpringCombatMod(SHARE_TARGET_DIST) * .5, { "_combat", "_health", "pig" }, { "werepig", "guard", "INLIMBO" })
    local num_helpers = 0
    for i, v in ipairs(ents) do
        if v ~= inst and not v.components.health:IsDead() then
            v:PushEvent("suggest_tree_target", { tree = attacker })
            num_helpers = num_helpers + 1
            if num_helpers >= MAX_TARGET_SHARES then
                break
            end
        end
    end
end

local function IsPig(dude)
    return dude:HasTag("pig")
end

local function IsWerePig(dude)
    return dude:HasTag("werepig")
end

local function IsNonWerePig(dude)
    return dude:HasTag("pig") and not dude:HasTag("werepig")
end

local function IsGuardPig(dude)
    return dude:HasTag("guard") and dude:HasTag("pig")
end

local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker
    inst:ClearBufferedAction()

    if attacker.prefab == "deciduous_root" and attacker.owner ~= nil then 
        OnAttackedByDecidRoot(inst, attacker.owner)
    elseif attacker.prefab ~= "deciduous_root" then
        inst.components.combat:SetTarget(attacker)
        if inst:HasTag("werepig") then
            inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsWerePig, MAX_TARGET_SHARES)
        elseif inst:HasTag("guard") then
            inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, attacker:HasTag("pig") and IsGuardPig or IsPig, MAX_TARGET_SHARES)
        elseif not (attacker:HasTag("pig") and attacker:HasTag("guard")) then
            if not inst.components.pkc_group then
                --print("pkc_pig..attacker:"..tostring(attacker.prefab))
                inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude)
                    return dude:HasTag("pig") and not dude:HasTag("werepig")
                            and not dude.components.pkc_group
                end, MAX_TARGET_SHARES)
            else
                --print("pkc_pig..attacker:"..tostring(attacker.prefab))
                inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST,
                        function(dude)
                            local fn_result = dude:HasTag("pig") and not dude:HasTag("werepig")
                                    and dude.components.pkc_group and inst.components.pkc_group
                                    and dude.components.pkc_group:getChooseGroup() == inst.components.pkc_group:getChooseGroup()
                            --print("pkc_fn_result:"..tostring(fn_result))
                            return fn_result
                        end,
                        MAX_TARGET_SHARES)
            end
        end
    end
end

local function OnNewTarget(inst, data)
    local target = data.target
    if inst:HasTag("werepig") then
        inst.components.combat:ShareTarget(target, SHARE_TARGET_DIST, IsWerePig, MAX_TARGET_SHARES)
    end
    if inst.components.pkc_group and IsNonWerePig(inst) then
        inst.components.combat:ShareTarget(target, SHARE_TARGET_DIST, function(dude)
            return dude and dude:HasTag("pig") and not dude:HasTag("werepig") and dude.components.pkc_group
                    and inst.components.pkc_group:getChooseGroup() == dude.components.pkc_group:getChooseGroup()
        end, MAX_TARGET_SHARES)
    end
end

local builds = { "pig_build", "pigspotted_build" }
local guardbuilds = { "pig_guard_build" }
--[[
local function NormalRetargetFn(inst)
    return FindEntity(
        inst,
        TUNING.PIG_TARGET_DIST,
        function(guy)
            return (guy.LightWatcher == nil or guy.LightWatcher:IsInLight())
                and inst.components.combat:CanTarget(guy)
        end,
        { "monster", "_combat" }, -- see entityreplica.lua
        inst.components.follower.leader ~= nil and
        { "playerghost", "INLIMBO", "abigail" } or
        { "playerghost", "INLIMBO" }
    )
end
]]--

local function NormalRetargetFn(inst)
	local dist = PIG_TARGET_DIST
	local invader = nil
	invader = FindEntity(inst, dist, function(guy)
		if not inst.components.pkc_group then
			return guy:HasTag("monster") and guy:HasTag("_combat") and not guy:HasTag("playerghost") and not guy:HasTag("INLIMBO")
		end
        ----不能以同队作为目标
        --if guy and guy.components.pkc_group
        --        and guy:HasTag("pkc_group"..tostring(inst.components.pkc_group:getChooseGroup())) then
        --    return false
        --end
        --
        ----不能以同队的随从为目标
        --if guy and guy.components.follower then
        --    local leader = guy.components.follower.leader
        --    if leader and leader.components.pkc_group
        --            and leader.components.pkc_group:getChooseGroup() == inst.components.pkc_group:getChooseGroup() then
        --        return false
        --    end
        --end

        --以敌对成员的随从为目标
        if guy and guy.components.follower then
            local leader = guy.components.follower.leader
            if leader and leader.components.pkc_group and inst and inst.components.pkc_group
                    and leader.components.pkc_group:getChooseGroup() ~= inst.components.pkc_group:getChooseGroup() then
                return true
            end
        end

        --以怪物或敌对成员为目标，且不能为灵魂
		return (guy:HasTag("monster")
		or  (guy.components.pkc_group and guy.components.pkc_group:getChooseGroup() ~= inst.components.pkc_group:getChooseGroup()))
		and guy:HasTag("_combat") and not guy:HasTag("playerghost") and not guy:HasTag("INLIMBO")
	end)
	return invader
end

local function NormalKeepTargetFn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
    return inst.components.combat:CanTarget(target)
        and (target.LightWatcher == nil or target.LightWatcher:IsInLight())
        and not (target.sg ~= nil and target.sg:HasStateTag("transform"))
end

local function NormalShouldSleep(inst)
    return DefaultSleepTest(inst)
        and (inst.components.follower == nil or inst.components.follower.leader == nil
            or (FindEntity(inst, 6, nil, { "campfire", "fire" }) ~= nil and
                (inst.LightWatcher == nil or inst.LightWatcher:IsInLight())))
end

local normalbrain = require "brains/pkc_pigbrain"

local function SuggestTreeTarget(inst, data)
    if data ~= nil and data.tree ~= nil and inst:GetBufferedAction() ~= ACTIONS.CHOP then
        inst.tree_target = data.tree
    end
end

--点击猪时调用
local function ongetstatus(inst, viewer)
	viewer:DoTaskInTime(0, function ()	
		if viewer and viewer.components.talker then
			viewer.components.talker:Say(PKC_SPEECH.PIGCLICK[math.random(#PKC_SPEECH.PIGCLICK)])
		end
	end)
    return nil
end

local function SetNormalPig(inst)
	--变回正常时，记住自己所属的阵营
	if inst.pkc_group_id ~= nil and inst.components.pkc_group then
		inst.components.pkc_group:setChooseGroup(inst.pkc_group_id)
	end
	
    inst:RemoveTag("werepig")
    inst:RemoveTag("guard")
    inst:SetBrain(normalbrain)
    inst:SetStateGraph("pkc_SGpig")
    inst.AnimState:SetBuild(inst.build)

--    inst.components.werebeast:SetOnNormalFn(SetNormalPig)
	inst.components.werebeast:SetOnNormalFn(SetNormalPig)
    inst.components.sleeper:SetResistance(2)

    inst.components.combat:SetDefaultDamage(PKC_PIGMAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(PKC_PIGMAN_ATTACKPERIOD)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED

    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)

    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("meat", 2)
    inst.components.lootdropper:AddRandomLoot("pigskin", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.health:SetMaxHealth(PKC_PIGMAN_HEALTH)
	inst.components.health:StartRegen(5, 5) --回血
	
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetTarget(nil)
    inst:ListenForEvent("suggest_tree_target", SuggestTreeTarget)

    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll("becamewerepig")
	
	--名字
	if not inst.components.inspectable then
		inst:AddComponent("inspectable")
	end
	inst.components.inspectable.getstatus = ongetstatus
	if not inst.components.named then
		inst:AddComponent("named")
	end
	inst.components.named:SetName("战斗猪")
	
end

local function GuardRetargetFn(inst)
    --defend the king, then the torch, then myself
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    local defendDist = SpringCombatMod(TUNING.PIG_GUARD_DEFEND_DIST)
    local defenseTarget =
        FindEntity(inst, defendDist, nil, { "king" }) or
        (home ~= nil and inst:IsNear(home, defendDist) and home) or
        inst

    if not defenseTarget.happy then
        local invader = FindEntity(defenseTarget, SpringCombatMod(TUNING.PIG_GUARD_TARGET_DIST), nil, { "character" }, { "guard", "INLIMBO" })
        if invader ~= nil and
            not (defenseTarget.components.trader ~= nil and defenseTarget.components.trader:IsTryingToTradeWithMe(invader)) and
            not (inst.components.trader ~= nil and inst.components.trader:IsTryingToTradeWithMe(invader)) then
            return invader
        end

        if not TheWorld.state.isday and home ~= nil and home.components.burnable ~= nil and home.components.burnable:IsBurning() then
            local lightThief = FindEntity(
                home,
                home.components.burnable:GetLargestLightRadius(),
                function(guy)
                    return guy.LightWatcher:IsInLight()
                        and not (defenseTarget.components.trader ~= nil and defenseTarget.components.trader:IsTryingToTradeWithMe(guy))
                        and not (inst.components.trader ~= nil and inst.components.trader:IsTryingToTradeWithMe(guy))
                end,
                { "player" }
            )
            if lightThief ~= nil then
                return lightThief
            end
        end
    end
    return FindEntity(defenseTarget, defendDist, nil, { "monster" }, { "INLIMBO" })
end

local function GuardKeepTargetFn(inst, target)
    if not inst.components.combat:CanTarget(target) or
        (target.sg ~= nil and target.sg:HasStateTag("transform")) or
        (target:HasTag("guard") and target:HasTag("pig")) then
        return false
    end

    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home == nil then
        return true
    end

    local defendDist = not TheWorld.state.isday
                    and home.components.burnable ~= nil
                    and home.components.burnable:IsBurning()
                    and home.components.burnable:GetLargestLightRadius()
                    or SpringCombatMod(TUNING.PIG_GUARD_DEFEND_DIST)
    return target:IsNear(home, defendDist) and inst:IsNear(home, defendDist)
end

local function GuardShouldSleep(inst)
    return false
end

local function GuardShouldWake(inst)
    return true
end

local guardbrain = require "brains/pigguardbrain"

local function SetGuardPig(inst)
    inst:RemoveTag("werepig")
    inst:AddTag("guard")
    inst:SetBrain(guardbrain)
    inst:SetStateGraph("SGpig")
    inst.AnimState:SetBuild(inst.build)

--    inst.components.werebeast:SetOnNormalFn(SetGuardPig)
	inst.components.werebeast:SetOnNormalFn(SetGuardPig)
    inst.components.sleeper:SetResistance(3)

    inst.components.health:SetMaxHealth(TUNING.PIG_GUARD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PIG_GUARD_DAMAGE)
    inst.components.combat:SetAttackPeriod(1.1)
    inst.components.combat:SetKeepTargetFunction(GuardKeepTargetFn)
    inst.components.combat:SetRetargetFunction(1, GuardRetargetFn)
    inst.components.combat:SetTarget(nil)
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED

    inst.components.sleeper:SetSleepTest(GuardShouldSleep)
    inst.components.sleeper:SetWakeTest(GuardShouldWake)

    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("meat", 3)
    inst.components.lootdropper:AddRandomLoot("pigskin", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll("becamewerepig")
    inst.components.follower:SetLeader(nil)
end

local function WerepigRetargetFn(inst)
    return FindEntity(
        inst,
        SpringCombatMod(TUNING.PIG_TARGET_DIST),
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and not (guy.sg ~= nil and guy.sg:HasStateTag("transform"))
        end,
        { "_combat" }, --See entityreplica.lua (re: "_combat" tag)
        { "werepig", "alwaysblock", "beaver", "king" }
    )
end

local function WerepigKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and not target:HasTag("werepig")
           and not target:HasTag("beaver")
           and not (target.sg ~= nil and target.sg:HasStateTag("transform"))
end

local function IsNearMoonBase(inst, dist)
    local moonbase = inst.components.entitytracker:GetEntity("moonbase")
    return moonbase == nil or inst:IsNear(moonbase, dist)
end

local function MoonpigRetargetFn(inst)
    return IsNearMoonBase(inst, TUNING.MOONPIG_AGGRO_DIST)
        and FindEntity(
                inst,
                TUNING.PIG_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                        and not (guy.sg ~= nil and guy.sg:HasStateTag("transform"))
                end,
                { "_combat" }, --See entityreplica.lua (re: "_combat" tag)
                { "werepig", "alwaysblock", "beaver", "moonbeast" }
            )
        or nil
end

local function MoonpigKeepTargetFn(inst, target)
    return IsNearMoonBase(inst, TUNING.MOONPIG_RETURN_DIST)
        and not target:HasTag("moonbeast")
        and WerepigKeepTargetFn(inst, target)
end

local function WerepigSleepTest(inst)
    return false
end

local function WerepigWakeTest(inst)
    return true
end

local werepigbrain = require "brains/werepigbrain"

local function SetWerePig(inst)
    inst:AddTag("werepig")
    inst:RemoveTag("guard")
    inst:SetBrain(werepigbrain)
    inst:SetStateGraph("SGwerepig")
    inst.AnimState:SetBuild("werepig_build")
	--变成了疯猪，可攻击
	if inst.components.pkc_group then
		inst.components.pkc_group:setChooseGroup(0)
	end
	
    inst.components.sleeper:SetResistance(3)

    inst.components.combat:SetDefaultDamage(1.5 * TUNING.WEREPIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WEREPIG_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.WEREPIG_RUN_SPEED 
    inst.components.locomotor.walkspeed = TUNING.WEREPIG_WALK_SPEED 

    inst.components.sleeper:SetSleepTest(WerepigSleepTest)
    inst.components.sleeper:SetWakeTest(WerepigWakeTest)

    inst.components.lootdropper:SetLoot({ "meat", "meat", "pigskin" })
    inst.components.lootdropper.numrandomloot = 0

    inst.components.health:SetMaxHealth(2 * TUNING.WEREPIG_HEALTH)
    inst.components.combat:SetTarget(nil)
    inst.components.combat:SetRetargetFunction(3, WerepigRetargetFn)
    inst.components.combat:SetKeepTargetFunction(WerepigKeepTargetFn)

    inst.components.trader:Disable()
    inst.components.follower:SetLeader(nil)
    inst.components.talker:IgnoreAll("becamewerepig")
end

local function GetStatus(inst)
    return (inst:HasTag("werepig") and "WEREPIG")
        or (inst:HasTag("guard") and "GUARD")
        or (inst.components.follower.leader ~= nil and "FOLLOWER")
        or nil
end

local function displaynamefn(inst)
    return inst.name
end

local function OnSave(inst, data)
    data.build = inst.build
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.build = data.build or builds[1]
--        if not inst.components.werebeast:IsInWereState() then
           -- inst.AnimState:SetBuild(inst.build)
--        end
		if not inst.components.werebeast:IsInWereState() then
            inst.AnimState:SetBuild(inst.build)
		end
    end
end

local function CustomOnHaunt(inst)
    if not inst:HasTag("werepig") and math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
        local remainingtime = TUNING.TOTAL_DAY_TIME * (1 - TheWorld.state.time)
        local mintime = TUNING.SEG_TIME
--      inst.components.werebeast:SetWere(math.max(mintime, remainingtime) + math.random() * TUNING.SEG_TIME)
		inst.components.werebeast:SetWere(math.max(mintime, remainingtime) + math.random() * TUNING.SEG_TIME)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
    end
end

local function OnClientFadeUpdate(inst)
    inst._fadeval = math.max(0, inst._fadeval - FRAMES)
    local k = 1 - inst._fadeval * inst._fadeval
    inst.AnimState:OverrideMultColour(k, k, k, k)
    if inst._fadeval <= 0 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnMasterFadeUpdate(inst)
    OnClientFadeUpdate(inst)
    inst._fade:set_local(math.floor(7 * inst._fadeval + .5))
    inst.DynamicShadow:Enable(inst._fadeval < .8)
    if inst._fadetask == nil then
        inst:RemoveTag("NOCLICK")
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadeval = inst._fade:value() / 7
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnClientFadeUpdate)
        OnClientFadeUpdate(inst)
    end
end

local function FadeIn(inst)
    inst._fadeval = 1
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnMasterFadeUpdate)
        inst:AddTag("NOCLICK")
    end
    OnMasterFadeUpdate(inst)
end

local function common(moonbeast)
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLightWatcher()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

	inst:AddComponent("pkc_group")
	inst:AddTag("pkc_defences") --标记为防御力量
    inst:AddTag("character")
    inst:AddTag("pig")
	inst:AddTag("pkc_pigman")
    inst:AddTag("scarytoprey")
    inst.AnimState:SetBank("pigman")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:Hide("hat")

    if not moonbeast then
        --trader (from trader component) added to pristine state for optimization
        inst:AddTag("trader")
    end

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    if moonbeast then
        inst:AddTag("werepig")
        inst:AddTag("moonbeast")
        inst.AnimState:SetBuild("werepig_build")
        --Since we override prefab name, we will need to use the higher
        --priority displaynamefn to return us back plain old .name LOL!
        inst:SetPrefabNameOverride("pigman")
        inst.displaynamefn = displaynamefn

        inst._fade = net_tinybyte(inst.GUID, "moonpig._fade", "fadedirty")
    else
        inst:AddComponent("talker")
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
        --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
        inst.components.talker.offset = Vector3(0, -400, 0)
        inst.components.talker:MakeChatter()
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        if moonbeast then
            inst:ListenForEvent("fadedirty", OnFadeDirty)
        end

        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    if not moonbeast then
        inst.components.talker.ontalk = ontalk
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = 1.1 * TUNING.PIG_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED --3

    inst:AddComponent("bloomer")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetCanEatRaw()
    inst.components.eater.strongstomach = true -- can eat monster meat!
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"

    MakeMediumBurnableCharacter(inst, "pig_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.PIGNAMES
    inst.components.named:PickNewName()

    ------------------------------------------
    --MakeHauntablePanic(inst)
	--[[
    if not moonbeast then
        inst:AddComponent("werebeast")
        inst.components.werebeast:SetOnWereFn(SetWerePig)
        inst.components.werebeast:SetTriggerLimit(4)

        AddHauntableCustomReaction(inst, CustomOnHaunt, true, nil, true)
    end
	]]--
	
	if not moonbeast then
        inst:AddComponent("werebeast")
        inst.components.werebeast:SetOnWereFn(SetWerePig)
        inst.components.werebeast:SetTriggerLimit(4)

        --AddHauntableCustomReaction(inst, CustomOnHaunt, true, nil, true)
    end
    ------------------------------------------
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME
    ------------------------------------------

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    if not moonbeast then
        inst:AddComponent("trader")
        inst.components.trader:SetAcceptTest(ShouldAcceptItem)
        inst.components.trader.onaccept = OnGetItemFromPlayer
        inst.components.trader.onrefuse = OnRefuseItem
        inst.components.trader.deleteitemonaccept = false
    end
    
    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------------------------------

    inst:AddComponent("sleeper")

    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    ------------------------------------------

    if moonbeast then
        inst.FadeIn = FadeIn
    else
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
    end

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

	--戴帽子
	inst.AnimState:OverrideSymbol("swap_hat", "hat_football", "swap_hat")
	inst.AnimState:Show("HAT")
	inst.AnimState:Show("HAT_HAIR")
	inst.AnimState:Hide("HAIR_NOHAT")
	inst.AnimState:Hide("HAIR")
	
    return inst
end

local function normal(groupId)
    local inst = common(false)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.build = builds[math.random(#builds)]
    inst.AnimState:SetBuild(inst.build)
    SetNormalPig(inst)
	inst:AddTag("pkc_group"..groupId)
    return inst
end

local function nightpig(groupId)
    local inst = common(false)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.build = builds[math.random(#builds)]
    inst.AnimState:SetBuild(inst.build)
    SetNormalPig(inst)
	inst:AddTag("pkc_group"..groupId)
    return inst
end


local function wearHat(inst, hatName)
    if inst then
        inst.AnimState:OverrideSymbol("swap_hat", hatName, "swap_hat")
        inst.AnimState:Show("HAT")
        inst.AnimState:Show("HAT_HAIR")
        inst.AnimState:Hide("HAIR_NOHAT")
        inst.AnimState:Hide("HAIR")
    end
end

return 
Prefab("pkc_pigman_big", function()
	local inst = normal(GROUP_BIGPIG_ID)
    --戴帽子
    wearHat(inst, "ewecushat_swap")
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.BIGPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
	inst.pkc_group_id = GROUP_BIGPIG_ID
	return inst
end, assets, prefabs),
Prefab("pkc_pigman_red", function()
	local inst = normal(GROUP_REDPIG_ID)
    --戴帽子
    wearHat(inst, "spartahelmut_swap2")
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.REDPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_REDPIG_ID)
	inst.pkc_group_id = GROUP_REDPIG_ID
	return inst
end, assets, prefabs),
Prefab("pkc_pigman_cui", function()
	local inst = normal(GROUP_CUIPIG_ID)
    --戴帽子
    wearHat(inst, "summerbandana_swap")
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.CUIPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_CUIPIG_ID)
	inst.pkc_group_id = GROUP_CUIPIG_ID
	return inst
end, assets, prefabs),
Prefab("pkc_pigman_long", function()
	local inst = normal(GROUP_LONGPIG_ID)
    --戴帽子
    wearHat(inst, "birchnuthat_swap")
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.LONGPIG.pigman_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	inst.components.pkc_group:setChooseGroup(GROUP_LONGPIG_ID)
	inst.pkc_group_id = GROUP_LONGPIG_ID
	return inst
end, assets, prefabs)







