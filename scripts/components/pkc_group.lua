--@name pkc_group
--@description 玩家所属阵营组件
--@auther redpig
--@date 2016-10-23

local PKC_GROUP = Class(function(self, inst)
	self.inst = inst 
end)

function PKC_GROUP:setChoosen(hasChoosen)
	self.inst.hasChoosen = hasChoosen
end

function PKC_GROUP:getChoosen()
	return self.inst.hasChoosen
end

function PKC_GROUP:OnSave()
	return
	{	
		hasChoosen = self.inst.hasChoosen,
	}
end

function PKC_GROUP:OnLoad(data)
	if data ~= nil then
		if data.hasChoosen ~= nil then
			self.inst.hasChoosen = data.hasChoosen
		end
	end
end

return PKC_GROUP