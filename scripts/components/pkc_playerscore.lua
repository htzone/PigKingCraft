--
-- 保存玩家得分信息的组件
-- 并将得分信息实时刷新到全局变量PKC_PLAYER_SCORES
-- Author: RedPig
-- Date: 2020/03/29
--
--Example：
--PKC_PLAYER_SCORES = {
--    KU_2312323s1 = {
--        SCORE = 100,
--        KILL_PLAYER_NUM = 100,
--		  CONTRIBUTION = 100,
--    },
--    KU_2312323s2 = {
--        SCORE = 200,
--        KILL_PLAYER_NUM = 100,
--		  CONTRIBUTION = 100,
--    },
--    ...
--}
local json = require "json"

local function onScoreDirty(player)
	local pkc_playerscore = player.components.pkc_playerscore
	local score = pkc_playerscore:GetScore()
	local killplayernum = pkc_playerscore:GetKillNum()
	if not PKC_PLAYER_SCORES[player.userid] then
		local playerScoreInfo = {}
		playerScoreInfo.SCORE = score
		playerScoreInfo.KILL_PLAYER_NUM = killplayernum
		PKC_PLAYER_SCORES[player.userid] = playerScoreInfo
	else
		PKC_PLAYER_SCORES[player.userid].SCORE = score
	end
end

local function onKillplayernumDirty(player)
	local pkc_playerscore = player.components.pkc_playerscore
	local score = pkc_playerscore:GetScore()
	local killplayernum = pkc_playerscore:GetKillNum()
	if not PKC_PLAYER_SCORES[player.userid] then
		local playerScoreInfo = {}
		playerScoreInfo.SCORE = score
		playerScoreInfo.KILL_PLAYER_NUM = killplayernum
		PKC_PLAYER_SCORES[player.userid] = playerScoreInfo
	else
		PKC_PLAYER_SCORES[player.userid].KILL_PLAYER_NUM = killplayernum
	end
end

local PKC_PLAYER_SCORE = Class(function(self, inst)
	self.inst = inst
	self.userid = self.inst.userid
	self._score = net_int(self.inst.GUID, "pkc_group._score", "_scoreDirty")
	self._killplayernum = net_int(self.inst.GUID, "_killplayernumDirty", "_killplayernumDirty")
	self._contribution = net_int(self.inst.GUID, "_contributionDirty", "_contributionDirty")

	self.inst.pkc_score = 0
	self.inst.pkc_killplayernum = 0
	self.inst.pkc_contribution = 0

	if not TheNet:GetIsServer() then
		self.inst:ListenForEvent("_scoreDirty", onScoreDirty)
		self.inst:ListenForEvent("_killplayernumDirty", onKillplayernumDirty)
	end
end, nil, {})

function PKC_PLAYER_SCORE:AddScore(score)
	self.inst.pkc_score = self.inst.pkc_score + (score or 1)
	if not PKC_PLAYER_SCORES[self.userid] then
		local playerScoreInfo = {}
		playerScoreInfo.SCORE = self.inst.pkc_score
		playerScoreInfo.KILL_PLAYER_NUM = 0
		PKC_PLAYER_SCORES[self.userid] = playerScoreInfo
	else
		PKC_PLAYER_SCORES[self.userid].SCORE = self.inst.pkc_score
	end
	self._score:set(self.inst.pkc_score)
end

function PKC_PLAYER_SCORE:AddKillPlayerNum(num)
	self.inst.pkc_killplayernum = self.inst.pkc_killplayernum + (num or 1)
	if not PKC_PLAYER_SCORES[self.userid] then
		local playerScoreInfo = {}
		playerScoreInfo.SCORE = 0
		playerScoreInfo.KILL_PLAYER_NUM = self.inst.pkc_killplayernum
		PKC_PLAYER_SCORES[self.userid] = playerScoreInfo
	else
		PKC_PLAYER_SCORES[self.userid].KILL_PLAYER_NUM = self.inst.pkc_killplayernum
	end
	self._killplayernum:set(self.inst.pkc_killplayernum)
end

function PKC_PLAYER_SCORE:AddContribution(contribution)
	self.inst.pkc_contribution = self.inst.pkc_contribution + (contribution or 1)
	self._contribution:set(self.inst.pkc_contribution)
end

function PKC_PLAYER_SCORE:GetScore()
	return self._score:value()
end

function PKC_PLAYER_SCORE:GetKillNum()
	return self._killplayernum:value()
end

function PKC_PLAYER_SCORE:GetContribution()
	return self._contribution:value()
end

function PKC_PLAYER_SCORE:OnSave()
	return
	{
		score = self._score:value(),
		killplayernum = self._killplayernum:value(),
		contribution = self._contribution:value(),
		playercores = json.encode(PKC_PLAYER_SCORES)
	}
end

function PKC_PLAYER_SCORE:OnLoad(data)
	if data then
		if data.playercores then
			PKC_PLAYER_SCORES = json.decode(data.playercores)
		end
		self.inst.pkc_score = data.score
		self.inst.pkc_killplayernum = data.killplayernum
		self.inst.pkc_contribution = data.contribution
		self._score:set(data.score)
		self._killplayernum:set(data.killplayernum)
		self._contribution:set(data.contribution)
	end
end

return PKC_PLAYER_SCORE
