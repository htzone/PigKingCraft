--@name pkc_levelup
--@description 升级组件
--@author redpig
--@date 2016-12-20
local _G = _G or GLOBAL

local function checkLevelUp(self, currentScore)
	local needLevelUpScore = WIN_SCORE / self.level_num
	local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
	if currentLevel ~= self.level and currentLevel > self.level then
		self.inst:PushEvent("pkc_pigkingLevelUp", { pigking = self.inst, level = currentLevel})
		self.level = currentLevel
	end
end

local PKC_LEVEL_UP = Class(function(self, inst)
	self.inst = inst 
	self.currentScore = nil
	self.level_num = 10
	self.level = 1
	
end)

function PKC_LEVEL_UP:init()
	self.inst:DoPeriodicTask(10, function()
		local needLevelUpScore = WIN_SCORE / self.level_num
		if self.inst:HasTag("pkc_group1") then
			checkLevelUp(self, _G.GROUP_SCORE.GROUP1_SCORE)
		elseif self.inst:HasTag("pkc_group2") then
			checkLevelUp(self, _G.GROUP_SCORE.GROUP2_SCORE)
		elseif self.inst:HasTag("pkc_group3") then
			checkLevelUp(self, _G.GROUP_SCORE.GROUP3_SCORE)
		elseif self.inst:HasTag("pkc_group4") then
			checkLevelUp(self, _G.GROUP_SCORE.GROUP4_SCORE)
		end
	end)
end

function PKC_LEVEL_UP:setLevelNum(level_num)
	self.level_num = level_num
end

function PKC_LEVEL_UP:OnSave()
	return
	{	
		level = self.level,
		level_num = self.level_num,
	}
end

function PKC_LEVEL_UP:OnLoad(data)
	if data ~= nil then
		if data.level then
			self.level = data.level
			self.inst:DoTaskInTime(5, function()
				self.inst:PushEvent("pkc_pigkingLevelUp", { pigking = self.inst, level = self.level})
			end)
		end
		if data.level_num then
			self.level_num = data.level_num
		end
	end
end

return PKC_LEVEL_UP