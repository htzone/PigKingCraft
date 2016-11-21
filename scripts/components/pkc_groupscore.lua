--@name pkc_score
--@description 阵营分数
--@auther redpig
--@date 2016-11-16

--保存分数的全局变量
local _GROUP_SCORE = GROUP_SCORE

_GROUP_SCORE.GROUP1_SCORE = 0
_GROUP_SCORE.GROUP2_SCORE = 0
_GROUP_SCORE.GROUP3_SCORE = 0
_GROUP_SCORE.GROUP4_SCORE = 0


local function onGroup1ScoreDirty(inst)
    local self = inst.components.pkc_groupscore
	_GROUP_SCORE.GROUP1_SCORE = self.group1Score:value()
end

local function onGroup2ScoreDirty(inst)
    local self = inst.components.pkc_groupscore
	_GROUP_SCORE.GROUP2_SCORE = self.group2Score:value()
end

local function onGroup3ScoreDirty(inst)
    local self = inst.components.pkc_groupscore
	_GROUP_SCORE.GROUP3_SCORE = self.group3Score:value()
end

local function onGroup4ScoreDirty(inst)
    local self = inst.components.pkc_groupscore
	_GROUP_SCORE.GROUP4_SCORE = self.group4Score:value()
end

local PKC_GROUP_SCORE = Class(function(self, inst)
	self.inst = inst
	
	self.group1Score = net_int(self.inst.GUID, "pkc_group.group1Score", "group1ScoreDirty")
	self.group2Score = net_int(self.inst.GUID, "pkc_group.group2Score", "group2ScoreDirty")
	self.group3Score = net_int(self.inst.GUID, "pkc_group.group3Score", "group3ScoreDirty")
	self.group4Score = net_int(self.inst.GUID, "pkc_group.group4Score", "group4ScoreDirty")
	
	inst:ListenForEvent("group1ScoreDirty", onGroup1ScoreDirty)
	inst:ListenForEvent("group2ScoreDirty", onGroup2ScoreDirty)
	inst:ListenForEvent("group3ScoreDirty", onGroup3ScoreDirty)
	inst:ListenForEvent("group4ScoreDirty", onGroup4ScoreDirty)
	
	self.winner = 0
	
	self:init()
end,
nil,
{
})

function PKC_GROUP_SCORE:init()
	self.group1Score:set(0)
	self.group2Score:set(0)
	self.group3Score:set(0)
	self.group4Score:set(0)
end

function PKC_GROUP_SCORE:OnEntityDied(data)
	if data 
	--and data.inst:HasTag("player") 
	and data.afflicter:HasTag("player") then
		if data.inst.components.pkc_group and data.afflicter.components.pkc_group then
			if data.inst.components.pkc_group:getChooseGroup() ~= data.afflicter.components.pkc_group:getChooseGroup() then
				if data.afflicter.components.pkc_group:getChooseGroup() == GROUP_BIGPIG_ID then
					self:addGroup1Score(10)
				elseif data.afflicter.components.pkc_group:getChooseGroup() == GROUP_REDPIG_ID then
					self:addGroup2Score(10)
					--pkc_announce("sb22!!!!!!!!!!!!!!!!!!!!"..(_GROUP_SCORE.GROUP2_SCORE or 0))
				elseif data.afflicter.components.pkc_group:getChooseGroup() == GROUP_LONGPIG_ID then
					self:addGroup3Score(10)
				elseif data.afflicter.components.pkc_group:getChooseGroup() == GROUP_CUIPIG_ID then
					self:addGroup4Score(10)
				end
			end
			
		end
	end
end

function PKC_GROUP_SCORE:setGroup1Score(score)
	_GROUP_SCORE.GROUP1_SCORE = score
	if TheNet:GetIsServer() then
		self.group1Score:set(score)
	end
	self:checkWin(score, GROUP_BIGPIG_ID)
end

function PKC_GROUP_SCORE:setGroup2Score(score)
	_GROUP_SCORE.GROUP2_SCORE = score
	if TheNet:GetIsServer() then
		self.group2Score:set(score)
	end
	self:checkWin(score, GROUP_REDPIG_ID)
end

function PKC_GROUP_SCORE:setGroup3Score(score)
	_GROUP_SCORE.GROUP3_SCORE = score
	if TheNet:GetIsServer() then
		self.group3Score:set(score)
	end
	self:checkWin(score, GROUP_LONGPIG_ID)
end

function PKC_GROUP_SCORE:setGroup4Score(score)
	_GROUP_SCORE.GROUP4_SCORE = score
	if TheNet:GetIsServer() then
		self.group4Score:set(score)
	end
	self:checkWin(score, GROUP_CUIPIG_ID)
end

function PKC_GROUP_SCORE:getGroup1Score()
	return self.group1Score:value()
end

function PKC_GROUP_SCORE:getGroup2Score()
	return self.group2Score:value()
end

function PKC_GROUP_SCORE:getGroup3Score()
	return self.group3Score:value()
end

function PKC_GROUP_SCORE:getGroup4Score()
	return self.group4Score:value()
end

function PKC_GROUP_SCORE:addGroupScore(groupId, addScore)
	if addScore == nil then
		addScore = 1
	end
	
	if groupId == GROUP_BIGPIG_ID then
		self:setGroup1Score(self:getGroup1Score() + addScore)
	elseif groupId == GROUP_REDPIG_ID then
		self:setGroup2Score(self:getGroup2Score() + addScore)
	elseif groupId == GROUP_LONGPIG_ID then
		self:setGroup3Score(self:getGroup3Score() + addScore)
	elseif groupId == GROUP_CUIPIG_ID then
		self:setGroup4Score(self:getGroup4Score() + addScore)
	end
end

function PKC_GROUP_SCORE:addGroup1Score(addScore)
	if addScore == nil then
		addScore = 1
	end
	self:setGroup1Score(self:getGroup1Score() + addScore)
end

function PKC_GROUP_SCORE:addGroup2Score(addScore)
	if addScore == nil then
		addScore = 1
	end
	self:setGroup2Score(self:getGroup2Score() + addScore)
end

function PKC_GROUP_SCORE:addGroup3Score(addScore)
	if addScore == nil then
		addScore = 1
	end
	self:setGroup3Score(self:getGroup3Score() + addScore)
end

function PKC_GROUP_SCORE:addGroup4Score(addScore)
	if addScore == nil then
		addScore = 1
	end
	self:setGroup4Score(self:getGroup4Score() + addScore)
end

function PKC_GROUP_SCORE:checkWin(score, groupId)
	if score >= WIN_SCORE then --赢了
		self.winner = groupId
		TheWorld:PushEvent("pkc_win", { winner = self.winner, score = score})
	end
end

function PKC_GROUP_SCORE:OnSave()
	return
	{	
		group1Score = self.group1Score:value(),
		group2Score = self.group2Score:value(),
		group3Score = self.group3Score:value(),
		group4Score = self.group4Score:value(),
	}
end

function PKC_GROUP_SCORE:OnLoad(data)
	if data ~= nil then
		if data.group1Score ~= nil then
			self:setGroup1Score(data.group1Score)
		end
		if data.group2Score ~= nil then
			self:setGroup2Score(data.group2Score)
		end
		if data.group3Score ~= nil then
			self:setGroup3Score(data.group3Score)
		end
		if data.group4Score ~= nil then
			self:setGroup4Score(data.group4Score)
		end
	end
end

return PKC_GROUP_SCORE