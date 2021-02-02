--
-- 怪物阵营
-- Author: RedPig
-- Date: 2017/03/20
--

AddPrefabPostInit("world", function(inst)
    if GLOBAL.PKC_MONSTER_POINT and inst.ismastersim then
        inst:AddComponent("pkc_monster_point") --怪物据点机制
    end
end)


