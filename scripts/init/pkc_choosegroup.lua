--@name pkc_multiplayer_portal
--@description 阵营选择
--@auther redpig
--@date 2016-10-23

local require = GLOBAL.require
local SpawnPrefab = GLOBAL.SpawnPrefab

--让玩家无敌
local function makePlayerInvincible(player)
	print("name:"..player.name)
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
	print("name:"..player.name)
	if player 
	--and player.components.pkc_group 
	--and player.components.pkc_group:getChoosen() == 0		
	and player.hasChoosen:value() == 0		--这个变量初值为0 
	then --未选择过阵营时执行
		makePlayerInvincible(player)
		local pkc_introduction_screen = require "screens/pkc_introduction_screen"
		GLOBAL.TheFrontEnd:PushScreen(pkc_introduction_screen())
	end
end

--监听玩家加入游戏
AddPrefabPostInit("world", function(inst)
	--if GLOBAL.TheWorld.ismastersim then
	inst:ListenForEvent("playeractivated", showStartWindow, TheWorld)
	--end
end)

