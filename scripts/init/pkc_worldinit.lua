--
-- 世界初始化
-- Author: RedPig
-- Date: 2016/10/23
--

local _G = _G or GLOBAL
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local require = GLOBAL.require

--需要自动清除的物品
local autoDeleteTable = {
	"skeleton_player", --玩家骨头
}

--执行自动删除
local function autodeletefn(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.pkc_autodelete then
			inst:AddComponent("pkc_autodelete")
		end
		inst.components.pkc_autodelete:SetPerishTime(GLOBAL.PKC_AUTO_DELETE_TIME)
		inst.components.pkc_autodelete:StartPerishing()
	end
end

for _, v in pairs(autoDeleteTable) do
	AddPrefabPostInit(v, autodeletefn)
end

--给初始物品
local function giveItemToPlayer(startInventory, num, prefab_name)
	for i = 1, num do
		table.insert(startInventory, prefab_name)
	end
end

--玩家初始物品
local function startingInventory(inst, player)
	local startInventory = {}
	--配置初始物品
	giveItemToPlayer(startInventory, 5, "cutgrass")
	giveItemToPlayer(startInventory, 5, "twigs")
	giveItemToPlayer(startInventory, 5, "log")
	giveItemToPlayer(startInventory, 5, "flint")
	giveItemToPlayer(startInventory, 5, "rocks")
	giveItemToPlayer(startInventory, 2, "meat")
	--如果是冬天
	if GLOBAL.TheWorld.state.iswinter
			or (GLOBAL.TheWorld.state.isautumn and GLOBAL.TheWorld.state.remainingdaysinseason < 3) then
		giveItemToPlayer(startInventory, 5, "cutgrass")
		giveItemToPlayer(startInventory, 5, "twigs")
		giveItemToPlayer(startInventory, 5, "log")
		giveItemToPlayer(startInventory, 1, "heatrock")
		giveItemToPlayer(startInventory, 1, "winterhat")
	end
	--如果是春天
	if GLOBAL.TheWorld.state.isspring
			or (GLOBAL.TheWorld.state.iswinter and GLOBAL.TheWorld.state.remainingdaysinseason < 3) then
		giveItemToPlayer(startInventory, 1, "umbrella")
	end
	--如果是夏天
	if GLOBAL.TheWorld.state.issummer
			or (GLOBAL.TheWorld.state.isspring and GLOBAL.TheWorld.state.remainingdaysinseason < 3) then
		giveItemToPlayer(startInventory, 6, "nitre")
		giveItemToPlayer(startInventory, 6, "ice")
		giveItemToPlayer(startInventory, 1, "heatrock")
		giveItemToPlayer(startInventory, 1, "strawhat")
	end
	--如果初始点在洞穴
	if GLOBAL.TheWorld:HasTag("cave") then
		giveItemToPlayer(startInventory, 1, "minerhat") --矿工帽
	end
	--如果是PVP模式
	if GLOBAL.TheNet:GetPVPEnabled() then
		giveItemToPlayer(startInventory, 1, "spear") --长矛
		giveItemToPlayer(startInventory, 1, "footballhat") --皮帽
	end
	--玩家第一次进入时获取初始物品
	if player.CurrentOnNewSpawn == nil then
		player.CurrentOnNewSpawn = player.OnNewSpawn or function() return true end
		player.OnNewSpawn = function(...)
			if player.components.inventory then
				player.components.inventory.ignoresound = true
				if startInventory ~= nil and #startInventory > 0 then
					for i, itemName in pairs(startInventory) do
						player.components.inventory:GiveItem(GLOBAL.SpawnPrefab(itemName))
					end
				end
				player.components.inventory.ignoresound = false
			end
			return player.CurrentOnNewSpawn(...)
		end
	end
end

--检查是不是同盟关系。
local function checkIsGroupMemberFn(attacker, target)
	if attacker and target then
		if attacker.components.pkc_group and target.components.pkc_group
				and target.components.pkc_group:getChooseGroup() ~= 0 then
			if attacker.components.pkc_group:getChooseGroup() == target.components.pkc_group:getChooseGroup() then
				return true
			end
			if target:HasTag("pig") and target.components.follower and target.components.follower.leader ~= nil then
				return false
			end
			if (GLOBAL.TheWorld.state.cycles + 2) <=  GLOBAL.PEACE_TIME then --和平时期
				return true
			end
		end
	end
	return false
end

--设置国王墓碑
local function setGravestoneForKing(inst, killerId)
	if inst and killerId then
		local pt = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
		inst:DoTaskInTime(1, function()
			GLOBAL.SpawnPrefab("lightning").Transform:SetPosition(pt:Get())
			GLOBAL.SpawnPrefab("maxwell_smoke").Transform:SetPosition(pt:Get())
			local ground_fx = GLOBAL.SpawnPrefab("groundpoundring_fx")
			if ground_fx then
				ground_fx.Transform:SetScale(1,1,1)
				ground_fx.Transform:SetPosition(pt:Get())
			end
			local pigking_grave = GLOBAL.SpawnPrefab("gravestone")
			if pigking_grave and pigking_grave.Transform then
				pigking_grave.Transform:SetPosition(pt:Get())
				pigking_grave:AddTag("king")
				pigking_grave:AddTag("kinggrave")
				if killerId then
					pigking_grave:AddTag("pkc_group"..killerId)
					pigking_grave.pkc_group_id = killerId
				end
				if not pigking_grave.components.pkc_prefabs then
					pigking_grave:AddComponent("pkc_prefabs")
				end
				if inst.components.pkc_group then
					local king_name = GLOBAL.getNamebyGroupId(inst.components.pkc_group:getChooseGroup())
					if king_name then
						pigking_grave.components.pkc_prefabs:make(king_name..GLOBAL.PKC_SPEECH.GRAVESTONE_TIPS.SPEECH1, GLOBAL.PKC_SPEECH.GRAVESTONE_TIPS.SPEECH2..king_name..GLOBAL.PKC_SPEECH.GRAVESTONE_TIPS.SPEECH3) --定制prefab
					end
				end
			end
		end)
	end
end

--boss击杀公告
local function bossKilledAnnounce(boss, killer)
	if GLOBAL.BOSS_NAME[boss.prefab] then
		GLOBAL.pkc_announce(GLOBAL.MODAL_WORDS[math.random(#(GLOBAL.MODAL_WORDS))]..GLOBAL.PKC_SPEECH.COMMA..GLOBAL.BOSS_NAME[boss.prefab].NAME..GLOBAL.PKC_SPEECH.KILLED_ANNOUNCE.SPEECH1..killer.name..GLOBAL.PKC_SPEECH.KILLED_ANNOUNCE.SPEECH2)
	end
end

--监听死亡
local function onEntityDied(data, inst)
	if data and data.inst and data.afflicter and not data.inst.pkc_hasKilled then
		data.inst.pkc_hasKilled = true
		--击杀者必须有队伍才能得分
		if data.afflicter.components.pkc_group then
			local killer_group_id = data.afflicter.components.pkc_group:getChooseGroup()
			if killer_group_id ~= nil and killer_group_id > 0 then
				if data.inst.components.pkc_group then --被击杀者有队伍
					if data.inst.components.pkc_group:getChooseGroup() ~= data.afflicter.components.pkc_group:getChooseGroup() then --击杀的是其他队伍的成员
						if data.inst:HasTag("player") then --击杀的是玩家
							inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL.PLAYER)
							inst.components.pkc_playerinfos:addPlayerKillNum(data.afflicter)
							inst.components.pkc_playerinfos:addPlayerScore(data.afflicter, GLOBAL.GAME_SCORE.KILL.PLAYER)
						elseif data.inst:HasTag("king") then --敌对首领
							inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL.KING)
							setGravestoneForKing(data.inst, killer_group_id) --设置墓碑
							GLOBAL.TheWorld:PushEvent("pkc_kingbekilled", {killed_group_id  = data.inst.components.pkc_group:getChooseGroup(), killer = data.afflicter})
						else --其他成员
							if data.inst.prefab ~= nil and GLOBAL.GAME_SCORE.KILL[data.inst.prefab] ~= nil then
								inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
								inst.components.pkc_playerinfos:addPlayerScore(data.afflicter, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
							end
						end
					end
				else --被击杀者没有队伍
					bossKilledAnnounce(data.inst, data.afflicter) --boss击杀公告
					if data.inst.prefab ~= nil and GLOBAL.GAME_SCORE.KILL[data.inst.prefab] ~= nil then
						inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
						inst.components.pkc_playerinfos:addPlayerScore(data.afflicter, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
					end
				end
			end
		else
			if data.inst.components.pkc_group and data.inst:HasTag("king") then
				setGravestoneForKing(data.inst) --设置墓碑
				GLOBAL.TheWorld:PushEvent("pkc_kingbekilled", {killed_group_id  = data.inst.components.pkc_group:getChooseGroup(), killer = data.afflicter})
			end
		end
	end
end

--监听贡献物品
local function onGiveScoreItem(data, inst)
	if data then
		if data.giver and data.getter and data.addScore and data.giver.components.pkc_group and data.getter.components.pkc_group then
			inst.components.pkc_groupscore:addGroupScore(data.getter.components.pkc_group:getChooseGroup(), data.addScore)
			inst.components.pkc_playerinfos:addPlayerScore(data.giver, data.addScore)
		end
	end
end

--监听胜利
local function onWin(win_data, inst)
	if win_data then
		inst:DoTaskInTime(.1, function()
			GLOBAL.SpawnPrefab("lightning")
			if inst and inst.components.pkc_popdialog then
				local data = {}
				local winPlayers = {}
				for _, player in pairs(GLOBAL.AllPlayers) do
					if player and player.components.pkc_group and player.components.pkc_group:getChooseGroup() == win_data.winner then
						winPlayers[player.userid] = 1
					end
				end
				data.type = GLOBAL.WIN_POPDIALOG
				data.title = GLOBAL.PKC_SPEECH.WINDIALOG_TITLE
				data.message = GLOBAL.PKC_SPEECH.WINDIALOG_CONTENT.SPEECH1..GLOBAL.getNamebyGroupId(win_data.winner)..GLOBAL.PKC_SPEECH.WINDIALOG_CONTENT.SPEECH2
				data.buttonText = GLOBAL.PKC_SPEECH.WINDIALOG_FAILED_BUTTON
				data.winPlayers = winPlayers
				inst.components.pkc_popdialog:setData(data)
				inst.components.pkc_popdialog:show()
			end
		end)

		inst:DoTaskInTime(20, function()
			GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.COUNT_POINTS.SPEECH1)
		end)

		if GLOBAL.AUTO_RESET_WORLD then
			inst:DoTaskInTime(30, function()
				GLOBAL.SpawnPrefab("lightning")
				GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.WORLDRESET_TIPS.SPEECH1)
			end)
			inst:DoTaskInTime(55, function()
				GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.WORLDRESET_TIPS.SPEECH2)
			end)
			inst:DoTaskInTime(60, function()
				GLOBAL.c_regenerateworld()
			end)
		end
	end
end

--转移财产（善后）（赢得一方占领）
local function transferProperty(killedId, killerId)
	local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 1000,{"pkc_group"..killedId})
	for _, obj in pairs(ents) do
		if obj and not obj:HasTag("player") then
			if obj:HasTag("pkc_defences") and not obj:HasTag("burnt") and obj.Transform then
				obj:DoTaskInTime(math.random(3), function()
					local currentscale = obj.Transform:GetScale()
					local collapse = GLOBAL.SpawnPrefab("collapse_small")
					if collapse then
						collapse.Transform:SetPosition(obj.Transform:GetWorldPosition())
						collapse.Transform:SetScale(currentscale*1,currentscale*1,currentscale*1)
					end
					obj:Remove()
				end)
			else
				if killerId then
					obj:RemoveTag("pkc_group"..killedId)
					obj.pkc_group_id = nil
					obj.pkc_group_id = killerId
					obj:AddTag("pkc_group"..killerId)
					if obj.saveTags ~= nil and GLOBAL.next(obj.saveTags) ~= nil then
						obj.saveTags["pkc_group"..killedId] = nil
						obj.saveTags["pkc_group"..killerId] = 1
					end
				end
			end
		end
	end
