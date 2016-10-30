--@name pkc_playerinit
--@description 玩家初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

--玩家初始化
AddPlayerPostInit(function(inst)
	if inst then
		--添加玩家阵营组件
		inst:AddComponent("pkc_group")
	end
end)