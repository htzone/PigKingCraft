--
-- RPC调用处理
-- Author: RedPig
-- Date: 2016/10/23
--

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local require = GLOBAL.require

--取消无敌状态
local function cancelInvincible(player, delay_time)
	player:DoTaskInTime(delay_time, function()
		if player then
			if player.components.health then
				if player.components.health.invincible == true then
					player.components.health:SetInvincible(false)
				end
			end
			if player._fx then
				player._fx:kill_fx()
				player._fx:Remove()
				player._fx = nil
			end
		end
	end)
end

--获取每个队伍的人数
local function getGroupPlayerNum()
	--保存队伍名和队伍人数的键值对
	local groupPlayerNum = {}
	for group_name, group_id in pairs(GLOBAL.CURRENT_EXIST_GROUPS) do
		groupPlayerNum[group_name] = 0
		for _, player in pairs(GLOBAL.AllPlayers) do 
			if player and player.components.pkc_group 
			and player.components.pkc_group:getChooseGroup() == group_id
			then
				groupPlayerNum[group_name] = groupPlayerNum[group_name] + 1
			end
		end
	end
	return groupPlayerNum
end

--比较每个队伍的人数，选出最小人数的队伍，相同人数则从中随机
local function compareGroupPlayerNum(groupPlayerNum)
	local min_num = 0
	local i = 1
	for _, num in pairs(groupPlayerNum) do 
		if i == 1 then
			min_num = num
		else
			if num < min_num then
				min_num = num
			end
		end
		i = i + 1
	end
	local minNumGroup = {} --保存拥有最小玩家数的队伍名
	for group_name, num in pairs(groupPlayerNum) do
		if min_num == num then
			table.insert(minNumGroup, group_name)
		end	
	end
	--多个则随机选择其中一个
	return GLOBAL.PKC_GROUP_INFOS[minNumGroup[math.random(#minNumGroup)]].id
end

------handle group choose---------
--添加队伍选择RPC处理
--@大猪猪 11-02
AddModRPCHandler("pkc_teleport", "TeleportToBase", function(player, group_id)
	if group_id == -1 then
		--如果为随机选队
		--新加入的玩家只会选择人数最少的队伍，人数相同则随机选择其中一个
		 group_id = compareGroupPlayerNum(getGroupPlayerNum())
	end
	--设置选择的阵营
	if not player.components.pkc_group then
		player:AddComponent("pkc_group")
	end
	player.components.pkc_group:setChooseGroup(group_id)
	GLOBAL.TheWorld:PushEvent("pkc_completedChooseGroup", { chooser = player}) --触发完成选人事件
	--取消无敌状态
	cancelInvincible(player, GLOBAL.PKC_INVINCIBLE_TIME)
	--传送至对应的基地
	for k, v in pairs(GLOBAL.PKC_GROUP_INFOS) do
		if group_id == GLOBAL.PKC_GROUP_INFOS[k].id then
			GLOBAL.pkc_announce(player.name..GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH1..v.name..GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH2)
			local x = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_"..k.."_POS_x"]
			local z = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_"..k.."_POS_z"]
			player.components.pkc_group:setBasePos({x, 0 , z}) --记住自己的基地位置
			if player.Physics ~= nil then
				player.Physics:Teleport(x, 0, z)
			else
				player.Transform:SetPosition(x, 0, z)
			end
			--fx
			local fx1 = GLOBAL.SpawnPrefab("small_puff")
			if fx1 then
				fx1.Transform:SetScale(1.5, 1.5, 1.5)
				fx1.Transform:SetPosition(x, 0, z)
			end
			player:DoTaskInTime(2, function()
				if player and player.components.talker then
					player.components.talker:Say(GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH3..v.name..GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH4)
				end
			end)
			player:DoTaskInTime(10, function()
				if player and player.components.talker then
					player.components.talker:Say(GLOBAL.PKC_SPEECH.GO_HOME.SPEECH7)
				end
			end)
			player:DoTaskInTime(14, function()
				if player and player.components.talker then
					player.components.talker:Say(GLOBAL.PKC_SPEECH.SPRINT.SPEECH4)
				end
			end)
			--根据选择的阵营进行相应的头部显示
			player.components.pkc_headshow:setHeadText(player:GetDisplayName())
			player.components.pkc_headshow:setHeadColor(v.head_color)
			player.components.pkc_headshow:setHeadGroupTag(v.head_tag)
			player.components.pkc_headshow._eventAddHeader:push()
			break
		end
	end
end)

-----处理游戏胜利------
local json = require "json"
--处理游戏胜利
AddModRPCHandler("pkc_popDialog", "showWinDialog", function(player, json_data)
	if player and json_data then
		local data = json.decode(json_data)
		local winPlayers = data.winPlayers
		local isWinner = false
		for userid, _ in pairs(winPlayers) do
			if player.userid == userid then
				isWinner = true
				break
			end
		end
		local title = ""
		local button = ""
		if isWinner then
			title = GLOBAL.PKC_SPEECH.WINDIALOG_VICTORY_TITLE
			button = GLOBAL.PKC_SPEECH.WINDIALOG_WIN_BUTTON
		else
			title = GLOBAL.PKC_SPEECH.WINDIALOG_FAILURE_TITLE
			button = GLOBAL.PKC_SPEECH.WINDIALOG_FAILED_BUTTON
		end
		local Text = require "widgets/text"
		local PopupDialogScreen = require("screens/popupdialog")
		local screen = PopupDialogScreen(title, data.message, { { text = button, cb = function() GLOBAL.TheFrontEnd:PopScreen() end } })
		GLOBAL.TheFrontEnd:PushScreen( screen )
	end
end)

---------Go back to home-----
--检查是否能传送
local function canTeleportFn(inst)
	if inst then
		local canTeleport = true
		if inst.components.sanity and inst.components.sanity.current >= GLOBAL.GOHOME_SANITY_DELTA then
			inst.components.sanity:DoDelta(-(GLOBAL.GOHOME_SANITY_DELTA))
		else
			if inst.components.talker then
				inst.components.talker:Say(GLOBAL.PKC_SPEECH.GO_HOME.SPEECH5)
			end
			canTeleport = false
		end
		if inst.components.hunger and inst.components.hunger.current >= GLOBAL.GOHOME_HUNGER_DELTA then
			inst.components.hunger:DoDelta(-(GLOBAL.GOHOME_HUNGER_DELTA))
		else
			if inst.components.talker then
				inst.components.talker:Say(GLOBAL.PKC_SPEECH.GO_HOME.SPEECH6)
			end
			canTeleport = false
		end
		return canTeleport
	end
	return false
end

--回城任务
local function goHomeTask(inst)
	inst:DoTaskInTime(1, function()
		if inst then
			--遇到以下情况回城中断
			if (inst.components.locomotor and inst.components.locomotor:WantsToMoveForward()) 
			or (inst.components.burnable and inst.components.burnable:IsBurning())
			or (inst.components.sleeper and inst.components.sleeper:IsAsleep())
			or (inst.components.health and inst.components.health:IsDead())
			then
				if inst:HasTag("pkc_gohome") then
					inst:RemoveTag("pkc_gohome")
				end
			end
			--回城计时
			if inst:HasTag("pkc_gohome") then
				if inst.goHomeCooldown ~= nil and inst.goHomeCooldown > 1 then
					inst.goHomeCooldown = inst.goHomeCooldown - 1
					inst.AnimState:SetMultColour(0, 0, 0, (inst.goHomeCooldown/GLOBAL.GOHOME_WAIT_TIME))
					inst:DoTaskInTime(0, function()
						if inst and inst.components.talker then
							inst.components.talker:Say(GLOBAL.PKC_SPEECH.GO_HOME.SPEECH3..inst.goHomeCooldown..GLOBAL.PKC_SPEECH.GO_HOME.SPEECH4)
						end
					end)
					goHomeTask(inst)
				else
					if canTeleportFn(inst) then
						--fx1
						local fx1 = GLOBAL.SpawnPrefab("small_puff")
						if fx1 then
							fx1.Transform:SetScale(1.5, 1.5, 1.5)
							fx1.Transform:SetPosition(GLOBAL.Vector3(inst.Transform:GetWorldPosition()):Get())
						end
						--teleport
						inst:DoTaskInTime(.2, function()
							if inst then
								if inst.components.pkc_group and inst.components.pkc_group:getBasePos() ~= nil then
									local x, y, z = GLOBAL.unpack(inst.components.pkc_group:getBasePos()) 
									--传送回基地
									if inst.Physics ~= nil then
										inst.Physics:Teleport(x, 0, z)
									else
										inst.Transform:SetPosition(x, 0, z)
									end
									--fx2
									local fx2 = GLOBAL.SpawnPrefab("small_puff")
									if fx2 then
										fx2.Transform:SetScale(1.5, 1.5, 1.5)
										fx2.Transform:SetPosition(x, y, z)
									end
								end
							end
						end)
					end
					--over
					--设置颜色
					inst.AnimState:SetMultColour(1, 1, 1, 1)
					inst.goHomeCooldown = nil
					inst:RemoveTag("pkc_gohome")
				end
			else
				inst:DoTaskInTime(0, function()
					if inst.components.talker then
						inst.components.talker:Say(GLOBAL.PKC_SPEECH.GO_HOME.SPEECH2)
						inst.goHomeCooldown = nil
						inst.AnimState:SetMultColour(1, 1, 1, 1)
					end
				end)
			end
		end
	end)
end

------回城按键处理-----
--@RedPig 12-23
AddModRPCHandler("pkc_keydown", "goHome", function(inst)
	if inst and inst.components.pkc_group then
		inst:AddTag("pkc_gohome")
		if inst.goHomeCooldown == nil then
			inst.goHomeCooldown = GLOBAL.GOHOME_WAIT_TIME
			inst:DoTaskInTime(0, function()
				if inst.components.talker then
					inst.components.talker:Say(GLOBAL.PKC_SPEECH.GO_HOME.SPEECH1)
				end
				--设置颜色
				inst.AnimState:SetMultColour(0, 0, 0, 1)
			end)
			goHomeTask(inst)
		end
	end
end)

-------冲刺动作-----
local function canSprintCheck(inst)
	if inst then
		local canSprint = true
		if inst.components.hunger and inst.components.hunger.current > GLOBAL.SPRINT_HUNGER_DELTA then
			inst.components.hunger:DoDelta(-(GLOBAL.SPRINT_HUNGER_DELTA))
		else
			pkc_talk(inst, PKC_SPEECH.SPRINT.SPEECH3)
			canSprint = false
		end
		return canSprint
	end
	return false
end

local function onTimerDone(inst, data)
	if data.name == "StartRunning" then
		if inst and inst:HasTag("running") then
			inst:RemoveTag("running")
			if inst.components.locomotor then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "running-mod", 1)
			end
			if inst.components.timer and not inst.components.timer:TimerExists("StopRunning") then
				inst.components.timer:StartTimer("StopRunning", PKC_SPRINT_COOLDOWN)
			end
		end
	elseif data.name == "StopRunning" then
		inst.runTag = true
		pkc_talk(inst, PKC_SPEECH.SPRINT.SPEECH2)
	end
end

local function turnOffRunning(inst, data)
	if inst and inst:HasTag("running") then
		--inst:RemoveTag("running")
		if inst.components.locomotor then
			inst.components.locomotor:SetExternalSpeedMultiplier(inst, "running-mod", 1)
		end
	end
end

local function startRunning(player)
	if player then
		if player.components.locomotor
			and player.components.locomotor:WantsToMoveForward()
			and player.components.timer
			and not player.components.timer:TimerExists("StartRunning")
			and not player.components.timer:TimerExists("StopRunning")
			and canSprintCheck(player)
			then
			player.components.timer:StartTimer("StartRunning", 0.3)
			pkc_talk(player, PKC_SPEECH.SPRINT.SPEECH1)
			player:AddTag("running")
			if player.components.locomotor then
				player.components.locomotor:SetExternalSpeedMultiplier(player, "running-mod", PKC_SPRINT_SPEED)
			end
			player:ListenForEvent("timerdone", onTimerDone)
			player:ListenForEvent("ms_becameghost", turnOffRunning)
			pkc_spawnFx("lucy_ground_transform_fx", player, 1.2)
		end
	end
end

--冲刺开始按键处理
--@RedPig 2-23
AddModRPCHandler("pkc_keydown", "startRunning", function(player)
	if player and player.components.pkc_group then
		startRunning(player)
	end
end)

--require "pkc_utils" 
--GLOBAL.getFromClient("sb", function(player, data)
--GLOBAL.TheNet:Announce(data)
--end)