end

--解散队伍成员
local  function dissolvePlayers(killedId)
	for _,player in ipairs(GLOBAL.AllPlayers) do
		if player and player:IsValid() and player.components.pkc_group and player.components.pkc_group:getChooseGroup() == killedId then
			if player.components.talker then
				player:DoTaskInTime(0, function()
					if player and player.components.talker then
						player.components.talker:Say(GLOBAL.PKC_SPEECH.PLAYER_LOSE_TIPS)
					end
				end)
			end
			player:DoTaskInTime(6, function()
				if player ~= nil and player:IsValid() then
					if GLOBAL.TheWorld.ismastersim then
						GLOBAL.TheWorld:PushEvent("ms_playerdespawnanddelete", player)
					end
				end
			end)
		end
	end
end

--移除阵营
local function removeGroup(inst, group_id)
	if inst and inst.components.pkc_existgroup then
		inst.components.pkc_existgroup:removeGroup(group_id)
	end
end

--检查胜利
local function checkWin(inst)
	if GLOBAL.tablelength(GLOBAL.CURRENT_EXIST_GROUPS) == 1 then
		--最后一个队伍胜利
		local winner = nil
		for _, groupId in pairs(GLOBAL.CURRENT_EXIST_GROUPS) do
			winner = groupId
		end
		if winner then
			GLOBAL.TheWorld:PushEvent("pkc_win", { winner = winner})
		end
	end
