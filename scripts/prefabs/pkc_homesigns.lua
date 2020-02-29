--
-- Created by IntelliJ IDEA.
-- User: RedPig
-- Date: 2017/2/18
-- Time: 23:23
-- To change this template use File | Settings | File Templates.
--

local assets =
{
    Asset("ANIM", "anim/sign_home.zip"),
    Asset("ANIM", "anim/ui_board_5x3.zip"),
    Asset("MINIMAP_IMAGE", "sign"),
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
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

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/sign_craft")
end

local function fn(groupId)

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .2)

    inst.MiniMapEntity:SetIcon("sign.png")

    inst.AnimState:SetBank("sign_home")
    inst.AnimState:SetBuild("sign_home")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst:AddTag("structure")
    inst:AddTag("sign")
    inst:AddTag("pkc_group"..groupId)

    --Sneak these into pristine state for optimization
    inst:AddTag("_writeable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_writeable")

    inst:AddComponent("inspectable")
    inst:AddComponent("writeable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableWork(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return
--Prefab("homesign", fn, assets, prefabs),
--MakePlacer("homesign_placer", "sign_home", "sign_home", "idle")

Prefab("pkc_homesign_big", function()
    local inst = fn(GROUP_BIGPIG_ID)
    if not TheWorld.ismastersim then
        return inst
    end
    --设置颜色
    local r, g, b = HexToPercentColor(GROUP_INFOS.BIGPIG.pighouse_color)
    inst.AnimState:SetMultColour(r, g, b, 1)
    --inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
    inst.saveTags = {}
    inst.saveTags["pkc_group"..GROUP_BIGPIG_ID] = 1
    inst.pkc_group_id = GROUP_BIGPIG_ID
    return inst
end, assets, prefabs),

Prefab("pkc_homesign_red", function()
    local inst = fn(GROUP_REDPIG_ID)
    if not TheWorld.ismastersim then
        return inst
    end
    --设置颜色
    local r, g, b = HexToPercentColor(GROUP_INFOS.REDPIG.pighouse_color)
    inst.AnimState:SetMultColour(r, g, b, 1)
    --inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
    inst.saveTags = {}
    inst.saveTags["pkc_group"..GROUP_REDPIG_ID] = 1
    inst.pkc_group_id = GROUP_REDPIG_ID
    return inst
end, assets, prefabs),

Prefab("pkc_homesign_long", function()
    local inst = fn(GROUP_LONGPIG_ID)
    if not TheWorld.ismastersim then
        return inst
    end
    --设置颜色
    local r, g, b = HexToPercentColor(GROUP_INFOS.LONGPIG.pighouse_color)
    inst.AnimState:SetMultColour(r, g, b, 1)
    --inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
    inst.saveTags = {}
    inst.saveTags["pkc_group"..GROUP_LONGPIG_ID] = 1
    inst.pkc_group_id = GROUP_LONGPIG_ID
    return inst
end, assets, prefabs),

Prefab("pkc_homesign_cui", function()
    local inst = fn(GROUP_CUIPIG_ID)
    if not TheWorld.ismastersim then
    return inst
    end
    --设置颜色
    local r, g, b = HexToPercentColor(GROUP_INFOS.CUIPIG.pighouse_color)
    inst.AnimState:SetMultColour(r, g, b, 1)
    --inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
    inst.saveTags = {}
    inst.saveTags["pkc_group"..GROUP_CUIPIG_ID] = 1
    inst.pkc_group_id = GROUP_CUIPIG_ID
    return inst
end, assets, prefabs)


