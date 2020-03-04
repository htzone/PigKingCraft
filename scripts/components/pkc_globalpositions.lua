-- 保存所有位置的组件（只在服务端执行）
-- Author: RedPig
-- Date: 2020/3/4

local GlobalPositions = Class(function(self, inst)
    self.inst = inst
    self.positions = {}
    if not TheWorld.ismastersim
            or not TheNet:IsDedicated() then return end
    -- Players will wait to get their map from here until this says it's loaded
    self.map_loaded = false
end)