end

--监听国王被杀
local function onKingbekilled(data, inst)
	if data and inst and data.killed_group_id and data.killer then
		--击杀公告提示
		GLOBAL.SpawnPrefab("lightning")
		GLOBAL.pkc_announce(GLOBAL.getNamebyGroupId(data.killed_group_id)..GLOBAL.PKC_SPEECH.KINGBEKILLED_ANNOUNCE.SPEECH1..data.killer.name..GLOBAL.PKC_SPEECH.KINGBEKILLED_ANNOUNCE.SPEECH2)
		--标记被消灭
		inst.components.pkc_groupscore:setGroupScore(data.killed_group_id, -9999)
		--如果击杀者为其他队伍，则转移财产
		if data.killer and data.killer.components.pkc_group then --善后
			transferProperty(data.killed_group_id, data.killer.components.pkc_group:getChooseGroup())
		else
			transferProperty(data.killed_group_id)
		end
		--解散成员
		dissolvePlayers(data.killed_group_id)
		--移除阵营
		removeGroup(inst, data.killed_group_id)
		--检查是否胜利了
		checkWin(data.killer)
		--阵营被消灭提示
		inst:DoTaskInTime(10, function()
			if data.killer then
				GLOBAL.SpawnPrefab("lightning")
				if data.killer.components.pkc_group then
					GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.GROUP_SMASH.SPEECH1..GLOBAL.getNamebyGroupId(data.killed_group_id)..GLOBAL.PKC_SPEECH.GROUP_SMASH.SPEECH2..GLOBAL.getNamebyGroupId(data.killer.components.pkc_group:getChooseGroup())..GLOBAL.PKC_SPEECH.GROUP_SMASH.SPEECH3)
				else
					GLOBAL.pkc_announce(GLOBAL.PKC_SPEECH.GROUP_SMASH.SPEECH1..GLOBAL.getNamebyGroupId(data.killed_group_id)..GLOBAL.PKC_SPEECH.GROUP_SMASH.SPEECH2..data.killer.name..GLOBAL.PKC_SPEECH.GROUP_SMASH.SPEECH4)
				end
			end
		end)
	end
