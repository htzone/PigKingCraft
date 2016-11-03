--@name pkc_group
--@description 玩家所属阵营组件
--@auther redpig
--@date 2016-10-23
--@大猪猪 10-31

--
local function onhasChoosen(self,v)
	self.inst.hasChoosen:set(v)
end

local PKC_GROUP = Class(function(self, inst)
	self.inst = inst
	self.hasChoosen=0	--为0表示没有阵营
end,
nil,
{
	hasChoosen=onhasChoosen,
})

function PKC_GROUP:setChoosen(hasChoosen)
	--self.inst.hasChoosen = hasChoosen
	self.hasChoosen = hasChoosen
	--self.inst.hasChoosen:set(hasChoosen)
end

function PKC_GROUP:getChoosen()
	return self.hasChoosen
end

function PKC_GROUP:OnSave()
	return
	{	
		--hasChoosen = self.inst.hasChoosen,
		hasChoosen = self.hasChoosen,
	}
end

function PKC_GROUP:OnLoad(data)
	if data ~= nil then
		if data.hasChoosen ~= nil then
			--self.inst.hasChoosen = data.hasChoosen
			self.hasChoosen = data.hasChoosen
		end
	end
end

return PKC_GROUP