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
				GROUP_BIGPIG_POS = { id=GLOBAL.GROUP_BIGPIG_ID, info="大猪猪阵营" },
				GROUP_REDPIG_POS = { id=GLOBAL.GROUP_REDPIG_ID, info="红猪猪阵营" },
				GROUP_LONGPIG_POS = { id=GLOBAL.GROUP_LONGPIG_ID, info="龙猪猪阵营" },
				GROUP_CUIPIG_POS = { id=GLOBAL.GROUP_CUIPIG_ID, info="崔猪猪阵营" },
			}
			inst:DoTaskInTime(0,function()
				for k,v in pairs(t) do
					if inst.components.pkc_group.hasChoosen==v.id then
						if inst.components.talker then
							inst.components.talker:Say("我属于 "..v.info)
						end
						break
					end
				end
			end)
		end
	end
end)