end

--测试用
local function TransToOtherBase(inst)

	if GLOBAL.TheWorld.state.cycles % 4 == 1 then
		local x = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_BIGPIG_POS_x"]
		local z = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_BIGPIG_POS_z"]
		for _,player in pairs(GLOBAL.AllPlayers) do
			player.Transform:SetPosition(x, 0, z)
		end
	end

	if GLOBAL.TheWorld.state.cycles % 4 == 2 then
		local x = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_LONGPIG_POS_x"]
		local z = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_LONGPIG_POS_z"]
		for _,player in pairs(GLOBAL.AllPlayers) do
			player.Transform:SetPosition(x, 0, z)
		end
	end

	if GLOBAL.TheWorld.state.cycles % 4 == 3 then
		local x = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_CUIPIG_POS_x"]
		local z = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_CUIPIG_POS_z"]
		for _,player in pairs(GLOBAL.AllPlayers) do
			player.Transform:SetPosition(x, 0, z)
		end
	end
end

--世界初始化
AddPrefabPostInit("world", function(inst)
	if inst then
		--添加防止队友相互攻击组件
		inst:AddComponent("pkc_checkattack")
		inst.components.pkc_checkattack:isGroupMember(checkIsGroupMemberFn)
		--添加记录阵营位置组件
		if IsServer then
			inst:AddComponent("pkc_baseinfo")
			--传送到其他基地（测试用）
			--inst:ListenForEvent("ms_cyclecomplete", function() TransToOtherBase(inst) end)
			--给初始物品
			if GLOBAL.GIVE_START_ITEM then
				inst:ListenForEvent("ms_playerspawn", startingInventory, inst)
			end
		end
	end
end)

