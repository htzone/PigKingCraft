--@name pkc_worldinit
--@description 世界初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local require = GLOBAL.require

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

local function onEntityDeathfn(inst, data)
	if data 
	--and data.inst:HasTag("player") 
	and data.afflicter:HasTag("player") then
		if data.inst.components.pkc_group and data.afflicter.components.pkc_group then
			--GLOBAL.pkc_announce("sb!!!!!!!!!!!!!!!!!!!!")
			if data.inst.components.pkc_group:getChooseGroup() ~= data.afflicter.components.pkc_group:getChooseGroup() then
				if data.afflicter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_BIGPIG_ID then
					inst.components.pkc_score:addGroup1()
				elseif data.afflicter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_REDPIG_ID then
					inst.components.pkc_score:addGroup2()
					--GLOBAL.pkc_announce("sb22!!!!!!!!!!!!!!!!!!!!"..inst.components.pkc_score:getGroup2Score())
				elseif data.afflicter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_LONGPIG_ID then
					inst.components.pkc_score:addGroup3()
				elseif data.afflicter.components.pkc_group:getChooseGroup() == GLOBAL.GROUP_CUIPIG_ID then
					inst.components.pkc_score:addGroup4()
				end
			end
			
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
		--添加分数机制
		inst:AddComponent("pkc_score")
		--添加记录阵营位置组件
		if IsServer then
			inst:AddComponent("pkc_baseinfo")	
			inst:ListenForEvent("entity_death", onEntityDeathfn, GLOBAL.TheWorld)
		end
	end
end)

AddClassPostConstruct("widgets/controls", function(wdt)
	wdt.inst:DoTaskInTime(0, function()
	
		local Pvp_Widget = require "widgets/pvp_widget"
		wdt.pvp_widget1 = wdt.top_root:AddChild(Pvp_Widget())
		wdt.pvp_widget2 = wdt.top_root:AddChild(Pvp_Widget())
		wdt.pvp_widget3 = wdt.top_root:AddChild(Pvp_Widget())
		wdt.pvp_widget4 = wdt.top_root:AddChild(Pvp_Widget())

		local old_OnUpdate = wdt.OnUpdate
		wdt.OnUpdate = function(self, dt)
		
			old_OnUpdate(self, dt)
			
			wdt.pvp_widget1.button:SetText("大:"..GLOBAL.TheWorld._group1Score:value())
			local d_colour1,d_colour2,d_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.BIGPIG.color)
			wdt.pvp_widget1.button:SetTextColour(d_colour1, d_colour2, d_colour3, 1)
			wdt.pvp_widget1.button:SetTextSize(48)
			wdt.pvp_widget1:SetPosition(-225,-15,0)
			
			wdt.pvp_widget2.button:SetText("红:"..GLOBAL.TheWorld._group2Score:value())
			local r_colour1,r_colour2,r_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.REDPIG.color)
			wdt.pvp_widget2.button:SetTextColour(r_colour1, r_colour2, r_colour3, 1)
			wdt.pvp_widget2.button:SetTextSize(48)
			wdt.pvp_widget2:SetPosition(-75,-15,0)
			
			wdt.pvp_widget3.button:SetText("龙:"..GLOBAL.TheWorld._group3Score:value())
			local l_colour1,l_colour2,l_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.LONGPIG.color)
			wdt.pvp_widget3.button:SetTextColour(l_colour1, l_colour2, l_colour3, 1)
			wdt.pvp_widget3.button:SetTextSize(48)
			wdt.pvp_widget3:SetPosition(75,-15,0)
			
			wdt.pvp_widget4.button:SetText("崔:"..GLOBAL.TheWorld._group4Score:value())
			local c_colour1,c_colour2,c_colour3 = GLOBAL.HexToPercentColor(GLOBAL.GROUP_INFOS.CUIPIG.color)
			wdt.pvp_widget4.button:SetTextColour(c_colour1, c_colour2, c_colour3, 1)
			wdt.pvp_widget4.button:SetTextSize(48)
			wdt.pvp_widget4:SetPosition(225,-15,0)	
		end
	end)
end)

















