--@name pkc_worldinit
--@description 世界初始化
--@auther 大猪猪，redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

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

--世界初始化
AddPrefabPostInit("world", function(inst)
	if inst then
		--添加防止队友相互攻击组件
		inst:AddComponent("pkc_checkattack")
		inst.components.pkc_checkattack:isGroupMember(checkIsGroupMemberFn)
		--添加记录阵营位置组件
		if IsServer then
			inst:AddComponent("pkc_baseinfo")	
		end
	end
end)

















