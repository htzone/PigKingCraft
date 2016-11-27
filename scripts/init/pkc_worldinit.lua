--@name pkc_worldinit
--@description 世界初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

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
		if not inst.components.exautodelete then
			inst:AddComponent("exautodelete")
		end
		inst.components.exautodelete:SetPerishTime(GLOBAL.AUTO_DELETE_TIME)
		inst.components.exautodelete:StartPerishing()
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

	--如果初始点在洞穴
	if GLOBAL.TheWorld:HasTag("cave") then
		giveItemToPlayer(startInventory, 1, "minerhat") --矿工帽
	end
	
	--if player.prefab ~= "wathgrithr" then
	--print("----wathgrithr------"..player.name)
	--end
	--如果是PVP模式
	--if GLOBAL.TheNet:GetPVPEnabled() then
	--	if player.prefab ~= "wathgrithr" then
	--		giveItemToPlayer(startInventory, 1, "spear") --长矛
	--		giveItemToPlayer(startInventory, 1, "footballhat") --皮帽
	--	end
	--end

	--玩家第一次进入时获取初始物品
	player.CurrentOnNewSpawn = player.OnNewSpawn or function() return true end
	player.OnNewSpawn = function(...)
		player.components.inventory.ignoresound = true
		if startInventory ~= nil and #startInventory > 0 then
			for i, itemName in pairs(startInventory) do
				player.components.inventory:GiveItem(GLOBAL.SpawnPrefab(itemName))
			end
		end
		return player.CurrentOnNewSpawn(...)
	end
	
end

--检查是不是同盟关系。
local function checkIsGroupMemberFn(attacker, target)
	if attacker and target then
		if attacker.components.pkc_group and target.components.pkc_group 
		and attacker.components.pkc_group:getChooseGroup() == target.components.pkc_group:getChooseGroup() 
		then
			return true;
		end
	end
	return false
end

--设置国王墓碑
local function setGravestoneForKing(inst, killerId)
	local pt = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
	inst:DoTaskInTime(1, function()
		GLOBAL.SpawnPrefab("lightning").Transform:SetPosition(pt:Get())
		GLOBAL.SpawnPrefab("maxwell_smoke").Transform:SetPosition(pt:Get())
		local ground_fx = GLOBAL.SpawnPrefab("groundpoundring_fx")
		ground_fx.Transform:SetScale(1,1,1)
		ground_fx.Transform:SetPosition(pt:Get())
		local pigking_grave = GLOBAL.SpawnPrefab("gravestone")
		if pigking_grave and pigking_grave.Transform then
			pigking_grave.Transform:SetPosition(pt:Get())
			pigking_grave:AddTag("king")
			pigking_grave:AddTag("kinggrave")
			pigking_grave:AddTag("pkc_group"..killerId)
			pigking_grave.pkc_group_id = killerId
			if not pigking_grave.components.pkc_prefabs then
				pigking_grave:AddComponent("pkc_prefabs")
			end
			if inst.components.pkc_group then
				local king_name = GLOBAL.getNamebyGroupId(inst.components.pkc_group:getChooseGroup())
				pigking_grave.components.pkc_prefabs:make(king_name..GLOBAL.PKC_SPEECH.GRAVESTONE_TIPS.SPEECH1, GLOBAL.PKC_SPEECH.GRAVESTONE_TIPS.SPEECH2..king_name..GLOBAL.PKC_SPEECH.GRAVESTONE_TIPS.SPEECH3) --定制prefab
			end
		end
	end)
end

