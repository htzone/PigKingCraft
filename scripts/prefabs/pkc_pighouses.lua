--
-- 重写猪人房
-- Author: RedPig
-- Date: 2017/03/20
--

require "prefabutil"
require "recipes"

local assets =
{
    Asset("ANIM", "anim/pig_house.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "pigman",
}

--Client update
local function OnUpdateWindow(window, inst, snow)
    if inst:HasTag("burnt") then
        inst._windowsnow = nil
        inst._window = nil
        snow:Remove()
        window:Remove()
    elseif inst.Light:IsEnabled() and inst.AnimState:IsCurrentAnimation("lit") then
        if not window._shown then
            window._shown = true
            window:Show()
            snow:Show()
        end
    elseif window._shown then
        window._shown = false
        window:Hide()
        snow:Hide()
    end
end

local function LightsOn(inst)
    if not inst:HasTag("burnt") and not inst.lightson then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true
        if inst._window ~= nil then
            inst._window.AnimState:PlayAnimation("windowlight_idle", true)
            inst._window:Show()
        end
        if inst._windowsnow ~= nil then
            inst._windowsnow.AnimState:PlayAnimation("windowsnow_idle", true)
            inst._windowsnow:Show()
        end
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") and inst.lightson then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
        if inst._window ~= nil then
            inst._window:Hide()
        end
        if inst._windowsnow ~= nil then
            inst._windowsnow:Hide()
        end
    end
end

local function onfar(inst)
    if not inst:HasTag("burnt") and inst.components.spawner:IsOccupied() then
        LightsOn(inst)
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.spawner ~= nil and
            inst.components.spawner:IsOccupied() and
            (inst.lightson and "FULL" or "LIGHTSOUT"))
        or nil
end

local function onnear(inst)
    if not inst:HasTag("burnt") and inst.components.spawner:IsOccupied() then
        LightsOff(inst)
    end
end

local function onwere(child)
    if child.parent ~= nil and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent ~= nil and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
    end
end

local function onoccupieddoortask(inst)
    inst.doortask = nil
    if not inst.components.playerprox:IsPlayerClose() then
        LightsOn(inst)
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then 
        inst.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1, onoccupieddoortask)
        if child ~= nil then
            inst:ListenForEvent("transformwere", onwere, child)
            inst:ListenForEvent("transformnormal", onnormal, child)
        end
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.doortask ~= nil then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        inst.SoundEmitter:KillSound("pigsound")
        LightsOff(inst)

        if child ~= nil then
            inst:RemoveEventCallback("transformwere", onwere, child)
            inst:RemoveEventCallback("transformnormal", onnormal, child)
            if child.components.werebeast ~= nil then
                child.components.werebeast:ResetTriggers()
            end
            if child.components.health ~= nil then
                child.components.health:SetPercent(1)
            end
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        inst.components.spawner:ReleaseChild()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then 
        inst.AnimState:PlayAnimation("hit")
        if inst.lightson then
            inst.AnimState:PushAnimation("lit")
            if inst._window ~= nil then
                inst._window.AnimState:PlayAnimation("windowlight_hit")
                inst._window.AnimState:PushAnimation("windowlight_idle")
            end
            if inst._windowsnow ~= nil then
                inst._windowsnow.AnimState:PlayAnimation("windowsnow_hit")
                inst._windowsnow.AnimState:PushAnimation("windowsnow_idle")
            end
        else
            inst.AnimState:PushAnimation("idle")
        end
    end
end

local function onstartdaydoortask(inst)
    inst.doortask = nil
    if not inst:HasTag("burnt") then
        inst.components.spawner:ReleaseChild()
    end
end

local function onstartdaylighttask(inst)
    if inst.LightWatcher:GetLightValue() > 0.8 then -- they have their own light! make sure it's brighter than that out.
        LightsOff(inst)
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaydoortask)
    elseif TheWorld.state.iscaveday then
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    else
        inst.doortask = nil
    end
end

local function OnStartDay(inst)
    --print(inst, "OnStartDay")
    if not inst:HasTag("burnt")
        and inst.components.spawner:IsOccupied() then

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function onburntup(inst)
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
    if inst._window ~= nil then
        inst._window:Remove()
        inst._window = nil
    end
    if inst._windowsnow ~= nil then
        inst._windowsnow:Remove()
        inst._windowsnow = nil
    end
end

