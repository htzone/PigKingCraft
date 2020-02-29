--@name pkc_group
--@description 玩家所属阵营组件
--@auther redpig
--@date 2016-10-23
--@大猪猪 10-31

local function onchooseGroup(self, v)
	self._chooseGroup:set(v)
end

local PKC_GROUP = Class(function(self, inst)
	self.inst = inst
	self._chooseGroup = net_shortint(self.inst.GUID, "pkc_group._chooseGroup", "_chooseGroupDirty")
	self.chooseGroup = 0
	self.basePos = {0, 0, 0} --队伍所在基地的位置
end,
nil,
{
	chooseGroup = onchooseGroup,
})

function PKC_GROUP:setChooseGroup(chooseGroup)
	self.chooseGroup = chooseGroup
	self.inst:AddTag("pkc_group_"..chooseGroup)
	self.inst.chooseGroup = chooseGroup 
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
		chooseGroup = self.chooseGroup,
		basePos = self.basePos,
	}
end

function PKC_GROUP:OnLoad(data)
	if data ~= nil then
		if data.chooseGroup ~= nil then
			self.chooseGroup = data.chooseGroup
			self.inst:AddTag("pkc_group_"..self.chooseGroup)
			self.inst.chooseGroup = data.chooseGroup
		end
		if data.basePos ~= nil then
			self.basePos = data.basePos
		end
	end
end

return PKC_GROUP