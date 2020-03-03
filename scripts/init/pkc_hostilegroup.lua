--
-- 怪物阵营
-- author: RedPig
-- Date: 2017/1/06
--

AddPrefabPostInit("world", function(inst)
    if inst.ismastersim then
        inst:AddComponent("pkc_monsterpoint")
    end
end)



