--
-- 玩家位置保存实体
-- Author: RedPig
-- Date: 2020/03/16
--

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