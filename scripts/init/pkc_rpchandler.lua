--@name pkc_rpchandler
--@description RPC调用处理
--@auther redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local require = GLOBAL.require

--取消无敌状态
local function cancelInvincible(player, delay_time)
	player:DoTaskInTime(delay_time, function()
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
	return GLOBAL.GROUP_INFOS[minNumGroup[math.random(#minNumGroup)]].id
end

--添加队伍选择RPC处理
--@大猪猪 11-02
AddModRPCHandler("pkc_teleport", "TeleportToBase", function(player, group_id)
	
	if group_id == -1 then
		--如果为随机选队
		--新加入的玩家只会选择人数最少的队伍，人数相同则选择其中一个
		 group_id = compareGroupPlayerNum(getGroupPlayerNum())
	end
	
	--设置选择的阵营
	if not player.components.pkc_group then
		player:AddComponent("pkc_group")
	end
	player.components.pkc_group:setChooseGroup(group_id)
	--取消无敌状态
	cancelInvincible(player, GLOBAL.INVINCIBLE_TIME)
	--传送至对应的基地
	for k, v in pairs(GLOBAL.GROUP_INFOS) do
		if group_id == GLOBAL.GROUP_INFOS[k].id then
			GLOBAL.pkc_announce(player.name..GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH1..v.name..GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH2)
			local x = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_"..k.."_POS_x"]
			local z = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_"..k.."_POS_z"]
			player.components.pkc_group:setBasePos({x, 0 , z}) --记住自己的基地位置
			--player.Transform:SetPosition(x, 0, z)
			player.Physics:Teleport(x, 0, z)
			player:DoTaskInTime(2, function()
				if player and player.components.talker then
					player.components.talker:Say(GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH3..v.name..GLOBAL.PKC_SPEECH.GROUP_JOIN.SPEECH4)
				end
			end)
			--根据选择的阵营进行相应的头部显示
			player.components.pkc_headshow:setHeadText(player:GetDisplayName())
			player.components.pkc_headshow:setHeadColor(v.head_color)
			player.components.pkc_headshow:setChoose(true)
			break
		end
	end
end)

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
		if isWinner then
			title = "胜利，然并卵"
		else
			title = "失败，好气啊"
		end
		local Text = require "widgets/text"
		local PopupDialogScreen = require("screens/popupdialog")
		local screen = PopupDialogScreen(title, data.message, { { text = data.buttonText, cb = function() GLOBAL.TheFrontEnd:PopScreen() end } })
		GLOBAL.TheFrontEnd:PushScreen( screen )
	end
end)