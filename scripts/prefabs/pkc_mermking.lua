--
-- pkc_mermking
-- Author: RedPig
-- Date: 2021/2/5
--

local assets =
{
    Asset("ANIM", "anim/merm_build.zip"),
    Asset("ANIM", "anim/merm_guard_build.zip"),
    Asset("ANIM", "anim/merm_guard_small_build.zip"),
    Asset("ANIM", "anim/merm_actions.zip"),
    Asset("ANIM", "anim/merm_guard_transformation.zip"),
    Asset("ANIM", "anim/ds_pig_boat_jump.zip"),
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("SOUND", "sound/merm.fsb"),
}

local prefabs =
{
    "pondfish",
    "froglegs",
    "mermking",
    "merm_splash",
    "merm_spawn_fx",
}

local merm_guard_loot =
{
    "pondfish","pondfish", "pondfish","pondfish",
    "froglegs","froglegs","froglegs","froglegs",
    "eyeturret_item",
    "eyeturret_item",
    "bluegem",
    "bluegem",
    "bluegem",
    "bluegem",
}

local sounds_guard = {
    attack = "dontstarve/characters/wurt/merm/warrior/attack",
    hit = "dontstarve/characters/wurt/merm/warrior/hit",
    death = "dontstarve/characters/wurt/merm/warrior/death",
    talk = "dontstarve/characters/wurt/merm/warrior/talk",
    buff = "dontstarve/characters/wurt/merm/warrior/yell",
    --debuff = ,
}

local merm_guard_brain = require "brains/pkc_mermkingbrain"
local SLEEP_DIST_FROMTHREAT = 20
local SLEEP_DIST_FROMHOME_SQ = 1 * 1

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

local function RememberKnownLocation(inst)
    if not inst.isSetHome then
        inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
        inst.isSetHome = true
    end
end

local function onTimerDone(inst, data)
    if data.name == "Freezing" then
        inst.canfreezing = true
    elseif data.name == "Togglestate" then
        if not inst.cantogglestate then
            inst.cantogglestate = true
            inst.components.combat:SetDefaultDamage(70)
            inst.components.combat:SetAttackPeriod(0.7)
            inst.components.combat:SetRange(12, 14)
        else
            inst.cantogglestate = false
            inst.components.combat:SetDefaultDamage(70)
            inst.components.combat:SetAttackPeriod(2.5)
            inst.components.combat:SetRange(3, 4)
        end
        --print("toggle!!!! ")
        if not (inst.components.timer:TimerExists("Togglestate")) then
            --print("start timer!!!")
            inst.components.timer:StartTimer("Togglestate", MERM_TOGGLE_COOLDOWN)
        end
    end
end

--鱼鱼远程冰冻
local function MakeWeapon(inst)
    if inst.components.inventory ~= nil then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        MakeInventoryPhysics(weapon)
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(50)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange + 2)
        --weapon.components.weapon:SetRange(10,14)
        weapon.components.weapon:SetProjectile("ice")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
        weapon:AddComponent("equippable")
        inst.weapon = weapon
        inst.components.inventory:Equip(inst.weapon)
        inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)

    end
end

local function NormalRetargetFn(inst)
    return not inst:IsInLimbo()
            and FindEntity(inst, 20, function(guy)
        if guy:HasTag("player") then
            return true
        end
        if guy.components.follower and guy.components.follower.leader
                and guy.components.follower.leader:HasTag("player") then
            return true
        end
        --not obj:HasTag("merm") and not obj:HasTag("tentacle")
        if guy:HasTag("monster") or guy:HasTag("pkc_hostile")
                or guy:HasTag("shadowboss") or guy:HasTag("playerghost") or guy:HasTag("mermguard")
                or guy:HasTag("merm") or guy:HasTag("tentacle")
        then
            return false
        end
        return guy:HasTag("pkc_defences")
    end)
            or nil
end

local function KeepTargetFn(inst, target)
    if target:HasTag("pkc_hostile") then
        return false
    end
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home then
        return home:GetDistanceSqToInst(target) < 50*50
                and home:GetDistanceSqToInst(inst) < 50*50
    end
    return inst.components.combat:CanTarget(target)
end

local DECIDROOTTARGET_MUST_TAGS = { "_combat", "_health", "merm" }
local DECIDROOTTARGET_CANT_TAGS = { "INLIMBO" }

