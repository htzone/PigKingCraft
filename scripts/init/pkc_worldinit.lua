--@name pkc_worldinit
--@description 世界初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--世界初始化
AddPrefabPostInit("world", function(inst)
	if inst then
	
	end
end)