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
AddPlayerPostInit(function(player)
	if player then
		--添加分组组件
		player:AddComponent("pkc_group")
		--添加头部显示组件
		player:AddComponent("pkc_headshow")
		--玩家复活任务
		player:AddComponent("pkc_playerrevivetask")
		--角色平衡
		player:AddComponent("pkc_characterbalance")
		--计时器
		if not player.components.timer then
			player:AddComponent("timer")
		end
		player.runTag = true
		--处理按键
		if not GLOBAL.TheNet:IsDedicated() then
			cKeyHandler = simpleKeyHandler()
		end
		--显示头部名字
		player:DoTaskInTime(0, function()
			if player and player.components.pkc_group and player.components.pkc_group:getChooseGroup() ~= 0 then
				player.components.pkc_headshow:addHeadView()
			end
		end)
		if IsServer then
			--出生提示属于哪个阵营（前提是已选择了阵营）
			player:DoTaskInTime(6, function()
				for _,v in pairs(GLOBAL.PKC_GROUP_INFOS) do
					if player and player.components.pkc_group and player.components.pkc_group:getChooseGroup() == v.id then
						if player.components.talker then
							player.components.talker:Say(GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH1..v.name..GLOBAL.PKC_SPEECH.BELONG_TIPS.SPEECH2)
						end
						break
					end
				end
			end)
			--监听被攻击
			player:ListenForEvent("attacked", onAttacked)
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

