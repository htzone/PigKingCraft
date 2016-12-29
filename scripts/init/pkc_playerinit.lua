--@name pkc_playerinit
--@description 玩家初始化
--@auther 大猪猪，redpig
--@date 2016-10-23
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local TheInput = GLOBAL.TheInput

--让玩家在一段时间内无敌
local function makePlayerInvincible(player, timeDelay)
	if player and player.components.health then
		player.components.health:SetInvincible(true)
		player._fx = GLOBAL.SpawnPrefab("forcefieldfx")
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
						--inst.Transform:SetPosition(x, 0, z)
						inst.Physics:Teleport(x, 0, z)
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

--当玩家被攻击时有一定几率虚弱
local function onAttacked(inst, data)
	if data.attacker then
		if inst and inst:HasTag("pkc_gohome") then
			inst:RemoveTag("pkc_gohome")
		end
		if data.attacker:HasTag("player") then
			if math.random() < .5 then
				if inst.components.grogginess ~= nil then
					inst.components.grogginess:AddGrogginess(1, 4)
				end
			end
		else
			if data.attacker.components.pkc_group then
				if math.random() < .3 then
					if inst.components.grogginess ~= nil then
						inst.components.grogginess:AddGrogginess(1, 4)
					end
				end
			end
		end
	end
end

--玩家初始化
--@大猪猪 10-31
AddPlayerPostInit(function(inst)
	if inst then
		--添加分组组件
		inst:AddComponent("pkc_group")
		--添加头部显示组件
		inst:AddComponent("pkc_headshow")
		
		if not GLOBAL.TheNet:IsDedicated() then
			cKeyHandler = simpleKeyHandler()
		end
		
		--人物分组测试
		--[[
		if inst.prefab == "wilson" then
			inst:DoTaskInTime(0, function()
				if inst.components.talker then
					inst.components.pkc_group:setChooseGroup(GLOBAL.GROUP_BIGPIG_ID)
				end
			end)
		end
		if inst.prefab == "willow" then
			inst:DoTaskInTime(0, function()
				if inst.components.talker then
					inst.components.pkc_group:setChooseGroup(GLOBAL.GROUP_BIGPIG_ID)
				end
			end)
		end
		]]--
		
		--显示头部名字
		inst:DoTaskInTime(0, function()
			if inst and inst.components.pkc_group and inst.components.pkc_group:getChooseGroup() ~= 0 then
				inst.components.pkc_headshow:addHeadView()
			end
		end)
		
		if IsServer then
			--出生提示属于哪个阵营（前提是已选择了阵营）
			inst:DoTaskInTime(5, function()
				for _,v in pairs(GLOBAL.GROUP_INFOS) do
					if inst and inst.components.pkc_group and inst.components.pkc_group:getChooseGroup() == v.id then
						if inst.components.talker then
							inst.components.talker:Say(GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH1..v.name..GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH2)
						end
						break
					end
				end
			end)
			--启动复活任务
			inst:ListenForEvent("death", function(inst)
				inst.revive_time = GLOBAL.PLAYER_REVIVE_TIME 
				reviveTask(inst)
			end)
			inst:ListenForEvent("attacked", onAttacked)
			--复活
			inst:ListenForEvent("respawnfromghost", function(inst, data)
				inst.revive_time = -1
				inst:DoTaskInTime(5, function()
					makePlayerInvincible(inst, GLOBAL.REVIVE_INVINCIBLE_TIME)
				end)
			end)
		end
	end
end)

simpleKeyHandler = Class(function(self, inst) 
  
	self.handler = TheInput:AddKeyHandler(function(key, down) self:OnRawKey(key, down, inst) end )
	
end)

function simpleKeyHandler:OnRawKey(key, down, inst)
	local handleName = "pkc_keydown"
	local actionName = "goHome"
	if (key == GLOBAL.KEY_B and down) then
		print("key_down------")
		SendModRPCToServer(MOD_RPC[handleName][actionName])
	end
end





