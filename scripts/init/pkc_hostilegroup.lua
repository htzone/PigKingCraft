--
-- 怪物阵营
-- Auther: RedPig
-- Date: 2017/1/06
--

AddPrefabPostInit("world", function(inst)
    if inst.ismastersim then
        inst:AddComponent("pkc_monsterpoint")
    end
end)



