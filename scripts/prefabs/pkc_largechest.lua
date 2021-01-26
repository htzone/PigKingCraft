-- 猪王的宝箱
-- pkc_bigchests
-- Author: RedPig
-- Date: 2021/1/26
--
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/ui_chest_5x16.zip"),
}

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function MakeChest(groupId, color, name, bank, build, indestructible, master_postinit, prefabs, assets, common_postinit, force_non_burnable)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon(name..".png")

        inst:AddTag("structure")
        inst:AddTag("chest")
        inst:AddTag("pkc_large_chest")
        inst:AddTag("pkc_group"..tostring(groupId)) --队伍标记

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("closed")
        --设置颜色
        local r, g, b = HexToPercentColor(color)
        inst.AnimState:SetMultColour(r, g, b, 1)

        MakeSnowCoveredPristine(inst)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end
        --设置标签
        inst.saveTags = {}
        inst.saveTags["pkc_group"..tostring(groupId)] = 1
        inst.pkc_group_id = groupId

        inst:AddComponent("inspectable")
        inst:AddComponent("named")
        inst.components.named:SetName("猪王的宝箱")
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose
        inst.components.container.skipclosesnd = true
        inst.components.container.skipopensnd = true

        if not indestructible then
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onhit)

            if not force_non_burnable then
                MakeSmallBurnable(inst, nil, nil, true)
                MakeMediumPropagator(inst)
            end
        end

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("onbuilt", onbuilt)
        MakeSnowCovered(inst)

        -- Save / load is extended by some prefab variants
        inst.OnSave = onsave
        inst.OnLoad = onload

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function minotuar_master_postinit(inst)
    --inst:ListenForEvent("resetruins", function()
    --    inst.components.container:Close()
    --    inst.components.container:DropEverything()
    --
    --    if not inst:IsAsleep() then
    --        local fx = SpawnPrefab("collapse_small")
    --        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    --        fx:SetMaterial("wood")
    --    end
    --
    --    inst:Remove()
    --end, TheWorld)
end

--MakeChest("treasurechest", "chest", "treasure_chest", false, nil, { "collapse_small" }),
return MakeChest(GROUP_BIGPIG_ID, PKC_GROUP_INFOS.BIGPIG.pighouse_color, "pkc_largechest_big", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_master_postinit, { "collapse_small" }, assets),
    MakeChest(GROUP_REDPIG_ID, PKC_GROUP_INFOS.REDPIG.pighouse_color, "pkc_largechest_red", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_master_postinit, { "collapse_small" }, assets),
    MakeChest(GROUP_CUIPIG_ID, PKC_GROUP_INFOS.CUIPIG.pighouse_color,"pkc_largechest_cui", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_master_postinit, { "collapse_small" }, assets),
    MakeChest(GROUP_LONGPIG_ID, PKC_GROUP_INFOS.LONGPIG.pighouse_color,"pkc_largechest_long", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_master_postinit, { "collapse_small" }, assets)
