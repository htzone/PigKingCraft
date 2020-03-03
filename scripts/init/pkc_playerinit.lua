--@name pkc_playerinit
--@description 玩家初始化
--@author 大猪猪，redpig
--@date 2016-10-23
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local TheInput = GLOBAL.TheInput

--当玩家被攻击时有一定几率虚弱
local function onAttacked(inst, data)
	if inst and data and data.attacker then
		if inst:HasTag("pkc_gohome") then
			inst:RemoveTag("pkc_gohome")
		end
		if data.attacker:HasTag("player") then
			if math.random() < .7 then
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
		--玩家复活任务
		inst:AddComponent("pkc_playerrevivetask")

		if GLOBAL.TheWorld.ismastersim then
			--角色平衡
			inst:AddComponent("pkc_characterbalance")
			--计时器
			if not inst.components.timer then
				inst:AddComponent("timer")
			end
			inst.runTag = true
		end
		--处理按键
		if not GLOBAL.TheNet:IsDedicated() then
			cKeyHandler = simpleKeyHandler()
		end

--		if inst.prefab == "wilson" then
--			inst.components.pkc_group:setChooseGroup(GROUP_BIGPIG_ID)
--		end
--		if inst.prefab == "willow" then
--			inst.components.pkc_group:setChooseGroup(GROUP_REDPIG_ID)
--		end

		--显示头部名字
		inst:DoTaskInTime(0, function()
			if inst and inst.components.pkc_group and inst.components.pkc_group:getChooseGroup() ~= 0 then
				inst.components.pkc_headshow:addHeadView()
			end
		end)
		
		if IsServer then
			--出生提示属于哪个阵营（前提是已选择了阵营）
			inst:DoTaskInTime(6, function()
				for _,v in pairs(GLOBAL.GROUP_INFOS) do
					if inst and inst.components.pkc_group and inst.components.pkc_group:getChooseGroup() == v.id then
						if inst.components.talker then
							inst.components.talker:Say(GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH1..v.name..GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH2)
						end
						break
					end
				end
			end)
			--监听被攻击
			inst:ListenForEvent("attacked", onAttacked)
		end
	end
end)

simpleKeyHandler = Class(function(self, inst) 
	self.handler = TheInput:AddKeyHandler(function(key, down) self:OnRawKey(key, down, inst) end )
end)

--Press key B
function simpleKeyHandler:OnRawKey(key, down, inst)
	local screen = TheFrontEnd:GetActiveScreen()
	local isHUDActive = screen and screen.name == "HUD"
	if isHUDActive then
		if (key == GLOBAL.KEY_B or key == GLOBAL.KEY_C) and down then
			SendModRPCToServer(MOD_RPC["pkc_keydown"]["goHome"])
		elseif (key == GLOBAL.KEY_LSHIFT and down) then
			SendModRPCToServer(MOD_RPC["pkc_keydown"]["startRunning"])
		end
	end
end

