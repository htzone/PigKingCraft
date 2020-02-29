--@name pkc_multiplayer_portal
--@description 阵营选择
--@auther redpig
--@date 2016-10-23

local require = GLOBAL.require
local SpawnPrefab = GLOBAL.SpawnPrefab

--让玩家无敌
local function makePlayerInvincible(player)
	if player and player.components.health then
		player.components.health:SetInvincible(true)
		if player._fx == nil then
			player._fx = SpawnPrefab("forcefieldfx")
		end
		if player._fx then
			player._fx.entity:SetParent(player.entity)
			player._fx.Transform:SetPosition(0, 0.2, 0)	
		end
	end
end

--显示开始弹框
local function showStartWindow(inst, player)
	if player 	
	and player.components.pkc_group:getChooseGroup() == 0 --这个变量初值为0 
	then --未选择过阵营时执行
		local pkc_introduction_screen = require "screens/pkc_introduction_screen"
		GLOBAL.TheFrontEnd:PushScreen(pkc_introduction_screen())
	end
end

--检查队伍是否还存在
local function isMyGroupExist(groupId)
	for _, v in pairs(GLOBAL.CURRENT_EXIST_GROUPS) do
		if v == groupId then
			return true
		end
	end
	return false
end

--监听玩家加入游戏
AddComponentPostInit("playerspawner", function(OnPlayerSpawn, inst)
    inst:ListenForEvent("ms_playerjoined", function(inst, player)
		if player and player.components.pkc_group then
			if player.components.pkc_group:getChooseGroup() == 0 then
				--第一次进入游戏
				makePlayerInvincible(player)
			else
				--如果队伍已被消灭，重新选人
				if not isMyGroupExist(player.components.pkc_group:getChooseGroup()) then
					player:DoTaskInTime(2, function()
						if player and player.components.talker then
							player.components.talker:Say(GLOBAL.PKC_SPEECH.GROUP_HASBE_KILLED)
						end
					end)
					player:DoTaskInTime(5, function()
						if player and player:IsValid() then
						  if GLOBAL.TheWorld.ismastersim then
							GLOBAL.TheWorld:PushEvent("ms_playerdespawnanddelete", player)
						  end
						end
					end)
				end
			end
		end
	end)
end)

--监听玩家加入游戏
AddPrefabPostInit("world", function(inst)
	inst:ListenForEvent("playeractivated", showStartWindow, TheWorld)
end)