local function onignite(inst)
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        inst.components.spawner:ReleaseChild()
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function spawncheckday(inst)
    inst.inittask = nil
    inst:WatchWorldState("startcaveday", OnStartDay)
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        if TheWorld.state.iscaveday or
            (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            inst.components.spawner:ReleaseChild()
        else
            inst.components.playerprox:ForceUpdate()
            onoccupieddoortask(inst)
        end
    end
end

local function oninit(inst)
    inst.inittask = inst:DoTaskInTime(math.random(), spawncheckday)
    if inst.components.spawner ~= nil and
        inst.components.spawner.child == nil and
        inst.components.spawner.childname ~= nil and
        not inst.components.spawner:IsSpawnPending() then
        local child = SpawnPrefab(inst.components.spawner.childname)
        if child ~= nil then
            inst.components.spawner:TakeOwnership(child)
            inst.components.spawner:GoHome(child)
        end
    end
end

local function MakeWindow()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("windowlight_idle")
    inst.AnimState:SetLightOverride(.6)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst:Hide()

    return inst
end

local function MakeWindowSnow()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("windowsnow_idle")
    inst.AnimState:SetFinalOffset(2)

    inst:Hide()

    MakeSnowCovered(inst)

    return inst
end

local loot_table = {"boards","boards","cutstone","cutstone","pigskin","pigskin",}

local function fn(groupId)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("pighouse.png")
--{anim="level1", sound="dontstarve/common/campfire", radius=2, intensity=.75, falloff=.33, colour = {197/255,197/255,170/255}},
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1)
    inst.Light:Enable(false)
    inst.Light:SetColour(180/255, 195/255, 50/255)

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")
	inst:AddTag("pkc_defences") --标记为防御设施
	inst:AddTag("pkc_group"..groupId) --队伍标记
    inst:AddTag("pighouse")

    MakeSnowCoveredPristine(inst)

    if not TheNet:IsDedicated() then
        inst._window = MakeWindow()
        inst._window.entity:SetParent(inst.entity)
        inst._windowsnow = MakeWindowSnow()
        inst._windowsnow.entity:SetParent(inst.entity)
        if not TheWorld.ismastersim then
            inst._window:DoPeriodicTask(FRAMES, OnUpdateWindow, nil, inst, inst._windowsnow)
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(loot_table)
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    --inst:AddComponent("spawner")
    --inst.components.spawner:Configure("pigman", TUNING.TOTAL_DAY_TIME*4)
    --inst.components.spawner.onoccupied = onoccupied
    --inst.components.spawner.onvacate = onvacate
    --inst.components.spawner:CancelSpawning()

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 13)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

	--名字
	if not inst.components.inspectable then
		inst:AddComponent("inspectable")
	end
	if not inst.components.named then
		inst:AddComponent("named")
	end
	inst.components.named:SetName("争霸猪人房")
    inst.components.inspectable.getstatus = getstatus

    MakeSnowCovered(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    inst:ListenForEvent("burntup", onburntup)
    inst:ListenForEvent("onignite", onignite)

    inst.OnSave = onsave 
    inst.OnLoad = onload

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.inittask = inst:DoTaskInTime(0, oninit)

    return inst
end

return
Prefab("pkc_pighouse_big", function()
	local inst = fn(GROUP_BIGPIG_ID)
	if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("spawner")
    inst.components.spawner:Configure("pkc_pigman_big", TUNING.TOTAL_DAY_TIME*1)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst.components.spawner:CancelSpawning()
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.BIGPIG.pighouse_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	--inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
	inst.saveTags = {}
	inst.saveTags["pkc_group"..GROUP_BIGPIG_ID] = 1
	inst.pkc_group_id = GROUP_BIGPIG_ID
	return inst
end, assets, prefabs),

Prefab("pkc_pighouse_red", function()
	local inst = fn(GROUP_REDPIG_ID)
	if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("spawner")
    inst.components.spawner:Configure("pkc_pigman_red", TUNING.TOTAL_DAY_TIME*1)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst.components.spawner:CancelSpawning()
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.REDPIG.pighouse_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	--inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
	inst.saveTags = {}
	inst.saveTags["pkc_group"..GROUP_REDPIG_ID] = 1
	inst.pkc_group_id = GROUP_REDPIG_ID
	return inst
end, assets, prefabs),

Prefab("pkc_pighouse_long", function()
	local inst = fn(GROUP_LONGPIG_ID)
	if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("spawner")
    inst.components.spawner:Configure("pkc_pigman_long", TUNING.TOTAL_DAY_TIME*1)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst.components.spawner:CancelSpawning()
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.LONGPIG.pighouse_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	--inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
	inst.saveTags = {}
	inst.saveTags["pkc_group"..GROUP_LONGPIG_ID] = 1
	inst.pkc_group_id = GROUP_LONGPIG_ID
	return inst
end, assets, prefabs),

Prefab("pkc_pighouse_cui", function()
	local inst = fn(GROUP_CUIPIG_ID)
	if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("spawner")
    inst.components.spawner:Configure("pkc_pigman_cui", TUNING.TOTAL_DAY_TIME*1)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst.components.spawner:CancelSpawning()
	--设置颜色
	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.CUIPIG.pighouse_color)
	inst.AnimState:SetMultColour(r, g, b, 1)
	--inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
	inst.saveTags = {}
	inst.saveTags["pkc_group"..GROUP_CUIPIG_ID] = 1
	inst.pkc_group_id = GROUP_CUIPIG_ID
	return inst
end, assets, prefabs)

--MakePlacer("pighouse_placer", "pig_house", "pig_house", "idle")
--return Prefab("pighouse", fn, assets, prefabs),
  --  MakePlacer("pighouse_placer", "pig_house", "pig_house", "idle")
