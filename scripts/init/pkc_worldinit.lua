--@name pkc_worldinit
--@description 世界初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--检查是不是同盟关系。
local function checkFn(attacker, target)
	if attacker and target then
		if attacker.components.pkc_group 
		and target.components.pkc_group 
		and attacker.components.pkc_group.hasChoosen == target.components.pkc_group.hasChoosen then
			return true
		end
	end
	return false
end

--世界初始化
--@大猪猪 10-31
AddPrefabPostInit("world", function(inst)
	if inst then
		
		--添加防止队友相互攻击组件
		inst:AddComponent("pkc_checkattack")
		inst.components.pkc_checkattack:isGroupMember(checkFn)
		
		if IsServer then
			inst:AddComponent("pkc_baseinfo")	--记录阵营的位置
		end
	end
end)


--取消无敌状态
local function cnancleInvincible(player, delay_time)
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
	if not player.components.pkc_group then
		player:AddComponent("pkc_group")
	end
	player.components.pkc_group:setChoosen(group_id)
	
	cnancleInvincible(player, 5)
	
	local t=
	{
		GROUP_BIGPIG_POS = { id=GLOBAL.GROUP_BIGPIG_ID, info="大猪猪营地", color={0,1,0}, },
		GROUP_REDPIG_POS = { id=GLOBAL.GROUP_REDPIG_ID, info="红猪猪营地", color={1,0,0}, },
		GROUP_LONGPIG_POS = { id=GLOBAL.GROUP_LONGPIG_ID, info="龙猪猪营地", color={0,0,1}, },
		GROUP_CUIPIG_POS = { id=GLOBAL.GROUP_CUIPIG_ID, info="崔猪猪营地", color={1,0,1}, },
	}
	for k,v in pairs(t) do
		if group_id == t[k].id then
			local x = GLOBAL.TheWorld.components.pkc_baseinfo[k.."_x"]
			local z = GLOBAL.TheWorld.components.pkc_baseinfo[k.."_z"]
			player.Transform:SetPosition(x,0,z)
			if player.components.talker then
				player.components.talker:Say("我来到了 "..t[k].info.." 坐标位置是 { "..x..", ".."0, "..z.." }")
			end
			
			GLOBAL.pkc_spawnat(player,"pkc_title",{0,3,0},1,function(guy,player)
				guy.Label:SetColour(GLOBAL.unpack(v.color))
				guy.Label:SetText( string.sub(player:GetDisplayName(),1,20) )
				if player.pkc_title~=nil then
					player.pkc_title:Remove()
					player.pkc_title=guy
				end
			end)
			
			break
		end
	end
end)













