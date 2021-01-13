--
-- 重写猪脑子
-- Author: RedPig
-- Date: 2017/03/04
--

require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
--require "behaviours/choptree"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"

local BrainCommon = require "brains/braincommon"

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 7
local MAX_WANDER_DIST = 15

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 15

local START_RUN_DIST = 2
local STOP_RUN_DIST = 3
local MAX_CHASE_TIME = 6
local MAX_CHASE_DIST = 12
local SEE_LIGHT_DIST = 20
local TRADE_DIST = 20
local SEE_TREE_DIST = 15
local SEE_TARGET_DIST = 30
local SEE_FOOD_DIST = 10

local SEE_BURNING_HOME_DIST_SQ = 20*20

local COMFORT_LIGHT_LEVEL = 0.3

local KEEP_CHOPPING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

--猪人能看到箱子的最大距离
local SEE_CHEST_DIST = 30
--猪人能看到地上物品的最大距离
local SEE_GROUND_ITEM_DIST = 6
--猪人采集的最大距离
local SEE_HARVEST_ITEM_DIST = 15

local function ShouldRunAway(inst, target)
    return not inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetTraderFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for i, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then
            return v
        end
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function FindFoodAction(inst)
    local target = nil

    if inst.sg:HasStateTag("busy") then
        return
    end

    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end

    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    local noveggie = time_since_eat and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD*4

    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) 
                if item:GetTimeAlive() < 8 then return false end
                if item.prefab == "mandrake" then return false end
                if noveggie and item.components.edible and item.components.edible.foodtype ~= FOODTYPE.MEAT then
                    return false
                end
                if not item:IsOnValidGround() then
                    return false
                end
                return inst.components.eater:CanEat(item)
            end)
    end
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) 
                if not item.components.shelf then return false end
                if not item.components.shelf.itemonshelf or not item.components.shelf.cantakeitem then return false end
                if noveggie and item.components.shelf.itemonshelf.components.edible and item.components.shelf.itemonshelf.components.edible.foodtype ~= FOODTYPE.MEAT then
                    return false
                end
                if not item:IsOnValidGround() then
                    return false
                end
                return inst.components.eater:CanEat(item.components.shelf.itemonshelf) 
            end)
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end
end

local function IsDeciduousTreeMonster(guy)
    return guy.monster and guy.prefab == "deciduoustree"
end

local function FindDeciduousTreeMonster(inst)
    return FindEntity(inst, SEE_TREE_DIST / 3, IsDeciduousTreeMonster, { "CHOP_workable" })
end

local function KeepChoppingAction(inst)
    return inst.tree_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst:IsNear(inst.components.follower.leader, KEEP_CHOPPING_DIST))
        or FindDeciduousTreeMonster(inst) ~= nil
end

local function StartChoppingCondition(inst)
    return inst.tree_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst.components.follower.leader.sg ~= nil and
            inst.components.follower.leader.sg:HasStateTag("chopping"))
        or FindDeciduousTreeMonster(inst) ~= nil
end

local function StartPikUpCondition(inst)
    return inst.components.follower.leader ~= nil and
            inst.components.follower.leader.sg ~= nil and
            inst.components.follower.leader.sg:HasStateTag("chopping")
            or FindDeciduousTreeMonster(inst) ~= nil
end

local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, nil, { "CHOP_workable" })
    if target ~= nil then
        if inst.tree_target ~= nil then
            target = inst.tree_target
            inst.tree_target = nil
        else
            target = FindDeciduousTreeMonster(inst) or target
        end
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end
end

