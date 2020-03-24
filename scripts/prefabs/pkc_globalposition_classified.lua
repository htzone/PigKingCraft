--
-- Author: RedPig
-- Date: 2020/3/5

--local function UpdatePortrait(inst)
--    TheWorld.net.components.globalpositions:UpdatePortrait(inst)
--end

local function enableGlobalIcon(inst)
    if inst then
--        if inst.icon then
--            inst.icon.MiniMapEntity:SetEnabled(true)
--            print("inst.icon.MiniMapEntity:SetEnabled:true")
--        end
        if inst.icon2 then
            inst.icon2.MiniMapEntity:SetEnabled(true)
            print("inst.icon2.MiniMapEntity:SetEnabled:true")
        else
            pkc_announce("enableGlobalIcon:icon2 is nil")
        end
    end
end

local function disenableGlobalIcon(inst)
    if inst then
--        if inst.icon then
--            inst.icon.MiniMapEntity:SetEnabled(false)
--            print("inst.icon.MiniMapEntity:SetEnabled:false")
--        end
        if inst.icon2 then
            inst.icon2.MiniMapEntity:SetEnabled(false)
            print("inst.icon2.MiniMapEntity:SetEnabled:false")
        else
            pkc_announce("disenableGlobalIcon:icon2 is nil")
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")
    inst.playercolour = DEFAULT_PLAYER_COLOUR
    inst.name = "unknown"
    inst.parentprefab = net_string(inst.GUID, "prefab")
    inst.parententity = net_entity(inst.GUID, "parent")
    inst.parentuserid = net_string(inst.GUID, "parentuserid")
    inst.parentname = net_string(inst.GUID, "parentname")
    inst.userid = net_string(inst.GUID, "userid", "useriddirty")
    inst.portraitdirty = net_event(inst.GUID, "portraitdirty", "portraitdirty")
    inst._isIconVisible = net_bool(inst.GUID, "_isiconvisible")
    inst._enableGlobalIcon = net_event(inst.GUID, "_enableGlobalIconDirty", "_enableGlobalIconDirty")
    inst._disenableGlobalIcon = net_event(inst.GUID, "_disenableGlobalIconDirty", "_disenableGlobalIconDirty")
    inst.entity:SetCanSleep(false)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("useriddirty", function()
            if TheWorld.net.components.pkc_globalpositions then
                TheWorld.net.components.pkc_globalpositions:AddClientEntity(inst)
            end
        end)
        return inst
    end
    inst.persists = false
    return inst
end

return Prefab("pkc_globalposition_classified", fn)