--
-- 快速采集（服务端）
-- Author: 大猪猪
-- Date: 2016/10/23
--

----全局变量声明
local _G = GLOBAL
local TimeEvent = _G.TimeEvent
local FRAMES = _G.FRAMES
local EQUIPSLOTS = _G.EQUIPSLOTS
local EventHandler = _G.EventHandler
local GetWorld = _G.GetWorld
local SpawnPrefab = _G.SpawnPrefab
local State = _G.State
local DEGREES = _G.DEGREES
local Vector3 = _G.Vector3
local STRINGS = _G.STRINGS
local ACTIONS = _G.ACTIONS
local FOODTYPE = _G.FOODTYPE

local fast_do = true
local fast_eat = true

AddStategraphPostInit("wilson", function(sg)

    --长动作变短动作
    if fast_do then

        --长动作改进
        local state_dolongaction = sg.states["dolongaction"]
        state_dolongaction.onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(5 * FRAMES)
        end
        state_dolongaction.timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        }
        state_dolongaction.ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end
        state_dolongaction.onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end
        state_dolongaction.events =
        {

        }

        --短动作改进
        local state_doshortaction = sg.states["doshortaction"]
        state_doshortaction.onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(5 * FRAMES)
        end
        state_doshortaction.timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        }
        state_doshortaction.ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end
        state_doshortaction.onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end
        state_doshortaction.events =
        {

        }

    end

    --吃变快吃
    if fast_eat then

        local state_eat = sg.states["eat"]
        state_eat.onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()
            local feed = foodinfo and foodinfo.feed
            if feed ~= nil then
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                inst.sg.statemem.feed = foodinfo.feed
                inst.sg.statemem.feeder = foodinfo.feeder
                inst.sg:AddStateTag("pausepredict")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction()
                end
            elseif inst:GetBufferedAction() then
                feed = inst:GetBufferedAction().invobject
            end
            if feed == nil or
                    feed.components.edible == nil or
                    feed.components.edible.foodtype ~= FOODTYPE.GEARS then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            end
            inst.AnimState:PlayAnimation("quick_eat_pre")
            inst.AnimState:PushAnimation("quick_eat", false)
            inst.components.hunger:Pause()
        end
        state_eat.timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.feed ~= nil then
                    inst.components.eater:Eat(inst.sg.statemem.feed, inst.sg.statemem.feeder)
                else
                    inst:PerformBufferedAction()
                end
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        }
        state_eat.events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        }
        state_eat.onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
            inst.components.hunger:Resume()
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
        end

    end

    ----砍树,挖矿,砸, 铲,给于等的延迟消除

--    local action_chop = sg.actionhandlers[ACTIONS.CHOP]
--    action_chop.deststate = function(inst)
--        if inst:HasTag("beaver") then
--            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
--        end
--        return not inst.sg:HasStateTag("prechop") and "chop" or nil
--    end

    local action_mine = sg.actionhandlers[ACTIONS.MINE]
    action_mine.deststate = function(inst)
        if inst:HasTag("beaver") then
            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
        end
        return not inst.sg:HasStateTag("premine") and "mine" or nil
    end

--    local action_hammer = sg.actionhandlers[ACTIONS.HAMMER]
--    action_hammer.deststate = function(inst)
--        if inst:HasTag("beaver") then
--            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
--        end
--        return not inst.sg:HasStateTag("prehammer") and "hammer" or nil
--    end

--    local action_dig = sg.actionhandlers[ACTIONS.DIG]
--    action_dig.deststate = function(inst)
--        if inst:HasTag("beaver") then
--            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
--        end
--        return "dig" or nil
--    end

    local state_give = sg.states["give"]
    state_give.onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("give")
        inst.sg:SetTimeout(5*FRAMES)
    end
    state_give.timeline =
    {
        TimeEvent(2*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
    }
    state_give.events =
    {

    }
    state_give.ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end

    --叉地皮延迟消除
--    local state_terraform = sg.states["terraform"]
--    state_terraform.onenter = function(inst)
--        inst.components.locomotor:Stop()
--        inst.AnimState:PlayAnimation("shovel_loop", false)
--        inst.sg:SetTimeout(10*FRAMES)
--    end
--    state_terraform.timeline =
--    {
--        TimeEvent(8 * FRAMES, function(inst)
--            inst:PerformBufferedAction()
--            inst.sg:RemoveStateTag("busy")
--            inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
--        end),
--    }
--    state_terraform.events =
--    {
--        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
--    }
--    state_terraform.ontimeout = function(inst)
--        inst.sg:GoToState("idle")
--    end

end)