local json = require "json"
local function onPlayerJoin(inst, player)
	inst:DoTaskInTime(0, function()
		if inst and inst.components.pkc_playerinfos and GLOBAL.PKC_PLAYER_INFOS then
			if IsServer then
				--让客户端获取最新数据
				inst.components.pkc_playerinfos._playerinfos:set(json.encode(GLOBAL.PKC_PLAYER_INFOS))
			end
		end
	end)
end

local function onPlayerLeft(inst, player)
	inst:DoTaskInTime(0, function()
	end)
end

local function network(inst)
	--添加队伍得分机制
	inst:AddComponent("pkc_groupscore")
	--初始化存在队伍
	inst:AddComponent("pkc_existgroup")
	--简单弹框
	inst:AddComponent("pkc_popdialog")
	--玩家信息
	inst:AddComponent("pkc_playerinfos")

	inst:DoTaskInTime(0, function()
		inst.components.pkc_existgroup:init()
	end)
	--添加监听事件
	if IsServer then
		--物体死亡
		inst:ListenForEvent("entity_death", function(world, data) onEntityDied(data, inst) end, GLOBAL.TheWorld)
		--贡献得分
		inst:ListenForEvent("pkc_giveScoreItem", function(world, data) onGiveScoreItem(data, inst) end, GLOBAL.TheWorld)
		--猪王被杀
		inst:ListenForEvent("pkc_kingbekilled", function(world, data) onKingbekilled(data, inst) end, GLOBAL.TheWorld)
		--胜利
		inst:ListenForEvent("pkc_win", function(world, data) onWin(data, inst) end, GLOBAL.TheWorld)
		--玩家加入
		inst:ListenForEvent("ms_playerjoined", function (world, player) onPlayerJoin(inst, player) end, GLOBAL.TheWorld)
		--玩家离开
		--inst:ListenForEvent("ms_playerleft", function (world, player) onPlayerLeft(inst, player) end, GLOBAL.TheWorld)
		--玩家加入
		--inst:ListenForEvent("ms_playerjoined", function (world, player) onPlayerJoin(inst, player) end, GLOBAL.TheWorld)
		--玩家离开
		--inst:ListenForEvent("ms_playerleft", function (world, player) onPlayerLeft(inst, player) end, GLOBAL.TheWorld)
	end
end

AddPrefabPostInit("forest_network", network)
AddPrefabPostInit("cave_network", network)

