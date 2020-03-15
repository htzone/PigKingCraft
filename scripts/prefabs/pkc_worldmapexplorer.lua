-- 世界地图探索器
-- Author: RedPig
-- Date: 2020/3/5

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMapExplorer()
    inst.entity:AddNetwork()
    inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("pkc_worldmapexplorer", fn)