--boss击杀公告
local function bossKilledAnnounce(boss, killer)
	if GLOBAL.BOSS_NAME[boss.prefab] then
		GLOBAL.pkc_announce(GLOBAL.MODAL_WORDS[math.random(#(GLOBAL.MODAL_WORDS))]..GLOBAL.PKC_SPEECH.COMMA..GLOBAL.BOSS_NAME[boss.prefab].NAME..GLOBAL.PKC_SPEECH.KILLED_ANNOUNCE.SPEECH1..killer.name..GLOBAL.PKC_SPEECH.KILLED_ANNOUNCE.SPEECH2)
	end
end

--监听死亡
local function onEntityDied(data, inst)
	if data and data.inst and data.afflicter then
		--击杀者必须有队伍才能得分
		if data.afflicter.components.pkc_group then
		
			local killer_group_id = data.afflicter.components.pkc_group:getChooseGroup()
			
			if data.inst.components.pkc_group then --被击杀者有队伍
				if data.inst.components.pkc_group:getChooseGroup() ~= data.afflicter.components.pkc_group:getChooseGroup() then --击杀的是其他队伍的成员
					if data.inst:HasTag("player") then --击杀的是玩家
						inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL.PLAYER)
					elseif data.inst:HasTag("king") then --敌对首领
						inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL.KING)
						setGravestoneForKing(data.inst, killer_group_id)
						GLOBAL.TheWorld:PushEvent("pkc_kingbekilled", {killed_group_id  = data.inst.components.pkc_group:getChooseGroup(), killer = data.afflicter})
					else --其他成员
						if GLOBAL.GAME_SCORE.KILL[data.inst.prefab] ~= nil then
							inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
						end
					end
				end
			else --被击杀者没有队伍
				bossKilledAnnounce(data.inst, data.afflicter) --boss击杀公告
				if GLOBAL.GAME_SCORE.KILL[data.inst.prefab] ~= nil then
					inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
				end
			end
		else
			if data.inst:HasTag("king") and data.inst.components.pkc_group then
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
		end
	end
end

--监听胜利
local function onWin(data, inst)
	if data then
		inst:DoTaskInTime(.5, function()
			if inst and inst.components.pkc_popdialog then
				inst.components.pkc_popdialog:setTitle(GLOBAL.PKC_SPEECH.WINDIALOG_TITLE)
				inst.components.pkc_popdialog:setMessage(GLOBAL.PKC_SPEECH.WINDIALOG_CONTENT.SPEECH1..GLOBAL.getNamebyGroupId(data.winner)..GLOBAL.PKC_SPEECH.WINDIALOG_CONTENT.SPEECH2)
				inst.components.pkc_popdialog:setButtonText(GLOBAL.PKC_SPEECH.WINDIALOG_BUTTON)
				inst.components.pkc_popdialog:show()
			end
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
 
--转移财产（赢得一方占领）
local function transferProperty(killedId, killerId)
	local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 1000,{"pkc_group"..killedId})
	for _, obj in pairs(ents) do
		 if obj and not obj:HasTag("player") then
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
			player:DoTaskInTime(5, function()
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
		--if inst and inst.components.pkc_group then
		--	local winner = inst.components.pkc_group:getChooseGroup()
		--	GLOBAL.TheWorld:PushEvent("pkc_win", { winner = winner})
		--end
	end
end

--监听国王被杀
local function onKingbekilled(data, inst)
	if data then
		GLOBAL.SpawnPrefab("lightning")
		GLOBAL.pkc_announce(GLOBAL.getNamebyGroupId(data.killed_group_id)..GLOBAL.PKC_SPEECH.KINGBEKILLED_ANNOUNCE.SPEECH1..data.killer.name..GLOBAL.PKC_SPEECH.KINGBEKILLED_ANNOUNCE.SPEECH2)
		inst.components.pkc_groupscore:setGroupScore(data.killed_group_id, -9999) --标记被消灭
		if data.killer and data.killer.components.pkc_group then
			transferProperty(data.killed_group_id, data.killer.components.pkc_group:getChooseGroup()) --转移财产
		end
		
		dissolvePlayers(data.killed_group_id) --解散成员
		removeGroup(inst, data.killed_group_id) --移除阵营
		checkWin(data.killer) --检查胜利
		
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

--[[
--测试用
local function updateWorld(inst)
	inst:DoTaskInTime(8, function()

	end)
	
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
]]--

--世界初始化
--@大猪猪 10-31
AddPrefabPostInit("world", function(inst)
	if inst then
		--添加防止队友相互攻击组件
		inst:AddComponent("pkc_checkattack")
		inst.components.pkc_checkattack:isGroupMember(checkIsGroupMemberFn)
		--添加记录阵营位置组件
		if IsServer then
			inst:AddComponent("pkc_baseinfo")	
			--inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(inst) end)
			--给初始物品
			if GLOBAL.GIVE_START_ITEM then 
				inst:ListenForEvent("ms_playerspawn", startingInventory, inst)
			end
		end
	end
end)

local function network(inst)
	--添加队伍得分机制
    inst:AddComponent("pkc_groupscore")
	--初始化存在队伍
	inst:AddComponent("pkc_existgroup")
	
	inst:AddComponent("pkc_popdialog")
	
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
		
		wdt.d_colour1,wdt.d_colour2,wdt.d_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.BIGPIG.score_color)
		wdt.r_colour1,wdt.r_colour2,wdt.r_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.REDPIG.score_color)
		wdt.l_colour1,wdt.l_colour2,wdt.l_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.LONGPIG.score_color)
		wdt.c_colour1,wdt.c_colour2,wdt.c_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.CUIPIG.score_color)
		
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

















