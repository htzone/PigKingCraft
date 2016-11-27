--@name pkc_producebase
--@description 基地生成
--@auther redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--以这种方式生成基地
AddPrefabPostInit("multiplayer_portal", function(inst)
	if inst then
		if IsServer then
			if inst and not inst.components.pkc_base then
				inst:AddComponent("pkc_base")
			end
			inst:DoTaskInTime(0, function()
				--生成基地
				inst.components.pkc_base:produceBase(GLOBAL.GROUP_NUM)
			end)
		end
	end
end)


--[[
AddPrefabPostInit("world", function(inst)
	if inst then
		--无出生点
		if inst and not inst.components.pkc_base then
			inst:AddComponent("pkc_base")
		end
		inst:DoTaskInTime(1, function()
			local protal = GLOBAL.pkc_findFirstPrefabByTag("portal")
			if protal == nil then 
				print("--无出生点！")
				--生成基地
				--inst.components.pkc_base:produceBase2(GLOBAL.GROUP_NUM)
			else
				print("--有出生点！")
			end
		end)
	end
end)]]--