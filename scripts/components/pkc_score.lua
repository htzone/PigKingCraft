--@name pkc_score
--@description 阵营分数
--@auther redpig
--@date 2016-11-15
--@大猪猪 10-31

local function ongroup1Score(self, v)
	self.inst._group1Score:set(v)
end

local function ongroup2Score(self, v)
	self.inst._group2Score:set(v)
end

local function ongroup3Score(self, v)
	self.inst._group3Score:set(v)
end

local function ongroup4Score(self, v)
	self.inst._group4Score:set(v)
end

local PKC_SCORE = Class(function(self, inst)
	self.inst = inst
	self.inst._group1Score = net_int(self.inst.GUID, "pkc_group._group1Score", "_group1ScoreDirty")
	self.inst._group2Score = net_int(self.inst.GUID, "pkc_group._group2Score", "_group2ScoreDirty")
	self.inst._group3Score = net_int(self.inst.GUID, "pkc_group._group3Score", "_group3ScoreDirty")
	self.inst._group4Score = net_int(self.inst.GUID, "pkc_group._group4Score", "_group4ScoreDirty")
	self.group1Score = 0
	self.group2Score = 0
	self.group3Score = 0
	self.group4Score = 0
	
end,
nil,
{
	group1Score = ongroup1Score,
	group2Score = ongroup2Score,
	group3Score = ongroup3Score,
	group4Score = ongroup4Score,
})

function PKC_SCORE:setGroup1Score(score)
	self.group1Score = score
end

function PKC_SCORE:setGroup2Score(score)
	self.group2Score = score
end

function PKC_SCORE:setGroup3Score(score)
	self.group3Score = score
end

function PKC_SCORE:setGroup4Score(score)
	self.group4Score = score
end

function PKC_SCORE:getGroup1Score()
	return self.inst._group1Score:value()
end

function PKC_SCORE:getGroup2Score()
	return self.inst._group2Score:value()
end

function PKC_SCORE:getGroup3Score()
	return self.inst._group3Score:value()
end

function PKC_SCORE:getGroup4Score()
	return self.inst._group4Score:value()
end

function PKC_SCORE:addGroup1()
	self.group1Score = self:getGroup1Score() + 1
end

function PKC_SCORE:addGroup2()
	self.group2Score = self:getGroup2Score() + 1
end

function PKC_SCORE:addGroup3()
	self.group3Score = self:getGroup3Score() + 1
end

function PKC_SCORE:addGroup4()
	self.group4Score = self:getGroup4Score() + 1
end

function PKC_SCORE:OnSave()
	return
	{	
		group1Score = self.group1Score,
		group2Score = self.group2Score,
		group3Score = self.group3Score,
		group4Score = self.group4Score,
	}
end

function PKC_SCORE:OnLoad(data)
	if data ~= nil then
		if data.group1Score ~= nil then
			self.group1Score = data.group1Score

		end
		if data.group2Score ~= nil then
			self.group2Score = data.group2Score
		end
		if data.group3Score ~= nil then
			self.group3Score = data.group3Score

		end
		if data.group4Score ~= nil then
			self.group4Score = data.group4Score
		end
	end
end

return PKC_SCORE