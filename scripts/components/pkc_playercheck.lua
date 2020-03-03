--@name pkc_playercheck
--@description 玩家自动检查组件
--@author redpig
--@date 2016-11-20

local function isMyGroupExist(groupId)
	for k, v in pairs(CURRENT_EXIST_GROUPS) do 
		if v == groupId then
			return true
		end
	end
	return false
end

local PKC_PLAYER_CHECK = Class(function(self, inst)
	self.inst = inst 
end)

function PKC_PLAYER_CHECK:check()
	if not isMyGroupExist(self.inst.components.pkc_group:getChooseGroup()) then
		--我的队伍已不存在
		self.inst:DoTaskInTime(3, function()
			if self.inst and self.inst.components.talker then
			
			end
		end)
	end
end

function PKC_PLAYER_CHECK:OnSave()
	return
	{	
	}
end

function PKC_PLAYER_CHECK:OnLoad(data)
	if data ~= nil then
	end
end

return PKC_PLAYER_CHECK