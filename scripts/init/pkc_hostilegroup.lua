--
-- 怪物阵营
-- Author: RedPig
-- Date: 2017/03/20
--

AddPrefabPostInit("world", function(inst)
    if inst.ismastersim then
        inst:AddComponent("pkc_monsterpoint")
    end
end)



