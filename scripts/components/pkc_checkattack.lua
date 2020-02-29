--@name pkc_checkattack
--@description 防止队友互相攻击组件
--@auther redpig
--@date 2016-11-05

local PKC_CHECK_ATTACK = Class(function(self, inst)
	self.inst = inst 
end)

--防止队友攻击（限制攻击动作）
function PKC_CHECK_ATTACK:isGroupMember(checkFn)
	local combat_replica = require "components/combat_replica"
	pkc_inject(combat_replica, "IsAlly", function(compn, target)
		if checkFn(compn.inst, target) then
			return true
		end
		return compn:OldIsAlly(target)
	end )
end

function PKC_CHECK_ATTACK:OnSave()
	return
	{	
	}
end

function PKC_CHECK_ATTACK:OnLoad(data)
	if data ~= nil then
	end
end

return PKC_CHECK_ATTACK