local function OnAttackedByDecidRoot(inst, attacker)
    local share_target_dist = inst:HasTag("mermguard") and TUNING.MERM_GUARD_SHARE_TARGET_DIST or TUNING.MERM_SHARE_TARGET_DIST
    local max_target_shares = inst:HasTag("mermguard") and TUNING.MERM_GUARD_MAX_TARGET_SHARES or TUNING.MERM_MAX_TARGET_SHARES

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SpringCombatMod(share_target_dist) * .5, DECIDROOTTARGET_MUST_TAGS, DECIDROOTTARGET_CANT_TAGS)
    local num_helpers = 0

    for i, v in ipairs(ents) do
        if v ~= inst and not v.components.health:IsDead() then
            v:PushEvent("suggest_tree_target", { tree = attacker })
            num_helpers = num_helpers + 1
            if num_helpers >= max_target_shares then
                break
            end
        end
    end
end

local function OnAttacked(inst, data)

    local attacker = data and data.attacker
    if attacker and attacker.prefab == "deciduous_root" and attacker.owner ~= nil then
        OnAttackedByDecidRoot(inst, attacker.owner)

    elseif attacker and inst.components.combat:CanTarget(attacker) and attacker.prefab ~= "deciduous_root" then

        local share_target_dist = inst:HasTag("mermguard") and TUNING.MERM_GUARD_SHARE_TARGET_DIST or TUNING.MERM_SHARE_TARGET_DIST
        local max_target_shares = inst:HasTag("mermguard") and TUNING.MERM_GUARD_MAX_TARGET_SHARES or TUNING.MERM_MAX_TARGET_SHARES

        inst.components.combat:SetTarget(attacker)

        if inst.components.homeseeker and inst.components.homeseeker.home then
            local home = inst.components.homeseeker.home

            if home and home.components.childspawner and inst:GetDistanceSqToInst(home) <= share_target_dist*share_target_dist then
                max_target_shares = max_target_shares - home.components.childspawner.childreninside
                home.components.childspawner:ReleaseAllChildren(attacker)
            end

            inst.components.combat:ShareTarget(attacker, share_target_dist, function(dude)
                return (dude.components.homeseeker and dude.components.homeseeker.home and dude.components.homeseeker.home == home) or
                        (dude:HasTag("merm") and not dude:HasTag("player") and not
                        (dude.components.follower and dude.components.follower.leader and dude.components.follower.leader:HasTag("player")))
            end, max_target_shares)
        end
    end
end

local function IsAbleToAccept(inst, item, giver)
    if inst.components.health ~= nil and inst.components.health:IsDead() then
        return false, "DEAD"
    elseif inst.sg ~= nil and inst.sg:HasStateTag("busy") then
        if inst.sg:HasStateTag("sleeping") then
            return true
        end
        return false, "BUSY"
    end
    return true
end

local function ShouldAcceptItem(inst, item, giver)
    if inst:HasTag("mermguard") and inst.king ~= nil then
        return false
    end

    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end

    return (giver:HasTag("merm") and not (inst:HasTag("mermguard") and giver:HasTag("mermdisguise"))) and
            ((item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD) or
                    (item.components.edible and inst.components.eater:CanEat(item)) or
                    (item:HasTag("fish") and not (TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:IsCandidate(inst))))
end

local function OnGetItemFromPlayer(inst, giver, item)

    local loyalty_max = inst:HasTag("mermguard") and TUNING.MERM_GUARD_LOYALTY_MAXTIME or TUNING.MERM_LOYALTY_MAXTIME
    local loyalty_per_hunger = inst:HasTag("mermguard") and TUNING.MERM_GUARD_LOYALTY_PER_HUNGER or TUNING.MERM_LOYALTY_PER_HUNGER

    if item.components.edible ~= nil then
        if inst.components.combat:TargetIs(giver) then
            inst.components.combat:SetTarget(nil)
        elseif giver.components.leader ~= nil and not (TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:IsCandidate(inst)) then
            giver:PushEvent("makefriend")
            giver.components.leader:AddFollower(inst)

            inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * loyalty_per_hunger)
            inst.components.follower.maxfollowtime = loyalty_max
        end
    end

    -- I also wear hats
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current ~= nil then
            inst.components.inventory:DropItem(current)
        end
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")

    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function SuggestTreeTarget(inst, data)
    local ba = inst:GetBufferedAction()
    if data ~= nil and data.tree ~= nil and (ba == nil or ba.action ~= ACTIONS.CHOP) then
        inst.tree_target = data.tree
    end
end

local function ResolveMermChatter(inst, strid, strtbl)

    local stringtable = STRINGS[strtbl:value()]
    if stringtable then
        if stringtable[strid:value()] ~= nil then
            if ThePlayer and ThePlayer:HasTag("mermfluent") then
                return stringtable[strid:value()][1] -- First value is always the translated one
            else
                return stringtable[strid:value()][2]
            end
        end
    end

end

local function ShouldGuardSleep(inst)
    return false
end

local function ShouldGuardWakeUp(inst)
    return true
end

local function OnTimerDone(inst, data)
    if data.name == "facetime" then
        inst.components.timer:StartTimer("dontfacetime", 10)
    end
end

