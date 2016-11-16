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
		player._fx = SpawnPrefab("forcefieldfx")
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

AddComponentPostInit("playerspawner", function(OnPlayerSpawn, inst)
    inst:ListenForEvent("ms_playerjoined", function(inst, player)
		if player 
		and player.components.pkc_group
		and player.components.pkc_group:getChooseGroup() == 0 
		then
			makePlayerInvincible(player)
		end
	end)
end)

--监听玩家加入游戏
AddPrefabPostInit("world", function(inst)
	inst:ListenForEvent("playeractivated", showStartWindow, TheWorld)
end)