local function HasValidHome(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home ~= nil
        and home:IsValid()
        and not (home.components.burnable ~= nil and home.components.burnable:IsBurning())
        and not home:HasTag("burnt")
end

local function GoHomeAction(inst)
    if not inst.components.follower.leader and
        HasValidHome(inst) and
        not inst.components.combat.target then
            return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local function GetNoLeaderHomePos(inst)
    if GetLeader(inst) then
        return nil
    end
    return GetHomePos(inst)
end

local function GetNearestLightPos(inst)
    local light = GetClosestInstWithTag("lightsource", inst, SEE_LIGHT_DIST)
    if light then
        return Vector3(light.Transform:GetWorldPosition())
    end
    return nil
end

local function GetNearestLightRadius(inst)
    local light = GetClosestInstWithTag("lightsource", inst, SEE_LIGHT_DIST)
    if light then
        return light.Light:GetCalculatedRadius()
    end
    return 1
end

local function RescueLeaderAction(inst)
    return BufferedAction(inst, GetLeader(inst), ACTIONS.UNPIN)
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function SafeLightDist(inst, target)
    return (target:HasTag("player") or target:HasTag("playerlight")
            or (target.inventoryitem and target.inventoryitem:GetGrandOwner() and target.inventoryitem:GetGrandOwner():HasTag("player")))
        and 4
        or target.Light:GetCalculatedRadius() / 3
end

local function IsHomeOnFire(inst)
    return inst.components.homeseeker
        and inst.components.homeseeker.home
        and inst.components.homeseeker.home.components.burnable
        and inst.components.homeseeker.home.components.burnable:IsBurning()
        and inst:GetDistanceSqToInst(inst.components.homeseeker.home) < SEE_BURNING_HOME_DIST_SQ
end

--找附近的箱子
local function findChest(inst)
    local chestTarget = FindEntity(inst, SEE_CHEST_DIST, function(item)
        return item and item:HasTag("chest") and item:HasTag("structure")
                and item.components.container and not item.components.container:IsFull()
                and item.pkc_group_id == inst.components.pkc_group:getChooseGroup()
    end)
    return chestTarget
end

--捡扔地上的东西
local function FindGroundItemAction(inst)
    if not inst or inst.sg:HasStateTag("busy") or not inst.components.pkc_group then
        return
    end
    --找附近有没有不是满的容器或箱子(本队的)
    local chestTarget = findChest(inst)
    --没有箱子则不执行捡东西的操作
    if not chestTarget then
        return
    end
    --附近有箱子才捡地上的东西
    local itemTarget = FindEntity(inst, SEE_GROUND_ITEM_DIST, function(item)
        if not item:IsOnValidGround() then
            return false
        end
        --找物品栏能装下的东西
        local inventoryItem = item.components.inventoryitem
        if inventoryItem then
            --且不能是小切
            if item.prefab == "chester_eyebone" then
                return false
            end
            --且不能是有容器的
            if inventoryItem:GetContainer() ~= nil then
                return false
            end
            --且不能是活的会动的
            if item.components.health ~= nil or item.components.locomotor ~= nil then
                return false
            end
            --且不能是可以吃的
            if inst and inst.components.eater and inst.components.eater:CanEat(item) then
                return false
            end
            --且不能搬重物
            if item:HasTag("heavy") then
                return false
            end
            return true
        end
    end)
    --目标不能是着火的
    if itemTarget and not itemTarget:HasTag("fire") and not itemTarget:HasTag("burnt") then
        local act = BufferedAction(inst, itemTarget, ACTIONS.PICKUP)
        return act
    end
end

--物品栏不为空
local function isInventoryNotEmpty(inventory)
    for k = 1, inventory.maxslots do
        if inventory.itemslots[k] then
            return true
        end
    end
    return false
end

--找箱子把东西放进去
local function FindContainerAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local inventory = inst.components.inventory
    if not inventory then
        return
    end
    --物品栏不为空则把东西放箱子里
    if isInventoryNotEmpty(inventory) then
        local target = findChest(inst)
        if target and not target:HasTag("fire") and not target:HasTag("burnt") then
            inst.give_chest_target = target
            local act = BufferedAction(inst, target, ACTIONS.GIVE)
            if act then
                act:AddSuccessAction(function()
                end)
                act:AddFailAction(function()
                end)
            end
            return act
        end
    end
end

--找采集的东西
local function FindThingsToHarvestAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    local target = FindEntity(inst, SEE_HARVEST_ITEM_DIST, function(item)
        return item.components.pickable and item.components.pickable:CanBePicked()
                and item:HasTag("plant") and item:HasTag("renewable")
    end)

    if target and target.components.pickable then
        inst.pkc_harvest_target = target
        local act = BufferedAction(inst, target, ACTIONS.PICKUP)
        return act
    end
end

local PigBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function PigBrain:OnStart()
    --print(self.inst, "PigBrain:OnStart")
    --白天的行为树
    local day = WhileNode( function() return not TheWorld.state.isnight end, "IsDay",
        PriorityNode{
            --找食物
            ChattyNode(self.inst, "PIG_TALK_FIND_MEAT", DoAction(self.inst, FindFoodAction )),
            --帮忙砍树
            IfNode(function() return StartChoppingCondition(self.inst) end, "chop",
                WhileNode(function() return KeepChoppingAction(self.inst) end, "keep chopping",
                    LoopNode{ 
                        ChattyNode(self.inst, "PIG_TALK_HELP_CHOP_WOOD", DoAction(self.inst, FindTreeToChopAction ))})),
            --帮忙采集
            --ChattyNode(self.inst, "PIG_TALK_HELP_CHOP_WOOD", DoAction(self.inst, FindThingsToHarvestAction )),
            --IfNode(function() return StartChoppingCondition(self.inst) end, "chop",
            --        WhileNode(function() return KeepChoppingAction(self.inst) end, "keep chopping",
            --                LoopNode{
            --                    ChattyNode(self.inst, "PIG_TALK_HELP_CHOP_WOOD", DoAction(self.inst, FindTreeToChopAction ))})),
            --跟随主人
            ChattyNode(self.inst, "PIG_TALK_FOLLOWWILSON",
                Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
            --面朝主人
            IfNode(function() return GetLeader(self.inst) end, "has leader",
                ChattyNode(self.inst, "PIG_TALK_FOLLOWWILSON",
                    FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn ))),
            --在家附近徘徊
            Leash(self.inst, GetNoLeaderHomePos, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            --把身上的东西放箱子里
            ChattyNode(self.inst, "PIG_TALK_FIND_GROUND_ITEM", DoAction(self.inst, FindContainerAction )),
            --找掉地上的东西
            ChattyNode(self.inst, "PIG_TALK_FIND_GROUND_ITEM", DoAction(self.inst, FindGroundItemAction )),
            --与玩家保持距离
            ChattyNode(self.inst, "PIG_TALK_RUNAWAY_WILSON",
                RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST)),
            --面朝玩家
            ChattyNode(self.inst, "PIG_TALK_LOOKATWILSON",
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
            --发呆
            Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST)
        }, .5)

    --晚上的行为树
    local night = WhileNode( function() return TheWorld.state.isnight end, "IsNight",
        PriorityNode{
            --逃离蜘蛛
            ChattyNode(self.inst, "PIG_TALK_RUN_FROM_SPIDER", RunAway(self.inst, "spider", 4, 8)),
            --找食物
            ChattyNode(self.inst, "PIG_TALK_FIND_MEAT", DoAction(self.inst, FindFoodAction )),
            --与玩家保持距离，除非玩家给自己东西
            RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST, function(target) return ShouldRunAway(self.inst, target) end ),
            --回家
            ChattyNode(self.inst, "PIG_TALK_GO_HOME",
                WhileNode( function() return not TheWorld.state.iscaveday or not self.inst.LightWatcher:IsInLight() end, "Cave nightness",
                    DoAction(self.inst, GoHomeAction, "go home", true ))),
            --当光线足够亮时站着发呆
            WhileNode(function() return TheWorld.state.isnight and self.inst.LightWatcher:GetLightValue() > COMFORT_LIGHT_LEVEL end, "IsInLight", -- wants slightly brighter light for this
                Wander(self.inst, GetNearestLightPos, GetNearestLightRadius, {
                    minwalktime = 0.6,
                    randwalktime = 0.2,
                    minwaittime = 5,
                    randwaittime = 5
                })
            ),
            --寻找光源
            ChattyNode(self.inst, "PIG_TALK_FIND_LIGHT",
                FindLight(self.inst, SEE_LIGHT_DIST, SafeLightDist)),
            --受到攻击时
            ChattyNode(self.inst, "PIG_TALK_PANIC",
                Panic(self.inst)),
        }, 1)

    --公共的行为
    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .25, "PIG_TALK_PANICBOSS"),
            --被作祟
            WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted",
                ChattyNode(self.inst, "PIG_TALK_PANICHAUNT",
                    Panic(self.inst))),
            --着火
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
                ChattyNode(self.inst, "PIG_TALK_PANICFIRE",
                    Panic(self.inst))),
            --追打
            ChattyNode(self.inst, "PIG_TALK_FIGHT",
                WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                    ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) )),
            --解救主人
            ChattyNode(self.inst, "PIG_TALK_RESCUE",
                WhileNode( function() return GetLeader(self.inst) and GetLeader(self.inst).components.pinnable and GetLeader(self.inst).components.pinnable:IsStuck() end, "Leader Phlegmed",
                    DoAction(self.inst, RescueLeaderAction, "Rescue Leader", true) )),
            --闪避
            ChattyNode(self.inst, "PIG_TALK_FIGHT",
                WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                    RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) )),
            --家着火
            WhileNode(function() return IsHomeOnFire(self.inst) end, "OnFire",
                ChattyNode(self.inst, "PIG_TALK_PANICHOUSEFIRE",
                    Panic(self.inst))),
            --逃跑
            RunAway(self.inst, function(guy) return guy:HasTag("pig") and guy.components.combat and guy.components.combat.target == self.inst end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST ),
            --玩家给东西时
            ChattyNode(self.inst, "PIG_TALK_ATTEMPT_TRADE",
                FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),
            day, --白天的行为
            night, --晚上的行为
        }, .5)

    self.bt = BT(self.inst, root)
end

return PigBrain
