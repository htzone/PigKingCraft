--
-- pkc_bunnymanking
-- Author: RedPig
-- Date: 2021/2/4
--

local assets =
{
    Asset("ANIM", "anim/manrabbit_basic.zip"),
    Asset("ANIM", "anim/manrabbit_actions.zip"),
    Asset("ANIM", "anim/manrabbit_attacks.zip"),
    Asset("ANIM", "anim/manrabbit_build.zip"),
    Asset("ANIM", "anim/manrabbit_boat_jump.zip"),

    Asset("ANIM", "anim/manrabbit_beard_build.zip"),
    Asset("ANIM", "anim/manrabbit_beard_basic.zip"),
    Asset("ANIM", "anim/manrabbit_beard_actions.zip"),
    Asset("SOUND", "sound/bunnyman.fsb"),
}

local prefabs =
{
    "meat",
    "monstermeat",
    "manrabbit_tail",
    "beardhair",
    "carrot",
}

local beardlordloot = { "beardhair", "beardhair", "monstermeat", "eyeturret_item"}

local brain = require("brains/pkc_bunnykingbrain")

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function onsave(inst, data)
    data.isSecondState = inst.isSecondState
end

local function onload(inst, data)
    if data ~= nil then
        if data.isSecondState ~= nil then
            inst.isSecondState = data.isSecondState
        end
    end
end

local function OnHealthDelta1(inst, data)
    if inst.components.health:GetPercent() < .5 then
        if not inst.isSecondState then
            inst.sg:GoToState("taunt")
            inst.isSecondState = true
            inst.beardlord = true
            inst.AnimState:SetBuild("manrabbit_beard_build")

            local fx = SpawnPrefab("statue_transition_2")
            local x,y,z = inst.Transform:GetWorldPosition()
            fx.Transform:SetPosition(x, y, z)
            local currentscale = fx.Transform:GetScale()
            fx.Transform:SetScale(currentscale*4,currentscale*4,currentscale*4)

            inst.components.combat:SetDefaultDamage(90)
            inst.components.combat:SetAttackPeriod(2)
            inst.components.locomotor.walkspeed= 3
            inst.components.locomotor.runspeed = 5
        end
    else
        if inst.isSecondState then
            inst.isSecondState = false
            inst.beardlord = false
            inst.AnimState:SetBuild("manrabbit_build")

            local fx = SpawnPrefab("statue_transition")
            local x,y,z = inst.Transform:GetWorldPosition()
            fx.Transform:SetPosition(x, y+1, z)
            local currentscale = fx.Transform:GetScale()
            fx.Transform:SetScale(currentscale*2,currentscale*2,currentscale*2)

            inst.components.combat:SetDefaultDamage(70)
            inst.components.combat:SetAttackPeriod(2.2)
            inst.components.locomotor.walkspeed= 1
            inst.components.locomotor.runspeed = 2
        end
    end
end

local function IsCrazyGuy(guy)
    local sanity = guy ~= nil and guy.replica.sanity or nil
    return sanity ~= nil and sanity:IsInsanityMode() and sanity:GetPercentNetworked() <= (guy:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY)
end

