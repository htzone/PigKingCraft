--@name pkc_multiplayer_portal
--@description 基地生成
--@auther redpig
--@date 2016-10-23

--local group_num = GetModConfigData("group_num")
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

AddPrefabPostInit("multiplayer_portal", function(inst)
	if inst then
		if IsServer then
			if inst and not inst.components.pkc_base then
				inst:AddComponent("pkc_base")
			end
			inst:DoTaskInTime(1, function()
				--基地生成
				inst.components.pkc_base:ProduceBase(GLOBAL.GROUP_NUM)
			end)
		end
	end
end)