--
-- 地图图标
-- Author: RedPig
-- Date: 2020/03/01
--

local function fn()
    local inst = Prefabs.globalmapicon.fn()
    inst.MiniMapEntity:SetIsProxy(false)
    return inst
end

return Prefab("pkc_globalmapicon_noproxy", fn)

