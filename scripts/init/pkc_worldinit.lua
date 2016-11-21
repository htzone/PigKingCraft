--@name pkc_worldinit
--@description 世界初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

local _G = _G or GLOBAL
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local require = GLOBAL.require

--通过组件实现的prefab
local ComponentPrefabs = {
"gravestone",
}
local function addComponent(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:AddComponent("pkc_prefabs")
	end
end
for _,v in pairs(ComponentPrefabs) do
	AddPrefabPostInit(v, addComponent) --组件实现的prefab,减少定义prefab的麻烦
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
			pigking_grave:AddComponent("pkc_prefabs")
			if inst.components.pkc_group then
				local king_name = GLOBAL.getNamebyGroupId(inst.components.pkc_group:getChooseGroup())
				pigking_grave.components.pkc_prefabs:make(king_name.."沉睡的地方", "可惜，"..king_name.."已是曾经的辉煌！") --定制prefab
			end
		end
	end)
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
				if GLOBAL.GAME_SCORE.KILL[data.inst.prefab] ~= nil then
					inst.components.pkc_groupscore:addGroupScore(killer_group_id, GLOBAL.GAME_SCORE.KILL[data.inst.prefab])
				end
			end
			
		end
	end
end

--监听贡献物品
local function onGiveScoreItem(data, inst)
	if data then
		if data.giver and data.getter and data.giver.components.pkc_group and data.getter.components.pkc_group then
			--if data.giver.components.pkc_group:getChooseGroup() == data.getter.components.pkc_group:getChooseGroup() then
				if data.getter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_BIGPIG_ID then
					inst.components.pkc_groupscore:addGroup1Score(data.addScore)
				elseif data.getter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_REDPIG_ID then 
					inst.components.pkc_groupscore:addGroup2Score(data.addScore)
				elseif data.getter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_LONGPIG_ID then
					inst.components.pkc_groupscore:addGroup3Score(data.addScore)
				elseif data.getter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_CUIPIG_ID then
					inst.components.pkc_groupscore:addGroup4Score(data.addScore)
				end
			--end
		end
	end
end

--监听胜利
local function onWin(data, inst)
	if data then
		GLOBAL.SpawnPrefab("lightning")
		if data.winner == GLOBAL.GROUP_BIGPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.BIGPIG.name.."阵营 取得了最后的胜利！！！", 30)
		elseif data.winner == GLOBAL.GROUP_REDPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.REDPIG.name.."阵营 取得了最后的胜利！！！", 30)
		elseif data.winner == GLOBAL.GROUP_LONGPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.LONGPIG.name.."阵营 取得了最后的胜利！！！", 30)
		elseif data.winner == GLOBAL.GROUP_CUIPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.CUIPIG.name.."阵营 取得了最后的胜利！！！", 30)
		end
	end
end
 
--转移财产
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
					player.components.talker:Say("不！我们要解散了！！！")
				end)
			end
			player:DoTaskInTime(4, function()
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
	--GLOBAL.GROUP_NUM = 3
	--未实现
	inst.components.pkc_existgroup:setExistGroupNum(GLOBAL.GROUP_NUM - 1)
end

--监听国王被杀
local function onKingbekilled(data, inst)
	if data then
		GLOBAL.SpawnPrefab("lightning")
		if data.killed_group_id == GLOBAL.GROUP_BIGPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.BIGPIG.name.."首领 已被 "..data.killer.name.." 击杀！！！")
		elseif data.killed_group_id == GLOBAL.GROUP_REDPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.REDPIG.name.."首领 已被 "..data.killer.name.." 击杀！！！")
		elseif data.killed_group_id == GLOBAL.GROUP_LONGPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.LONGPIG.name.."首领 已被 "..data.killer.name.." 击杀！！！")
		elseif data.killed_group_id == GLOBAL.GROUP_CUIPIG_ID then
			GLOBAL.pkc_announce(GLOBAL.GROUP_INFOS.CUIPIG.name.."首领 已被 "..data.killer.name.." 击杀！！！")
		end
		
		if data.killer and data.killer.components.pkc_group then
			transferProperty(data.killed_group_id, data.killer.components.pkc_group:getChooseGroup()) --转移财产
		end
		
		dissolvePlayers(data.killed_group_id) --解散成员
		removeGroup(inst, data.killed_group_id) --移除阵营
		
		inst:DoTaskInTime(10, function()
			GLOBAL.SpawnPrefab("lightning")
			GLOBAL.pkc_announce("不好啦，"..GLOBAL.getNamebyGroupId(data.killed_group_id).."阵营 已被 "..GLOBAL.getNamebyGroupId(data.killer.components.pkc_group:getChooseGroup()).."阵营 消灭啦！！！")
		end)
	end
end

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
			inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(inst) end)
		end
	end
end)

local function network(inst)
	--添加队伍得分机制
    inst:AddComponent("pkc_groupscore")
	inst:AddComponent("pkc_existgroup")
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
	
		local Pvp_Widget = require "widgets/pvp_widget"
		wdt.pvp_widget1 = wdt.top_root:AddChild(Pvp_Widget())
		wdt.pvp_widget2 = wdt.top_root:AddChild(Pvp_Widget())
		wdt.pvp_widget3 = wdt.top_root:AddChild(Pvp_Widget())
		wdt.pvp_widget4 = wdt.top_root:AddChild(Pvp_Widget())
		
		wdt.d_colour1,wdt.d_colour2,wdt.d_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.BIGPIG.score_color)
		wdt.r_colour1,wdt.r_colour2,wdt.r_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.REDPIG.score_color)
		wdt.l_colour1,wdt.l_colour2,wdt.l_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.LONGPIG.score_color)
		wdt.c_colour1,wdt.c_colour2,wdt.c_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.CUIPIG.score_color)
		
		local old_OnUpdate = wdt.OnUpdate
		wdt.OnUpdate = function(self, dt)
		
			old_OnUpdate(self, dt)
			
			wdt.pvp_widget1.button:SetText("大:"..(_G.GROUP_SCORE.GROUP1_SCORE or 0))
			wdt.pvp_widget1.button:SetTextColour(wdt.d_colour1, wdt.d_colour2, wdt.d_colour3, 1)
			wdt.pvp_widget1.button:SetTextSize(48)
			wdt.pvp_widget1:SetPosition(-225,-15,0)
			
			wdt.pvp_widget2.button:SetText("红:"..(_G.GROUP_SCORE.GROUP2_SCORE or 0))
			wdt.pvp_widget2.button:SetTextColour(wdt.r_colour1, wdt.r_colour2, wdt.r_colour3, 1)
			wdt.pvp_widget2.button:SetTextSize(48)
			wdt.pvp_widget2:SetPosition(-75,-15,0)

			wdt.pvp_widget3.button:SetText("龙:"..(_G.GROUP_SCORE.GROUP3_SCORE or 0))
			wdt.pvp_widget3.button:SetTextColour(wdt.l_colour1, wdt.l_colour2, wdt.l_colour3, 1)
			wdt.pvp_widget3.button:SetTextSize(48)
			wdt.pvp_widget3:SetPosition(75,-15,0)
			
			wdt.pvp_widget4.button:SetText("崔:"..(_G.GROUP_SCORE.GROUP4_SCORE or 0))
			wdt.pvp_widget4.button:SetTextColour(wdt.c_colour1, wdt.c_colour2, wdt.c_colour3, 1)
			wdt.pvp_widget4.button:SetTextSize(48)
			wdt.pvp_widget4:SetPosition(225,-15,0)	
			
		end
	end)
end)

