local function ontalk(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/idle_med")
end

local function ClearBeardlord(inst)
    inst.clearbeardlordtask = nil
    inst.beardlord = nil
end

local function SetBeardLord(inst)
    inst.beardlord = true
    if inst.clearbeardlordtask ~= nil then
        inst.clearbeardlordtask:Cancel()
    end
    inst.clearbeardlordtask = inst:DoTaskInTime(5, ClearBeardlord)
end

local function CalcSanityAura(inst, observer)
    if IsCrazyGuy(observer) then
        SetBeardLord(inst)
        return -TUNING.SANITYAURA_MED
    end
    return inst.components.follower ~= nil
            and inst.components.follower:GetLeader() == observer
            and TUNING.SANITYAURA_SMALL
            or 0
end

local function ShouldAcceptItem(inst, item)
    return
    (   --accept all hats!
            item.components.equippable ~= nil and
                    item.components.equippable.equipslot == EQUIPSLOTS.HEAD
    ) or
            (   --accept food, but not too many carrots for loyalty!
                    inst.components.eater:CanEat(item) and
                            (   (item.prefab ~= "carrot" and item.prefab ~= "carrot_cooked") or
                                    inst.components.follower.leader == nil or
                                    inst.components.follower:GetLoyaltyPercent() <= .9
                            )
            )
end

local function OnGetItemFromPlayer(inst, giver, item)
    --I eat food
    if item.components.edible ~= nil then
        if (    item.prefab == "carrot" or
                item.prefab == "carrot_cooked"
        ) and
                item.components.inventoryitem ~= nil and
                (   --make sure it didn't drop due to pockets full
                        item.components.inventoryitem:GetGrandOwner() == inst or
                                --could be merged into a stack
                                (   not item:IsValid() and
                                        inst.components.inventory:FindItem(function(obj)
                                            return obj.prefab == item.prefab
                                                    and obj.components.stackable ~= nil
                                                    and obj.components.stackable:IsStack()
                                        end) ~= nil)
                ) then
            if inst.components.combat:TargetIs(giver) then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader ~= nil then
                if giver.components.minigame_participator == nil then
                    giver:PushEvent("makefriend")
                    giver.components.leader:AddFollower(inst)
                end
                inst.components.follower:AddLoyaltyTime(
                        giver:HasTag("polite")
                                and TUNING.RABBIT_CARROT_LOYALTY + TUNING.RABBIT_POLITENESS_LOYALTY_BONUS
                                or TUNING.RABBIT_CARROT_LOYALTY
                )
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
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude.prefab == inst.prefab end, MAX_TARGET_SHARES)
end

local function OnNewTarget(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude.prefab == inst.prefab end, MAX_TARGET_SHARES)
end

local function is_meat(item)
    return item.components.edible ~= nil and item.components.edible.foodtype == FOODTYPE.MEAT and not item:HasTag("smallcreature")
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
                if guy:HasTag("monster") or guy:HasTag("pkc_hostile")
                        or guy:HasTag("shadowboss") or guy:HasTag("playerghost") then
                    return false
                end
                return guy:HasTag("pkc_defences")
            end)
            or nil
end

local function NormalKeepTargetFn(inst, target)
    if target:HasTag("pkc_hostile") then
        return false
    end
    local homePos = inst.components.knownlocations and inst.components.knownlocations:GetLocation("home") or nil
    if homePos then
        return target:GetDistanceSqToPoint(homePos:Get()) < PKC_HOSTILE_BOSS_DEFENCE_MAX_DIST * PKC_HOSTILE_BOSS_DEFENCE_MAX_DIST
                and inst:GetDistanceSqToPoint(homePos:Get()) < PKC_HOSTILE_BOSS_DEFENCE_MAX_DIST * PKC_HOSTILE_BOSS_DEFENCE_MAX_DIST
    end
    return not (target.sg ~= nil and target.sg:HasStateTag("hiding")) and inst.components.combat:CanTarget(target)
end

