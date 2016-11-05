--@name pkc_playerinit
--@description 玩家初始化
--@auther 大猪猪，redpig
--@date 2016-10-23
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--玩家初始化
--@大猪猪 10-31
AddPlayerPostInit(function(inst)
	if inst then
		GLOBAL.pkc_setNetvar(inst,{
			hasChoosen = {"net_shortint", 0},
		})
		if IsServer then	--必须主机加载,否则无法保存
			--添加玩家阵营组件
			inst:AddComponent("pkc_group")
			local t=
			{
				GROUP_BIGPIG_POS = { id=GLOBAL.GROUP_BIGPIG_ID, info="大猪猪营地", color={0,1,0}, },
				GROUP_REDPIG_POS = { id=GLOBAL.GROUP_REDPIG_ID, info="红猪猪营地", color={1,0,0}, },
				GROUP_LONGPIG_POS = { id=GLOBAL.GROUP_LONGPIG_ID, info="龙猪猪营地", color={0,0,1}, },
				GROUP_CUIPIG_POS = { id=GLOBAL.GROUP_CUIPIG_ID, info="崔猪猪营地", color={1,0,1}, },
			}
			inst:DoTaskInTime(0,function()
				for k,v in pairs(t) do
					if inst.components.pkc_group.hasChoosen==v.id then
						if inst.components.talker then
							inst.components.talker:Say("我属于 "..v.info)
						end
						
						GLOBAL.pkc_spawnat(inst,"pkc_title",{0,3,0},1,function(guy,inst)
							guy.Label:SetColour(GLOBAL.unpack(v.color))
							guy.Label:SetText( inst:GetDisplayName() )
							if inst.pkc_title~=nil then
								inst.pkc_title:Remove()
								inst.pkc_title=guy
							end
						end)
						
						break
					end
				end
			end)
		end
	end
end)


--给蜘蛛加阵营组件 测试
AddPrefabPostInit("spider",function(inst)
	GLOBAL.pkc_setNetvar(inst,{
		hasChoosen = {"net_shortint", 0},
	})
	if GLOBAL.TheWorld.ismastersim then
		inst:AddComponent("pkc_group")
		inst.components.pkc_group:setChoosen(GLOBAL.GROUP_BIGPIG_ID)
		
		if inst.components.combat then
			local o_CanTarget = inst.components.combat.CanTarget
			function inst.components.combat:CanTarget(target)
				if target and target.components.pkc_group.hasChoosen==inst.components.pkc_group.hasChoosen then
					return false
				end
				return o_CanTarget(self,target)
			end
		end
	end
end)









