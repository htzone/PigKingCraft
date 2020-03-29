--
-- 队伍标识组件
-- Author: RedPig, 大猪猪
-- Date: 2016/10/31
--

local PKC_GROUP = Class(function(self, inst)
	self.inst = inst
	self.inst.pkc_groupid = 0
	-- 队伍ID (网络变量，客户端也需要访问)
	self._chooseGroup = net_shortint(self.inst.GUID, "pkc_group._chooseGroup", "_chooseGroupDirty")
	-- 基地位置
	self.basePos = {0, 0, 0}
end,
nil,
{
})

function PKC_GROUP:setChooseGroup(chooseGroup)
	self._chooseGroup:set(chooseGroup)
	self.inst.pkc_groupid = chooseGroup
	self.inst:AddTag("pkc_group_"..chooseGroup)
end

function PKC_GROUP:getChooseGroup()
	return self._chooseGroup:value()
end

function PKC_GROUP:setBasePos(basePos)
	self.basePos = basePos
end

function PKC_GROUP:getBasePos()
	return self.basePos
end

function PKC_GROUP:OnSave()
	return
	{	
		chooseGroup = self._chooseGroup:value(),
		basePos = self.basePos,
	}
end

function PKC_GROUP:OnLoad(data)
	if data ~= nil then
		if data.chooseGroup ~= nil then
			self._chooseGroup:set(data.chooseGroup)
			self.inst.pkc_groupid = data.chooseGroup
			self.inst:AddTag("pkc_group_"..data.chooseGroup)
		end
		if data.basePos ~= nil then
			self.basePos = data.basePos
		end
	end
end

return PKC_GROUP