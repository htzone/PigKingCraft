--@name pkc_rpchandler
--@description RPC调用处理
--@auther redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

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

--添加按钮的RPC
--@大猪猪 11-02
AddModRPCHandler("pkc_teleport", "TeleportToBase", function(player, group_id)
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
			GLOBAL.pkc_announce(player.name.." 选择加入了 "..v.name.." 阵营！")
			local x = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_"..k.."_POS_x"]
			local z = GLOBAL.TheWorld.components.pkc_baseinfo["GROUP_"..k.."_POS_z"]
			player.components.pkc_group:setBasePos({x, 0 , z}) --记住自己的基地位置
			player.Transform:SetPosition(x, 0, z)
			player:DoTaskInTime(2, function()
				if player and player.components.talker then
					player.components.talker:Say("我来到了 "..v.name.."阵营！")
				end
			end)
			--根据选择的阵营进行相应的头部显示
			player.components.pkc_headshow:setHeadText(player:GetDisplayName())
			player.components.pkc_headshow:setHeadColor(v.color)
			player.components.pkc_headshow:setChoose(true)
			break
		end
	end
end)