--得分显示
AddClassPostConstruct("widgets/controls", function(wdt)
	wdt.inst:DoTaskInTime(0, function()
		local pkc_scoreboard = require "widgets/pkc_scoreboard"

		if GLOBAL.GROUP_NUM >= 2 then
			wdt.pvp_widget1 = wdt.top_root:AddChild(pkc_scoreboard())
			wdt.pvp_widget2 = wdt.top_root:AddChild(pkc_scoreboard())
		end
		if GLOBAL.GROUP_NUM >= 3 then
			wdt.pvp_widget3 = wdt.top_root:AddChild(pkc_scoreboard())
		end
		if GLOBAL.GROUP_NUM >= 4 then
			wdt.pvp_widget4 = wdt.top_root:AddChild(pkc_scoreboard())
		end

		wdt.d_colour1,wdt.d_colour2,wdt.d_colour3 = GLOBAL.HexToPercentColor(GLOBAL.PKC_GROUP_INFOS.BIGPIG.score_color)
		wdt.r_colour1,wdt.r_colour2,wdt.r_colour3 = GLOBAL.HexToPercentColor(GLOBAL.PKC_GROUP_INFOS.REDPIG.score_color)
		wdt.l_colour1,wdt.l_colour2,wdt.l_colour3 = GLOBAL.HexToPercentColor(GLOBAL.PKC_GROUP_INFOS.LONGPIG.score_color)
		wdt.c_colour1,wdt.c_colour2,wdt.c_colour3 = GLOBAL.HexToPercentColor(GLOBAL.PKC_GROUP_INFOS.CUIPIG.score_color)

		local old_OnUpdate = wdt.OnUpdate
		wdt.OnUpdate = function(self, dt)

			old_OnUpdate(self, dt)
			wdt.pvp_widget1.button:SetText(GLOBAL.SHORT_NAME.BIGPIG..":"..(_G.GROUP_SCORE.GROUP1_SCORE >=0 and _G.GROUP_SCORE.GROUP1_SCORE or GLOBAL.PKC_SPEECH.GROUP_BEKILLED))
			wdt.pvp_widget1.button:SetTextColour(wdt.d_colour1, wdt.d_colour2, wdt.d_colour3, 1)
			wdt.pvp_widget1.button:SetTextSize(48)

			wdt.pvp_widget2.button:SetText(GLOBAL.SHORT_NAME.REDPIG..":"..(_G.GROUP_SCORE.GROUP2_SCORE >=0 and _G.GROUP_SCORE.GROUP2_SCORE or GLOBAL.PKC_SPEECH.GROUP_BEKILLED))
			wdt.pvp_widget2.button:SetTextColour(wdt.r_colour1, wdt.r_colour2, wdt.r_colour3, 1)
			wdt.pvp_widget2.button:SetTextSize(48)

			if GLOBAL.GROUP_NUM >= 2 then
				wdt.pvp_widget1:SetPosition(-75,-15,0)
				wdt.pvp_widget2:SetPosition(75,-15,0)
			end

			if GLOBAL.GROUP_NUM >= 3 then
				wdt.pvp_widget3.button:SetText(GLOBAL.SHORT_NAME.LONGPIG..":"..(_G.GROUP_SCORE.GROUP3_SCORE >=0 and _G.GROUP_SCORE.GROUP3_SCORE or GLOBAL.PKC_SPEECH.GROUP_BEKILLED))
				wdt.pvp_widget3.button:SetTextColour(wdt.l_colour1, wdt.l_colour2, wdt.l_colour3, 1)
				wdt.pvp_widget3.button:SetTextSize(48)

				wdt.pvp_widget1:SetPosition(-150,-15,0)
				wdt.pvp_widget2:SetPosition(0,-15,0)
				wdt.pvp_widget3:SetPosition(150,-15,0)
			end

			if GLOBAL.GROUP_NUM >= 4 then
				wdt.pvp_widget4.button:SetText(GLOBAL.SHORT_NAME.CUIPIG..":"..(_G.GROUP_SCORE.GROUP4_SCORE >=0 and _G.GROUP_SCORE.GROUP4_SCORE or GLOBAL.PKC_SPEECH.GROUP_BEKILLED))
				wdt.pvp_widget4.button:SetTextColour(wdt.c_colour1, wdt.c_colour2, wdt.c_colour3, 1)
				wdt.pvp_widget4.button:SetTextSize(48)

				wdt.pvp_widget1:SetPosition(-225,-15,0)
				wdt.pvp_widget2:SetPosition(-75,-15,0)
				wdt.pvp_widget3:SetPosition(75,-15,0)
				wdt.pvp_widget4:SetPosition(225,-15,0)
			end
		end
	end)
end)

















