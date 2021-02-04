--
-- pkc_leifking
-- Author: RedPig
-- Date: 2021/2/4
--

local brain = require "brains/pkc_leifkingbrain"
local SLEEP_DIST_FROMTHREAT = 3
local SLEEP_DIST_FROMHOME_SQ = 2 * 2

local assets =
{
    Asset("ANIM", "anim/leif_walking.zip"),
    Asset("ANIM", "anim/leif_actions.zip"),
    Asset("ANIM", "anim/leif_attacks.zip"),
    Asset("ANIM", "anim/leif_idles.zip"),
    Asset("ANIM", "anim/leif_build.zip"),
    Asset("ANIM", "anim/leif_lumpy_build.zip"),
    Asset("SOUND", "sound/leif.fsb"),
}

local prefabs =
{
    "meat",
    "log",
    "character_fire",
    "livinglog",
}

local function SetLeifScale(inst, scale)
    inst._scale = scale ~= 1 and scale or nil

    inst.Transform:SetScale(scale, scale, scale)
    inst.Physics:SetCapsule(.5 * scale, 1)
    inst.DynamicShadow:SetSize(4 * scale, 1.5 * scale)

    inst.components.locomotor.walkspeed = 1.5 * scale

    inst.components.combat:SetDefaultDamage(TUNING.LEIF_DAMAGE * scale)
    inst.components.combat:SetRange(3 * scale)

    local health_percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(TUNING.LEIF_HEALTH * scale)
    inst.components.health:SetPercent(health_percent, true)
end

local function onpreloadfn(inst, data)
    if data ~= nil and data.leifscale ~= nil then
        SetLeifScale(inst, data.leifscale)
    end
end

local function onloadfn(inst, data)
    if data ~= nil then
        if data.hibernate then
            inst.components.sleeper.hibernate = true
        end
        if data.sleep_time ~= nil then
            inst.components.sleeper.testtime = data.sleep_time
        end
        if data.sleeping then
            inst.components.sleeper:GoToSleep()
        end
    end
end

local function onsavefn(inst, data)
    data.leifscale = inst._scale

    if inst.components.sleeper:IsAsleep() then
        data.sleeping = true
        data.sleep_time = inst.components.sleeper.testtime
    end

    if inst.components.sleeper:IsHibernating() then
        data.hibernate = true
    end
end

local function CalcSanityAura(inst)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_LARGE or -TUNING.SANITYAURA_MED
end

local function OnBurnt(inst)
    if inst.components.propagator and inst.components.health and not inst.components.health:IsDead() then
        inst.components.propagator.acceptsheat = true
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function retargetfn(inst)
    local dist = 20
    return FindEntity(inst, dist, function(guy)
        if guy:HasTag("player") then
            return true
        end
        if guy.components.follower and guy.components.follower.leader
                and guy.components.follower.leader:HasTag("player") then
            return true
        end
        if guy:HasTag("monster") or guy:HasTag("pkc_hostile")
                or guy:HasTag("shadowboss") or guy:HasTag("playerghost") then
            return false
        end
        return guy:HasTag("pkc_defences")
    end)
end

local function keepTargetOverride(inst, target)
    return inst.components.combat:CanTarget(target)
end

local loot = {
    "livinglog", "livinglog", "livinglog", "livinglog", "livinglog", "livinglog", "monstermeat",
    "thulecite",  "thulecite",
    "eyeturret_item",
    "redgem",
    "greengem",
    "bluegem",
    "purplegem",}

local function common_fn(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, .5)

    inst.DynamicShadow:SetSize(4, 1.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("leif")
    inst:AddTag("tree")
    inst:AddTag("evergreens")
    inst:AddTag("largecreature")
    inst:AddTag("pkc_hostile")
    inst:AddTag("pkc_hostile_boss")

    inst.AnimState:SetBank("leif")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local color = .5 + math.random() * .5
    inst.AnimState:SetMultColour(color, color, color, 1)

    ------------------------------------------

    inst.OnPreLoad = onpreloadfn
    inst.OnLoad = onloadfn
    inst.OnSave = onsavefn

    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5

    ------------------------------------------
    inst:SetStateGraph("pkc_SGleifking")

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    MakeLargeBurnableCharacter(inst, "marker")
    inst.components.burnable.flammability = TUNING.LEIF_FLAMMABILITY
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.propagator.acceptsheat = true

    MakeHugeFreezableCharacter(inst, "marker")
    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LEIF_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LEIF_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.LEIF_DAMAGE_PLAYER_PERCENT
    inst.components.combat.hiteffectsymbol = "marker"
    inst.components.combat:SetRange(3)
    inst.components.combat:SetAttackPeriod(TUNING.LEIF_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(keepTargetOverride)

    ------------------------------------------
    MakeHauntableIgnite(inst)
    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()
    ------------------------------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    inst.SetLeifScale = SetLeifScale

    return inst
end

local function _BasicWakeCheck(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
            or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
            or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
            or GetClosestInstWithTag("player", inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
            and inst:GetDistanceSqToPoint(homePos:Get()) < SLEEP_DIST_FROMHOME_SQ
            and not _BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil and
            inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
            or _BasicWakeCheck(inst)
end

local function onTimerDone(inst, data)
    if data.name == "Earthquake" then
        inst.canearthquake = true
    end
end

local function RememberKnownLocation(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function normal_fn()
    local mob = common_fn("leif_lumpy_build")
    local currentscale = mob.Transform:GetScale()
    mob.Transform:SetScale(currentscale*2,currentscale*2,currentscale*2)

    if mob.components.sleeper ~= nil then
        mob.components.sleeper:SetSleepTest(ShouldSleep)
        mob.components.sleeper:SetWakeTest(ShouldWake)
    end

    --血多厚
    mob.components.health:SetMaxHealth(LEIF_HEALTH)
    mob.components.health:StartRegen(200, 100)

    --战斗力强不强
    mob.components.combat:SetDefaultDamage(150)
    mob.components.combat:SetAttackPeriod(2.2)
    mob.components.combat:SetAreaDamage(2, 1)
    mob.components.combat:SetRange(4, 5)
    mob.components.locomotor.walkspeed= 2
    mob.components.locomotor.runspeed = 4

    function mob.components.combat:DoAreaAttack(target, range, weapon, validfn, stimuli)
        local hitcount = 0
        local x, y, z = target.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, range, { "_combat" }, {"pkc_hostile"})
        for i, ent in ipairs(ents) do
            if ent ~= target and
                    ent ~= self.inst and
                    self:IsValidTarget(ent) and
                    (validfn == nil or validfn(ent)) then
                self.inst:PushEvent("onareaattackother", { target = target, weapon = weapon, stimuli = stimuli })
                ent.components.combat:GetAttacked(self.inst, self:CalcDamage(ent, weapon, self.areahitdamagepercent), weapon, stimuli)
                hitcount = hitcount + 1
            end
        end
        return hitcount
    end

    --技能学了么
    mob:AddComponent("timer")
    mob.canearthquake = false
    mob:ListenForEvent("timerdone", onTimerDone)

    --回家
    mob:AddComponent("knownlocations")
    mob:DoTaskInTime(0, RememberKnownLocation)

    return mob
end

return Prefab("pkc_leifking", normal_fn, assets, prefabs)