local function battlecry(combatcmp, target)
    local strtbl =
    combatcmp.inst:HasTag("guard") and
            "MERM_BATTLECRY" or
            "MERM_BATTLECRY"
    return strtbl, math.random(#STRINGS[strtbl])
end

local function MakeMerm(name, assets, prefabs, common_postinit, master_postinit)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        MakeCharacterPhysics(inst, 50, .5)

        inst.DynamicShadow:SetSize(1.5, .75)
        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("pigman")
        inst.AnimState:Hide("hat")

        inst:AddTag("character")
        inst:AddTag("merm")
        inst:AddTag("wet")
        inst:AddTag("pkc_hostile")
        inst:AddTag("pkc_hostile_boss")
        inst:AddTag("monster")
        inst:AddTag("_named")
        inst:AddTag("pkc_mermking")

        inst:AddComponent("talker")
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
        inst.components.talker.offset = Vector3(0, -400, 0)
        inst.components.talker.resolvechatterfn = ResolveMermChatter
        inst.components.talker:MakeChatter()

        if common_postinit ~= nil then
            common_postinit(inst)
        end
        inst:RemoveTag("_named")
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor")
        -- boat hopping setup
        inst.components.locomotor:SetAllowPlatformHopping(true)
        inst.components.locomotor.walkspeed= 1
        inst.components.locomotor.runspeed = 2

        inst:AddComponent("embarker")
        inst:AddComponent("drownable")

        inst:AddComponent("eater")
        inst.components.eater:SetDiet({ FOODGROUP.VEGETARIAN }, { FOODGROUP.VEGETARIAN })

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(MERM_HEALTH)
        inst.components.health:StartRegen(200, 100)

        inst:AddComponent("combat")
        inst.components.combat.GetBattleCryString = battlecry
        inst.components.combat.hiteffectsymbol = "pig_torso"
        inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        inst.components.combat:SetDefaultDamage(100)
        inst.components.combat:SetAttackPeriod(2)
        inst.components.combat:SetRange(12, 14) --第一个参数为攻击距离，第二个为能够击中的距离

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(merm_guard_loot)

        inst:AddComponent("inventory")
        inst:AddComponent("inspectable")
        inst:AddComponent("knownlocations")
        inst:AddComponent("follower")
        inst:AddComponent("leader")

        inst:AddComponent("sleeper")

        inst:AddComponent("mermcandidate")

        inst:AddComponent("timer")

        inst:AddComponent("trader")
        inst.components.trader:SetAcceptTest(ShouldAcceptItem)
        inst.components.trader:SetAbleToAcceptTest(IsAbleToAccept)
        inst.components.trader.onaccept = OnGetItemFromPlayer
        inst.components.trader.onrefuse = OnRefuseItem
        inst.components.trader.deleteitemonaccept = false

        --叫什么
        inst:AddComponent("named")
        inst.components.named:SetName(BOSS_NAME.pkc_mermking.NAME)

        MakeMediumBurnableCharacter(inst, "pig_torso")
        MakeMediumFreezableCharacter(inst, "pig_torso")

        inst:ListenForEvent("timerdone", OnTimerDone)
        inst:ListenForEvent("attacked", OnAttacked)
        inst:ListenForEvent("suggest_tree_target", SuggestTreeTarget)

        inst.AnimState:OverrideSymbol("swap_hat", "hat_ruins", "swap_hat")
        inst.AnimState:Show("HAT")
        inst.AnimState:Show("HAT_HAIR")
        inst.AnimState:Hide("HAIR_NOHAT")
        inst.AnimState:Hide("HAIR")
        --体格
        local currentscale = inst.Transform:GetScale()
        inst.Transform:SetScale(currentscale*3,currentscale*3,currentscale*3)

        --技能学了么
        inst.canfreezing = false
        inst.cantogglestate = false
        inst:ListenForEvent("timerdone", onTimerDone)

        MakeWeapon(inst)
        inst:DoTaskInTime(0, RememberKnownLocation)

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function guard_common(inst)
    inst.AnimState:SetBuild("merm_guard_build")
    inst:AddTag("mermguard")
    inst.Transform:SetScale(1, 1, 1)
    inst:AddTag("guard")

    inst.sounds = sounds_guard
end

local function guard_master(inst)
    inst:SetStateGraph("pkc_SGmermking")
    inst:SetBrain(merm_guard_brain)
    inst.components.follower.maxfollowtime = TUNING.MERM_GUARD_LOYALTY_MAXTIME
    --睡不睡觉啊
    if inst.components.sleeper ~= nil then
        inst.components.sleeper:SetSleepTest(ShouldSleep)
        inst.components.sleeper:SetWakeTest(ShouldWake)
    end
end

return MakeMerm("pkc_mermking", assets, prefabs, guard_common, guard_master)