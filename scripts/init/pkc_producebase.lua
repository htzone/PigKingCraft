--
-- 基地生成
-- Author: RedPig
-- Date: 2016/10/23
--

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

local function spawnAncientAltar(inst)
	inst:DoTaskInTime(0, function()
		local pt = inst:GetPosition()
		local offset = Vector3(3, 0, 3)
		local mob = pkc_spawnPrefab("ancient_altar", pt + offset)
		if mob then
			print("pkc spawn ancient_altar success.")
		end
	end)
end

--以这种方式生成基地
AddPrefabPostInit("multiplayer_portal", function(inst)
	if inst then
		if IsServer then
			--安置远古科技
			spawnAncientAltar(inst)
			if inst and not inst.components.pkc_base then
				inst:AddComponent("pkc_base")
			end
			if inst then
				inst:DoTaskInTime(0, function()
					--生成基地
					inst.components.pkc_base:produceBase(GLOBAL.GROUP_NUM)
				end)
			end
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