local function giveupstring()
    return "RABBIT_GIVEUP", math.random(#STRINGS["RABBIT_GIVEUP"])
end

local function battlecry(combatcmp, target)
    local strtbl =
    target ~= nil and
            target.components.inventory ~= nil and
            target.components.inventory:FindItem(is_meat) ~= nil and
            "RABBIT_MEAT_BATTLECRY" or
            "RABBIT_BATTLECRY"
    return strtbl, math.random(#STRINGS[strtbl])
end

local function GetStatus(inst)
    return inst.components.follower.leader ~= nil and "FOLLOWER" or nil
end

local function LootSetupFunction(lootdropper)
    local guy = lootdropper.inst.causeofdeath
    if IsCrazyGuy(guy ~= nil and guy.components.follower ~= nil and guy.components.follower.leader or guy) then
        -- beard lord
        lootdropper:SetLoot(beardlordloot)
    else
        -- regular loot
        lootdropper:AddRandomLoot("carrot", 3)
        lootdropper:AddRandomLoot("meat", 3)
        lootdropper:AddRandomLoot("manrabbit_tail", 2)
        lootdropper.numrandomloot = 1
    end
end

local function onTimerDone(inst, data)
    if data.name == "Hypnosis" then
        inst.canhypnosis = true
    elseif data.name == "Lighting" then
        inst.canlighting = true
    end
end

local function RememberKnownLocation(inst)
    inst.homePos = inst:GetPosition()
    inst.components.knownlocations:RememberLocation("home", inst.homePos)
end

local loot = {
    "eyeturret_item",
    "eyeturret_item",
    "redgem",
    "redgem",
    "orangegem",
    "orangegem",
    "meat", "meat", "meat", "meat",
    "carrot", "carrot", "carrot", "carrot", "carrot", "carrot", "carrot", "carrot",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLightWatcher()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("manrabbit_build")

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst:AddTag("cavedweller")
    inst:AddTag("character")
    inst:AddTag("pig")
    inst:AddTag("manrabbit")
    inst:AddTag("scarytoprey")
    inst:AddTag("pkc_hostile")
    inst:AddTag("pkc_hostile_boss")
    inst:AddTag("monster")
    inst:AddTag("pkc_bunnymanking")

    inst.AnimState:SetBank("manrabbit")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("hat")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_ruins", "swap_hat")
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAT_HAIR")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")

    inst.AnimState:SetClientsideBuildOverride("insane", "manrabbit_build", "manrabbit_beard_build")

    inst:AddTag("_named")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 24
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -500, 0)
    inst.components.talker:MakeChatter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst.components.talker.ontalk = ontalk

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed= 1
    inst.components.locomotor.runspeed = 2

    -- boat hopping setup
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("bloomer")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    inst.components.eater:SetCanEatRaw()

    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "manrabbit_torso"
    inst.components.combat.panic_thresh = TUNING.BUNNYMAN_PANIC_THRESH
    inst.components.combat:SetDefaultDamage(100)
    inst.components.combat:SetAttackPeriod(TUNING.BUNNYMAN_ATTACK_PERIOD)
    inst.components.combat:SetAreaDamage(2.5, 1)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    --AOE伤害忽略队友
    function inst.components.combat:DoAreaAttack(target, range, weapon, validfn, stimuli)
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
    --inst.components.combat.GetBattleCryString = battlecry
    --inst.components.combat.GetGiveUpString = giveupstring
    --MakeMediumBurnableCharacter(inst, "manrabbit_torso")

    --叫什么
    inst:AddComponent("named")
    inst.components.named:SetName(BOSS_NAME.pkc_bunnymanking.NAME)

    ------------------------------------------
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(BUNNYMAN_KING_HEALTH)
    inst.components.health:StartRegen(500, 200)
    inst:ListenForEvent("healthdelta", OnHealthDelta1)

    ------------------------------------------

    inst:AddComponent("inventory")
    inst:AddComponent("leader")

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    --inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)
    --LootSetupFunction(inst.components.lootdropper)

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:DoTaskInTime(.1, RememberKnownLocation)
    ------------------------------------------

    --inst:AddComponent("trader")
    --inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    --inst.components.trader.onaccept = OnGetItemFromPlayer
    --inst.components.trader.onrefuse = OnRefuseItem
    --inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(function(inst) return false  end)
    inst.components.sleeper:SetWakeTest(function(inst) return true  end)
    --inst.components.sleeper:SetResistance(2)
    --inst.components.sleeper.sleeptestfn = NocturnalSleepTest
    --inst.components.sleeper.waketestfn = NocturnalWakeTest

    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    ------------------------------------------

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    --MakeHauntablePanic(inst)

    inst:SetBrain(brain)
    inst:SetStateGraph("pkc_SGbunnyking")

    --体格
    local currentscale = inst.Transform:GetScale()
    inst.Transform:SetScale(currentscale*2.5,currentscale*2.5,currentscale*2.5)

    --技能学了么
    inst:AddComponent("timer")
    inst.canhypnosis = false
    inst.canlighting = false
    inst.candodge = false
    inst:ListenForEvent("timerdone", onTimerDone)

    --长得咋样
    if inst.isSecondState then
        inst.AnimState:SetBuild("manrabbit_beard_build")
    else
        inst.AnimState:SetBuild("manrabbit_build")
    end

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("pkc_bunnymanking", fn, assets, prefabs)
