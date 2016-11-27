--@name pkc_playerinit
--@description 玩家初始化
--@auther 大猪猪，redpig
--@date 2016-10-23
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--让玩家在一段时间内无敌
local function makePlayerInvincible(player, timeDelay)
	if player and player.components.health then
		player.components.health:SetInvincible(true)
		player._fx = SpawnPrefab("forcefieldfx")
		if player._fx then
			player._fx.entity:SetParent(player.entity)
			player._fx.Transform:SetPosition(0, 0.2, 0)	
		end
		player:DoTaskInTime(timeDelay, function()
			if player then
				if player.components.health then
					player.components.health:SetInvincible(false)
				end
				if player._fx then
					player._fx:kill_fx()
					player._fx:Remove()
					player._fx = nil
				end
			end
		end)
	end
end

--复活计时任务
local function reviveTask(inst)
	inst:DoTaskInTime(1, function()
		if inst then
			if inst.revive_time > 1 then
				inst.revive_time = inst.revive_time - 1
				if inst.components.talker then
					inst.components.talker:Say(GLOBAL.PKC_SPEECH.REVIVE_TIPS1.SPEECH1..inst.revive_time..GLOBAL.PKC_SPEECH.REVIVE_TIPS1.SPEECH2)
				end
				reviveTask(inst)
			else
				if not GLOBAL.TheWorld:HasTag("cave") then
					if inst.components.pkc_group then
						local x, y, z = GLOBAL.unpack(inst.components.pkc_group:getBasePos()) 
						inst.Transform:SetPosition(x, 0, z)
					end
					if inst.components.talker then
						inst.components.talker:Say(GLOBAL.PKC_SPEECH.REVIVE_TIPS2)
					end
					inst:DoTaskInTime(3, function()
						if inst then
							inst:PushEvent("respawnfromghost")
						end							
					end)
				else
					inst:PushEvent("respawnfromghost")
				end
			end
		end
	end)
end

--玩家初始化
--@大猪猪 10-31
AddPlayerPostInit(function(inst)
	if inst then
		--添加分组组件
		inst:AddComponent("pkc_group")
		--添加头部显示组件
		inst:AddComponent("pkc_headshow")
		
		--显示头部名字
		inst:DoTaskInTime(0, function()
			if inst and inst.components.pkc_group and inst.components.pkc_group:getChooseGroup() ~= 0 then
				inst.components.pkc_headshow:addHeadView()
			end
		end)
		
		if IsServer then
			--出生提示属于哪个阵营（前提是已选择了阵营）
			inst:DoTaskInTime(2, function()
				for _,v in pairs(GLOBAL.GROUP_INFOS) do
					if inst and inst.components.pkc_group and inst.components.pkc_group:getChooseGroup() == v.id then
						if inst.components.talker then
							inst.components.talker:Say(GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH1..v.name..GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH2)
						end
						break
					end
				end
			end)
			--死亡复活机制
			inst:ListenForEvent("death", function(inst)
				inst.revive_time = GLOBAL.PLAYER_REVIVE_TIME 
				reviveTask(inst)
			end)
			inst:ListenForEvent("respawnfromghost", function(inst, data)
				inst.revive_time = -1
			end)
		end
	end
end)

--[[
--给蜘蛛加阵营组件 测试
AddPrefabPostInit("tallbird",function(inst)
	inst:AddComponent("pkc_group")
	inst.components.pkc_group:setChooseGroup(GLOBAL.GROUP_REDPIG_ID)
	--if inst.components.combat then
	--	local o_CanTarget = inst.components.combat.CanTarget
	--	function inst.components.combat:CanTarget(target)
	--	if target and target.components.pkc_group.hasChoosen==inst.components.pkc_group.hasChoosen then
	--			return false
	--		end
	--		return o_CanTarget(self,target)
	--	end
	--end
--end
end)

AddPrefabPostInit("spider",function(inst)
	inst:AddComponent("pkc_group")
	inst.components.pkc_group:setChooseGroup(GLOBAL.GROUP_BIGPIG_ID)
end)

AddPrefabPostInit("merm",function(inst)
	inst:AddComponent("pkc_group")
	inst.components.pkc_group:setChooseGroup(GLOBAL.GROUP_BIGPIG_ID)
end)
]]--







